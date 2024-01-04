variable "upstream" {
  type        = string
  default     = "4.8"
  description = "The Wallarm node version to be deployed. Minimum supported version is '4.0'. More details: https://docs.wallarm.com/updating-migrating/versioning-policy/#version-list"
  validation {
    condition     = can(regex("^[4-9]+\\.[\\d]+", var.upstream))
    error_message = "The 'upstream' value should point to the Wallarm node version '4.0' or higher."
  }
}

variable "app_name" {
  type        = string
  default     = "wallarm"
  description = "Prefix for the AWS resource names the Wallarm module will create."
}

variable "app_name_no_template" {
  type        = bool
  default     = false
  description = "Whether to use upper-case letters, numbers and special characters in the AWS resource names the Wallarm module will create. If 'false', resource names will include only lower-case letters."
}

variable "vpc_id" {
  type        = string
  description = "ID of the AWS Virtual Private Cloud to deploy the Wallarm EC2 instance to. More details: https://docs.aws.amazon.com/managedservices/latest/userguide/find-vpc.html"
  validation {
    condition     = length(var.vpc_id) > 5 && substr(var.vpc_id, 0, 4) == "vpc-"
    error_message = "The 'vpc_id' value should be a valid VPC ID starting with 'vpc-'."
  }
}

variable "lb_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of AWS Virtual Private Cloud subnets IDs to deploy an Application Load Balancer in. The recommended value is public subnets associated with a route table that has a route to an internet gateway. More details: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html"
  validation {
    condition     = alltrue([for i in var.lb_subnet_ids : length(i) > 8 && substr(i, 0, 7) == "subnet-"])
    error_message = "The 'lb_subnet_ids' value should be a non-empty list with valid subnet IDs starting with 'subnet-'."
  }
}

variable "instance_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of AWS Virtual Private Cloud subnets IDs to deploy Wallarm EC2 instances in. The recommended value is private subnets configured for egress-only connections. More details: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html"
  validation {
    condition     = alltrue([for i in var.instance_subnet_ids : length(i) > 8 && substr(i, 0, 7) == "subnet-"])
    error_message = "The 'instance_subnet_ids' value should be a non-empty list with valid subnet IDs starting with 'subnet-'."
  }
}

variable "lb_enabled" {
  type        = bool
  default     = true
  description = "Whether to create an AWS Application Load Balancer. A target group will be created with any value passed in this variable unless a custom target group is specified in the 'custom_target_group' variable."
}

variable "lb_internal" {
  type        = bool
  default     = false
  description = "Whether to make an Application Load Balancer an internal load balancer. By default, an ALB has the internet-facing type. If using the asynchronous approach to handle connections, the recommended value is 'true'. More details: https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-internal-load-balancers.html"
}

variable "lb_deletion_protection" {
  type        = bool
  default     = true
  description = "Whether to enable protection for an Application Load Balancer to be prevented from being deleted accidentally. For production deployments, the recommended value is 'true'. More details: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#deletion-protection"
}

variable "lb_ssl_enabled" {
  type        = bool
  default     = false
  description = "Whether to negotiate SSL connections between a client and an Application Load Balancer. If 'true', the 'lb_ssl_policy' and 'lb_certificate_arn' variables are required. Recommended for production deployments. More details: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies"
}

variable "lb_ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  description = "Security policy for an Application Load Balancer. Required if 'lb_ssl_enabled' is 'true'. More details: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies"
}

variable "lb_certificate_arn" {
  type        = string
  default     = ""
  description = "Amazon Resource Name (ARN) of an AWS Certificate Manager (ACM) certificate. Required if 'lb_ssl_enabled' is 'true'. More details: https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html"
}

variable "lb_xff_header_processing_mode" {
  type        = string
  default     = null
  description = "Determines how the load balancer modifies the X-Forwarded-For header in the HTTP request before sending the request to the target. The possible values are 'append', 'preserve', and 'remove'. The default is 'append'"
}

variable "custom_target_group" {
  type        = string
  default     = ""
  description = "Name of existing target group to attach to the created Auto Scaling group. By default, a new target group will be created and attached. If the value is non-default, AWS ALB creation will be disabled. More details: https://docs.aws.amazon.com/autoscaling/ec2/userguide/attach-load-balancer-asg.html"
}

variable "inbound_allowed_ip_ranges" {
  type = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
  description = "List of source IPs and networks to allow inbound connections to Wallarm instances from. Please keep in mind that AWS masks load balancer traffic even if it is originated from public subnets."
}

variable "outbound_allowed_ip_ranges" {
  type = list(string)
  default = [
    "0.0.0.0/0",
  ]
  description = "List of source IPs and networks to allow Wallarm instance outbount connections to."
}

variable "extra_ports" {
  type        = list(number)
  default     = []
  description = "List of internal network extra ports to allow inbound connections to Wallarm instances from. The configuration will be applied to a security group."
}

variable "extra_public_ports" {
  type        = list(number)
  default     = []
  description = "List of public network extra ports to allow inbound connections to Wallarm instances from."
}

variable "extra_policies" {
  type        = list(string)
  default     = []
  description = "AWS IAM policies to be associated with the Wallarm stack. Can be helpful to use together with the 'post_script' variable running the script that requests data from Amazon S3."
}

variable "source_ranges" {
  type = list(string)
  default = [
    "0.0.0.0/0",
  ]
  description = "List of source IPs and networks to allow an AWS Application Load Balancer traffic from."
}

