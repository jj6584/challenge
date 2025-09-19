# RDS Instance Module
# Single Instance, Single AZ deployment for cost optimization

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name != null ? var.db_subnet_group_name : "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = var.db_subnet_group_name != null ? var.db_subnet_group_name : "${var.identifier}-subnet-group"
  })
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  count  = var.create_parameter_group ? 1 : 0
  family = var.parameter_group_family
  name   = var.parameter_group_name

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.identifier}-rds-"
  description = "Security group for ${var.identifier} RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database access"
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    cidr_blocks     = var.vpc_cidr_block != null ? concat(var.allowed_cidr_blocks, [var.vpc_cidr_block]) : var.allowed_cidr_blocks
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-rds-sg"
  })
}

# Random password for master user (if not provided)
resource "random_password" "master_password" {
  count   = var.manage_master_user_password && var.master_password == null ? 1 : 0
  length  = 16
  special = true
}

# Store password in Parameter Store (if enabled and password is generated)
resource "aws_ssm_parameter" "master_password" {
  count = var.store_password_in_parameter_store && var.manage_master_user_password && var.master_password == null ? 1 : 0

  name  = var.parameter_store_password_name != null ? var.parameter_store_password_name : "/rds/${var.identifier}/master-password"
  type  = "SecureString"
  value = random_password.master_password[0].result

  key_id = var.parameter_store_kms_key_id

  description = "Master password for RDS instance ${var.identifier}"

  tags = merge(var.tags, {
    Name        = "${var.identifier}-master-password"
    RDSInstance = var.identifier
    Type        = "Database Password"
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = var.identifier

  # Engine configuration
  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  # Database configuration
  db_name  = var.db_name
  username = var.username
  password = var.manage_master_user_password ? (
    var.master_password != null ? var.master_password : random_password.master_password[0].result
  ) : var.master_password
  port = var.port

  # Network & Security
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = var.publicly_accessible
  availability_zone      = var.availability_zone

  # Parameter and option groups
  parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.main[0].name : var.parameter_group_name
  option_group_name    = var.option_group_name

  # Backup configuration
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  # Deletion protection
  deletion_protection = var.deletion_protection

  # Auto minor version upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Apply changes immediately
  apply_immediately = var.apply_immediately

  # Enable CloudWatch logs exports
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = merge(var.tags, {
    Name = var.identifier
  })

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    update = var.timeouts.update
  }

  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier,
    ]
  }
}