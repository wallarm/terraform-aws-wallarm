output "asg_name" {
  value = aws_autoscaling_group.default.name
}

output "asg_id" {
  value = aws_autoscaling_group.default.id
}

output "asg_arn" {
  value = aws_autoscaling_group.default.arn
}
