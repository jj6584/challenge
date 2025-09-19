# ===================================================================
# ECS TASK SECURITY GROUP (for Fargate and EC2 with awsvpc mode)
# ========================# Egress rules for load balancer to ECS tasks
resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  count = (var.create_alb_security_group || (local.create_load_balancer && var.load_balancer_type == "application" && length(var.load_balancer_security_groups) == 0)) && var.vpc_id != null && var.create_ecs_security_group ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "Traffic from load balancer to ECS tasks"

  from_port                    = local.target_group_port
  to_port                      = local.target_group_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_tasks[0].id

  tags = var.tags
}

# ===================================================================
# ECS TASKS SECURITY GROUP
# ===================================================================

# Security Group for ECS Tasks - Always created when VPC ID is provided
resource "aws_security_group" "ecs_tasks" {
  count       = var.vpc_id != null && var.create_ecs_security_group ? 1 : 0
  name        = "${var.cluster_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks in ${var.cluster_name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-ecs-tasks-sg"
    Type = "ECS-Tasks"
  })
}

# Ingress rules for ECS tasks
resource "aws_vpc_security_group_ingress_rule" "ecs_tasks_ingress" {
  count = var.vpc_id != null && var.create_ecs_security_group ? length(var.ecs_task_ingress_rules) : 0

  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = var.ecs_task_ingress_rules[count.index].description

  from_port   = var.ecs_task_ingress_rules[count.index].from_port
  to_port     = var.ecs_task_ingress_rules[count.index].to_port
  ip_protocol = var.ecs_task_ingress_rules[count.index].protocol

  # Handle different source types
  cidr_ipv4                    = lookup(var.ecs_task_ingress_rules[count.index], "cidr_blocks", null) != null ? var.ecs_task_ingress_rules[count.index].cidr_blocks[0] : null
  referenced_security_group_id = lookup(var.ecs_task_ingress_rules[count.index], "source_security_group_id", null)

  tags = var.tags
}

# Default ingress rule for container port (when no custom rules and no load balancer)
resource "aws_vpc_security_group_ingress_rule" "ecs_tasks_default_ingress" {
  count = var.vpc_id != null && var.create_ecs_security_group && length(var.ecs_task_ingress_rules) == 0 && !local.create_load_balancer && var.enable_default_ingress ? 1 : 0

  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = "Default access to container port"

  from_port   = var.container_port
  to_port     = var.container_port
  ip_protocol = "tcp"
  cidr_ipv4   = var.default_ingress_cidr

  tags = var.tags
}

# Ingress rule from load balancer to ECS tasks
resource "aws_vpc_security_group_ingress_rule" "ecs_tasks_from_lb" {
  count = var.vpc_id != null && var.create_ecs_security_group && local.create_load_balancer && var.load_balancer_type == "application" ? 1 : 0

  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = "Access from load balancer"

  from_port   = local.target_group_port
  to_port     = local.target_group_port
  ip_protocol = "tcp"

  # Reference the ALB security group
  referenced_security_group_id = length(local.load_balancer_security_groups) > 0 ? local.load_balancer_security_groups[0] : null

  tags = var.tags
}

# Egress rules for ECS tasks (allow all outbound by default)
resource "aws_vpc_security_group_egress_rule" "ecs_tasks_egress_all" {
  count = var.vpc_id != null && var.create_ecs_security_group && var.allow_all_egress ? 1 : 0

  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = "Allow all outbound traffic"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = var.tags
}

# Custom egress rules for ECS tasks
resource "aws_vpc_security_group_egress_rule" "ecs_tasks_egress_custom" {
  count = var.vpc_id != null && var.create_ecs_security_group && !var.allow_all_egress ? length(var.ecs_task_egress_rules) : 0

  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = var.ecs_task_egress_rules[count.index].description

  from_port   = var.ecs_task_egress_rules[count.index].from_port
  to_port     = var.ecs_task_egress_rules[count.index].to_port
  ip_protocol = var.ecs_task_egress_rules[count.index].protocol

  # Handle different destination types
  cidr_ipv4                    = lookup(var.ecs_task_egress_rules[count.index], "cidr_blocks", null) != null ? var.ecs_task_egress_rules[count.index].cidr_blocks[0] : null
  referenced_security_group_id = lookup(var.ecs_task_egress_rules[count.index], "destination_security_group_id", null)

  tags = var.tags
}

# ===================================================================
# LOAD BALANCER SECURITY GROUP (ALB/NLB)
# ===================================================================

