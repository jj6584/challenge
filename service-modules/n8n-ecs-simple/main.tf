# N8N ECS Simple Module
# Single with ALB using bridge networking

# Data sources for secrets
data "aws_ssm_parameter" "postgres_password" {
  name = var.postgres_password_ssm_parameter
}

data "aws_ssm_parameter" "n8n_basic_auth_password" {
  name = var.n8n_basic_auth_password_ssm_parameter
}

data "aws_ssm_parameter" "n8n_encryption_key" {
  count = var.n8n_encryption_key_ssm_parameter != "" ? 1 : 0
  name  = var.n8n_encryption_key_ssm_parameter
}



# Local values for configuration
locals {
  # Common labels
  common_labels = {
    Application = "n8n"
    Environment = "production"
    Component   = "workflow-automation"
  }

  # Container environment variables
  container_environment = [
    {
      name  = "N8N_HOST"
      value = var.n8n_host
    },
    {
      name  = "N8N_PORT"
      value = "5678"
    },
    {
      name  = "N8N_PROTOCOL"
      value = var.n8n_protocol
    },
    {
      name  = "WEBHOOK_URL"
      value = var.webhook_url != "" ? var.webhook_url : "${var.n8n_protocol}://${var.n8n_host}"
    },
    {
      name  = "GENERIC_TIMEZONE"
      value = var.generic_timezone
    },
    {
      name  = "DB_TYPE"
      value = "postgresdb"
    },
    {
      name  = "DB_POSTGRESDB_HOST"
      value = var.postgres_host
    },
    {
      name  = "DB_POSTGRESDB_PORT"
      value = tostring(var.postgres_port)
    },
    {
      name  = "DB_POSTGRESDB_DATABASE"
      value = var.postgres_database
    },
    {
      name  = "DB_POSTGRESDB_USER"
      value = var.postgres_user
    },
    {
      name  = "DB_POSTGRESDB_SSL_CA"
      value = ""
    },
    {
      name  = "DB_POSTGRESDB_SSL_CERT"
      value = ""
    },
    {
      name  = "DB_POSTGRESDB_SSL_KEY"
      value = ""
    },
    {
      name  = "DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED"
      value = "false"
    },
    {
      name  = "N8N_BASIC_AUTH_ACTIVE"
      value = var.n8n_basic_auth_active
    },
    {
      name  = "N8N_BASIC_AUTH_USER"
      value = var.n8n_basic_auth_user
    },
    {
      name  = "N8N_LOG_LEVEL"
      value = "info"
    },
    # Disable telemetry and external data collection
    {
      name  = "N8N_DIAGNOSTICS_ENABLED"
      value = "false"
    },
    {
      name  = "N8N_VERSION_NOTIFICATIONS_ENABLED"
      value = "false"
    },
    {
      name  = "N8N_TEMPLATES_ENABLED"
      value = "false"
    },
    {
      name  = "N8N_PERSONALIZATION_ENABLED"
      value = "false"
    }
  ]

  # Container secrets
  container_secrets = concat([
    {
      name      = "DB_POSTGRESDB_PASSWORD"
      valueFrom = data.aws_ssm_parameter.postgres_password.arn
    },
    {
      name      = "N8N_BASIC_AUTH_PASSWORD"
      valueFrom = data.aws_ssm_parameter.n8n_basic_auth_password.arn
    }
  ], var.n8n_encryption_key_ssm_parameter != "" ? [
    {
      name      = "N8N_ENCRYPTION_KEY"
      valueFrom = data.aws_ssm_parameter.n8n_encryption_key[0].arn
    }
  ] : [])

  # Container definition as JSON string (required by ECS module)
  container_definitions_json = jsonencode([
    {
      name      = "n8n"
      image     = "n8nio/n8n:1.19.4"
      essential = true
      cpu       = var.n8n_cpu        # CPU at container level for bridge mode
      memory    = var.n8n_memory     # Memory at container level for bridge mode
      
      portMappings = [
        {
          containerPort = 5678
          hostPort      = 0  # Dynamic port assignment for bridge mode
          protocol      = "tcp"
        }
      ]

      environment = local.container_environment
      secrets     = local.container_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.cluster_name}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# Get current AWS region
data "aws_region" "current" {}

# Create the ECS cluster and service using the shared ECS module
module "ecs_cluster" {
  source = "../../modules/AWS/ecs"

  # Cluster Configuration
  cluster_name = var.cluster_name

  # Network Configuration
  vpc_id          = var.vpc_id
  subnets         = var.subnet_ids
  subnet_ids      = var.subnet_ids
  load_balancer_subnets = var.subnet_ids  # Use all subnets for ALB (need 2+ AZs)
  security_groups = []  # Will be created by module
  network_mode    = "bridge"  # Use bridge mode for EC2 launch type

  # Security Groups Configuration
  create_ec2_security_group = true   # Let module create EC2 security group
  create_ecs_security_group = true   # Let module create ECS security group
  create_alb_security_group = true   # Let module create ALB security group

  # Launch Type - EC2
  launch_type = ["EC2"]

  # EC2 Configuration - Force single instance
  ec2_instance_type    = var.ec2_instance_type
  
  # ASG Configuration - Force single instance
  asg_min_size         = 1  # Force minimum 1 instance
  asg_max_size         = 1  # Force maximum 1 instance  
  asg_desired_capacity = 1  # Force desired 1 instance

  # Container Configuration
  container_definitions = local.container_definitions_json
  container_name        = "n8n"
  service_name          = "n8n"
  cpu                   = tostring(var.n8n_cpu)
  memory                = tostring(var.n8n_memory)
  environment_variables = {}  # Using environment from container_definitions
  volumes               = []  # No volumes needed for simple configuration

  # Service Configuration - Force single task
  desired_count                 = 1  # Force single N8N task
  health_check_grace_period     = 300  # Give N8N 5 minutes to start up

  # Load Balancer Configuration
  create_load_balancer    = true
  load_balancer_type      = "application"
  load_balancer_internal  = var.load_balancer_internal

  # Target Group Configuration
  target_group_port     = 5678
  target_group_protocol = "HTTP"

  # Health Check Configuration - Use root path for N8N
  health_check_path                = "/healthz"
  health_check_protocol            = "HTTP"
  health_check_interval           = 60
  health_check_timeout            = 30
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 10
  health_check_matcher            = "200,302"

  # HTTP/HTTPS Configuration
  enable_http_listener   = var.enable_http_listener
  enable_https_listener  = var.enable_https_listener
  http_redirect_to_https = true
  http_port              = var.http_port
  https_port             = var.https_port
  
  # SSL Certificate Configuration
  ssl_certificate_arn     = var.ssl_certificate_arn
  certificate_domain_name = var.certificate_domain_name
  certificate_validation_method = var.certificate_validation_method

  # IAM Configuration
  create_task_execution_role = true
  create_task_role           = true

  # Secrets configuration
  task_secrets_arns = var.task_secrets_arns

  # CloudWatch Logging
  enable_logging     = true
  log_retention_days = var.log_retention_days

  # Container Insights
  container_insights = true

  # Auto Scaling Configuration (disabled for single instance)
  enable_autoscaling = false

  # Capacity Provider Configuration (required for EC2 launch type)
  enable_capacity_provider = true

  # Tags
  tags = merge(local.common_labels, var.tags)
}

# ASG Target Group Attachment for Bridge Mode
# In bridge mode, ALB routes to EC2 instances, so ASG needs target group ARNs
resource "aws_autoscaling_attachment" "n8n_tg" {
  autoscaling_group_name = module.ecs_cluster.autoscaling_group_name
  lb_target_group_arn    = module.ecs_cluster.target_group_arn
  
  depends_on = [module.ecs_cluster]
}
