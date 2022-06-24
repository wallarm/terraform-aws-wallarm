# Submodule for the example Wallarm solution for AWS VPC Traffic Mirroring

**INFO** This is not a Terraform module or a module example configuration. This document provides you with the details on the submodule required to run the `terraform-aws-wallarm` module for traffic mirrored by AWS VPC.

The `vpc-mirror-sessions` submodule subscribes to packet mirroring stream via AWS VPC.

You can override default values for some options in AWS VPC Mirroring configurations:

* `target_nlb_arn` defining configuration of a target load balancer for mirrored packet stream.
* `direction_egress_enable` and `direction_ingress_enable` (optional): enables/disables the outgoing and incoming traffic mirroring for network interfaces that you set in `network_interface_ids`.

    By default, only incoming traffic is enabled.
* `session_id` (optional) defines the unique number of mirroring session.

    If you set more than one element in `network_interface_ids`, this variable sets the first in raw number. For example, for 3 ENIs and `7` value you will find `7`, `8` and `9` session numbers. Session numbers must be unique for single VPC.
* `vxlan_id` (optional) defines VXLAN VNI. This is internal parameter of mirrored packets stream that can be handled by another packet filtering solution, on the instances that analyze the packets.
