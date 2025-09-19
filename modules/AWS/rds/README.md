# AWS RDS Module

This Terraform module creates an AWS RDS instance with single-AZ deployment for cost optimization. It supports various database engines and provides comprehensive configuration options.

## Features

- ✅ **Single Instance, Single AZ** - Cost-optimized deployment
- ✅ **Multiple Database Engines** - PostgreSQL, MySQL, MariaDB, Oracle, SQL Server
- ✅ **Security Groups** - Automated security group creation with customizable access rules
- ✅ **Subnet Groups** - Automated DB subnet group creation
- ✅ **Parameter Groups** - Optional custom parameter group creation
- ✅ **Backup Configuration** - Configurable backup retention and maintenance windows
- ✅ **Monitoring** - Enhanced monitoring and Performance Insights support
- ✅ **Encryption** - Storage encryption with optional KMS key
- ✅ **Auto Password Generation** - Secure random password generation
- ✅ **CloudWatch Logs** - Export database logs to CloudWatch

## Usage

### Basic PostgreSQL Instance

```hcl
module "rds" {
  source = "./modules/AWS/rds"

  identifier = "my-app-db"
  
  # Network Configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  allowed_security_groups = [module.app.security_group_id]
  
  # Database Configuration
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  db_name        = "myapp"
  username       = "admin"
  
  # Storage Configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  
  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

### MySQL with Custom Parameter Group

```hcl
module "rds_mysql" {
  source = "./modules/AWS/rds"

  identifier = "mysql-db"
  
  # Database Configuration
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.small"
  port           = 3306
  
  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]
  
  # Custom Parameter Group
  create_parameter_group = true
  parameter_group_family = "mysql8.0"
  parameter_group_name   = "mysql-custom-params"
  parameters = [
    {
      name  = "innodb_buffer_pool_size"
      value = "{DBInstanceClassMemory*3/4}"
    },
    {
      name  = "max_connections"
      value = "200"
    }
  ]
  
  # Enhanced Monitoring
  monitoring_interval = 60
  performance_insights_enabled = true
  
  tags = var.tags
}
```

### High Availability Configuration

```hcl
module "rds_ha" {
  source = "./modules/AWS/rds"

  identifier = "prod-db"
  
  # High-performance configuration
  engine           = "postgres"
  engine_version   = "15.4"
  instance_class   = "db.r6g.large"
  allocated_storage = 100
  storage_type     = "gp3"
  
  # Network Configuration
  vpc_id                = var.vpc_id
  subnet_ids           = var.database_subnet_ids
  allowed_security_groups = [var.app_security_group_id]
  
  # Backup and Maintenance
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  deletion_protection    = true
  
  # Monitoring and Logging
  monitoring_interval           = 60
  performance_insights_enabled = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  tags = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identifier | Unique identifier for the RDS instance | `string` | n/a | yes |
| vpc_id | VPC ID where the RDS instance will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the DB subnet group | `list(string)` | n/a | yes |
| engine | Database engine type | `string` | `"postgres"` | no |
| engine_version | Database engine version | `string` | `"15.4"` | no |
| instance_class | RDS instance class | `string` | `"db.t3.micro"` | no |
| allocated_storage | Initial allocated storage in GB | `number` | `20` | no |
| max_allocated_storage | Maximum allocated storage for autoscaling in GB | `number` | `100` | no |
| storage_type | Storage type for the RDS instance | `string` | `"gp3"` | no |
| storage_encrypted | Enable storage encryption | `bool` | `true` | no |
| db_name | Name of the database to create | `string` | `null` | no |
| username | Master username for the database | `string` | `"admin"` | no |
| master_password | Master password for the database | `string` | `null` | no |
| port | Database port | `number` | `5432` | no |
| publicly_accessible | Make the RDS instance publicly accessible | `bool` | `false` | no |
| allowed_security_groups | List of security group IDs allowed to access the database | `list(string)` | `[]` | no |
| allowed_cidr_blocks | List of CIDR blocks allowed to access the database | `list(string)` | `[]` | no |
| backup_retention_period | Number of days to retain backups | `number` | `7` | no |
| deletion_protection | Enable deletion protection | `bool` | `true` | no |
| store_password_in_parameter_store | Store the generated master password in Parameter Store | `bool` | `true` | no |
| parameter_store_password_name | Parameter Store name for the master password | `string` | `null` | no |
| parameter_store_kms_key_id | KMS key ID for Parameter Store encryption | `string` | `null` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_endpoint | RDS instance endpoint |
| db_instance_address | RDS instance hostname |
| db_instance_port | RDS instance port |
| db_instance_username | RDS instance master username |
| db_instance_password | RDS instance master password |
| db_instance_db_name | RDS instance database name |
| security_group_id | Security group ID for the RDS instance |
| connection_string | Database connection string |
| connection_info | Database connection information object |
| parameter_store_password_name | Parameter Store name where the password is stored |
| parameter_store_password_arn | Parameter Store ARN where the password is stored |
| password_stored_in_parameter_store | Whether the password is stored in Parameter Store |

## Supported Database Engines

- **PostgreSQL** (default) - Versions 11.x, 12.x, 13.x, 14.x, 15.x
- **MySQL** - Versions 5.7.x, 8.0.x
- **MariaDB** - Versions 10.4.x, 10.5.x, 10.6.x
- **Oracle** - Enterprise Edition, Standard Edition
- **SQL Server** - Express, Web, Standard, Enterprise

## Security Considerations

1. **Network Security**: RDS instance is deployed in private subnets by default
2. **Access Control**: Security groups restrict access to specified sources
3. **Encryption**: Storage encryption is enabled by default
4. **Password Management**: Automatic secure password generation and storage in Parameter Store
5. **Deletion Protection**: Enabled by default to prevent accidental deletion

## Password Management

The module provides secure password management with the following features:

- **Auto-Generation**: Secure random passwords (16 characters with special chars)
- **Parameter Store**: Generated passwords are automatically stored in AWS Parameter Store
- **Encryption**: Parameter Store values are encrypted using KMS
- **Access Control**: Parameter Store access controlled via IAM policies

### Password Storage Configuration

```hcl
module "rds" {
  source = "./modules/AWS/rds"
  
  # ... other configuration ...
  
  # Password management (enabled by default)
  manage_master_user_password = true
  store_password_in_parameter_store = true
  
  # Optional: Custom parameter name
  parameter_store_password_name = "/myapp/database/password"
  
  # Optional: Custom KMS key for parameter encryption
  parameter_store_kms_key_id = aws_kms_key.database.key_id
}
```

### Retrieving Passwords

```bash
# Get password from Parameter Store
aws ssm get-parameter --name "/rds/my-app-db/master-password" --with-decryption --query 'Parameter.Value' --output text

# Or use in another Terraform configuration
data "aws_ssm_parameter" "db_password" {
  name = module.rds.parameter_store_password_name
}
```

## Cost Optimization

- **Single-AZ Deployment**: Reduces costs compared to Multi-AZ
- **Right-sizing**: Start with smaller instance classes (db.t3.micro)
- **Storage Autoscaling**: Automatic storage scaling prevents over-provisioning
- **Backup Retention**: Configurable retention period

## Examples

See the `examples/` directory for complete usage examples:

- `examples/basic/` - Basic PostgreSQL setup
- `examples/mysql/` - MySQL with custom configuration
- `examples/production/` - Production-ready setup with monitoring

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- VPC with at least 2 subnets in different AZs

## License

MIT License