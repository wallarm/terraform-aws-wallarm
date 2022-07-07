# Example deployment of Wallarm AWS Terraform Module: Proxy for API Gateway

This example demonstrates how to protect AWS API Gateway with Wallarm as an inline proxy, deployed into AWS Virtual Private Cloud (VPC) using the Terraform module.

Wallarm proxy solution provides an additional functional network layer serving as an advanced HTTP traffic router with the WAF and API security functions. It means that you can build any HTTP routing that you want, so protecting API Gateway can be another option.

## Key characteristics

* Wallarm processes traffic in the synchronous mode that does not limit Wallarm capabilities and enables instant threat mitigation (`preset=proxy`).
* Wallarm solution is deployed as a separate network layer that enables you to control it independently from API Gateway. You can use all API Gateway features, Wallarm deployment don't restrict anything in API Gateway.
* This example CREATES new API Gateway with single route `/demo/demo`.

## Solution architecture

![Wallarm proxy scheme](https://github.com/wallarm/terraform-aws-wallarm/blob/main/images/wallarm-as-proxy.png?raw=true)

The example Wallarm proxy solution has the following components:

* Internet-facing Application Load Balancer routing traffic to Wallarm node instances.
* Wallarm node instances analyzing traffic and proxying any requests to API Gateway. For this example, you can create "regional" or "private" API Gateway. For "regional" you can use only publicly-faced endpoint for `execute-api`. For "private" all traffic from Wallarm nodes will be forwared through AWS VPC Endpoints, attached to `execute-api`.
* API Gateway receives analyzed requests and perform as same as without Wallarm

The example runs Wallarm nodes in the monitoring mode that drives the described behavior. Wallarm nodes can also operate in other modes including those aimed at blocking malicious requests and forwarding only legitimate ones further. To learn more about Wallarm node modes, use [our documentation](https://docs.wallarm.com/admin-en/configure-wallarm-mode/).

All listed components will be deployed by the provided `wallarm` example module.

## Code components

This example has the following code components:

* `main.tf`: the main configuration of the `wallarm` module to be deployed as a proxy solution. The configuration produces an AWS ALB and Wallarm instances.
* `apigw.tf`: the example API Gateway, with a single "MOCK" integration accessible by `/demo/demo` request path. This file can create "regional" or "private" types of API Gateway. The difference between and migration guide are described below.
* `endpoint.tf`: the AWS VPC Endpoint configuration for "private" API Gateway.

## Difference between "private" and "regional" API Gateways

You can restrict access to you API Gateway regardless "private" or "regional" is it. For both or ones you can use [resource policies](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-resource-policies.html) for rulling access, and for "regional" you can restrict it by [source ip](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-resource-policies-examples.html), and for "private" (that is not accessible from public networks by design) [by VPC and/or Endpoint](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-resource-policies-examples.html). Nevertheless, it is important to change your API Gateway to "private" otherwise traffic from Wallarm nodes to API Gateway will be passed via the public network and can produce additional charges.

### Migration between types of API Gateways

You can change type of API Gateway without recreation of the component. But you must keep in mind these specials of the procedure:
* During "regional" -> "private" migration publicly-faced endpoints (both via `execute-api` and via domain names) becomes to be unaccesible
* During "private" -> "regional" migration AWS VPC Endpoints targeted to you API Gateway will be immediately detached and API Gateway becomes to be unaccessible
* NGINX cannot detect changing of DNS names (in community version), and after changing type of API Gateway you need to trigger configuration refresh in Wallarm nodes (reboot, instance recreate, or just `nginx -s reload` in each instance)

So, there is a preferable way to run this from "regional" to "private":
* Create AWS VPC Endpoint to `execute-api` (see example in `endpoint.tf`)
* Switch type of API Gateway and add previosly created endpoint to API Gateway configuration. After success you traffic will be stopped
* Run `nginx -s reload` on each Wallarm node or just recreate every Wallarm node. After that your traffic becomes to work again

For migration from "private" to "regional":
* Remove endpoint required for running in "private" mode. Switch type of API Gateway.
* Run `nginx -s reload` on each Wallarm node or just recreate every Wallarm node. After that your traffic becomes to work again

For details use reference links in the end of this topic.

## Requirements

* Terraform 1.0.5 or higher [installed locally](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Access to the account with the **Administrator** role in Wallarm Console in the [EU Cloud](https://my.wallarm.com/) or [US Cloud](https://us1.my.wallarm.com/)
* Access to `https://api.wallarm.com` if working with EU Wallarm Cloud or to `https://us1.api.wallarm.com` if working with US Wallarm Cloud. Please ensure the access is not blocked by a firewall

## Running the example Wallarm AWS proxy for API Gateway

1. Sign up for Wallarm Console in the [EU Cloud](https://my.wallarm.com/nodes) or [US Cloud](https://us1.my.wallarm.com/nodes).
1. Open Wallarm Console → **Nodes** and create the node of the **Wallarm node** type.
1. Copy the generated node token.
1. Clone the repository containing the example code to your machine:

    ```
    git clone https://github.com/wallarm/terraform-aws-wallarm.git
    ```
1. Set variable values in the `default` options in the `examples/apigateway/variables.tf` file of the cloned repository and save changes. You must define at least `token`, `vpc_id`, `public_subnets`, and `private_subnets`.
1. Set `apigw_private` variable to `true` of `false`. You can try to make migrations described above with this variable.
1. Deploy the stack by executing the following commands from the `examples/proxy` directory:

    ```
    terraform init
    terraform apply
    ```

To remove the deployed environment, use the following command:

```
terraform destroy
```

## References

* [Wallarm documentation](https://docs.wallarm.com)
* [AWS VPC with public and private subnets (NAT)](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
* [API Gateway Private APIs](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-private-apis.html)
* [API Gateway Policies](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-resource-policies.html)
* [API Gateway Policies examples](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-resource-policies-examples.html)
* [API Gateway Types](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-api-endpoint-types.html)
