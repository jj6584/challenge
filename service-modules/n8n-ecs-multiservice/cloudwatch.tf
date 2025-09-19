# ===================================================================
# CLOUDWATCH LOG GROUPS
# ===================================================================

# CloudWatch Log Groups for Services
resource "aws_cloudwatch_log_group" "n8n" {
  name              = "/ecs/${var.environment}-${var.project_name}-n8n"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "n8n_worker" {
  count             = var.enable_n8n_worker ? 1 : 0
  name              = "/ecs/${var.environment}-${var.project_name}-n8n-worker"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}


