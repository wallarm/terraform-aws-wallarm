resource "aws_iam_instance_profile" "default" {
  name = var.app_name

  role = length(var.extra_policies) > 0 ? aws_iam_role.default[0].name : null

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_iam_role" "default" {
  count = length(var.extra_policies) > 0 ? 1 : 0

  name = var.app_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "default" {
  for_each   = toset(var.extra_policies)
  role       = aws_iam_role.default[0].name
  policy_arn = each.value
}
