### Example: Collect ENI IDs by tag
### This is the rarely used method since
### ENIs have pre-configured tags that can be set manually.
###
variable "tags" {
  type = map(string)
}

data "aws_network_interfaces" "example" {
  ### https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeNetworkInterfaces.html
  ###
  filter {
    name   = "vpc-id"
    values = [var.vpcid]
  }
  dynamic "filter" {
    for_each = var.tags
    content = {
      name = format("tag:%s", each.key)
      values = [
        each.value,
      ]
    }
  }
}

output "network_interfaces" {
  value = data.aws_network_interfaces.example.ids
}
