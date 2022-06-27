### Example: Collect ENI IDs by tag
###
### This is the rare method to be used to get ENIs by
### manually created tags since AWS does not
### create any tags for ENIs automatically.
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
