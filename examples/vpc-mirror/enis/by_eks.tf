### Example: Collect ENI IDs for EKS Node Group
###
variable "eks_name" {
  type = string
}

variable "eks_node_group_names" {
  type = list(string)
}

data "aws_instances" "example" {
  filter {
    name   = "eks:cluster-name"
    values = var.eks_name
  }
  filter {
    name   = "eks:nodegroup-name"
    values = var.eks_node_group_names
  }
}

data "aws_instance" "example" {
  for_each    = toset(data.aws_instances.example.ids)
  instance_id = each.value
}

output "network_interfaces" {
  value = values(data.aws_instance.example)[*].network_interface_id
}
