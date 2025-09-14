# ECS Module Variables

# Basic Configuration
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "container_definitions" {
  description = "Container definitions for the ECS task definition"
  type        = string
  default     = null
}

variable "task_role_policy" {
  description = "Custom IAM policy document (JSON) for the ECS task role"
  type        = string
  default     = null
}

variable "task_role_additional_policies" {
  description = "List of additional inline IAM policy documents (JSON) for the ECS task role"
  type        = list(string)
  default     = []
}

variable "task_role_managed_policies" {
  description = "List of ARNs of AWS managed policies to attach to the ECS task role"
  type        = list(string)
  default     = []
}

# Common AWS service access toggles
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

variable "enable_rds_access" {
  description = "Enable RDS data access for the ECS task role"
  type        = bool
  default     = false
}

variable "enable_secrets_manager_access" {
  description = "Enable Secrets Manager access for the ECS task role"
  type        = bool
  default     = false
}

variable "enable_parameter_store_access" {
  description = "Enable Parameter Store read access for the ECS task role"
  type        = bool
  default     = false
}

# Resource-specific access variables
variable "task_role_s3_bucket_arns" {
  description = "List of S3 bucket ARNs that the ECS task role should have access to"
  type        = list(string)
  default     = []
}

variable "task_role_sqs_queue_arns" {
  description = "List of SQS queue ARNs that the ECS task role should have access to"
  type        = list(string)
  default     = []
}

variable "task_role_dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs that the ECS task role should have access to"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Environment variables for the task"
  type        = any
}

variable "cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for the task"
  type        = string
  default     = "512"
}

variable "network_mode" {
  description = "Network mode for the task"
  type        = string
  default     = "awsvpc"
}

