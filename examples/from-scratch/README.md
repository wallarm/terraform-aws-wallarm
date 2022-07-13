# Example deployment of Wallarm AWS Terraform Module: Proxy solution from scratch
​
This example demonstrates how to deploy Wallarm as an inline proxy to an AWS Virtual Private Cloud (VPC) using the Terraform module. In contrast to the [regular](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/proxy) or [advanced](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/advanced) proxy deployment examples, this example configuration will create VPC resources directly during this example deployment using the [AWS VPC Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/). That is why the example is called "proxy solution from scratch".

This is the **recommended** deployment option if:

* You do not have subnets, NATs, route tables and other VPC resources configured. This deployment example launches the [AWS VPC Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/) along with the Wallarm Terraform module to create VPC resources and integrate Wallarm with them.
* You want to learn the way the Wallarm module is integrated with AWS VPC, the VPC resources and the module variables required for this integration.
​
## Key characteristics

* Wallarm processes traffic in the synchronous mode that does not limit Wallarm capabilities and enables instant threat mitigation (`preset=proxy`).
* Wallarm solution is deployed as a separate network layer that enables you to control it independently from other layers and place the layer in almost any network structure position. The recommended position is behind an internet-facing load balancer.
* This solution does not require the DNS and SSL features to be configured.
* It creates VPC resources and automatically integrates the Wallarm inline proxy to the created VPC whilst the regular proxy example requires VPC resources to exist and requests their identifiers.
* The only variable required to run this example is `token` with the Wallarm node token.
​
## Solution architecture
​
![Wallarm proxy scheme](https://github.com/wallarm/terraform-aws-wallarm/blob/main/images/wallarm-as-proxy.png?raw=true)
​
This example solution has the same architecture as the [regular proxy solution](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/proxy):

* AWS VPC resources including subnets, NATs, route tables, EIPs, etc. will be automatically deployed by the [`vpc`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/) module during this example launch. They are not displayed on the provided scheme.
* Internet-facing Application Load Balancer routing traffic to Wallarm node instances. This component will be deployed by the provided `wallarm` example module.
* Wallarm node instances analyzing traffic and proxying any requests further. Corresponding elements on the scheme are A, B, C EC2 instances. This component will be deployed by the provided `wallarm` example module.

    The example runs Wallarm nodes in the monitoring mode that drives the described behavior. Wallarm nodes can also operate in other modes including those aimed at blocking malicious requests and forwarding only legitimate ones further. To learn more about Wallarm node modes, use [our documentation](https://docs.wallarm.com/admin-en/configure-wallarm-mode/).
* The services Wallarm nodes proxy requests to. The service can be of any type, e.g.:

    * AWS API Gateway application connected to VPC via VPC Endpoints (the corresponding Wallarm Terraform deployment is covered in the [example for API Gateway](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/apigateway))
    * AWS S3
    * EKS nodes running in the EKS cluster (configuration of Internal Load Balancer or NodePort Service is recommended for this case)
    * Any other backend service

    By default, Wallarm nodes will forward traffic to `https://httpbin.org`. During this example launch, you will be able to specify any other service domain or path available from AWS Virtual Private Cloud (VPC) to proxy traffic to.

    The `https_redirect_code = 302` module configuration option will allow you to safely redirect HTTP requests to HTTPS by AWS ALB.

## Code components
​
This example has the only `main.tf` configuration file with the following module settings:

* The [`vpc` module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/) settings to create AWS VPS resources.
* The `wallarm` module with the Wallarm configuration to be deployed as a proxy solution. The configuration produces an AWS ALB and Wallarm instances.
​
## Requirements
​
* Terraform 1.0.5 or higher [installed locally](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Access to the account with the **Administrator** role in Wallarm Console in the [EU Cloud](https://my.wallarm.com/) or [US Cloud](https://us1.my.wallarm.com/)
* Access to `https://api.wallarm.com` if working with EU Wallarm Cloud or to `https://us1.api.wallarm.com` if working with US Wallarm Cloud. Please ensure the access is not blocked by a firewall
​
## Running the example Wallarm AWS proxy solution
​
1. Sign up for Wallarm Console in the [EU Cloud](https://my.wallarm.com/nodes) or [US Cloud](https://us1.my.wallarm.com/nodes).
1. Open Wallarm Console → **Nodes** and create the node of the **Wallarm node** type.
1. Copy the generated node token.
1. Clone the repository containing the example code to your machine:
​
    ```
    git clone https://github.com/wallarm/terraform-aws-wallarm.git
    ```
1. Set variable values in the `default` options in the `examples/from-scratch/variables.tf` file of the cloned repository and save changes.
1. Deploy the stack by executing the following commands from the `examples/from-scratch` directory:
​
    ```
    terraform init
    terraform apply
    ```
​
To remove the deployed environment, use the following command:
​
```
terraform destroy
```
​
## References
​
* [Wallarm documentation](https://docs.wallarm.com)
* [Terraform module which creates VPC resources on AWS](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
* [AWS VPC with public and private subnets (NAT)](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
