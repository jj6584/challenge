# ===================================================================
# LOAD BALANCER RESOURCES
# ===================================================================

# ===================================================================
# ACM CERTIFICATE MANAGEMENT
# ===================================================================

# Data source to look up existing ACM certificate by domain name
data "aws_acm_certificate" "main" {
  count = local.create_load_balancer && var.enable_https_listener && var.ssl_certificate_arn == "" && var.certificate_domain_name != "" && !var.create_acm_certificate ? 1 : 0

  domain      = var.certificate_domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
  statuses    = ["ISSUED"]

  # Support for additional subject alternative names
  key_types = ["RSA_2048"]
}

# Optional: Create new ACM certificate if requested and none found
resource "aws_acm_certificate" "main" {
  count = local.create_load_balancer && var.enable_https_listener && var.create_acm_certificate && var.certificate_domain_name != "" ? 1 : 0

  domain_name               = var.certificate_domain_name
  subject_alternative_names = var.additional_certificate_subject_alternative_names
  validation_method         = var.certificate_validation_method

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, var.acm_certificate_tags, {
    Name        = "${var.certificate_domain_name}-cert"
    Environment = lookup(var.tags, "Environment", "unknown")
    Domain      = var.certificate_domain_name
    ManagedBy   = "terraform"
  })
}

# Local logic to determine which certificate ARN to use
locals {
  # Determine target type based on network mode
  resolved_target_type = var.target_type != null ? var.target_type : (
    var.network_mode == "awsvpc" ? "ip" : "instance"
  )

  # Determine the final certificate ARN to use
  final_certificate_arn = local.create_load_balancer && var.enable_https_listener ? (
    var.ssl_certificate_arn != "" ? var.ssl_certificate_arn : (
      var.create_acm_certificate && var.certificate_domain_name != "" ? aws_acm_certificate.main[0].arn : (
        var.certificate_domain_name != "" && length(data.aws_acm_certificate.main) > 0 ? data.aws_acm_certificate.main[0].arn : ""
      )
    )
  ) : ""

  # Validate that we have a certificate ARN when HTTPS is enabled
  certificate_available = local.create_load_balancer && var.enable_https_listener ? local.final_certificate_arn != "" : true
}

# ===================================================================
# APPLICATION LOAD BALANCER / NETWORK LOAD BALANCER
# ===================================================================

resource "aws_lb" "main" {
  count = local.create_load_balancer ? 1 : 0

  name               = local.load_balancer_name
  internal           = var.load_balancer_internal
  load_balancer_type = var.load_balancer_type

  # Security groups (ALB only)
  security_groups = var.load_balancer_type == "application" ? local.load_balancer_security_groups : null

  subnets = var.load_balancer_subnets

  enable_deletion_protection = var.enable_deletion_protection

  # Cross-zone load balancing (NLB only)
  enable_cross_zone_load_balancing = var.load_balancer_type == "network" ? var.enable_cross_zone_load_balancing : null

  ip_address_type = var.ip_address_type

  tags = merge(var.tags, {
    Name = local.load_balancer_name
    Type = var.load_balancer_type == "application" ? "ALB" : "NLB"
  })
}

# ===================================================================
# PRIMARY TARGET GROUP
# ===================================================================

resource "aws_lb_target_group" "main" {
  count = local.create_load_balancer ? 1 : 0

  name     = local.target_group_name
  port     = local.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  target_type                   = local.resolved_target_type
  deregistration_delay          = var.deregistration_delay
  slow_start                    = var.target_group_protocol == "HTTP" || var.target_group_protocol == "HTTPS" ? var.slow_start : null
  load_balancing_algorithm_type = var.target_group_protocol == "HTTP" || var.target_group_protocol == "HTTPS" ? var.load_balancing_algorithm_type : null

  # Health check configuration
  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.target_group_protocol == "HTTP" || var.target_group_protocol == "HTTPS" ? var.health_check_path : null
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    matcher             = var.target_group_protocol == "HTTP" || var.target_group_protocol == "HTTPS" ? var.health_check_matcher : null
  }

  tags = merge(var.tags, {
    Name = local.target_group_name
  })

  # Prevent target group destruction before creating new one
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.main]
}