variable "https_redirect_code" {
  type        = number
  default     = 0
  description = "Code for HTTP request redirection to HTTPS. Possible values: '0' (redirect is disabled), '301' (permanent redirect), '302' (temporary redirect)."
  validation {
    condition     = contains([0, 301, 302], var.https_redirect_code)
    error_message = "The 'https_redirect_code' value can be only 0, 301 or 302."
  }
}

variable "asg_enabled" {
  type        = bool
  default     = true
  description = "Whether to create an AWS Auto Scaling group. More details: https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of instances in the created AWS Auto Scaling group."
}

variable "max_size" {
  type        = number
  default     = 3
  description = "Maximum number of instances in the created AWS Auto Scaling group."
}

variable "desired_capacity" {
  type        = number
  default     = 1
  description = "Inital number of instances in the created AWS Auto Scaling group. Must be greater than or equal to \"min_size\" and less than or equal to \"max_size\"."
}

variable "autoscaling_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable Amazon EC2 Auto Scaling for the Wallarm cluster. More details: https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html"
}

variable "autoscaling_cpu_target" {
  type        = string
  default     = "70.0"
  description = "Average CPU utilization percentage to keep the AWS Auto Scaling group at."
}

variable "instance_type" {
  type        = string
  description = "Amazon EC2 instance type to be used for the Wallarm deployment, e.g.: 't3.small'. More details: https://aws.amazon.com/ec2/instance-types/"
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "ID of Amazon Machine Image to be used for the Wallarm instance deployment. By default (empty string), the latest image from upstream is used. You are welcome to create the custom AMI based on the Wallarm node. More details on AMI ID: https://docs.aws.amazon.com/managedservices/latest/userguide/find-ami.html"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "Name of AWS key pair to be used to connect to the Wallarm instances via SSH. By default, SSH connection is disabled. More details: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for AWS resources the Wallarm module will create."
}

# Wallarm-specific variables

variable "token" {
  type        = string
  description = "Wallarm node token copied from the Wallarm Console UI. More details: https://docs.wallarm.com/user-guides/nodes/nodes/#creating-a-node"
}

variable "host" {
  type        = string
  default     = ""
  description = "Wallarm API server. Possible values: 'api.wallarm.com' for the EU Cloud, 'us1.api.wallarm.com' for the US Cloud. By default, 'api.wallarm.com'. More details: https://docs.wallarm.com/about-wallarm-waf/overview/#cloud"
}

variable "preset" {
  type        = string
  default     = "proxy"
  description = "Wallarm deployment scheme. Possible values: 'proxy' and 'mirror'. More details: https://docs.wallarm.com/waf-installation/cloud-platforms/aws/terraform-module/overview/"
  validation {
    condition     = contains(["proxy", "mirror", "custom"], var.preset)
    error_message = "The 'preset' value can be only 'proxy' or 'mirror'."
  }
}

variable "proxy_pass" {
  type        = string
  default     = ""
  description = "Proxied server protocol and address. Wallarm node will process requests sent to the specified address and proxy legitimate ones to. As a protocol, 'http' or 'https' can be specified. The address can be specified as a domain name or IP address, and an optional port."
}

variable "mode" {
  type        = string
  default     = "monitoring"
  description = "Traffic filtration mode. Possible values: 'off', 'monitoring', 'safe_blocking', 'block'. More details: https://docs.wallarm.com/admin-en/configure-wallarm-mode/"
}

variable "libdetection" {
  type        = bool
  default     = false
  description = "Whether to use the libdetection library during the traffic analysis. More details: https://docs.wallarm.com/about-wallarm-waf/protecting-against-attacks/#library-libdetection."
}

variable "global_snippet" {
  type        = string
  default     = ""
  description = "Custom configuration to be added to the NGINX global configuration. You can put the file with the configuration to the Terraform code directory and specify the path to this file in this variable. You will find the variable configuration example in the example of the proxy advanced solution deployment: https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/advanced/main.tf#L17"
}

variable "http_snippet" {
  type        = string
  default     = ""
  description = "Custom configuration to be added to the 'http' configuration block of NGINX. You can put the file with the configuration to the Terraform code directory and specify the path to this file in this variable. You will find the variable configuration example in the example of the proxy advanced solution deployment: https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/advanced/main.tf#L18"
}

variable "server_snippet" {
  type        = string
  default     = ""
  description = "Custom configuration to be added to the 'server' configuration block of NGINX. You can put the file with the configuration to the Terraform code directory and specify the path to this file in this variable. You will find the variable configuration example in the example of the proxy advanced solution deployment: https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/advanced/main.tf#L19"
}

variable "post_script" {
  type        = string
  default     = ""
  description = "Custom script to be run after the Wallarm node initialization script (cloud-init), e.g. to place some content from AWS S3 to an instance directory. This example will also require access to AWS S3 that you can configure via the 'extra_policies' variable."
}

variable "lb_logs_enabled" {
  type        = bool
  default     = false
  description = "Whether to send logs from Load Balancer to S3 bucket"
}

variable "lb_logs_s3_bucket" {
  type        = string
  default     = ""
  description = "The S3 bucket name to store the access logs from Load Balancer"
}

variable "lb_logs_prefix" {
  type        = string
  default     = ""
  description = "The S3 bucket prefix. Logs are stored in the root if not configured"
}