module "n8n_ecs" {
  source = "../../modules/AWS/ecs"

  # Basic configuration
  cluster_name = "${var.environment}-n8n-cluster"
  service_name = "${var.environment}-n8n-service"

  # EC2 Launch Type Configuration
  launch_type = ["EC2"]
  
  # EC2 Instance Configuration
  ec2_instance_type     = var.ec2_instance_type
  ec2_min_size         = var.ec2_min_size
  ec2_max_size         = var.ec2_max_size
  ec2_desired_capacity = var.ec2_desired_capacity
  
  # EBS Volume Configuration
  enable_ebs_data_volume      = var.enable_ebs_volumes
  ebs_data_volume_size        = var.ebs_data_volume_size
  ebs_data_volume_type        = var.ebs_data_volume_type
  ebs_data_volume_iops        = var.ebs_data_volume_iops
  ebs_data_volume_throughput  = var.ebs_data_volume_throughput
  ebs_data_volume_encrypted   = var.ebs_data_volume_encrypted
  ebs_data_volume_kms_key_id  = var.ebs_data_volume_kms_key_id
  ebs_data_mount_point        = "/data"
  
  # Enable capacity provider for auto scaling
  enable_capacity_provider = true

  # Network configuration
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  security_groups = var.security_group_ids

  # Container configuration
  cpu           = var.cpu
  memory        = var.memory
  desired_count = var.desired_count

