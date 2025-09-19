# SSM Parameter Store for N8N Configuration

# Sensitive parameters (SecureString type for encryption)
resource "aws_ssm_parameter" "n8n_basic_auth_password" {
  name  = "/${var.environment}/n8n/auth/password"
  type  = "SecureString"
  value = var.n8n_basic_auth_password

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "sensitive"
  }
}

resource "aws_ssm_parameter" "workflow_health_token" {
  name  = "/${var.environment}/n8n/health/token"
  type  = "SecureString"
  value = var.workflow_health_token

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "sensitive"
  }
}

resource "aws_ssm_parameter" "n8n_encryption_key" {
  count = var.n8n_encryption_key != "" ? 1 : 0
  name  = "/${var.environment}/n8n/encryption/key"
  type  = "SecureString"
  value = var.n8n_encryption_key

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "sensitive"
  }
}

# SMTP Configuration (sensitive)
resource "aws_ssm_parameter" "smtp_password" {
  count = var.smtp_password != "" ? 1 : 0
  name  = "/${var.environment}/n8n/smtp/password"
  type  = "SecureString"
  value = var.smtp_password

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "sensitive"
  }
}

resource "aws_ssm_parameter" "oauth_google_secret" {
  count = var.oauth_google_secret != "" ? 1 : 0
  name  = "/${var.environment}/n8n/oauth/google/secret"
  type  = "SecureString"
  value = var.oauth_google_secret

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "sensitive"
  }
}

# Non-sensitive configuration parameters (String type)
resource "aws_ssm_parameter" "n8n_host" {
  name  = "/${var.environment}/n8n/host"
  type  = "String"
  value = var.n8n_host

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "n8n_protocol" {
  name  = "/${var.environment}/n8n/protocol"
  type  = "String"
  value = var.n8n_protocol

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "webhook_url" {
  name  = "/${var.environment}/n8n/webhook_url"
  type  = "String"
  value = var.webhook_url

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "generic_timezone" {
  name  = "/${var.environment}/n8n/timezone"
  type  = "String"
  value = var.generic_timezone

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "n8n_basic_auth_active" {
  name  = "/${var.environment}/n8n/auth/active"
  type  = "String"
  value = var.n8n_basic_auth_active

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "n8n_basic_auth_user" {
  name  = "/${var.environment}/n8n/auth/user"
  type  = "String"
  value = var.n8n_basic_auth_user

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "n8n_executions_mode" {
  name  = "/${var.environment}/n8n/executions/mode"
  type  = "String"
  value = var.n8n_executions_mode

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "n8n_log_level" {
  name  = "/${var.environment}/n8n/log/level"
  type  = "String"
  value = var.n8n_log_level

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

# Database configuration parameters
# SMTP Configuration (non-sensitive)
resource "aws_ssm_parameter" "smtp_host" {
  count = var.smtp_host != "" ? 1 : 0
  name  = "/${var.environment}/n8n/smtp/host"
  type  = "String"
  value = var.smtp_host

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "smtp_port" {
  count = var.smtp_port != "" ? 1 : 0
  name  = "/${var.environment}/n8n/smtp/port"
  type  = "String"
  value = var.smtp_port

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "smtp_user" {
  count = var.smtp_user != "" ? 1 : 0
  name  = "/${var.environment}/n8n/smtp/user"
  type  = "String"
  value = var.smtp_user

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}

resource "aws_ssm_parameter" "oauth_google_id" {
  count = var.oauth_google_id != "" ? 1 : 0
  name  = "/${var.environment}/n8n/oauth/google/id"
  type  = "String"
  value = var.oauth_google_id

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Type        = "config"
  }
}