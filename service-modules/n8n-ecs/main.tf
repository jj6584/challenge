module "n8n_ecs" {
  source = "../../modules/AWS/ecs"

  # Basic configuration
  cluster_name = "${var.environment}-n8n-cluster"
  service_name = "${var.environment}-n8n-service"

  # Network configuration
  vpc_id           = var.vpc_id
  subnets          = var.subnet_ids
  security_groups  = var.security_group_ids
  assign_public_ip = var.assign_public_ip

  # Container configuration
  cpu           = var.cpu
  memory        = var.memory
  desired_count = var.desired_count

  # Environment variables (can be empty object if not needed)
  environment_variables = {}

  container_definitions = jsonencode([
    {
      name  = "n8n"
      image = var.n8n_image

      portMappings = [
        {
          containerPort = 5678
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
          value = var.webhook_url
        }
      ]

      secrets = var.n8n_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}-n8n"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      essential = true
    }
  ])

  # Custom IAM policies for N8N specific requirements
  task_role_policy = var.custom_task_role_policy

  # Additional inline policies for specific N8N integrations
  task_role_additional_policies = var.additional_task_policies

  # AWS managed policies
  task_role_managed_policies = var.managed_policy_arns

  # Service-specific access toggles
  enable_s3_read_access         = var.enable_s3_read_access
  enable_s3_full_access         = var.enable_s3_full_access
  enable_secrets_manager_access = var.enable_secrets_manager_access
  enable_parameter_store_access = var.enable_parameter_store_access
  enable_rds_access             = var.enable_rds_access

  # Resource-specific access
  task_role_s3_bucket_arns      = var.s3_bucket_arns
  task_role_sqs_queue_arns      = var.sqs_queue_arns
  task_role_dynamodb_table_arns = var.dynamodb_table_arns

  # Secrets configuration
  task_secrets_arns = var.task_secrets_arns
  kms_key_arns      = var.kms_key_arns

  # Load balancer configuration (optional)
  create_alb        = var.enable_load_balancer
  alb_subnets       = var.alb_subnets
  alb_internal      = var.alb_internal
  container_port    = 5678
  health_check_path = var.health_check_path
  certificate_arn   = var.certificate_arn

  # Auto scaling
  enable_autoscaling       = var.enable_autoscaling
  autoscaling_min_capacity = var.min_capacity
  autoscaling_max_capacity = var.max_capacity
  cpu_target_value         = var.cpu_target_value
  memory_target_value      = var.memory_target_value

  # CloudWatch configuration
  enable_logging     = true
  log_retention_days = var.log_retention_days

  tags = merge(var.tags, {
    Service     = "n8n"
    Environment = var.environment
  })
}