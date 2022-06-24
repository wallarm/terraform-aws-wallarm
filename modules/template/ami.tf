locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.default.id
}

data "aws_ami" "default" {
  owners = [679593333241]

  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["aws-marketplace"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = [
      format("wallarm-node-%s-*", replace(var.upstream, ".", "-")),
    ]
  }
}