variable "launch_type" {
  description = "Launch type for the service"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "subnets" {
  description = "Subnets for the service"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups for the service"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

# ALB Configuration
variable "create_alb" {
  description = "Whether to create an Application Load Balancer"
  type        = bool
  default     = false
}

variable "alb_security_groups" {
  description = "Security groups for the ALB"
  type        = list(string)
  default     = []
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

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for the ALB target group"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive health checks required for healthy status"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks required for unhealthy status"
  type        = number
  default     = 5
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}

# Auto Scaling Configuration
variable "enable_autoscaling" {
  description = "Enable auto scaling for the ECS service"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 75
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
}

variable "scale_up_cooldown" {
  description = "Cooldown period in seconds for scale up actions"
  type        = number
  default     = 300
}

variable "scale_down_cooldown" {
  description = "Cooldown period in seconds for scale down actions"
  type        = number
  default     = 300
}

# CloudWatch Configuration
variable "enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 7
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = false
}

# Task Definition Configuration
variable "requires_compatibilities" {
  description = "Set of launch types required by the task"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "create_task_role" {
  description = "Whether to create a task role"
  type        = bool
  default     = true
}

variable "create_execution_role" {
  description = "Whether to create an execution role"
  type        = bool
  default     = true
}

variable "enable_efs" {
  description = "Enable EFS volume support"
  type        = bool
  default     = false
}

variable "efs_file_system_id" {
  description = "EFS file system ID"
  type        = string
  default     = ""
}

variable "efs_access_point_id" {
  description = "EFS access point ID"
  type        = string
  default     = ""
}

# EC2 Launch Type Configuration
variable "ec2_instance_type" {
  description = "EC2 instance type for ECS cluster when using EC2 launch type"
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
  default     = 2
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2 instances. If not provided, latest ECS-optimized AMI will be used"
  type        = string
  default     = ""
}

variable "user_data_script" {
  description = "Additional user data script to run on EC2 instances"
  type        = string
  default     = ""
}

variable "additional_user_data_commands" {
  description = "List of additional shell commands to append to the user data script"
  type        = list(string)
  default     = []
}

variable "custom_environment_variables" {
  description = "Map of custom environment variables to set in the user data script"
  type        = map(string)
  default     = {}
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = false
}

variable "ec2_volume_size" {
  description = "Root volume size for EC2 instances in GB"
  type        = number
  default     = 30
}

variable "ec2_volume_type" {
  description = "Root volume type for EC2 instances"
  type        = string
  default     = "gp3"
}

# EBS Data Volume Configuration
variable "enable_ebs_data_volume" {
  description = "Enable additional EBS data volume for persistent storage"
  type        = bool
  default     = false
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
  default     = null
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

variable "ebs_data_mount_point" {
  description = "Mount point for the EBS data volume"
  type        = string
  default     = "/data"
}

# Capacity Provider Configuration
variable "enable_capacity_provider" {
  description = "Enable capacity provider for the cluster"
  type        = bool
  default     = false
}

variable "capacity_provider_target_capacity" {
  description = "Target utilization for the capacity provider"
  type        = number
  default     = 100
}

variable "capacity_provider_maximum_scaling_step_size" {
  description = "Maximum step adjustment size for capacity provider"
  type        = number
  default     = 10
}

variable "capacity_provider_minimum_scaling_step_size" {
  description = "Minimum step adjustment size for capacity provider"
  type        = number
  default     = 1
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "Additional tags for the ECS cluster"
  type        = map(string)
  default     = {}
}

variable "service_tags" {
  description = "Additional tags for the ECS service"
  type        = map(string)
  default     = {}
}

# Additional IAM Configuration
variable "iam_instance_profile" {
  description = "Custom IAM instance profile ARN for EC2 instances. If not provided, one will be created"
  type        = string
  default     = null
}

variable "enable_ssm_patch_management" {
  description = "Enable SSM patch management for EC2 instances"
  type        = bool
  default     = true
}

variable "enforce_ssm_only" {
  description = "Enforce SSM-only access by denying SSH connections"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs access for EC2 instances"
  type        = bool
  default     = true
}

variable "create_task_execution_role" {
  description = "Whether to create a task execution role"
  type        = bool
  default     = true
}

variable "enable_task_ssm_access" {
  description = "Enable SSM access for ECS tasks"
  type        = bool
  default     = false
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

# Missing Core Variables
variable "container_insights" {
  description = "Enable container insights for the cluster"
  type        = bool
  default     = true
}

variable "task_family" {
  description = "Family name for the task definition"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "ARN of existing execution role to use instead of creating one"
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "ARN of existing task role to use instead of creating one"
  type        = string
  default     = null
}

variable "volumes" {
  description = "List of volumes to attach to the task definition"
  type        = list(any)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service (compatibility alias for subnets)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for the ECS service (compatibility alias for security_groups)"
  type        = list(string)
  default     = []
}

variable "create_ecs_security_group" {
  description = "Whether to create a security group for ECS tasks"
  type        = bool
  default     = true
}

variable "load_balancer_config" {
  description = "Load balancer configuration for the ECS service"
  type = object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  })
  default = null
}

variable "service_dependencies" {
  description = "List of resources the service depends on"
  type        = list(string)
  default     = []
}

# ASG Variables  
variable "asg_target_group_arns" {
  description = "List of target group ARNs for the Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "enable_spot_instances" {
  description = "Enable spot instances for the launch template"
  type        = bool
  default     = false
}

# Capacity Provider Variables
variable "max_scaling_step_size" {
  description = "Maximum step adjustment size for capacity provider"
  type        = number
  default     = 10
}

variable "min_scaling_step_size" {
  description = "Minimum step adjustment size for capacity provider"
  type        = number
  default     = 1
}

variable "target_capacity" {
  description = "Target utilization for the capacity provider"
  type        = number
  default     = 100
}

# Auto Scaling Variables
variable "max_capacity" {
  description = "Maximum capacity for auto scaling"
  type        = number
  default     = 10
}

variable "min_capacity" {
  description = "Minimum capacity for auto scaling"
  type        = number
  default     = 1
}

variable "scale_out_cooldown" {
  description = "Cooldown period in seconds for scale out actions"
  type        = number
  default     = 300
}

variable "scale_in_cooldown" {
  description = "Cooldown period in seconds for scale in actions"
  type        = number
  default     = 300
}

variable "enable_memory_scaling" {
  description = "Enable memory-based auto scaling"
  type        = bool
  default     = true
}

variable "enable_scheduled_scaling" {
  description = "Enable scheduled auto scaling"
  type        = bool
  default     = false
}

variable "night_scale_min_capacity" {
  description = "Minimum capacity for night scaling"
  type        = number
  default     = null
}

variable "night_scale_max_capacity" {
  description = "Maximum capacity for night scaling"
  type        = number
  default     = null
}

variable "night_scale_schedule" {
  description = "Schedule expression for night scaling"
  type        = string
  default     = "cron(0 22 * * ? *)"
}

variable "day_scale_min_capacity" {
  description = "Minimum capacity for day scaling"
  type        = number
  default     = null
}

variable "day_scale_max_capacity" {
  description = "Maximum capacity for day scaling"
  type        = number
  default     = null
}

variable "day_scale_schedule" {
  description = "Schedule expression for day scaling"
  type        = string
  default     = "cron(0 8 * * ? *)"
}

# Security Group Variables
variable "ecs_task_ingress_rules" {
  description = "List of ingress rules for ECS tasks security group"
  type = list(object({
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  default = []
}

variable "ecs_task_egress_rules" {
  description = "List of egress rules for ECS tasks security group"
  type = list(object({
    description                   = string
    from_port                     = number
    to_port                       = number
    protocol                      = string
    cidr_blocks                   = optional(list(string))
    destination_security_group_id = optional(string)
  }))
  default = []
}

variable "enable_default_ingress" {
  description = "Enable default ingress rule for container port"
  type        = bool
  default     = true
}

variable "default_ingress_cidr" {
  description = "CIDR block for default ingress rule"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allow_all_egress" {
  description = "Allow all egress traffic"
  type        = bool
  default     = true
}

variable "create_alb_security_group" {
  description = "Whether to create a security group for ALB"
  type        = bool
  default     = false
}

variable "enable_http" {
  description = "Enable HTTP access for ALB"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS access for ALB"
  type        = bool
  default     = true
}

variable "alb_ingress_rules" {
  description = "List of additional ingress rules for ALB security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "create_ec2_security_group" {
  description = "Whether to create a security group for EC2 instances"
  type        = bool
  default     = true
}

# Deployment Configuration Variables
variable "platform_version" {
  description = "Fargate platform version"
  type        = string
  default     = "LATEST"
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service"
  type        = string
  default     = "SERVICE"
  validation {
    condition     = contains(["TASK_DEFINITION", "SERVICE", "NONE"], var.propagate_tags)
    error_message = "propagate_tags must be one of: TASK_DEFINITION, SERVICE, NONE."
  }
}

variable "health_check_grace_period" {
  description = "Health check grace period for load balancer in seconds"
  type        = number
  default     = 60
}

variable "deployment_maximum_percent" {
  description = "Upper limit on the number of tasks in RUNNING state during deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit on the number of tasks in RUNNING state during deployment"
  type        = number
  default     = 100
}