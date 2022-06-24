# Appendix for for the vpc-mirror example: Gettings ENIs

**INFO** This is not a Terraform module or a module example configuration. This document provides you with the details on getting [AWS ENIs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html) to run the [example Wallarm solution analyzing traffic mirrored by AWS VPC]TBD.

This folder includes the following configuration examples allowing to get ENI IDs in different ways:

* `by_asg.tf`: to get all ENIs from all instances in Auto Scaling Group.
* `by_eks.tf`: to get all ENIs from all instances in EKS node group.
* `by_elb.tf`: to get all ENIs for Classic ELB. ALB and NLB does not support traffic mirroring.
* `by_tags.tf`: to get all ENIs by AWS Tags. AWS does not automaticaly set tags for ENIs but you can set it manually.

**NOTE** Manual and automatic resource creation or destruction may result in ENIs IDs being changed and consequently mirroring sessions being detached from the previous IDs. For example, scaling ASG up or down destroys EC2 Instances and then creates or desctroys ENIs for EC2. This Terraform examples shows how to collect ENIs from AWS API but does not garantee that traffic mirroring will continue in the described cases.

You can specify the required ENIs configuration in the `../interfaces.tf` file.