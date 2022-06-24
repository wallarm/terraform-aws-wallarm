resource "aws_launch_template" "default" {
  name = var.app_name

  image_id      = local.ami_id
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
        token          = var.token
        host           = var.host
        preset         = var.preset
        mode           = var.mode
        proxy_pass     = var.proxy_pass
        libdetection   = var.libdetection
        global_snippet = replace(var.global_snippet, "$", "\\$")
        http_snippet   = replace(var.http_snippet, "$", "\\$")
        server_snippet = replace(var.server_snippet, "$", "\\$")
        post_script    = var.post_script
      },
    ),
  )

  dynamic "tag_specifications" {
    for_each = toset(length(keys(var.tags)) > 0 ? [true] : [])
    content {
      resource_type = "instance"
      tags          = var.tags
    }
  }
}

data "aws_launch_template" "default" {
  name = var.app_name

  depends_on = [
    aws_launch_template.default,
  ]
}
