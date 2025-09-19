# Core Configuration Variables
variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "n8n"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

# VPC and Network Configuration
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS services"
  type        = list(string)
}

variable "load_balancer_subnets" {
  description = "List of subnet IDs for the load balancer (typically public subnets)"
  type        = list(string)
}

variable "load_balancer_internal" {
  description = "Whether the load balancer should be internal"
  type        = bool
  default     = false
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener. If not provided, will look up certificate by domain name"
  type        = string
  default     = ""
}

variable "certificate_domain_name" {
  description = "Domain name to look up ACM certificate for. Required if ssl_certificate_arn is not provided and HTTPS is enabled"
  type        = string
  default     = ""
}

variable "certificate_validation_method" {
  description = "Validation method for ACM certificate lookup (DNS or EMAIL)"
  type        = string
  default     = "DNS"
  validation {
    condition     = contains(["DNS", "EMAIL"], var.certificate_validation_method)
    error_message = "Certificate validation method must be either 'DNS' or 'EMAIL'."
  }
}

variable "additional_certificate_subject_alternative_names" {
  description = "Additional subject alternative names for ACM certificate lookup"
  type        = list(string)
  default     = []
}

variable "create_acm_certificate" {
  description = "Whether to create a new ACM certificate if none found. Requires Route53 hosted zone for DNS validation"
  type        = bool
  default     = false
}

variable "acm_certificate_tags" {
  description = "Additional tags for ACM certificate (if created)"
  type        = map(string)
  default     = {}
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener. Use newer policies for better security"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  validation {
    condition = contains([
      "ELBSecurityPolicy-TLS13-1-2-2021-06",
      "ELBSecurityPolicy-TLS-1-2-2017-01",
      "ELBSecurityPolicy-TLS-1-2-Ext-2018-06",
      "ELBSecurityPolicy-FS-2018-06",
      "ELBSecurityPolicy-FS-1-2-2019-08",
      "ELBSecurityPolicy-FS-1-2-Res-2019-08",
      "ELBSecurityPolicy-FS-1-2-Res-2020-10",
      "ELBSecurityPolicy-TLS-1-1-2017-01",
      "ELBSecurityPolicy-2016-08",
      "ELBSecurityPolicy-2015-05"
    ], var.ssl_policy)
    error_message = "SSL policy must be a valid ELB security policy."
  }
}

# ===================================================================
# HTTP/HTTPS LISTENER CONFIGURATION
# ===================================================================

variable "enable_http_listener" {
  description = "Enable HTTP listener on the load balancer"
  type        = bool
  default     = true
}

variable "enable_https_listener" {
  description = "Enable HTTPS listener on the load balancer (automatically enabled if SSL certificate is provided)"
  type        = bool
  default     = null # Will be auto-determined based on certificate configuration
}

variable "http_port" {
  description = "Port for HTTP listener"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Port for HTTPS listener"
  type        = number
  default     = 443
}

variable "http_redirect_to_https" {
  description = "Redirect HTTP traffic to HTTPS (automatically enabled if SSL certificate is provided)"
  type        = bool
  default     = null # Will be auto-determined based on certificate configuration
}

variable "security_group_ids" {
  description = "List of additional security group IDs for ECS tasks (optional - module creates its own)"
  type        = list(string)
  default     = []
}

# EC2 Configuration
variable "ec2_instance_type" {
  description = "EC2 instance type for ECS cluster"
  type        = string
  default     = "t3.small"
}

variable "ec2_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "ec2_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 1
}

# Storage Configuration
variable "enable_ebs_volumes" {
  description = "Enable EBS volumes for persistent storage"
  type        = bool
  default     = true
}

variable "ebs_data_volume_size" {
  description = "Size of the EBS data volume in GB"
  type        = number
  default     = 20
}

variable "ebs_data_volume_type" {
  description = "Type of the EBS data volume"
  type        = string
  default     = "gp3"
}

variable "ebs_data_volume_encrypted" {
  description = "Enable encryption for the EBS data volume"
  type        = bool
  default     = true
}

# N8N Configuration
variable "n8n_image" {
  description = "Docker image for N8N"
  type        = string
  default     = "jj6584/n8n-custom:0.0.1"
}

variable "n8n_worker_image" {
  description = "Docker image for N8N worker (if different from main)"
  type        = string
  default     = ""
}

variable "n8n_host" {
  description = "Host domain for N8N"
  type        = string
}

variable "n8n_protocol" {
  description = "Protocol for N8N (http/https)"
  type        = string
  default     = "https"
}

variable "webhook_url" {
  description = "Webhook URL for N8N"
  type        = string
  default     = ""
}

variable "generic_timezone" {
  description = "Timezone for the application"
  type        = string
  default     = "UTC"
}

variable "n8n_basic_auth_active" {
  description = "Enable basic authentication for N8N"
  type        = string
  default     = "true"
}

variable "n8n_basic_auth_user" {
  description = "Basic auth username for N8N"
  type        = string
  default     = "admin"
}

variable "n8n_executions_mode" {
  description = "N8N executions mode (main or queue)"
  type        = string
  default     = "queue"
}

