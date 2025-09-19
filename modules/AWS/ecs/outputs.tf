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
    id   = var.enable_multi_service_mode ? null : aws_ecs_service.main[0].id
    name = var.enable_multi_service_mode ? null : aws_ecs_service.main[0].name
  }
}

# Legacy individual outputs for backward compatibility
output "service_id" {
  description = "ID of the ECS service"
  value       = var.enable_multi_service_mode ? null : aws_ecs_service.main[0].id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = var.enable_multi_service_mode ? null : aws_ecs_service.main[0].name
}

# ===================================================================
# TASK DEFINITION OUTPUTS
# ===================================================================

output "task_definition" {
  description = "ECS task definition information"
  value = {
    arn      = var.enable_multi_service_mode ? null : aws_ecs_task_definition.main[0].arn
    family   = var.enable_multi_service_mode ? null : aws_ecs_task_definition.main[0].family
    revision = var.enable_multi_service_mode ? null : aws_ecs_task_definition.main[0].revision
  }
}

# Legacy individual outputs for backward compatibility
output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = var.enable_multi_service_mode ? null : aws_ecs_task_definition.main[0].arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = var.enable_multi_service_mode ? null : aws_ecs_task_definition.main[0].family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = var.enable_multi_service_mode ? null : aws_ecs_task_definition.main[0].revision
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
    instance_profile = var.iam_instance_profile == null ? {
      name = aws_iam_instance_profile.ecs_agent[0].name
      arn  = aws_iam_instance_profile.ecs_agent[0].arn
    } : null
    ebs_volume = var.enable_ebs_data_volume ? {
      enabled     = var.enable_ebs_data_volume
      size        = var.ebs_data_volume_size
      type        = var.ebs_data_volume_type
      encrypted   = var.ebs_data_volume_encrypted
      mount_point = var.ebs_data_mount_point
      device_name = "/dev/xvdf"
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

# EBS Volume Information
output "ebs_volume_config" {
  description = "EBS volume configuration (EC2 launch type only)"
  value = var.launch_type[0] == "EC2" && var.enable_ebs_data_volume ? {
    enabled     = var.enable_ebs_data_volume
    size        = var.ebs_data_volume_size
    type        = var.ebs_data_volume_type
    encrypted   = var.ebs_data_volume_encrypted
    mount_point = var.ebs_data_mount_point
    device_name = "/dev/xvdf"
  } : null
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
# LOAD BALANCER OUTPUTS
# ===================================================================

output "load_balancer" {
  description = "Load balancer information"
  value = local.create_load_balancer ? {
    id                         = aws_lb.main[0].id
    arn                        = aws_lb.main[0].arn
    name                       = aws_lb.main[0].name
    dns_name                   = aws_lb.main[0].dns_name
    zone_id                    = aws_lb.main[0].zone_id
    type                       = aws_lb.main[0].load_balancer_type
    scheme                     = aws_lb.main[0].internal ? "internal" : "internet-facing"
    vpc_id                     = aws_lb.main[0].vpc_id
    security_groups            = aws_lb.main[0].security_groups
    subnets                    = aws_lb.main[0].subnets
    ip_address_type            = aws_lb.main[0].ip_address_type
    enable_deletion_protection = aws_lb.main[0].enable_deletion_protection
  } : null
}

output "ssl_certificate" {
  description = "SSL certificate information"
  value = local.create_load_balancer && var.enable_https_listener ? {
    arn         = local.final_certificate_arn
    domain_name = var.certificate_domain_name != "" ? var.certificate_domain_name : null
    source      = var.ssl_certificate_arn != "" ? "provided" : (var.create_acm_certificate ? "created" : "lookup")
    created_certificate = var.create_acm_certificate && var.certificate_domain_name != "" ? {
      arn                     = aws_acm_certificate.main[0].arn
      domain_name             = aws_acm_certificate.main[0].domain_name
      domain_validation_options = aws_acm_certificate.main[0].domain_validation_options
      validation_method       = aws_acm_certificate.main[0].validation_method
      status                  = aws_acm_certificate.main[0].status
    } : null
    looked_up_certificate = var.certificate_domain_name != "" && !var.create_acm_certificate && length(data.aws_acm_certificate.main) > 0 ? {
      arn         = data.aws_acm_certificate.main[0].arn
      domain_name = data.aws_acm_certificate.main[0].domain
      status      = data.aws_acm_certificate.main[0].status
    } : null
  } : null
}

output "target_group" {
  description = "Primary target group information"
  value = local.create_load_balancer ? {
    id                    = aws_lb_target_group.main[0].id
    arn                   = aws_lb_target_group.main[0].arn
    name                  = aws_lb_target_group.main[0].name
    port                  = aws_lb_target_group.main[0].port
    protocol              = aws_lb_target_group.main[0].protocol
    target_type           = aws_lb_target_group.main[0].target_type
    vpc_id                = aws_lb_target_group.main[0].vpc_id
    health_check_path     = aws_lb_target_group.main[0].health_check[0].path
    health_check_protocol = aws_lb_target_group.main[0].health_check[0].protocol
    health_check_port     = aws_lb_target_group.main[0].health_check[0].port
  } : null
}

output "additional_target_groups" {
  description = "Additional target groups information"
  value = local.create_load_balancer ? {
    for name, tg in aws_lb_target_group.additional : name => {
      id                    = tg.id
      arn                   = tg.arn
      name                  = tg.name
      port                  = tg.port
      protocol              = tg.protocol
      target_type           = tg.target_type
      vpc_id                = tg.vpc_id
      health_check_path     = tg.health_check[0].path
      health_check_protocol = tg.health_check[0].protocol
      health_check_port     = tg.health_check[0].port
    }
  } : {}
}

output "listeners" {
  description = "Load balancer listeners information"
  value = local.create_load_balancer ? {
    http = var.enable_http_listener && var.load_balancer_type == "application" ? {
      id             = aws_lb_listener.http[0].id
      arn            = aws_lb_listener.http[0].arn
      port           = aws_lb_listener.http[0].port
      protocol       = aws_lb_listener.http[0].protocol
      default_action = aws_lb_listener.http[0].default_action
    } : null

    https = var.enable_https_listener && (var.ssl_certificate_arn != "" || var.create_acm_certificate || var.certificate_domain_name != "") && var.load_balancer_type == "application" ? {
      id              = aws_lb_listener.https[0].id
      arn             = aws_lb_listener.https[0].arn
      port            = aws_lb_listener.https[0].port
      protocol        = aws_lb_listener.https[0].protocol
      ssl_policy      = aws_lb_listener.https[0].ssl_policy
      certificate_arn = aws_lb_listener.https[0].certificate_arn
      default_action  = aws_lb_listener.https[0].default_action
    } : null

    tcp = var.load_balancer_type == "network" && var.target_group_protocol == "TCP" ? {
      id             = aws_lb_listener.tcp[0].id
      arn            = aws_lb_listener.tcp[0].arn
      port           = aws_lb_listener.tcp[0].port
      protocol       = aws_lb_listener.tcp[0].protocol
      default_action = aws_lb_listener.tcp[0].default_action
    } : null

    tls = var.load_balancer_type == "network" && var.target_group_protocol == "TLS" && (var.ssl_certificate_arn != "" || var.create_acm_certificate || var.certificate_domain_name != "") ? {
      id              = aws_lb_listener.tls[0].id
      arn             = aws_lb_listener.tls[0].arn
      port            = aws_lb_listener.tls[0].port
      protocol        = aws_lb_listener.tls[0].protocol
      ssl_policy      = aws_lb_listener.tls[0].ssl_policy
      certificate_arn = aws_lb_listener.tls[0].certificate_arn
      default_action  = aws_lb_listener.tls[0].default_action
    } : null

    udp = var.load_balancer_type == "network" && var.target_group_protocol == "UDP" ? {
      id             = aws_lb_listener.udp[0].id
      arn            = aws_lb_listener.udp[0].arn
      port           = aws_lb_listener.udp[0].port
      protocol       = aws_lb_listener.udp[0].protocol
      default_action = aws_lb_listener.udp[0].default_action
    } : null
  } : {
    http  = null
    https = null
    tcp   = null
    tls   = null
    udp   = null
  }
}

# Legacy individual outputs for backward compatibility
output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = local.create_load_balancer ? aws_lb.main[0].id : null
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = local.create_load_balancer ? aws_lb.main[0].arn : null
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = local.create_load_balancer ? aws_lb.main[0].dns_name : null
}

output "load_balancer_zone_id" {
  description = "Canonical hosted zone ID of the load balancer"
  value       = local.create_load_balancer ? aws_lb.main[0].zone_id : null
}

output "load_balancer_name" {
  description = "Name of the load balancer"
  value       = local.create_load_balancer ? aws_lb.main[0].name : null
}

output "target_group_arn" {
  description = "ARN of the primary target group"
  value       = local.create_load_balancer ? aws_lb_target_group.main[0].arn : null
}

output "target_group_name" {
  description = "Name of the primary target group"
  value       = local.create_load_balancer ? aws_lb_target_group.main[0].name : null
}

# SSL Certificate outputs
output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate used by the load balancer"
  value       = local.create_load_balancer && var.enable_https_listener ? local.final_certificate_arn : null
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate (if created by this module)"
  value       = var.create_acm_certificate && var.certificate_domain_name != "" ? aws_acm_certificate.main[0].arn : null
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer (alias for load_balancer_dns_name)"
  value       = local.create_load_balancer ? aws_lb.main[0].dns_name : null
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer (alias for load_balancer_zone_id)"
  value       = local.create_load_balancer ? aws_lb.main[0].zone_id : null
}

