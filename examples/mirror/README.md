# Example deployment of Wallarm AWS Terraform Module: Mirror solution

This example demonstrates how to deploy the Wallarm Terraform module as an Out-of-Band solution analyzing mirrored traffic. It is expected that the NGINX, Envoy, Istio and/or Traefik web server already provides traffic mirroring.

## Key characteristics

* Wallarm processes traffic in the asynchronous mode (`preset=mirror`) without affecting the current traffic flow which makes the approach the safest one.
* Wallarm solution is deployed as a separate network layer that enables you to control it independently from other layers and place the layer in almost any network structure position. The recommended position is in the private network.

## Solution architecture

<!--TBD ![Wallarm for mirrored traffic](https://github.com/wallarm/terraform-aws-wallarm/blob/main/images/wallarm-for-mirrored-traffic.png?raw=true) -->

This example Wallarm solution has the following components:

* Internet-facing load balancer routing traffic to the Wallarm node instances. It is expected that a load balancer has been already deployed, the `wallarm` module will not create this resource.
* Any web server serving traffic from a load balancer and mirroring HTTP requests to an internal ALB endpoint and backend services. It is expected that a web server has been already deployed, the `wallarm` module will not create this resource.
* An internal ALB accepting mirrored HTTPS requests from a web server and forwarding them to the Wallarm node instances.
* Wallarm node analyzing requests from an internal ALB and proxying any requests further.

    The example runs the Wallarm nodes in the monitoring mode that drives the described behavior. Wallarm nodes can also operate in other modes including those aimed at blocking malicious requests and forwarding only legitimate ones further. To learn more about Wallarm node modes, use [our documentation](https://docs.wallarm.com/admin-en/configure-wallarm-mode/).

The last two components will be deployed by the provided `wallarm` example module.

## Code components

This example has the following code components:

* `main.tf`: the main configuration of the `wallarm` module to be deployed as a mirror solution. The configuration produces an internal AWS ALB and Wallarm instances.

## Configuring HTTP request mirroring

Traffic mirroring is a feature provided by many web servers. Below is the documentation on how to configure traffic mirroring with some of them.

### NGINX

The following snippet [should be added](http://nginx.org/en/docs/http/ngx_http_mirror_module.html) to the `server {}` context:

```conf
# ${TARGET} must be replaced with Internal ALB DNS name

mirror /mirror;
mirror_request_body on;
location /mirror {
  internal;
  proxy_pass ${TARGET}$request_uri;
  proxy_set_header X-Server-Addr $server_addr;
  proxy_set_header X-Server-Port $server_port;
  proxy_set_header Host $http_host;
  proxy_set_header X-Forwarded-For $realip_remote_addr;
  proxy_set_header X-Forwarded-Port $realip_remote_port;
  proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
  proxy_set_header X-Scheme $scheme;
  proxy_set_header X-Request-ID $request_id;
}
```

### Traefik

[Traefik documentation](https://doc.traefik.io/traefik/routing/services/#mirroring-service)

```yaml
http:
  services:
    mirrored-api:
      mirroring:
        service: appv1
        maxBodySize: 1024
        mirrors:
        - name: appv2
          percent: 10
```

### Envoy

[Envoy documentation](https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/route/v3/route_components.proto)

```yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 80 }
    filter_chains:
    - filters:
      - name: envoy.http_connection_manager
        config:
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route:
                  host_rewrite: original-backend.example.com
                  cluster: myservice_cluster
                  request_mirror_policy:
                    cluster: myservice_test_cluster
                    runtime_fraction: { default_value: { numerator: 25 } }
          http_filters:
          - name: envoy.router
  clusters:
  - name: myservice_cluster
    type: LOGICAL_DNS
    hosts: [{ socket_address: { address: original-backend.example.com, port_value: 80 }}]
  - name: myservice_test_cluster
    type: LOGICAL_DNS
    hosts: [{ socket_address: { address: internal-alb-mirror-endpoint.example.com, port_value: 8445 }}]
```

### Istio

[Istio documentation](https://istio.io/latest/docs/tasks/traffic-management/mirroring/)

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
    - httpbin
  http:
  - route:
    - destination:
        host: original-backend.example.com
        subset: v1
      weight: 100
    mirror:
      host: internal-alb-mirror-endpoint.example.com
      port: 8445
      subset: v2
    mirrorPercentage:
      value: 100.0
```

## Limitations

Despite the fact that the described example solution is the most functional Out-of-Band Wallarm solution, it has some limitations inherent in the asynchronous approach:

* Wallarm node does not instantly block malicious requests since traffic analysis proceeds irrespective of actual traffic flow.
* The solution requires an additional component - the web server providing traffic mirroring or a similar tool (e.g. NGINX, Envoy, Istio, Traefik, custom Kong module, etc).

## Running the example Wallarm AWS mirror solution

1. Sign up for Wallarm Console in the [EU Cloud](https://my.wallarm.com/nodes) or [US Cloud](https://us1.my.wallarm.com/nodes).
1. Open Wallarm Console → **Nodes** and create the node of the **Wallarm node** type.
1. Copy the generated node token.
1. Clone the repository containing the example code to your machine:

    ```
    git clone https://github.com/wallarm/terraform-aws-wallarm.git
    ```
1. Set variable values in the `default` options in the `examples/mirror/variables.tf` file of the cloned repository and save changes.
1. Deploy the stack by executing the following commands from the `examples/mirror` directory:

    ```
    terraform init
    terraform apply
    ```

To remove the deployed environment, use the following command:

```
terraform destroy
```

## References

* [AWS VPC with public and private subnets (NAT)](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
* [Wallarm documentation](https://docs.wallarm.com)
