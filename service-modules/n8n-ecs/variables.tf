variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "n8n_image" {
  description = "N8N Docker image"
  type        = string
  default     = "n8nio/n8n:latest"
}

variable "n8n_host" {
  description = "N8N host"
  type        = string
}

variable "n8n_protocol" {
  description = "N8N protocol (http/https)"
  type        = string
  default     = "https"
}

variable "webhook_url" {
  description = "Webhook URL for N8N"
  type        = string
}

variable "n8n_secrets" {
  description = "List of secrets for N8N container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "512"
}

variable "memory" {
  description = "Memory for the task"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign public IP"
  type        = bool
  default     = false
}

# Custom IAM Policy Variables
variable "custom_task_role_policy" {
  description = "Custom IAM policy document (JSON) for the ECS task role"
  type        = string
  default     = null
}

variable "additional_task_policies" {
  description = "List of additional inline IAM policy documents (JSON) for the ECS task role"
  type        = list(string)
  default     = []
}

variable "managed_policy_arns" {
  description = "List of ARNs of AWS managed policies to attach to the ECS task role"
  type        = list(string)
  default     = []
}

# AWS Service Access Toggles
variable "enable_s3_read_access" {
  description = "Enable read-only access to S3 for the ECS task role"
  type        = bool
  default     = false
}

variable "enable_s3_full_access" {
  description = "Enable full access to S3 for the ECS task role"
  type        = bool
  default     = false
}

variable "enable_secrets_manager_access" {
  description = "Enable Secrets Manager access for the ECS task role"
  type        = bool
  default     = true
}

variable "enable_parameter_store_access" {
  description = "Enable Parameter Store read access for the ECS task role"
  type        = bool
  default     = true
}

variable "enable_rds_access" {
  description = "Enable RDS data access for the ECS task role"
  type        = bool
  default     = false
}

# Resource-specific access variables
variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs that the ECS task role should have access to"
  type        = list(string)
  default     = []
}

variable "sqs_queue_arns" {
  description = "List of SQS queue ARNs that the ECS task role should have access to"
  type        = list(string)
  default     = []
}

variable "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs that the ECS task role should have access to"
  type        = list(string)
  default     = []
}

variable "task_secrets_arns" {
  description = "List of Secrets Manager secret ARNs that the execution role should access"
  type        = list(string)
  default     = []
}

variable "kms_key_arns" {
  description = "List of KMS key ARNs for secrets decryption"
  type        = list(string)
  default     = []
}

# Load Balancer Variables
variable "enable_load_balancer" {
  description = "Enable load balancer"
  type        = bool
  default     = false
}

variable "alb_subnets" {
  description = "Subnets for the ALB"
  type        = list(string)
  default     = []
}

variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check path for the ALB target group"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}

# Auto Scaling Variables
variable "enable_autoscaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum capacity for auto scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
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
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}