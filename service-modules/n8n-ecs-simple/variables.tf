# N8N ECS Simple Module Variables

# VPC and Network Configuration
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service and ALB"
  type        = list(string)
}

# ECS Cluster Configuration
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

# EC2 Instance Configuration
variable "ec2_instance_type" {
  description = "EC2 instance type for ECS cluster"
  type        = string
  default     = "t3.small"
}

variable "ec2_min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 1
}

variable "ec2_desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 1
}

variable "security_group_ids" {
  description = "List of security group IDs for EC2 instances"
  type        = list(string)
  default     = []
}

# N8N Service Configuration
variable "desired_count" {
  description = "Desired number of N8N tasks"
  type        = number
  default     = 1
}

variable "n8n_cpu" {
  description = "CPU units for N8N service (1 vCPU = 1024 units)"
  type        = number
  default     = 512
}

variable "n8n_memory" {
  description = "Memory in MB for N8N service"
  type        = number
  default     = 1024
}

# N8N Application Configuration
variable "n8n_host" {
  description = "Host for N8N application"
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
  description = "Timezone for N8N"
  type        = string
  default     = "Asia/Singapore"
}

# Database Configuration
variable "postgres_host" {
  description = "PostgreSQL database host"
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
}

variable "postgres_user" {
  description = "PostgreSQL database user"
  type        = string
}

variable "postgres_password_ssm_parameter" {
  description = "SSM parameter name for PostgreSQL password"
  type        = string
}

# Redis Configuration (for queue mode)
variable "upstash_redis_host" {
  description = "Upstash Redis host"
  type        = string
  default     = ""
}

variable "upstash_redis_port" {
  description = "Upstash Redis port"
  type        = number
  default     = 6379
}

variable "redis_url_ssm_parameter" {
  description = "SSM parameter name for Redis URL"
  type        = string
  default     = ""
}

# N8N Authentication
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

variable "n8n_basic_auth_password_ssm_parameter" {
  description = "SSM parameter name for N8N basic auth password"
  type        = string
}

# Load Balancer Configuration
variable "load_balancer_internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "enable_http_listener" {
  description = "Enable HTTP listener on ALB"
  type        = bool
  default     = true
}

variable "enable_https_listener" {
  description = "Enable HTTPS listener on ALB"
  type        = bool
  default     = false
}

variable "http_port" {
  description = "HTTP port for ALB"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port for ALB"
  type        = number
  default     = 443
}

# SSL Configuration
variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate"
  type        = string
  default     = ""
}

variable "certificate_domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
  default     = ""
}

variable "certificate_validation_method" {
  description = "Certificate validation method"
  type        = string
  default     = "DNS"
}

# Secrets Management
variable "task_secrets_arns" {
  description = "List of Secrets Manager ARNs that the task can access"
  type        = list(string)
  default     = []
}

# CloudWatch Logging
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}