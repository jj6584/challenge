# ===================================================================
# ECS CLUSTER OUTPUTS
# ===================================================================

output "cluster" {
  description = "ECS cluster information"
  value = {
    id   = aws_ecs_cluster.main.id
    arn  = aws_ecs_cluster.main.arn
    name = aws_ecs_cluster.main.name
  }
}

# Legacy individual outputs for backward compatibility
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# ===================================================================
# ECS SERVICE OUTPUTS
# ===================================================================

output "service" {
  description = "ECS service information"
  value = {
    id   = aws_ecs_service.main.id
    arn  = aws_ecs_service.main.arn
    name = aws_ecs_service.main.name
  }
}

# Legacy individual outputs for backward compatibility
output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.main.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.main.arn
}

# ===================================================================
# TASK DEFINITION OUTPUTS
# ===================================================================

output "task_definition" {
  description = "ECS task definition information"
  value = {
    arn      = aws_ecs_task_definition.main.arn
    family   = aws_ecs_task_definition.main.family
    revision = aws_ecs_task_definition.main.revision
  }
}

# Legacy individual outputs for backward compatibility
output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = aws_ecs_task_definition.main.family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = aws_ecs_task_definition.main.revision
}

# ===================================================================
# IAM ROLE OUTPUTS
# ===================================================================

output "iam_roles" {
  description = "ECS IAM roles information"
  value = {
    task_execution_role = var.create_task_execution_role ? {
      arn  = aws_iam_role.ecs_task_execution_role[0].arn
      name = aws_iam_role.ecs_task_execution_role[0].name
    } : null

    task_role = var.create_task_role ? {
      arn  = aws_iam_role.ecs_task_role[0].arn
      name = aws_iam_role.ecs_task_role[0].name
    } : null

    instance_profile = var.launch_type[0] == "EC2" && var.iam_instance_profile == null ? {
      arn  = aws_iam_instance_profile.ecs_agent[0].arn
      name = aws_iam_instance_profile.ecs_agent[0].name
    } : null
  }
}

# Legacy individual outputs for backward compatibility
output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = var.create_task_execution_role ? aws_iam_role.ecs_task_execution_role[0].arn : null
}

output "task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = var.create_task_execution_role ? aws_iam_role.ecs_task_execution_role[0].name : null
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = var.create_task_role ? aws_iam_role.ecs_task_role[0].arn : null
}

output "task_role_name" {
  description = "Name of the ECS task role"
  value       = var.create_task_role ? aws_iam_role.ecs_task_role[0].name : null
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile (EC2 launch type only)"
  value       = var.launch_type[0] == "EC2" && var.iam_instance_profile == null ? aws_iam_instance_profile.ecs_agent[0].name : var.iam_instance_profile
}

# ===================================================================
# EC2 LAUNCH TYPE OUTPUTS
# ===================================================================

output "ec2_infrastructure" {
  description = "EC2 launch type infrastructure information"
  value = var.launch_type[0] == "EC2" ? {
    autoscaling_group = {
      arn  = aws_autoscaling_group.ecs_asg[0].arn
      name = aws_autoscaling_group.ecs_asg[0].name
    }

    launch_template = {
      id      = aws_launch_template.ecs_lt[0].id
      version = aws_launch_template.ecs_lt[0].latest_version
    }

    capacity_provider = var.enable_capacity_provider ? {
      name = aws_ecs_capacity_provider.main[0].name
      arn  = aws_ecs_capacity_provider.main[0].arn
    } : null
  } : null
}

# Legacy individual outputs for backward compatibility
output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group (EC2 launch type only)"
  value       = var.launch_type[0] == "EC2" ? aws_autoscaling_group.ecs_asg[0].arn : null
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group (EC2 launch type only)"
  value       = var.launch_type[0] == "EC2" ? aws_autoscaling_group.ecs_asg[0].name : null
}

output "launch_template_id" {
  description = "ID of the Launch Template (EC2 launch type only)"
  value       = var.launch_type[0] == "EC2" ? aws_launch_template.ecs_lt[0].id : null
}

output "capacity_provider_name" {
  description = "Name of the ECS Capacity Provider (EC2 launch type only)"
  value       = var.launch_type[0] == "EC2" && var.enable_capacity_provider ? aws_ecs_capacity_provider.main[0].name : null
}

# ===================================================================
# SECURITY GROUP OUTPUTS
# ===================================================================

