### Example: Collect ENI IDs for AutoScaling Group
### instances
###
variable "asg_name" {
  type = string
}

data "aws_instances" "example" {
  filter {
    name = "tag:aws:autoscaling:groupName"
    values = [
      var.asg_name,
    ]
  }
}

data "aws_instance" "example" {
  for_each    = toset(data.aws_instances.example.ids)
  instance_id = each.value
}

output "network_interfaces" {
  value = values(data.aws_instance.example)[*].network_interface_id
}
