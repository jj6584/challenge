# ECS Cluster Outputs
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.n8n_ecs.cluster_id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.n8n_ecs.cluster_name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.n8n_ecs.cluster_arn
}

# ECS Service Outputs
output "service_name" {
  description = "Name of the ECS service"
  value       = module.n8n_ecs.service_name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = module.n8n_ecs.service_arn
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.n8n_ecs.task_definition_arn
}

# EC2 Infrastructure Outputs
output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.n8n_ecs.autoscaling_group_arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.n8n_ecs.autoscaling_group_name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = module.n8n_ecs.launch_template_id
}

output "capacity_provider_name" {
  description = "Name of the ECS Capacity Provider"
  value       = module.n8n_ecs.capacity_provider_name
}

# Application URLs
output "n8n_url" {
  description = "N8N application URL"
  value       = "${var.n8n_protocol}://${var.n8n_host}"
}

output "traefik_dashboard_url" {
  description = "Traefik dashboard URL (port 8080)"
  value       = "http://${var.n8n_host}:8080"
}

# Security Group Information
output "security_groups" {
  description = "Security group information"
  value       = module.n8n_ecs.security_groups
}

# IAM Role Information
output "iam_roles" {
  description = "IAM role information"
  value       = module.n8n_ecs.iam_roles
}

# Database Configuration
output "database_config" {
  description = "Database configuration information"
  value = {
    database_name = var.postgres_db
    username      = var.postgres_user
    host          = "localhost"
    port          = 5432
    type          = "postgresql"
  }
  sensitive = false
}

# Network Configuration
output "network_config" {
  description = "Network configuration"
  value = {
    vpc_id              = var.vpc_id
    subnet_ids          = var.subnet_ids
    security_group_ids  = var.security_group_ids
  }
}

# Container Information
output "container_info" {
  description = "Container configuration information"
  value = {
    n8n_image        = var.n8n_image
    postgres_image   = var.postgres_image
    traefik_image    = var.traefik_image
    cpu              = var.cpu
    memory           = var.memory
    desired_count    = var.desired_count
  }
}

# Volume Configuration
output "volume_config" {
  description = "Volume configuration information"
  value = {
    postgres_data_path          = var.postgres_data_path
    n8n_data_path              = var.n8n_data_path
    enable_efs_volumes         = var.enable_efs_volumes
    efs_file_system_id         = var.efs_file_system_id
    enable_ebs_volumes         = var.enable_ebs_volumes
    ebs_data_volume_size       = var.ebs_data_volume_size
    ebs_data_volume_type       = var.ebs_data_volume_type
    ebs_data_volume_encrypted  = var.ebs_data_volume_encrypted
    volume_type               = var.enable_efs_volumes ? "EFS" : var.enable_ebs_volumes ? "EBS" : "Host Path"
  }
}

# Ports Configuration
output "service_ports" {
  description = "Service port mappings"
  value = {
    n8n = {
      container_port = 5678
      description    = "N8N application port"
    }
    postgres = {
      container_port = 5432
      host_port      = 5432
      description    = "PostgreSQL database port"
    }
    traefik_http = {
      container_port = 80
      host_port      = 80
      description    = "Traefik HTTP port"
    }
    traefik_https = {
      container_port = 443
      host_port      = 443
      description    = "Traefik HTTPS port"
    }
    traefik_dashboard = {
      container_port = 8080
      host_port      = 8080
      description    = "Traefik dashboard port"
    }
  }
}