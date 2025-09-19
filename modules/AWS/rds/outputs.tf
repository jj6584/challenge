# RDS Instance Outputs
output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.identifier
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "RDS instance hosted zone ID"
  value       = aws_db_instance.main.hosted_zone_id
}

output "db_instance_address" {
  description = "RDS instance hostname"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_engine" {
  description = "RDS instance engine"
  value       = aws_db_instance.main.engine
}

output "db_instance_engine_version_actual" {
  description = "RDS instance engine version (actual)"
  value       = aws_db_instance.main.engine_version_actual
}

output "db_instance_status" {
  description = "RDS instance status"
  value       = aws_db_instance.main.status
}

output "db_instance_availability_zone" {
  description = "RDS instance availability zone"
  value       = aws_db_instance.main.availability_zone
}

output "db_instance_backup_retention_period" {
  description = "RDS instance backup retention period"
  value       = aws_db_instance.main.backup_retention_period
}

output "db_instance_backup_window" {
  description = "RDS instance backup window"
  value       = aws_db_instance.main.backup_window
}

output "db_instance_maintenance_window" {
  description = "RDS instance maintenance window"
  value       = aws_db_instance.main.maintenance_window
}

output "db_instance_username" {
  description = "RDS instance master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_password" {
  description = "RDS instance master password"
  value = var.manage_master_user_password ? (
    var.master_password != null ? var.master_password : try(random_password.master_password[0].result, null)
  ) : var.master_password
  sensitive = true
}

output "db_instance_db_name" {
  description = "RDS instance database name"
  value       = aws_db_instance.main.db_name
}

# Security Group Outputs
output "security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = aws_security_group.rds.id
}

output "security_group_arn" {
  description = "Security group ARN for the RDS instance"
  value       = aws_security_group.rds.arn
}

# Subnet Group Outputs
output "db_subnet_group_id" {
  description = "DB subnet group ID"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "DB subnet group ARN"
  value       = aws_db_subnet_group.main.arn
}

# Parameter Group Outputs
output "parameter_group_id" {
  description = "Parameter group ID"
  value       = var.create_parameter_group ? aws_db_parameter_group.main[0].id : null
}

output "parameter_group_arn" {
  description = "Parameter group ARN"
  value       = var.create_parameter_group ? aws_db_parameter_group.main[0].arn : null
}

# Connection Information
output "connection_string" {
  description = "Database connection string"
  value = format(
    "%s://%s:%s@%s:%s/%s",
    var.engine == "postgres" ? "postgresql" : var.engine,
    aws_db_instance.main.username,
    var.manage_master_user_password ? (
      var.master_password != null ? var.master_password : try(random_password.master_password[0].result, "<password>")
    ) : var.master_password != null ? var.master_password : "<password>",
    aws_db_instance.main.address,
    aws_db_instance.main.port,
    aws_db_instance.main.db_name != null ? aws_db_instance.main.db_name : ""
  )
  sensitive = true
}

output "connection_info" {
  description = "Database connection information"
  value = {
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    database = aws_db_instance.main.db_name
    username = aws_db_instance.main.username
  }
}

# Parameter Store Outputs
output "parameter_store_password_name" {
  description = "Parameter Store name where the master password is stored"
  value = var.store_password_in_parameter_store && var.manage_master_user_password && var.master_password == null ? (
    var.parameter_store_password_name != null ? var.parameter_store_password_name : "/rds/${var.identifier}/master-password"
  ) : null
}

output "parameter_store_password_arn" {
  description = "Parameter Store ARN where the master password is stored"
  value = var.store_password_in_parameter_store && var.manage_master_user_password && var.master_password == null ? (
    try(aws_ssm_parameter.master_password[0].arn, null)
  ) : null
}

output "password_stored_in_parameter_store" {
  description = "Whether the password is stored in Parameter Store"
  value       = var.store_password_in_parameter_store && var.manage_master_user_password && var.master_password == null
}