# ===================================================================
# ADDITIONAL TARGET GROUPS
# ===================================================================

resource "aws_lb_target_group" "additional" {
  for_each = local.create_load_balancer ? { for tg in var.additional_target_groups : tg.name => tg } : {}

  name     = each.value.name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id

  target_type                   = each.value.target_type
  deregistration_delay          = each.value.deregistration_delay
  slow_start                    = each.value.protocol == "HTTP" || each.value.protocol == "HTTPS" ? each.value.slow_start : null
  load_balancing_algorithm_type = each.value.protocol == "HTTP" || each.value.protocol == "HTTPS" ? each.value.load_balancing_algorithm_type : null

  # Health check configuration
  health_check {
    enabled             = each.value.health_check.enabled
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    timeout             = each.value.health_check.timeout
    interval            = each.value.health_check.interval
    path                = each.value.protocol == "HTTP" || each.value.protocol == "HTTPS" ? each.value.health_check.path : null
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    matcher             = each.value.protocol == "HTTP" || each.value.protocol == "HTTPS" ? each.value.health_check.matcher : null
  }

  tags = merge(var.tags, {
    Name = each.value.name
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.main]
}

# ===================================================================
# HTTP LISTENER (Port 80)
# ===================================================================

resource "aws_lb_listener" "http" {
  count = local.create_load_balancer && var.enable_http_listener && var.load_balancer_type == "application" ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = var.http_port
  protocol          = "HTTP"

  # Default action - forward to target group or redirect to HTTPS
  dynamic "default_action" {
    for_each = var.http_redirect_to_https && var.enable_https_listener ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = tostring(var.https_port)
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = !var.http_redirect_to_https || !var.enable_https_listener ? [1] : []
    content {
      type             = "forward"
      target_group_arn = var.enable_multi_service_mode ? (
        can(aws_lb_target_group.services["n8n-main"]) ? aws_lb_target_group.services["n8n-main"].arn : aws_lb_target_group.main[0].arn
      ) : aws_lb_target_group.main[0].arn
    }
  }

  tags = var.tags
}

# ===================================================================
# HTTPS LISTENER (Port 443)
# ===================================================================

# HTTPS listener for Application Load Balancer
resource "aws_lb_listener" "https" {
  count = local.create_load_balancer && var.enable_https_listener && var.load_balancer_type == "application" && (var.ssl_certificate_arn != "" || var.create_acm_certificate || var.certificate_domain_name != "") ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.final_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.enable_multi_service_mode ? (
      can(aws_lb_target_group.services["n8n-main"]) ? aws_lb_target_group.services["n8n-main"].arn : aws_lb_target_group.main[0].arn
    ) : aws_lb_target_group.main[0].arn
  }

  tags = merge(var.tags, {
    Name        = "${local.load_balancer_name}-https-listener"
    Type        = "HTTPS-Listener"
    Port        = var.https_port
    Certificate = local.final_certificate_arn
  })
}

# ===================================================================
# TCP/TLS LISTENERS (For NLB)
# ===================================================================

resource "aws_lb_listener" "tcp" {
  count = local.create_load_balancer && var.load_balancer_type == "network" && var.target_group_protocol == "TCP" ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = local.target_group_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  tags = var.tags
}

resource "aws_lb_listener" "tls" {
  count = local.create_load_balancer && var.load_balancer_type == "network" && var.target_group_protocol == "TLS" && (var.ssl_certificate_arn != "" || var.create_acm_certificate || var.certificate_domain_name != "") ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = var.https_port
  protocol          = "TLS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.final_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  tags = merge(var.tags, {
    Name        = "${local.load_balancer_name}-tls-listener"
    Protocol    = "TLS"
    Port        = tostring(var.https_port)
    Certificate = local.final_certificate_arn
  })

  depends_on = [
    aws_acm_certificate.main,
    data.aws_acm_certificate.main
  ]
}

# ===================================================================
# UDP LISTENER (For NLB)
# ===================================================================

resource "aws_lb_listener" "udp" {
  count = local.create_load_balancer && var.load_balancer_type == "network" && var.target_group_protocol == "UDP" ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = local.target_group_port
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  tags = var.tags
}