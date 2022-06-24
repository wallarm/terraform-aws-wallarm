locals {
  asg_name = var.asg_name
}

data "aws_instances" "example" {
  filter {
    name = "tag:aws:autoscaling:groupName"
    values = [
      local.asg_name,
    ]
  }
}

data "aws_instance" "example" {
  for_each    = toset(data.aws_instances.example.ids)
  instance_id = each.value
}
