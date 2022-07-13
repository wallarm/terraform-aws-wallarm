# Example deployment of Wallarm AWS Terraform Module: Proxy advanced solution

This example demonstrates how to deploy Wallarm as an inline proxy with advanced settings to an existing AWS Virtual Private Cloud (VPC) using the Terraform module. It is a lot like the [simple proxy deployment](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/proxy) but with some frequent advanced configuration options demonstrated.

For an easier start with this example, have a look at the [simple proxy example](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/proxy) first. 

Wallarm proxy advanced solution (as well as a simple proxy) provides an additional functional network layer serving as an advanced HTTP traffic router with the WAF and API security functions.

## Key characteristics

The proxy advanced solution differs from the simple one as follows:

* The solution does not create any load balancer (`lb_enabled=false`) but still creates a target group you can further attach to an existing load balancer.

    This can help to switch to the synchronous traffic processing approach seamlessly.
* NGINX and Wallarm configuration is specified not only in the standard variables but also in the `global_snippet`, `http_snippet` and `server_snippet` NGINX snippets.
* Once the Wallarm node initialization script (cloud-init) is finished, the custom `post-cloud-init.sh` script will place the custom HTML index page in the `/var/www/mysite/index.html` instance directory.
* Deployed stack is associated with the extra AWS IAM policy enabling read only access to AWS S3.

    If using this example "as is", the provided access will not be needed. Nevertheless, the `post-cloud-init.sh` file contains an inactive example of requesting files from AWS S3 that usually requires special access. If activating the S3 code from the `post-cloud-init.sh` file, you will need to specify AWS S3 access IAM policies in the `extra_policies` variable.
* The solution allows inbound connections to Wallarm instances from the extra internal network port, 7777. This is configured with the `extra_ports` variable and `http_snippet.conf`.

    To allow the port 7777 for `0.0.0.0/0`, you can additionally use the `extra_public_ports` variable (optionally).
* The Wallarm node processes traffic in the blocking mode.

## Solution architecture

![Wallarm proxy scheme](https://github.com/wallarm/terraform-aws-wallarm/blob/main/images/wallarm-as-proxy.png?raw=true)

The example Wallarm proxy advanced solution has the following components:

* Target group attached to the Auto Scaling group with no load balancer.
* Wallarm node instances analyzing traffic, blocking malicious requests and proxying legitimate requests further.

    The example runs the Wallarm nodes in the blocking mode that drives the described behavior. Wallarm nodes can also operate in other modes including those aimed at only traffic monitoring with no malicious request blocking. To learn more about Wallarm node modes, use [our documentation](https://docs.wallarm.com/admin-en/configure-wallarm-mode/).
* Wallarm nodes proxy traffic to `https://httpbin.org`.

    During this example launch, you will be able to specify any other service domain or path available from AWS Virtual Private Cloud (VPC) to proxy traffic to.

All listed components (except for the proxied server) will be deployed by the provided `wallarm` example module.

## Code components

This example has the following code components:

* `main.tf`: the main configuration of the `wallarm` module to be deployed as a proxy advanced solution.
* `global_snippet.conf`: example of a custom NGINX configuration to be added to the NGINX global configuration using the `global_snippet` variable. Mounted configuration may include the directives like `load_module`, `stream`, `mail` or `env`.
* `http_snippet.conf`: custom NGINX configuration to be added to the `http` NGINX context using the `http_snippet` variable. Mounted configuration may include the directives like `map` or `server`.
* `server_snippet.conf`: custom NGINX configuration to be added to the `server` NGINX context using the `server_snippet` variable. Mounted configuration may introduce the `if` NGINX logic and required `location` settings.

    This snippet configuration will be applied only to port 80. To open another port, specify the corresponding `server` directive in `http_snippet`.

    In the `server_snippet.conf` file, you will also find a more complicated configuration example.
* `post-cloud-init.sh`: the custom script placing the custom HTML index page to the `/var/www/mysite/index.html` instance directory. The script will be executed after the Wallarm node initialization (the cloud-init script).

    In the `post-cloud-init.sh` file, you will also find the example commands to place the AWS S3 content in the instance directory. If using this option, do not forget to specify the S3 access policy in the `extra_policies` variable.

## Running the example Wallarm AWS proxy solution

1. Sign up for Wallarm Console in the [EU Cloud](https://my.wallarm.com/nodes) or [US Cloud](https://us1.my.wallarm.com/nodes).
1. Open Wallarm Console → **Nodes** and create the node of the **Wallarm node** type.
1. Copy the generated node token.
1. Clone the repository containing the example code to your machine:

    ```
    git clone https://github.com/wallarm/terraform-aws-wallarm.git
    ```
1. Set variable values in the `default` options in the `examples/advanced/variables.tf` file of the cloned repository and save changes.
1. Set the proxied server protocol and address in `examples/advanced/main.tf` → `proxy_pass`.

    By default, Wallarm will proxy traffic to `https://httpbin.org`. If the default value meets your needs, leave it as is.
1. Deploy the stack by executing the following commands from the `examples/advanced` directory:

    ```
    terraform init
    terraform apply
    ```

To remove the deployed environment, use the following command:

```
terraform destroy
```

## References

* [Attaching an AWS load balancer to an Auto Scaling group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/attach-load-balancer-asg.html)
* [AWS VPC with public and private subnets (NAT)](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
* [Wallarm documentation](https://docs.wallarm.com)
