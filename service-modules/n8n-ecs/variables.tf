# Core Configuration
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

# EC2 Launch Type Configuration
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

# Network Configuration
variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

# Container Resource Configuration
variable "cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "2048"
}

variable "memory" {
  description = "Memory for the task"
  type        = string
  default     = "4096"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

# N8N Configuration
variable "n8n_image" {
  description = "N8N Docker image"
  type        = string
  default     = "n8nio/n8n:latest"
}

variable "n8n_host" {
  description = "N8N host domain"
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

variable "n8n_additional_env" {
  description = "Additional environment variables for N8N"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# PostgreSQL Configuration
variable "postgres_image" {
  description = "PostgreSQL Docker image"
  type        = string
  default     = "postgres:15-alpine"
}

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

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "postgres_secrets" {
  description = "List of secrets for PostgreSQL container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# Traefik Configuration
variable "traefik_image" {
  description = "Traefik Docker image"
  type        = string
  default     = "traefik:v3.0"
}

# Volume Configuration
variable "postgres_data_path" {
  description = "Host path for PostgreSQL data persistence"
  type        = string
  default     = "/data/postgres"
}

variable "n8n_data_path" {
  description = "Host path for N8N data persistence"
  type        = string
  default     = "/data/n8n"
}

variable "enable_efs_volumes" {
  description = "Enable EFS volumes instead of host path volumes"
  type        = bool
  default     = false
}

variable "efs_file_system_id" {
  description = "EFS file system ID for persistent storage"
  type        = string
  default     = null
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
  description = "Type of the EBS data volume (gp3, gp2, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "ebs_data_volume_iops" {
  description = "IOPS for the EBS data volume (io1/io2 volumes only)"
  type        = number
  default     = null
}

variable "ebs_data_volume_throughput" {
  description = "Throughput for the EBS data volume in MB/s (gp3 volumes only)"
  type        = number
  default     = 125
}

variable "ebs_data_volume_encrypted" {
  description = "Enable encryption for the EBS data volume"
  type        = bool
  default     = true
}

variable "ebs_data_volume_kms_key_id" {
  description = "KMS key ID for EBS data volume encryption"
  type        = string
  default     = null
}

# IAM Configuration
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

# Auto Scaling Variables
variable "enable_autoscaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = true
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

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}