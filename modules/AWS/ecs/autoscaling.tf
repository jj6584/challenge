# Auto Scaling Target for ECS Service
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = var.tags
}

# CPU-based Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.service_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_out_cooldown = var.scale_out_cooldown
    scale_in_cooldown  = var.scale_in_cooldown
  }
}

# Memory-based Auto Scaling Policy (optional)
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count              = var.enable_autoscaling && var.enable_memory_scaling ? 1 : 0
  name               = "${var.service_name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_target_value
    scale_out_cooldown = var.scale_out_cooldown
    scale_in_cooldown  = var.scale_in_cooldown
  }
}

# Schedule-based scaling for predictable workloads (scale down at night)
resource "aws_appautoscaling_scheduled_action" "scale_down_night" {
  count              = var.enable_scheduled_scaling && var.night_scale_min_capacity != null ? 1 : 0
  name               = "${var.service_name}-scale-down-night"
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension

  schedule = var.night_scale_schedule

  scalable_target_action {
    min_capacity = var.night_scale_min_capacity
    max_capacity = var.night_scale_max_capacity
  }
}

# Schedule-based scaling for predictable workloads (scale up in morning)
resource "aws_appautoscaling_scheduled_action" "scale_up_morning" {
  count              = var.enable_scheduled_scaling && var.day_scale_min_capacity != null ? 1 : 0
  name               = "${var.service_name}-scale-up-morning"
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension

  schedule = var.day_scale_schedule

  scalable_target_action {
    min_capacity = var.day_scale_min_capacity
    max_capacity = var.day_scale_max_capacity
  }
}