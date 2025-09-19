# ===================================================================
# ECS CLUSTER OUTPUTS (from enhanced ECS module)
# ===================================================================

# Security Group Outputs
output "security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = module.ecs_cluster.ecs_tasks_security_group_id
}

# Cluster Outputs
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_cluster.cluster_id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

# Service Outputs
output "n8n_service" {
  description = "N8N main service information"
  value = {
    name = module.ecs_cluster.service_name
    arn  = module.ecs_cluster.service_id
  }
}

# ===================================================================
# LOAD BALANCER OUTPUTS (NEW - from enhanced ECS module)
# ===================================================================

output "load_balancer" {
  description = "Load balancer information"
  value       = module.ecs_cluster.load_balancer
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.ecs_cluster.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Route53 zone ID of the load balancer"
  value       = module.ecs_cluster.load_balancer_zone_id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = module.ecs_cluster.load_balancer_arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.ecs_cluster.target_group_arn
}

# ===================================================================
# SSL CERTIFICATE OUTPUTS (NEW - ACM Certificate Information)
# ===================================================================

output "ssl_certificate" {
  description = "SSL certificate information"
  value       = module.ecs_cluster.ssl_certificate
}

output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate used by the load balancer"
  value       = module.ecs_cluster.ssl_certificate_arn
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate (if created by this module)"
  value       = module.ecs_cluster.acm_certificate_arn
}

# Alias outputs for better compatibility
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer (alias for load_balancer_dns_name)"
  value       = module.ecs_cluster.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer (alias for load_balancer_zone_id)"
  value       = module.ecs_cluster.alb_zone_id
}

# ===================================================================
# IAM ROLE OUTPUTS (from enhanced ECS module)
# ===================================================================

output "iam_roles" {
  description = "IAM roles for ECS services"
  value = {
    execution_role_arn = module.ecs_cluster.task_execution_role_arn
    task_role_arn      = module.ecs_cluster.task_role_arn
  }
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.ecs_cluster.task_role_arn
}

output "execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = module.ecs_cluster.task_execution_role_arn
}

# ===================================================================
# APPLICATION ACCESS OUTPUTS
# ===================================================================

# Application URLs
output "n8n_url" {
  description = "URL to access N8N application"
  value       = (var.ssl_certificate_arn != "" || var.certificate_domain_name != "") ? "https://${var.n8n_host}" : "http://${module.ecs_cluster.load_balancer_dns_name}"
}

output "n8n_alb_url" {
  description = "Direct ALB URL to access N8N application"
  value       = (var.ssl_certificate_arn != "" || var.certificate_domain_name != "") ? "https://${module.ecs_cluster.load_balancer_dns_name}" : "http://${module.ecs_cluster.load_balancer_dns_name}"
}

# ===================================================================
# CLOUDWATCH OUTPUTS
# ===================================================================

# CloudWatch Log Groups
output "log_groups" {
  description = "CloudWatch log group names"
  value = {
    cluster = module.ecs_cluster.cloudwatch_log_group_name
  }
}

# ===================================================================
# INFRASTRUCTURE OUTPUTS
# ===================================================================

# Auto Scaling Group (for EC2 launch type)
output "autoscaling_group" {
  description = "Auto Scaling Group information"
  value       = module.ecs_cluster.ec2_infrastructure
}

# ===================================================================
# RESOURCE ALLOCATION SUMMARY
# ===================================================================

output "resource_allocation" {
  description = "CPU and memory allocation summary"
  value = {
    n8n = {
      cpu    = var.n8n_cpu
      memory = var.n8n_memory
    }
    total = {
      cpu    = var.n8n_cpu
      memory = var.n8n_memory
    }
  }
}

# ===================================================================
# COMPREHENSIVE MODULE OUTPUT
# ===================================================================

output "n8n_deployment" {
  description = "Complete N8N deployment information"
  value = {
    # Application Access
    application_url = (var.ssl_certificate_arn != "" || var.certificate_domain_name != "") ? "https://${var.n8n_host}" : "http://${module.ecs_cluster.load_balancer_dns_name}"
    direct_alb_url  = (var.ssl_certificate_arn != "" || var.certificate_domain_name != "") ? "https://${module.ecs_cluster.load_balancer_dns_name}" : "http://${module.ecs_cluster.load_balancer_dns_name}"

    # Infrastructure
    cluster_name = module.ecs_cluster.cluster_name
    service_name = module.ecs_cluster.service_name

    # Load Balancer
    load_balancer = {
      dns_name = module.ecs_cluster.load_balancer_dns_name
      zone_id  = module.ecs_cluster.load_balancer_zone_id
      arn      = module.ecs_cluster.load_balancer_arn
    }

    # Security
    security_group_id = module.ecs_cluster.ecs_tasks_security_group_id

    # Resource Allocation
    resources = {
      cpu    = var.n8n_cpu
      memory = var.n8n_memory
    }

    # External Dependencies
    external_services = {
      postgres_host = var.postgres_host
      postgres_port = var.postgres_port
      redis_host    = local.redis_host_resolved
      redis_port    = local.redis_port_resolved
      redis_type    = var.redis_url_ssm_parameter != "" ? "upstash-ssm" : var.redis_url != "" ? "upstash-direct" : "traditional"
    }

    # Status
    deployment_type = "enhanced-with-alb"
    launch_type     = "EC2"
  }
}

# ===================================================================
# MULTI-SERVICE OUTPUTS
# ===================================================================

output "multi_service_info" {
  description = "Information about multi-service configuration"
  value       = module.ecs_cluster.multi_service_info
}