output "security_groups" {
  description = "Security groups information"
  value = {
    ecs_tasks = var.vpc_id != null && var.create_ecs_security_group ? {
      id  = aws_security_group.ecs_tasks[0].id
      arn = aws_security_group.ecs_tasks[0].arn
    } : null

    alb = var.create_alb_security_group ? {
      id  = aws_security_group.alb[0].id
      arn = aws_security_group.alb[0].arn
    } : null

    ec2_instances = var.launch_type[0] == "EC2" && var.create_ec2_security_group ? {
      id  = aws_security_group.ec2_instances[0].id
      arn = aws_security_group.ec2_instances[0].arn
    } : null

    # List of all security group IDs for easy reference
    all_ids = compact([
      var.vpc_id != null && var.create_ecs_security_group ? aws_security_group.ecs_tasks[0].id : null,
      var.create_alb_security_group ? aws_security_group.alb[0].id : null,
      var.launch_type[0] == "EC2" && var.create_ec2_security_group ? aws_security_group.ec2_instances[0].id : null
    ])
  }
}

# Legacy individual outputs for backward compatibility
output "ecs_tasks_security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = var.vpc_id != null && var.create_ecs_security_group ? aws_security_group.ecs_tasks[0].id : null
}

output "ecs_tasks_security_group_arn" {
  description = "ARN of the ECS tasks security group"
  value       = var.vpc_id != null && var.create_ecs_security_group ? aws_security_group.ecs_tasks[0].arn : null
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.create_alb_security_group ? aws_security_group.alb[0].id : null
}

output "alb_security_group_arn" {
  description = "ARN of the ALB security group"
  value       = var.create_alb_security_group ? aws_security_group.alb[0].arn : null
}

output "ec2_instances_security_group_id" {
  description = "ID of the EC2 instances security group (EC2 launch type only)"
  value       = var.launch_type[0] == "EC2" && var.create_ec2_security_group ? aws_security_group.ec2_instances[0].id : null
}

output "ec2_instances_security_group_arn" {
  description = "ARN of the EC2 instances security group (EC2 launch type only)"
  value       = var.launch_type[0] == "EC2" && var.create_ec2_security_group ? aws_security_group.ec2_instances[0].arn : null
}

output "security_group_ids" {
  description = "List of all created security group IDs"
  value = compact([
    var.vpc_id != null && var.create_ecs_security_group ? aws_security_group.ecs_tasks[0].id : null,
    var.create_alb_security_group ? aws_security_group.alb[0].id : null,
    var.launch_type[0] == "EC2" && var.create_ec2_security_group ? aws_security_group.ec2_instances[0].id : null
  ])
}

# ===================================================================
# AUTO SCALING OUTPUTS
# ===================================================================

output "autoscaling" {
  description = "Auto scaling configuration information"
  value = var.enable_autoscaling ? {
    target = {
      resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
      scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
      min_capacity       = aws_appautoscaling_target.ecs_target[0].min_capacity
      max_capacity       = aws_appautoscaling_target.ecs_target[0].max_capacity
    }

    policies = {
      cpu_scaling = {
        arn  = aws_appautoscaling_policy.ecs_policy_cpu[0].arn
        name = aws_appautoscaling_policy.ecs_policy_cpu[0].name
      }

      memory_scaling = var.enable_memory_scaling ? {
        arn  = aws_appautoscaling_policy.ecs_policy_memory[0].arn
        name = aws_appautoscaling_policy.ecs_policy_memory[0].name
      } : null
    }
  } : null
}

# ===================================================================
# CLOUDWATCH OUTPUTS
# ===================================================================

output "cloudwatch" {
  description = "CloudWatch resources information"
  value = {
    log_group = var.enable_logging ? {
      name              = aws_cloudwatch_log_group.ecs_logs[0].name
      arn               = aws_cloudwatch_log_group.ecs_logs[0].arn
      retention_in_days = aws_cloudwatch_log_group.ecs_logs[0].retention_in_days
    } : null
  }
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for ECS tasks"
  value       = var.enable_logging ? aws_cloudwatch_log_group.ecs_logs[0].name : null
}

# ===================================================================
# COMPREHENSIVE MODULE OUTPUT
# ===================================================================

output "ecs_module" {
  description = "Complete ECS module information"
  value = {
    cluster            = output.cluster.value
    service            = output.service.value
    task_definition    = output.task_definition.value
    iam_roles          = output.iam_roles.value
    security_groups    = output.security_groups.value
    ec2_infrastructure = output.ec2_infrastructure.value
    autoscaling        = output.autoscaling.value
    cloudwatch         = output.cloudwatch.value

    # Module metadata
    launch_type    = var.launch_type[0]
    module_version = "enhanced"
  }
}