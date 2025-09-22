terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  #Configure backend for state management (uncomment and configure as needed)
  backend "s3" {
    bucket = "challange-s3-tfstates"
    key    = "apps/production/apsea1/n8n-pioneerdev/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.aws_region

  # Role assumption configuration (optional)
  dynamic "assume_role" {
    for_each = var.assume_role_arn != null ? [1] : []
    content {
      role_arn     = var.assume_role_arn
      session_name = var.assume_role_session_name
      external_id  = var.assume_role_external_id
    }
  }

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      Application = "n8n"
      Region      = var.aws_region
    }
  }
}

# =============================================================================
# DATA SOURCES
# =============================================================================

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Data source for the hosted zone
data "aws_route53_zone" "main" {
  name         = "joshuamanaol.com"
  private_zone = false
}

# =============================================================================
# LOCALS
# =============================================================================

locals {
  # VPC and subnet configuration - using values from terraform.tfvars
  vpc_id             = var.vpc_id
  private_subnet_ids = var.subnet_ids  # Assuming these are private subnets for database
}

# =============================================================================
# SECURITY GROUPS
# =============================================================================

# Security groups will be created by the ECS module

# =============================================================================
# ROUTE53 DNS RECORD
# =============================================================================

# CNAME record pointing n8n.joshuamanaol.com to the ALB
resource "aws_route53_record" "n8n" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "n8n.joshuamanaol.com"
  type    = "CNAME"
  ttl     = 300
  records = [module.n8n_ecs_service.load_balancer_dns_name]

  depends_on = [module.n8n_ecs_service]
}

# =============================================================================
# N8N SERVICE MODULE DEPLOYMENT
# =============================================================================

module "n8n_ecs_service" {
  source = "../../../../service-modules/n8n-ecs-simple"

  # Cluster Configuration
  cluster_name = "prod-n8n-pioneer"  # Short name to avoid ALB 32-char limit

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # EC2 Configuration
  ec2_instance_type    = var.ec2_instance_type
  ec2_min_size         = var.ec2_min_size
  ec2_max_size         = var.ec2_max_size
  ec2_desired_capacity = var.ec2_desired_capacity

  # N8N Service Configuration
  desired_count = var.desired_count
  n8n_cpu       = tonumber(var.task_cpu)
  n8n_memory    = tonumber(var.task_memory)

  # N8N Application Configuration
  n8n_host                 = var.n8n_host
  n8n_protocol             = var.n8n_protocol
  webhook_url              = var.webhook_url
  generic_timezone         = var.generic_timezone
  n8n_basic_auth_active    = var.n8n_basic_auth_active
  n8n_basic_auth_user      = var.n8n_basic_auth_user

  # Database Configuration
  postgres_host     = module.n8n_database.db_instance_address
  postgres_port     = 5432
  postgres_database = var.postgres_db
  postgres_user     = var.postgres_user
  postgres_password_ssm_parameter = module.n8n_database.parameter_store_password_arn

  # Redis Configuration (Upstash)
  upstash_redis_host = var.upstash_redis_host
  upstash_redis_port = var.upstash_redis_port
  redis_url_ssm_parameter = var.redis_url_ssm_parameter

  # Authentication
  n8n_basic_auth_password_ssm_parameter = aws_ssm_parameter.n8n_basic_auth_password.name
  n8n_encryption_key_ssm_parameter      = length(aws_ssm_parameter.n8n_encryption_key) > 0 ? aws_ssm_parameter.n8n_encryption_key[0].name : ""

  # Load Balancer Configuration
  load_balancer_internal = false
  enable_http_listener   = var.enable_http_listener
  enable_https_listener  = var.enable_https_listener
  http_port              = var.http_port
  https_port             = var.https_port

  # SSL Configuration
  ssl_certificate_arn     = var.ssl_certificate_arn
  certificate_domain_name = var.certificate_domain_name
  certificate_validation_method = var.certificate_validation_method

  # Secrets configuration
  task_secrets_arns = [
    aws_ssm_parameter.n8n_basic_auth_password.arn,
    aws_ssm_parameter.workflow_health_token.arn,
    aws_ssm_parameter.n8n_encryption_key[0].arn,
    module.n8n_database.parameter_store_password_arn
  ]

  # CloudWatch Logging
  log_retention_days = var.log_retention_days

  # Tags
  tags = var.tags
}
