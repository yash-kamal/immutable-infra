output "alb_listener_arn" {
  value       = aws_lb_listener.app_listener.arn
  description = "ALB listener ARN for switching traffic."
}

output "primary_target_group_arn" {
  value       = aws_lb_target_group.primary.arn
  description = "Primary (blue) target group ARN."
}

output "public_ip" {
  value = aws_instance.app.public_ip
}
