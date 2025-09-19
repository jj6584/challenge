# ===================================================================
# MULTI-SERVICE ECS CONFIGURATION
# ===================================================================
# This file handles multiple ECS services when enable_multi_service_mode is true

locals {
  # Determine if we're using multi-service mode
  use_multi_service = var.enable_multi_service_mode && length(var.services) > 0
}

# ===================================================================
# TASK DEFINITIONS FOR MULTI-SERVICE MODE
# ===================================================================

resource "aws_ecs_task_definition" "services" {
  for_each = local.use_multi_service ? var.services : {}

  family                   = "${var.cluster_name}-${each.key}"
  network_mode             = var.network_mode
  requires_compatibilities = var.launch_type
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = var.create_task_execution_role ? aws_iam_role.ecs_task_execution_role[0].arn : var.execution_role_arn
  task_role_arn            = var.create_task_role ? aws_iam_role.ecs_task_role[0].arn : var.task_role_arn

  container_definitions = each.value.container_definitions

  # Volumes
  dynamic "volume" {
    for_each = each.value.volumes
    content {
      name = volume.value.name

      # Host path volume
      host_path = lookup(volume.value, "host_path", null)

      # EFS volume configuration
      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", null) != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", "/")
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", "ENABLED")
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port", 2049)

          dynamic "authorization_config" {
            for_each = lookup(efs_volume_configuration.value, "authorization_config", null) != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              access_point_id = lookup(authorization_config.value, "access_point_id", null)
              iam             = lookup(authorization_config.value, "iam", "DISABLED")
            }
          }
        }
      }

      # Docker volume configuration
      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration", null) != null ? [volume.value.docker_volume_configuration] : []
        content {
          scope         = lookup(docker_volume_configuration.value, "scope", "task")
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", true)
          driver        = lookup(docker_volume_configuration.value, "driver", "local")
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts", {})
          labels        = lookup(docker_volume_configuration.value, "labels", {})
        }
      }
    }
  }

  tags = var.tags
}

# ===================================================================
# TARGET GROUPS FOR MULTI-SERVICE MODE (for services with load balancer)
# ===================================================================

resource "aws_lb_target_group" "services" {
  for_each = local.use_multi_service ? {
    for name, config in var.services : name => config
    if config.enable_load_balancer
  } : {}

  name     = substr("${var.cluster_name}-${each.key}-tg", 0, 32)
  port     = each.value.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = var.network_mode == "awsvpc" ? "ip" : "instance"

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${each.key}-tg"
    Type = "ALB-Target-Group"
  })

  depends_on = [aws_lb.main]
}

# ===================================================================
# ECS SERVICES FOR MULTI-SERVICE MODE
# ===================================================================

resource "aws_ecs_service" "services" {
  for_each = local.use_multi_service ? var.services : {}

  name            = "${var.cluster_name}-${each.key}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = length(var.launch_type) == 1 && var.launch_type[0] == "FARGATE" ? "FARGATE" : "EC2"

  # Deployment configuration
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  # Network configuration for awsvpc mode
  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [1] : []
    content {
      subnets          = var.subnets
      security_groups  = concat(var.security_groups, var.create_ecs_security_group ? [aws_security_group.ecs_tasks[0].id] : [])
      assign_public_ip = each.value.assign_public_ip
    }
  }

  # Capacity provider strategy for EC2 - DISABLED temporarily due to capacity provider association issues
  # dynamic "capacity_provider_strategy" {
  #   for_each = contains(var.launch_type, "EC2") ? [1] : []
  #   content {
  #     capacity_provider = aws_ecs_capacity_provider.main[0].name
  #     weight           = 100
  #   }
  # }

  # Load balancer configuration (only if enable_load_balancer is true)
  dynamic "load_balancer" {
    for_each = each.value.enable_load_balancer && local.create_load_balancer ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.services[each.key].arn
      container_name   = each.value.container_name
      container_port   = each.value.container_port
    }
  }

  # Dependencies
  depends_on = [
    aws_ecs_cluster_capacity_providers.main,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
    aws_iam_role_policy_attachment.ecs_task_role_additional
  ]

  tags = var.tags
}