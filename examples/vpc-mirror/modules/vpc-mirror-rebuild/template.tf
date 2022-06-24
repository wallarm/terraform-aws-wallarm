data "aws_ami" "default" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-10-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"] # Debian
}

resource "aws_iam_instance_profile" "default" {
  name = local.app_name
}

resource "aws_launch_template" "default" {
  name = local.app_name

  image_id      = data.aws_ami.default.id
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 30
      delete_on_termination = true
    }
  }

  network_interfaces {
    delete_on_termination = true
    security_groups = [
      aws_security_group.default.id,
    ]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.default.name
  }

  monitoring {
    enabled = true
  }

  disable_api_termination              = true
  instance_initiated_shutdown_behavior = "terminate"

  key_name = var.key_name != "" ? var.key_name : null

  user_data = base64encode(
    templatefile(
      format("%s/cloud-init.tftpl", path.module),
      {
        vxlan_port           = 4789
        vxlan_id             = var.vxlan_id
        buffer_packet_expire = var.buffer_packet_expire
        buffer_size          = var.buffer_size
        mirror_endpoint      = var.mirror_endpoint
        debug                = var.debug
      },
    ),
  )
}

data "aws_launch_template" "default" {
  name = local.app_name

  depends_on = [
    aws_launch_template.default,
  ]
}