  # Multi-container task definition with n8n, PostgreSQL, and Traefik
  container_definitions = jsonencode([
    # PostgreSQL Database Container
    {
      name  = "postgres"
      image = var.postgres_image

      portMappings = [
        {
          containerPort = 5432
          hostPort      = 5432
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "POSTGRES_DB"
          value = var.postgres_db
        },
        {
          name  = "POSTGRES_USER"
          value = var.postgres_user
        },
        {
          name  = "POSTGRES_NON_ROOT_USER"
          value = var.postgres_user
        },
        {
          name  = "POSTGRES_NON_ROOT_PASSWORD"
          value = var.postgres_password
        }
      ]

      secrets = var.postgres_secrets

      mountPoints = [
        {
          sourceVolume  = "postgres-data"
          containerPath = "/var/lib/postgresql/data"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}-postgres"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "postgres"
        }
      }

      essential = true
    },
    
    # Traefik Proxy Container
    {
      name  = "traefik"
      image = var.traefik_image

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        },
        {
          containerPort = 443
          hostPort      = 443
          protocol      = "tcp"
        },
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "TRAEFIK_API_DASHBOARD"
          value = "true"
        },
        {
          name  = "TRAEFIK_API_INSECURE"
          value = "true"
        },
        {
          name  = "TRAEFIK_PROVIDERS_ECS"
          value = "true"
        },
        {
          name  = "TRAEFIK_PROVIDERS_ECS_REGION"
          value = var.aws_region
        },
        {
          name  = "TRAEFIK_PROVIDERS_ECS_CLUSTER"
          value = "${var.environment}-n8n-cluster"
        },
        {
          name  = "TRAEFIK_PROVIDERS_ECS_REFRESHSECONDS"
          value = "15"
        },
        {
          name  = "TRAEFIK_ENTRYPOINTS_WEB_ADDRESS"
          value = ":80"
        },
        {
          name  = "TRAEFIK_ENTRYPOINTS_WEBSECURE_ADDRESS"
          value = ":443"
        },
        {
          name  = "TRAEFIK_GLOBAL_SENDANONYMOUSUSAGE"
          value = "false"
        },
        {
          name  = "TRAEFIK_LOG_LEVEL"
          value = "INFO"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}-traefik"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "traefik"
        }
      }

      essential = true
    },

    # N8N Application Container
    {
      name  = "n8n"
      image = var.n8n_image

      portMappings = [
        {
          containerPort = 5678
          protocol      = "tcp"
        }
      ]

      environment = concat([
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
        },
        {
          name  = "DB_TYPE"
          value = "postgresdb"
        },
        {
          name  = "DB_POSTGRESDB_HOST"
          value = "localhost"
        },
        {
          name  = "DB_POSTGRESDB_PORT"
          value = "5432"
        },
        {
          name  = "DB_POSTGRESDB_DATABASE"
          value = var.postgres_db
        },
        {
          name  = "DB_POSTGRESDB_USER"
          value = var.postgres_user
        },
        {
          name  = "DB_POSTGRESDB_PASSWORD"
          value = var.postgres_password
        },
        {
          name  = "N8N_METRICS"
          value = "true"
        }
      ], var.n8n_additional_env)

      secrets = var.n8n_secrets

      mountPoints = [
        {
          sourceVolume  = "n8n-data"
          containerPath = "/home/node/.n8n"
          readOnly      = false
        }
      ]

      dockerLabels = {
        "traefik.enable"                                = "true"
        "traefik.http.routers.n8n.rule"                = "Host(`${var.n8n_host}`)"
        "traefik.http.routers.n8n.entrypoints"         = var.n8n_protocol == "https" ? "websecure" : "web"
        "traefik.http.services.n8n.loadbalancer.server.port" = "5678"
        "traefik.http.routers.n8n.tls"                 = var.n8n_protocol == "https" ? "true" : "false"
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}-n8n"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "n8n"
        }
      }

      essential = true
      dependsOn = [
        {
          containerName = "postgres"
          condition     = "START"
        },
        {
          containerName = "traefik"
          condition     = "START"
        }
      ]
    }
  ])

  # Persistent volumes for data storage
  volumes = [
    {
      name = "postgres-data"
      host_path = var.enable_efs_volumes ? null : var.postgres_data_path
      efs_volume_configuration = var.enable_efs_volumes && var.efs_file_system_id != null ? {
        file_system_id     = var.efs_file_system_id
        root_directory     = "/postgres"
        transit_encryption = "ENABLED"
      } : null
      docker_volume_configuration = null
    },
    {
      name = "n8n-data" 
      host_path = var.enable_efs_volumes ? null : var.n8n_data_path
      efs_volume_configuration = var.enable_efs_volumes && var.efs_file_system_id != null ? {
        file_system_id     = var.efs_file_system_id
        root_directory     = "/n8n"
        transit_encryption = "ENABLED"
      } : null
      docker_volume_configuration = null
    }
  ]

  # Environment variables (required by module)
  environment_variables = {}

  # Network configuration (EC2 requires subnets parameter)
  subnets = var.subnet_ids

  # Custom IAM policies for N8N, PostgreSQL, and Traefik
  task_role_policy = var.custom_task_role_policy

  # Additional inline policies for specific integrations
  task_role_additional_policies = var.additional_task_policies

  # AWS managed policies
  task_role_managed_policies = var.managed_policy_arns

  # Service-specific access toggles  
  enable_s3_read_access         = var.enable_s3_read_access
  enable_s3_full_access         = var.enable_s3_full_access
  enable_secrets_manager_access = true  # Required for database credentials
  enable_parameter_store_access = true  # Required for configuration
  enable_rds_access             = var.enable_rds_access

  # Resource-specific access
  task_role_s3_bucket_arns      = var.s3_bucket_arns
  task_role_sqs_queue_arns      = var.sqs_queue_arns
  task_role_dynamodb_table_arns = var.dynamodb_table_arns

  # Secrets configuration
  task_secrets_arns = var.task_secrets_arns
  kms_key_arns      = var.kms_key_arns

  # NO Load balancer - Traefik handles routing
  create_alb = false

  # Auto scaling for EC2 instances
  enable_autoscaling       = var.enable_autoscaling
  autoscaling_min_capacity = var.min_capacity
  autoscaling_max_capacity = var.max_capacity
  cpu_target_value         = var.cpu_target_value
  memory_target_value      = var.memory_target_value

  # CloudWatch configuration
  enable_logging     = true
  log_retention_days = var.log_retention_days

  tags = merge(var.tags, {
    Service     = "n8n-stack"
    Environment = var.environment
    Stack       = "n8n-postgres-traefik"
  })
}