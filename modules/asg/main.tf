resource "aws_autoscaling_group" "default" {
  name = var.app_name

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = 180

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 75
    }
  }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = var.template_id
        version            = var.template_version
      }
    }
  }

  target_group_arns = [
    var.tg_id,
  ]

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
  ]

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = each.key
      value               = each.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "default" {
  count = var.autoscaling_enabled ? 1 : 0

  name = var.app_name

  autoscaling_group_name = aws_autoscaling_group.default.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.autoscaling_cpu_target
  }
}
