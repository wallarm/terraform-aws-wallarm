# Submodule for the example Wallarm solution for AWS VPC Traffic Mirroring

**INFO** This is not a Terraform module or a module example configuration. This document provides you with the details on the submodule required to run the `terraform-aws-wallarm` module for traffic mirrored by AWS VPC.

The `vpc-mirror-rebuild` submodule runs the nodes that can rebuild HTTP requests from VXLAN packets stream and pass these requests to Wallarm nodes configured for analyzing mirrored traffic.

## Description

In the module, you can find the Autoscaling Group based on Debian 10 AMI, and cloud-init script that automatically installs `goreplay`.

In the `cloud-init.tftpl`, you can find basic template for the cloud-init sctipt that:

* Installs the required set of packages
* Installs `goreplay` (building from sources, due to `vxlan` feature is accessible only in the master branch at the moment of releasing this example)
* Configures `goreplay` for running right after instance reboot
* Configures healthcheck for load balancer

## Usage details

This module support a few customisation options. You can set:

* `instance_type` for scaling vertically and `subnet_ids` for define where to place EC2 instances. We also recommend to place these instances in private subnets.
* The `mirror_endpoint` variable. This is an endpoint for passing extracted HTTP requests to Wallarm nodes.

In order to properly configure this application, you can define `vxlan_id`, `buffer_packet_expire` and `buffer_size`:

* `vxlan_id` can define the VXLAN VNI. It can be helpful in case of multiple VXLAN streams in the single load balancer or instance.
* `buffer_packet_expire` and `buffer_size` set buffer limits.

You also can set `debug` option. This enable log verbosity for the `goreplay` application in systemd daemon (use `journalctl -xefu goreplay.service` on the instances).
