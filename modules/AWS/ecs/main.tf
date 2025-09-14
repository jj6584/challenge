# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  # Add capacity providers for EC2 instance type selection
  dynamic "capacity_providers" {
    for_each = var.launch_type[0] == "EC2" ? [1] : []
    content {
      capacity_providers = [aws_ecs_capacity_provider.main[0].name]

      default_capacity_provider_strategy {
        capacity_provider = aws_ecs_capacity_provider.main[0].name
        weight            = 100
      }
    }
  }

  tags = var.tags
}

# CloudWatch Log Group for ECS tasks
resource "aws_cloudwatch_log_group" "ecs_logs" {
  count             = var.enable_logging ? 1 : 0
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-logs"
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.task_family != null ? var.task_family : var.service_name
  network_mode             = var.network_mode
  requires_compatibilities = var.launch_type
  cpu                      = var.cpu
  memory                   = var.memory

  # Use created task execution role or provided one
  execution_role_arn = var.execution_role_arn != null ? var.execution_role_arn : (var.create_task_execution_role ? aws_iam_role.ecs_task_execution_role[0].arn : null)

  # Use created task role or provided one
  task_role_arn = var.task_role_arn != null ? var.task_role_arn : (var.create_task_role ? aws_iam_role.ecs_task_role[0].arn : null)

  container_definitions = var.container_definitions

  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", null)
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", null)
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port", null)
        }
      }
    }
  }

  tags = var.tags
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count

  # Enhanced service configuration
  platform_version       = var.launch_type[0] == "FARGATE" ? var.platform_version : null
  enable_execute_command = var.enable_execute_command
  propagate_tags         = var.propagate_tags

  # Health check grace period for ALB
  health_check_grace_period_seconds = var.load_balancer_config != null ? var.health_check_grace_period : null

  # Use capacity provider strategy for EC2, launch_type for Fargate
  dynamic "capacity_provider_strategy" {
    for_each = var.launch_type[0] == "EC2" ? [1] : []
    content {
      capacity_provider = aws_ecs_capacity_provider.main[0].name
      weight            = 100
    }
  }

  launch_type = var.launch_type[0] == "FARGATE" ? var.launch_type[0] : null

  dynamic "network_configuration" {
    for_each = var.launch_type[0] == "FARGATE" ? [1] : []
    content {
      subnets = length(var.subnet_ids) > 0 ? var.subnet_ids : var.subnets

      # Use created security groups or provided ones
      security_groups = length(var.security_group_ids) > 0 ? var.security_group_ids : (
        var.create_ecs_security_group ? [aws_security_group.ecs_tasks[0].id] : []
      )

      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer_config != null ? [var.load_balancer_config] : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # Deployment configuration  
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  depends_on = [var.service_dependencies]

  tags = var.tags
}
