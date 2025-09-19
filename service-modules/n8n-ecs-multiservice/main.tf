# N8N ECS Deployment using Enhanced ECS Module
# This module creates ECS services for N8N components with integrated load balancer:
# - N8N Main Application
# - N8N Worker (optional)
# - Application Load Balancer for external access

# ===================================================================
# DATA SOURCES FOR SECURE PARAMETER RETRIEVAL
# ===================================================================

# Redis URL from SSM Parameter Store (for Upstash Redis)
data "aws_ssm_parameter" "redis_url" {
  count = var.redis_url_ssm_parameter != "" ? 1 : 0
  name  = var.redis_url_ssm_parameter
}

# Redis password from SSM Parameter Store (for traditional Redis)
data "aws_ssm_parameter" "redis_password" {
  count = var.redis_password_ssm_parameter != "" ? 1 : 0
  name  = var.redis_password_ssm_parameter
}

# Upstash Redis token from your specific SSM parameter
data "aws_ssm_parameter" "upstash_redis_token" {
  count = var.upstash_redis_host != "" ? 1 : 0
  name  = "/upstash/redis/token"
}

locals {
  # Common labels and configurations
  common_labels = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  # Docker Hub repository credentials (if provided)
  docker_hub_credentials = var.docker_hub_username != "" && var.docker_hub_password_arn != "" ? [
    {
      credentialsParameter = var.docker_hub_password_arn
    }
  ] : []

  # Redis configuration resolution
  # Priority: 1. Upstash with SSM token -> 2. SSM Parameter URL -> 3. Direct URL -> 4. Host/Port with SSM password -> 5. Host/Port with direct password

  # Construct Upstash Redis URL if host is provided (uses token from /upstash/redis/token)
  upstash_redis_url = var.upstash_redis_host != "" ? "rediss://default:${data.aws_ssm_parameter.upstash_redis_token[0].value}@${var.upstash_redis_host}:${var.upstash_redis_port}" : ""

  # Final Redis URL resolution
  redis_url = var.upstash_redis_host != "" ? local.upstash_redis_url : (
    var.redis_url_ssm_parameter != "" ? data.aws_ssm_parameter.redis_url[0].value : var.redis_url
  )

  redis_password_value = var.redis_password_ssm_parameter != "" ? data.aws_ssm_parameter.redis_password[0].value : var.redis_password

  # Parse Redis URL if provided (format: rediss://default:<token>@host:port)
  redis_host_resolved     = local.redis_url != "" ? var.upstash_redis_host : var.redis_host
  redis_port_resolved     = local.redis_url != "" ? var.upstash_redis_port : var.redis_port
  redis_password_resolved = local.redis_url != "" ? data.aws_ssm_parameter.upstash_redis_token[0].value : local.redis_password_value

  # Container definitions for N8N
  n8n_container_definitions = jsonencode([
    {
      name      = "n8n"
      image     = var.n8n_image
      cpu       = var.n8n_cpu
      memory    = var.n8n_memory
      essential = true

      repositoryCredentials = length(local.docker_hub_credentials) > 0 ? local.docker_hub_credentials[0] : null

      portMappings = [
        {
          containerPort = 5678
          hostPort      = 0  # Dynamic port assignment for bridge mode
          protocol      = "tcp"
        }
      ]

      environment = [
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
          name  = "N8N_EXECUTIONS_MODE"
          value = var.n8n_executions_mode
        },
        {
          name  = "N8N_LOG_LEVEL"
          value = var.n8n_log_level
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
        },
        # Redis Configuration - use full URL for queue mode
        {
          name  = "QUEUE_BULL_REDIS_URL"
          value = local.redis_url
        },
        # Additional Redis config for compatibility
        {
          name  = "QUEUE_BULL_REDIS_HOST"
          value = local.redis_host_resolved
        },
        {
          name  = "QUEUE_BULL_REDIS_USERNAME"
          value = "default"
        },
        {
          name  = "QUEUE_BULL_REDIS_PORT"
          value = tostring(local.redis_port_resolved)
        },
        {
          name  = "QUEUE_BULL_REDIS_PASSWORD"
          value = local.redis_password_resolved
        },
        {
          name  = "QUEUE_BULL_REDIS_DB"
          value = "0"
        },
        # Redis TLS configuration for Upstash
        {
          name  = "QUEUE_BULL_REDIS_TLS_DISABLED"
          value = "false"
        }
      ]

      secrets = var.n8n_secrets

      mountPoints = var.enable_ebs_volumes ? [
        {
          sourceVolume  = "n8n-data"
          containerPath = "/home/node/.n8n"
          readOnly      = false
        }
      ] : []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}-${var.project_name}-ms"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  # N8N Worker Container Configuration (when enabled)
  n8n_worker_container_definitions = var.enable_n8n_worker ? jsonencode([
    {
      name      = "n8n-worker"
      image     = var.n8n_worker_image != "" ? var.n8n_worker_image : var.n8n_image
      cpu       = var.n8n_worker_cpu
      memory    = var.n8n_worker_memory
      essential = true

            # Worker command for n8n 1.19.4 - matches docker-compose setup
      command = ["worker"]

      repositoryCredentials = length(local.docker_hub_credentials) > 0 ? local.docker_hub_credentials[0] : null

      # Workers don't need port mappings as they don't serve HTTP traffic
      portMappings = []

      environment = [
        {
          name  = "N8N_HOST"
          value = var.n8n_host
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
          name  = "N8N_LOG_LEVEL"
          value = var.n8n_log_level
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
        },
        # Redis Configuration - use full URL for queue mode
        {
          name  = "QUEUE_BULL_REDIS_URL"
          value = local.redis_url
        },
        # Additional Redis config for compatibility
        {
          name  = "QUEUE_BULL_REDIS_HOST"
          value = local.redis_host_resolved
        },
        {
          name  = "QUEUE_BULL_REDIS_PORT"
          value = tostring(local.redis_port_resolved)
        },
        {
          name  = "QUEUE_BULL_REDIS_PASSWORD"
          value = local.redis_password_resolved
        },
        {
          name  = "QUEUE_BULL_REDIS_USERNAME"
          value = "default"
        },
        {
          name  = "QUEUE_BULL_REDIS_DB"
          value = "0"
        },
        # Redis TLS configuration for Upstash
        {
          name  = "QUEUE_BULL_REDIS_TLS_DISABLED"
          value = "false"
        },
        # Worker-specific configuration
        {
          name  = "N8N_EXECUTIONS_MODE"
          value = "queue"
        },
        {
          name  = "EXECUTIONS_PROCESS"
          value = "main"
        }
      ]

      secrets = var.n8n_secrets

      mountPoints = var.enable_ebs_volumes ? [
        {
          sourceVolume  = "n8n-data"
          containerPath = "/home/node/.n8n"
          readOnly      = false
        }
      ] : []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}-${var.project_name}-ms"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ]) : null

  # Volumes configuration
  n8n_volumes = var.enable_ebs_volumes ? [
    {
      name                         = "n8n-data"
      docker_volume_configuration = {
        scope         = "shared"
        autoprovision = true
        driver        = "local"
      }
      efs_volume_configuration = null
    }
  ] : []
}

# ===================================================================
# ENHANCED ECS MODULE WITH LOAD BALANCER
# ===================================================================

module "ecs_cluster" {
  source = "../../modules/AWS/ecs"

  # Cluster Configuration
  cluster_name = "${var.environment}-${var.project_name}-ms"  # Shortened for ALB name limit
  service_name = "${var.environment}-${var.project_name}-n8n"

  # Multi-Service Configuration - ENABLED
  enable_multi_service_mode = true
  services = merge(
    {
      # N8N Main Service (with load balancer)
      n8n-main = {
        name                     = "n8n-main"
        desired_count           = var.n8n_desired_count
        container_definitions   = local.n8n_container_definitions
        cpu                     = tostring(var.n8n_cpu)
        memory                  = tostring(var.n8n_memory)
        requires_compatibilities = ["EC2"]
        enable_load_balancer    = true  # Main service gets load balancer
        container_name          = "n8n"
        container_port          = 5678
        volumes                 = local.n8n_volumes
        environment_variables   = {}
        secrets                 = []
      }
    },
    var.enable_n8n_worker ? {
      # N8N Worker Service (no load balancer)
      n8n-worker = {
        name                     = "n8n-worker"
        desired_count           = var.n8n_worker_desired_count
        container_definitions   = local.n8n_worker_container_definitions
        cpu                     = tostring(var.n8n_worker_cpu)
        memory                  = tostring(var.n8n_worker_memory)
        requires_compatibilities = ["EC2"]
        enable_load_balancer    = false  # Worker service does NOT get load balancer
        container_name          = "n8n-worker"
        container_port          = 5678
        volumes                 = local.n8n_volumes
        environment_variables   = {}
        secrets                 = []
      }
    } : {}
  )

  # Legacy single-service configuration (now unused)
  container_definitions = local.n8n_container_definitions
  container_name        = "n8n"
  environment_variables = {}
  cpu    = tostring(var.n8n_cpu)
  memory = tostring(var.n8n_memory)
  volumes = local.n8n_volumes

  # Network Configuration
  vpc_id          = var.vpc_id
  subnets         = var.subnet_ids
  subnet_ids      = var.subnet_ids
  security_groups = [] # Will be created by module
  network_mode    = "bridge"  # Use bridge mode for EC2 launch type

  # Launch Type - EC2
  launch_type = ["EC2"]

  # EC2 Configuration
  ec2_instance_type    = var.ec2_instance_type
  ec2_min_size         = var.ec2_min_size
  ec2_max_size         = var.ec2_max_size
  ec2_desired_capacity = var.ec2_desired_capacity

  # ASG Target Group Configuration for Bridge Mode
  # In bridge mode, ALB routes to EC2 instances, so ASG needs target group ARNs
  # We'll pass this after the module creates the target groups
  asg_target_group_arns = []  # Will be updated with attachment resource

  # EBS Configuration
  enable_ebs_data_volume    = var.enable_ebs_volumes
  ebs_data_volume_size      = var.ebs_data_volume_size
  ebs_data_volume_type      = var.ebs_data_volume_type
  ebs_data_volume_encrypted = var.ebs_data_volume_encrypted
  ebs_data_mount_point      = "/data"

  # Load Balancer Configuration - NEW!
  create_load_balancer   = true
  load_balancer_type     = "application"
  load_balancer_subnets  = var.load_balancer_subnets
  load_balancer_internal = var.load_balancer_internal

  # Target Group Configuration
  target_group_port     = 5678
  target_group_protocol = "HTTP"

  # Health Check Configuration - Use root path (most reliable for N8N)
  health_check_path     = "/"
  health_check_protocol = "HTTP"
  health_check_interval = 60
  health_check_timeout  = 30
  health_check_healthy_threshold = 2
  health_check_unhealthy_threshold = 10
  health_check_matcher = "200,302"

  # HTTP/HTTPS Configuration with smart auto-detection
  enable_http_listener   = var.enable_http_listener
  enable_https_listener  = var.enable_https_listener != null ? var.enable_https_listener : (var.ssl_certificate_arn != "" || var.certificate_domain_name != "")
  http_port              = var.http_port
  https_port             = var.https_port
  
  # SSL Certificate Configuration - Enhanced ACM Support
  ssl_certificate_arn     = var.ssl_certificate_arn
  certificate_domain_name = var.certificate_domain_name
  certificate_validation_method = var.certificate_validation_method
  additional_certificate_subject_alternative_names = var.additional_certificate_subject_alternative_names
  create_acm_certificate  = var.create_acm_certificate
  acm_certificate_tags    = var.acm_certificate_tags
  ssl_policy              = var.ssl_policy
  
  # Redirect HTTP to HTTPS - auto-enabled if HTTPS is configured
  http_redirect_to_https = var.http_redirect_to_https != null ? var.http_redirect_to_https : (var.ssl_certificate_arn != "" || var.certificate_domain_name != "")

  # Service Configuration
  desired_count = var.n8n_desired_count
  health_check_grace_period = 300  # Give N8N 5 minutes to start up

  # Security Groups
  create_ecs_security_group = true
  create_alb_security_group = true

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

  # Auto Scaling Configuration (optional)
  enable_autoscaling = false

  # Tags
  tags = merge(local.common_labels, var.tags)
}

# ===================================================================
# ASG TARGET GROUP ATTACHMENT FOR BRIDGE MODE
# ===================================================================

# Attach the main N8N service target group to the Auto Scaling Group
# This is required for bridge mode where ALB routes to EC2 instances
resource "aws_autoscaling_attachment" "n8n_main_tg" {
  autoscaling_group_name = module.ecs_cluster.autoscaling_group_name
  lb_target_group_arn    = module.ecs_cluster.multi_service_info.services["n8n-main"].target_group.arn
  
  depends_on = [module.ecs_cluster]
}