locals {
  app_name = format("%s-%s", var.app_name, random_string.random.result)
}

resource "random_string" "random" {
  length = 5

  lower   = true
  upper   = false
  numeric = false
  special = false
}

resource "aws_autoscaling_group" "default" {
  name = local.app_name

  ### Doesn't support sharding yet. So, this may be in future
  ### releases of this example, or even the new Wallarm AMI.
  ### For now if you make more that single instance different
  ### parts of TCP streams will be distributed between instances
  ### and these instances will never extract HTTP requiests from
  ### the traffic.
  ###
  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  vpc_zone_identifier = var.subnet_ids

  health_check_type = "ELB"

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 75
    }
  }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.default.id
        version            = data.aws_launch_template.default.latest_version
      }
    }
  }

  target_group_arns = [
    aws_lb_target_group.default.id,
  ]
}
