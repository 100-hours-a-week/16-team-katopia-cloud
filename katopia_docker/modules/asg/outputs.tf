output "asg_name" {
  description = "ASG name."
  value       = aws_autoscaling_group.this.name
}

output "asg_arn" {
  description = "ASG ARN."
  value       = aws_autoscaling_group.this.arn
}

output "launch_template_id" {
  description = "Launch template ID."
  value       = aws_launch_template.this.id
}
