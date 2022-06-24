### Example: Collect ENI IDs by tag
###
### So, you can catch ENIs by tags that can be set manually. Due to
### there is no way to automaticaly create ENI for anything and ENI
### have PRECONFIGURED TAGS, so, this is rarely-used option
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
