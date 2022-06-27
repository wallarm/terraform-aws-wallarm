# Wallarm AWS Terraform Module

[Wallarm](https://www.wallarm.com/) is the platform Dev, Sec, and Ops teams choose to build cloud-native APIs securely, monitor them for modern threats, and get alerted when threats arise. Whether you protect some of the legacy apps or brand new cloud-native APIs, Wallarm provides key components to secure your business against emerging threats.

This repo contains the module for deploying Wallarm on [AWS](https://aws.amazon.com/) using Terraform.

![Wallarm proxy scheme](https://github.com/wallarm/terraform-aws-wallarm/blob/main/images/wallarm-as-proxy.png?raw=true)

By implementing the Wallarm Terraform module, we have provided the solution enabling two core Wallarm deployment options: proxy and mirror security solutions. The deployment option is easily controlled by the `preset` Wallarm module variable. You can try both options by deploying either the [provided examples](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples) or configuring the module itself.

## Requirements

* Terraform 1.0.5 or higher [installed locally](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Access to the account with the **Administrator** role in Wallarm Console in the [EU Cloud](https://my.wallarm.com/) or [US Cloud](https://us1.my.wallarm.com/)
* Access to `https://api.wallarm.com` if working with EU Wallarm Cloud or to `https://us1.api.wallarm.com` if working with US Wallarm Cloud. Please ensure the access is not blocked by a firewall

## How to use this Module?

This repo has the following folder structure:

* [`modules`](https://github.com/wallarm/terraform-aws-wallarm/tree/main/modules): This folder contains submodules required to deploy the Wallarm module.
* [`examples`](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples): This folder shows examples of different ways to use the module from the `modules` folder to deploy Wallarm.

To deploy Wallarm for production using this repo:

1. Sign up for Wallarm Console in the [EU Cloud](https://my.wallarm.com/nodes) or [US Cloud](https://us1.my.wallarm.com/nodes).
1. Open Wallarm Console → **Nodes**  and create the node of the **Wallarm node** type.
1. Copy the generated node token.
1. Add the `wallarm` module code to your Terraform configuration:

    ```conf
    module "wallarm" {
      source = "wallarm/wallarm/aws"

      vpc_id     = "..."

      preset     = "proxy"
      proxy_pass = "https://..."
      token      = "..."

      instance_type = "..."

      ...
    }
    ```
1. Specify the copied node token in the `token` variable and configure other necessary variables.

## How is this Module maintained?

Wallarm AWS Module is maintained by [Wallarm Team](https://www.wallarm.com/).

If you have questions or feature requests related to Wallarm AWS Module, do not hesitate to send an email to [support@wallarm.com](mailto:support@wallarm.com?Subject=Terraform%20Module%20Question).

## License

This code is released under the [MIT License](https://github.com/wallarm/terraform-aws-wallarm/tree/main/LICENSE).

Copyright &copy; 2022 Wallarm, Inc.
