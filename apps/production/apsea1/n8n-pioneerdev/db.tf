# =============================================================================
# RDS DATABASE CONFIGURATION FOR N8N
# =============================================================================

# Get subnet information for database subnet group
data "aws_subnet" "database_subnets" {
  count = length(local.private_subnet_ids)
  id    = local.private_subnet_ids[count.index]
}

# Get VPC information to retrieve CIDR block
data "aws_vpc" "main" {
  id = local.vpc_id
}

# Get availability zones for database subnet group
data "aws_availability_zones" "available" {
  state = "available"
}

# Check if we have subnets in at least 2 AZs
locals {
  subnet_azs              = distinct([for subnet in data.aws_subnet.database_subnets : subnet.availability_zone])
  needs_additional_subnet = length(local.subnet_azs) < 2

  # Get first available AZ that's not already used
  available_az = local.needs_additional_subnet ? [
    for az in data.aws_availability_zones.available.names : az
    if !contains(local.subnet_azs, az)
  ][0] : null
}

# Create additional subnet if needed (RDS requires subnets in at least 2 AZs)
resource "aws_subnet" "additional_db_subnet" {
  count             = local.needs_additional_subnet ? 1 : 0
  vpc_id            = local.vpc_id
  cidr_block        = "172.31.200.0/24" # Using different CIDR range to avoid conflicts
  availability_zone = local.available_az

  tags = {
    Name        = "${var.environment}-${var.project_name}-db-additional"
    Type        = "database"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "rds-subnet-group"
  }
}

# Combine existing and additional subnets for DB subnet group
locals {
  db_subnet_ids = local.needs_additional_subnet ? concat(local.private_subnet_ids, aws_subnet.additional_db_subnet[*].id) : local.private_subnet_ids
}

# N8N PostgreSQL Database using our RDS module
module "n8n_database" {
  source = "../../../../modules/AWS/rds"

  # Basic Configuration
  identifier = "${var.environment}-${var.project_name}-postgres"

  # Network Configuration
  vpc_id                  = local.vpc_id
  subnet_ids              = local.db_subnet_ids
  allowed_security_groups = [module.n8n_ecs_service.ec2_instances_security_group_id]  # Direct access from EC2 instances
  vpc_cidr_block          = data.aws_vpc.main.cidr_block

  # Database Engine Configuration
  engine         = "postgres"
  engine_version = "17.4"
  instance_class = "db.t3.micro" # Cost-effective for development/testing
  db_name        = var.postgres_db
  username       = var.postgres_user
  port           = 5432

  # Storage Configuration
  allocated_storage     = 20  # 20 GB initial storage
  max_allocated_storage = 100 # Auto-scale up to 100 GB
  storage_type          = "gp3"
  storage_encrypted     = true

  # Password Management - Auto-generated and stored in Parameter Store
  manage_master_user_password       = true
  store_password_in_parameter_store = true
  parameter_store_password_name     = "/${var.environment}/${var.project_name}/database/postgres/master-password"

  # Backup Configuration
  backup_retention_period = 7                     # 7 days backup retention
  backup_window           = "03:00-04:00"         # UTC time (11 AM - 12 PM SGT)
  maintenance_window      = "sun:04:00-sun:05:00" # UTC time (12 PM - 1 PM SGT on Sunday)

  # High Availability (disabled for cost optimization)
  skip_final_snapshot = false # Create final snapshot for safety
  deletion_protection = true  # Prevent accidental deletion

  # Performance and Monitoring
  monitoring_interval             = 0     # Disabled for cost optimization
  performance_insights_enabled    = false # Disabled for cost optimization
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Security Configuration
  auto_minor_version_upgrade = true # Allow automatic minor version updates
  copy_tags_to_snapshot      = true

  # Parameter Group for performance tuning
  parameter_group_family = "postgres17"
  parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000" # Log queries taking more than 1 second
    },
    {
      name  = "max_connections"
      value = "100"
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Application = "n8n"
    Database    = "postgresql"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
    Backup      = "automated"
    Region      = var.aws_region
  }
}

# Create read-only user password in Parameter Store (example for additional database users)
resource "random_password" "n8n_readonly_user" {
  length  = 16
  special = true

  lifecycle {
    ignore_changes = [length, special]
  }
}

resource "aws_ssm_parameter" "n8n_readonly_password" {
  name        = "/${var.environment}/${var.project_name}/database/postgres/readonly-password"
  description = "Password for N8N read-only database user"
  type        = "SecureString"
  value       = random_password.n8n_readonly_user.result

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "database-access"
    UserType    = "readonly"
  }
}



# Output connection information for use in other resources
output "database_connection_info" {
  description = "Database connection information for N8N"
  value = {
    endpoint = module.n8n_database.db_instance_endpoint
    address  = module.n8n_database.db_instance_address
    port     = module.n8n_database.db_instance_port
    database = module.n8n_database.db_instance_db_name
    username = module.n8n_database.db_instance_username
  }
  sensitive = true
}

output "database_security_group_id" {
  description = "Security group ID for the database"
  value       = module.n8n_database.security_group_id
}

output "database_parameter_store_info" {
  description = "Parameter Store information for database credentials"
  value = {
    master_password_parameter   = module.n8n_database.parameter_store_password_name
    master_password_arn         = module.n8n_database.parameter_store_password_arn
    readonly_password_parameter = aws_ssm_parameter.n8n_readonly_password.name
    readonly_password_arn       = aws_ssm_parameter.n8n_readonly_password.arn
  }
}



# Example of how to use the database password in application configuration
# This shows the pattern but would typically be used in your application deployment
locals {
  example_n8n_database_config = {
    DB_TYPE                = "postgresdb"
    DB_POSTGRESDB_HOST     = module.n8n_database.db_instance_address
    DB_POSTGRESDB_PORT     = tostring(module.n8n_database.db_instance_port)
    DB_POSTGRESDB_DATABASE = module.n8n_database.db_instance_db_name
    DB_POSTGRESDB_USER     = module.n8n_database.db_instance_username
    # Password would be retrieved from Parameter Store in your application
    # DB_POSTGRESDB_PASSWORD = "Retrieved from Parameter Store"
  }
}
