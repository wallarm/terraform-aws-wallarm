output "template_name" {
  value = aws_launch_template.default.name
}

output "template_id" {
  value = aws_launch_template.default.id
}

output "template_version" {
  value = data.aws_launch_template.default.latest_version
}

output "role_name" {
  value = try(aws_iam_role.default[0].name, "")
}

output "role_arn" {
  value = try(aws_iam_role.default[0].arn, "")
}

output "ami_id" {
  value = local.ami_id
}