# ===================================================================
# COMPREHENSIVE MODULE OUTPUT
# ===================================================================

output "ecs_module" {
  description = "Complete ECS module information"
  value = {
    cluster = {
      id   = aws_ecs_cluster.main.id
      arn  = aws_ecs_cluster.main.arn
      name = aws_ecs_cluster.main.name
    }
    service = var.enable_multi_service_mode ? null : {
      id   = aws_ecs_service.main[0].id
      name = aws_ecs_service.main[0].name
    }
    task_definition = var.enable_multi_service_mode ? null : {
      arn           = aws_ecs_task_definition.main[0].arn
      family        = aws_ecs_task_definition.main[0].family
      revision      = aws_ecs_task_definition.main[0].revision
      network_mode  = aws_ecs_task_definition.main[0].network_mode
      task_role_arn = aws_ecs_task_definition.main[0].task_role_arn
    }
    iam_roles = var.create_task_role || var.create_task_execution_role ? {
      task_role_arn      = var.create_task_role ? aws_iam_role.ecs_task_role[0].arn : var.task_role_arn
      execution_role_arn = var.create_task_execution_role ? aws_iam_role.ecs_task_execution_role[0].arn : var.execution_role_arn
    } : {}
    security_groups = var.vpc_id != null && var.create_ecs_security_group ? {
      ecs_tasks = aws_security_group.ecs_tasks[0]
    } : {}
    ec2_infrastructure = var.launch_type[0] == "EC2" ? {
      autoscaling_group_name = aws_autoscaling_group.ecs_asg[0].name
      autoscaling_group_arn  = aws_autoscaling_group.ecs_asg[0].arn
      capacity_provider_name = var.enable_capacity_provider ? aws_ecs_capacity_provider.main[0].name : null
    } : {}
    autoscaling = var.enable_autoscaling ? {
      target_group_arn = aws_appautoscaling_target.ecs_target[0].id
    } : {}
    cloudwatch = var.enable_logging ? {
      log_group_name = aws_cloudwatch_log_group.ecs_logs[0].name
      log_group_arn  = aws_cloudwatch_log_group.ecs_logs[0].arn
    } : {}

    # Load balancer information
    load_balancer = local.create_load_balancer ? {
      id       = aws_lb.main[0].id
      arn      = aws_lb.main[0].arn
      name     = aws_lb.main[0].name
      dns_name = aws_lb.main[0].dns_name
      zone_id  = aws_lb.main[0].zone_id
      type     = aws_lb.main[0].load_balancer_type
      target_group = {
        arn  = aws_lb_target_group.main[0].arn
        name = aws_lb_target_group.main[0].name
        port = aws_lb_target_group.main[0].port
      }
    } : {
      id       = null
      arn      = null
      name     = null
      dns_name = null
      zone_id  = null
      type     = null
      target_group = {
        arn  = null
        name = null
        port = null
      }
    }

    # Module metadata
    launch_type    = var.launch_type[0]
    module_version = "enhanced-with-load-balancer"
  }
}

# ===================================================================
# MULTI-SERVICE MODE OUTPUTS
# ===================================================================

output "multi_service_info" {
  description = "Information about all services when in multi-service mode"
  value = var.enable_multi_service_mode ? {
    enabled = true
    services = {
      for name, config in var.services : name => {
        service = {
          name = aws_ecs_service.services[name].name
          arn  = aws_ecs_service.services[name].id
          id   = aws_ecs_service.services[name].id
        }
        task_definition = {
          arn    = aws_ecs_task_definition.services[name].arn
          family = aws_ecs_task_definition.services[name].family
        }
        target_group = config.enable_load_balancer ? {
          arn  = aws_lb_target_group.services[name].arn
          name = aws_lb_target_group.services[name].name
          port = aws_lb_target_group.services[name].port
        } : null
        service_discovery = null
      }
    }
  } : {
    enabled = false
    services = {}
  }
}