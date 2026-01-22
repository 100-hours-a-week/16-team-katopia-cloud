resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
  ip_address_type    = "ipv4"

  tags = merge(var.tags, { Name = var.name })
}

locals {
  https_enabled = var.certificate_arn != null && var.certificate_arn != ""
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name     = coalesce(each.value.name, "${var.name}-${each.key}-tg")
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id

  health_check {
    path    = each.value.health_check_path
    matcher = each.value.health_check_matcher
  }

  tags = merge(var.tags, { Name = coalesce(each.value.name, "${var.name}-${each.key}-tg") })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = local.https_enabled ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = local.https_enabled ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this[var.default_target_group_key].arn
    }
  }
}

resource "aws_lb_listener" "https" {
  count = local.https_enabled ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[var.default_target_group_key].arn
  }
}

resource "aws_lb_listener_rule" "path_rules" {
  for_each = { for idx, rule in var.path_rules : idx => rule }

  listener_arn = local.https_enabled ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }
}