variable "n8n_log_level" {
  description = "N8N log level"
  type        = string
  default     = "info"
}

variable "enable_n8n_worker" {
  description = "Enable separate N8N worker service"
  type        = bool
  default     = false
}

# N8N data path
variable "n8n_data_path" {
  description = "Host path for N8N data"
  type        = string
  default     = "/data/n8n"
}

# ===================================================================
# EXTERNAL DATABASE CONFIGURATION (PostgreSQL)
# ===================================================================

variable "postgres_host" {
  description = "PostgreSQL database host (RDS endpoint or external host)"
  type        = string
}

variable "postgres_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}

variable "postgres_database" {
  description = "PostgreSQL database name"
  type        = string
  default     = "n8n"
}

variable "postgres_user" {
  description = "PostgreSQL database username"
  type        = string
  default     = "n8n"
}

# ===================================================================
# EXTERNAL REDIS CONFIGURATION
# ===================================================================
# Supports both traditional Redis (host/port) and Upstash Redis (URL format)

variable "upstash_redis_host" {
  description = "Upstash Redis host (e.g., calm-aphid-47308.upstash.io). When provided, token will be read from /upstash/redis/token SSM parameter"
  type        = string
  default     = ""
}

variable "upstash_redis_port" {
  description = "Upstash Redis port"
  type        = number
  default     = 6379
}

variable "redis_url" {
  description = "Full Redis URL (for Upstash Redis). Format: redis://default:<token>@host:port. If provided, this takes precedence over host/port"
  type        = string
  default     = ""
}

variable "redis_url_ssm_parameter" {
  description = "SSM Parameter name containing the Redis URL (for secure storage of Upstash credentials)"
  type        = string
  default     = ""
}

variable "redis_host" {
  description = "Redis host (ElastiCache endpoint or external host). Used when redis_url is not provided"
  type        = string
  default     = ""
}

variable "redis_port" {
  description = "Redis port. Used when redis_url is not provided"
  type        = number
  default     = 6379
}

variable "redis_password" {
  description = "Redis password. Used when redis_url is not provided"
  type        = string
  default     = ""
  sensitive   = true
}

variable "redis_password_ssm_parameter" {
  description = "SSM Parameter name containing the Redis password"
  type        = string
  default     = ""
}



variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt certificate registration"
  type        = string
}

# Docker Hub Authentication (Optional)
variable "docker_hub_username" {
  description = "Docker Hub username for authenticated pulls"
  type        = string
  default     = ""
}

variable "docker_hub_password_arn" {
  description = "ARN of AWS SSM Parameter or Secrets Manager secret containing Docker Hub password"
  type        = string
  default     = ""
}

# Secrets Configuration
variable "n8n_secrets" {
  description = "List of secrets for N8N container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}


variable "task_secrets_arns" {
  description = "List of SSM Parameter Store ARNs for task secrets"
  type        = list(string)
  default     = []
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7
}

# Resource Allocation (CPU units and Memory in MB)
variable "n8n_cpu" {
  description = "CPU units for N8N main service"
  type        = number
  default     = 384
}

variable "n8n_memory" {
  description = "Memory in MB for N8N main service"
  type        = number
  default     = 768
}

variable "n8n_worker_cpu" {
  description = "CPU units for N8N worker service"
  type        = number
  default     = 256
}

variable "n8n_worker_memory" {
  description = "Memory in MB for N8N worker service"
  type        = number
  default     = 512
}

# Service Configuration

variable "n8n_desired_count" {
  description = "Desired number of N8N main tasks"
  type        = number
  default     = 1
}

variable "n8n_worker_desired_count" {
  description = "Desired number of N8N worker tasks"
  type        = number
  default     = 1
}

# Public IP Configuration
variable "n8n_assign_public_ip" {
  description = "Whether to assign public IP to N8N main service tasks"
  type        = bool
  default     = false
}

variable "n8n_worker_assign_public_ip" {
  description = "Whether to assign public IP to N8N worker service tasks"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# ===================================================================
# MULTI-SERVICE CONFIGURATION VARIABLES
# ===================================================================

variable "enable_multi_service_mode" {
  description = "Enable multi-service mode. When true, uses the services variable instead of single service configuration."
  type        = bool
  default     = false
}

variable "services" {
  description = "Map of ECS services to create. Each service can have its own task definition and configuration."
  type = map(object({
    # Basic Service Configuration
    name                    = string
    desired_count          = optional(number, 1)
    container_definitions  = string
    
    # Task Definition Configuration
    cpu                    = optional(string, "256")
    memory                 = optional(string, "512")
    requires_compatibilities = optional(list(string), ["FARGATE"])
    
    # Network Configuration
    assign_public_ip       = optional(bool, false)
    
    # Load Balancer Configuration (optional)
    enable_load_balancer   = optional(bool, false)
    container_name         = optional(string, "")
    container_port         = optional(number, 80)
    
    # Volumes and Environment
    volumes                = optional(list(any), [])
    environment_variables  = optional(map(string), {})
    secrets               = optional(list(object({
      name      = string
      valueFrom = string
    })), [])
  }))
  default = {}
}