# Security Group for Load Balancer (ALB only - NLB doesn't use security groups)
resource "aws_security_group" "alb" {
  count       = var.create_alb_security_group || (local.create_load_balancer && var.load_balancer_type == "application" && length(var.load_balancer_security_groups) == 0) ? 1 : 0
  name        = "${var.cluster_name}-lb-sg"
  description = "Security group for ${upper(var.load_balancer_type)} in ${var.cluster_name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-lb-sg"
    Type = upper(var.load_balancer_type)
  })
}

# HTTP ingress rule for ALB
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  count = (var.create_alb_security_group || (local.create_load_balancer && var.load_balancer_type == "application" && length(var.load_balancer_security_groups) == 0)) && var.enable_http_listener ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "HTTP traffic from internet"

  from_port   = var.http_port
  to_port     = var.http_port
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = var.tags
}

# HTTPS ingress rule for ALB  
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count = (var.create_alb_security_group || (local.create_load_balancer && var.load_balancer_type == "application" && length(var.load_balancer_security_groups) == 0)) && var.enable_https_listener ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "HTTPS traffic from internet"

  from_port   = var.https_port
  to_port     = var.https_port
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = var.tags
}

# Custom ingress rules for ALB
resource "aws_vpc_security_group_ingress_rule" "alb_custom_ingress" {
  count = var.create_alb_security_group ? length(var.alb_ingress_rules) : 0

  security_group_id = aws_security_group.alb[0].id
  description       = var.alb_ingress_rules[count.index].description

  from_port   = var.alb_ingress_rules[count.index].from_port
  to_port     = var.alb_ingress_rules[count.index].to_port
  ip_protocol = var.alb_ingress_rules[count.index].protocol

  cidr_ipv4 = var.alb_ingress_rules[count.index].cidr_blocks[0]

  tags = var.tags
}

# Egress rules for ALB to ECS tasks
resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_tasks" {
  count = var.create_alb_security_group && var.vpc_id != null && var.create_ecs_security_group ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "Traffic from ALB to ECS tasks"

  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_tasks[0].id

  tags = var.tags
}

# Egress rules for ALB to EC2 instances (for bridge mode)
resource "aws_vpc_security_group_egress_rule" "alb_to_ec2_instances" {
  count = var.launch_type[0] == "EC2" && var.create_alb_security_group && var.create_ec2_security_group ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "Traffic from ALB to EC2 instances for bridge mode"

  from_port                    = 32768
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2_instances[0].id

  tags = var.tags
}

# Ingress rule for ECS tasks from ALB (automatically created when both SGs exist)
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  count = var.create_alb_security_group && var.vpc_id != null && var.create_ecs_security_group ? 1 : 0

  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = "Traffic from ALB to ECS tasks"

  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb[0].id

  tags = var.tags
}

# ===================================================================
# EC2 SECURITY GROUP (for EC2 launch type)
# ===================================================================

# Security Group for EC2 instances (when using EC2 launch type)
resource "aws_security_group" "ec2_instances" {
  count       = var.launch_type[0] == "EC2" && var.create_ec2_security_group ? 1 : 0
  name        = "${var.cluster_name}-ec2-instances-sg"
  description = "Security group for EC2 instances in ECS cluster ${var.cluster_name} - SSM access only"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name   = "${var.cluster_name}-ec2-instances-sg"
    Type   = "EC2-Instances"
    Access = "SSM-Only"
  })
}

# NO SSH ACCESS - All access via SSM Session Manager
# SSH port 22 is intentionally NOT opened for security

# Dynamic port range for ECS agent communication
resource "aws_vpc_security_group_ingress_rule" "ec2_dynamic_ports" {
  count = var.launch_type[0] == "EC2" && var.create_ec2_security_group && var.create_alb_security_group ? 1 : 0

  security_group_id = aws_security_group.ec2_instances[0].id
  description       = "Dynamic ports for ECS tasks from ALB"

  from_port                    = 32768
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb[0].id

  tags = var.tags
}

# HTTPS outbound for SSM communication (required for Session Manager)
resource "aws_vpc_security_group_egress_rule" "ec2_ssm_https" {
  count = var.launch_type[0] == "EC2" && var.create_ec2_security_group && !var.allow_all_egress ? 1 : 0

  security_group_id = aws_security_group.ec2_instances[0].id
  description       = "HTTPS for SSM Session Manager communication"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = var.tags
}

# All outbound traffic for EC2 instances (when allow_all_egress is true)
resource "aws_vpc_security_group_egress_rule" "ec2_egress_all" {
  count = var.launch_type[0] == "EC2" && var.create_ec2_security_group && var.allow_all_egress ? 1 : 0

  security_group_id = aws_security_group.ec2_instances[0].id
  description       = "Allow all outbound traffic (includes SSM communication)"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = var.tags
}