# AWS Role Assumption Configuration
variable "assume_role_arn" {
  description = "ARN of the IAM role to assume for AWS operations"
  type        = string
  default     = null
}

variable "assume_role_session_name" {
  description = "Session name for the assumed role"
  type        = string
  default     = "terraform-deployment"
}

variable "assume_role_external_id" {
  description = "External ID for the assumed role (if required)"
  type        = string
  default     = null
}

# Core Configuration
variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "n8n-pioneerdev"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

# VPC Configuration
variable "vpc_id" {
  description = "VPC ID where resources will be created. If null, a new VPC will be created"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR block for VPC (only used if creating new VPC)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for VPC (only used if creating new VPC)"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (only used if creating new VPC)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (only used if creating new VPC)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "subnet_ids" {
  description = "Specific subnet IDs to use (if not provided, will use all private subnets)"
  type        = list(string)
  default     = []
}

# Security Configuration
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed to access admin interfaces (like Traefik dashboard)"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# Load Balancer Configuration
variable "create_alb" {
  description = "Whether to create an Application Load Balancer"
  type        = bool
  default     = false
}

# ECS Configuration
variable "ec2_instance_type" {
  description = "EC2 instance type for ECS cluster"
  type        = string
  default     = "t3.medium"
}

variable "ec2_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "ec2_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "2048"
}

variable "task_memory" {
  description = "Memory for the ECS task"
  type        = string
  default     = "4096"
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

# N8N Application Configuration
variable "n8n_image" {
  description = "Docker image for N8N"
  type        = string
  default     = "jj6584/n8n-custom:0.0.1"
}

variable "n8n_cpu" {
  description = "CPU units for N8N main service"
  type        = number
  default     = 512
}

variable "n8n_memory" {
  description = "Memory in MB for N8N main service"
  type        = number
  default     = 1024
}

variable "n8n_desired_count" {
  description = "Desired number of N8N main tasks"
  type        = number
  default     = 1
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

variable "n8n_basic_auth_password" {
  description = "Basic auth password for N8N"
  type        = string
  sensitive   = true
}

variable "n8n_executions_mode" {
  description = "N8N executions mode (main or queue)"
  type        = string
  default     = "regular"
}

variable "n8n_log_level" {
  description = "N8N log level"
  type        = string
  default     = "info"
}

variable "workflow_health_token" {
  description = "Health check token for N8N workflows"
  type        = string
  sensitive   = true
  default     = ""
}

# N8N Worker Configuration
variable "enable_n8n_worker" {
  description = "Enable separate N8N worker service"
  type        = bool
  default     = false
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

# Additional N8N Configuration (Optional)
variable "n8n_encryption_key" {
  description = "Encryption key for N8N data"
  type        = string
  sensitive   = true
  default     = ""
}

# Database Configuration
variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "n8n"
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "n8n"
}

# ===================================================================
# REDIS CONFIGURATION
# ===================================================================

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

# SSL Configuration
# SSL Configuration
variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS. If not provided, will look up certificate by domain name"
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
}

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

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt certificate registration"
  type        = string
  default     = "admin@joshuamanaol.com"
}





# Storage Configuration
variable "enable_efs" {
  description = "Enable EFS for persistent storage"
  type        = bool
  default     = false
}

variable "efs_provisioned_throughput" {
  description = "Provisioned throughput for EFS in MiB/s"
  type        = number
  default     = 100
}

variable "enable_ebs_volumes" {
  description = "Enable EBS volumes for persistent storage"
  type        = bool
  default     = true
}

variable "ebs_data_volume_size" {
  description = "Size of the EBS data volume in GB"
  type        = number
  default     = 100
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

# Auto Scaling Configuration
variable "enable_autoscaling" {
  description = "Enable auto scaling for the ECS service"
  type        = bool
  default     = true
}

variable "autoscaling_min_capacity" {
  description = "Minimum capacity for auto scaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum capacity for auto scaling"
  type        = number
  default     = 3
}

variable "cpu_target_value" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization for auto scaling"
  type        = number
  default     = 80
}

# Secrets Configuration
variable "secret_recovery_window_days" {
  description = "Recovery window for secrets in days"
  type        = number
  default     = 7
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7
}



# SMTP Configuration (Optional)
variable "smtp_host" {
  description = "SMTP host for email notifications"
  type        = string
  default     = ""
}

variable "smtp_port" {
  description = "SMTP port for email notifications"
  type        = string
  default     = "587"
}

variable "smtp_user" {
  description = "SMTP username for email notifications"
  type        = string
  default     = ""
}

variable "smtp_password" {
  description = "SMTP password for email notifications"
  type        = string
  sensitive   = true
  default     = ""
}

# OAuth Configuration (Optional)
variable "oauth_google_id" {
  description = "Google OAuth client ID"
  type        = string
  default     = ""
}

variable "oauth_google_secret" {
  description = "Google OAuth client secret"
  type        = string
  sensitive   = true
  default     = ""
}

# Route 53 DNS Configuration
variable "create_route53_records" {
  description = "Whether to create Route 53 DNS records for the N8N application"
  type        = bool
  default     = false
}

variable "hosted_zone_name" {
  description = "Name of the Route 53 hosted zone (e.g., example.com)"
  type        = string
  default     = ""
}

variable "private_zone" {
  description = "Whether the hosted zone is private"
  type        = bool
  default     = false
}

variable "n8n_subdomain" {
  description = "Subdomain for the N8N application (e.g., n8n.example.com or just n8n)"
  type        = string
  default     = ""
}

variable "cname_target" {
  description = "Custom CNAME target. If null, will use the first ECS instance's public DNS"
  type        = string
  default     = null
}

variable "dns_ttl" {
  description = "TTL for DNS records in seconds"
  type        = number
  default     = 300
}

variable "additional_cname_records" {
  description = "Map of additional CNAME records to create (subdomain -> target)"
  type        = map(string)
  default     = {}
  # Example:
  # {
  #   "api.example.com" = "n8n.example.com"
  #   "workflows.example.com" = "n8n.example.com"
  # }
}

variable "create_a_record" {
  description = "Whether to create an A record (useful for apex domains)"
  type        = bool
  default     = false
}

variable "a_record_subdomain" {
  description = "Subdomain for the A record (can be empty for apex domain)"
  type        = string
  default     = ""
}

variable "a_record_target" {
  description = "Custom A record target IP. If null, will use the first ECS instance's public IP"
  type        = string
  default     = null
}



# Tags
variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}