resource "aws_api_gateway_rest_api" "demo" {
  name = var.apigw_name

  endpoint_configuration {
    types = [
      var.apigw_private ? "PRIVATE" : "REGIONAL"
    ]
    vpc_endpoint_ids =  var.apigw_private ? [
      aws_vpc_endpoint.demo[0].id,
    ] : null
  }
}

resource "aws_api_gateway_rest_api_policy" "demo" {
  rest_api_id = aws_api_gateway_rest_api.demo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "AWS": "*"
        }
        Action = "execute-api:Invoke",
        Resource = format("%s/*", aws_api_gateway_rest_api.demo.execution_arn)
      }
    ]
  })
}

resource "aws_api_gateway_resource" "demo" {
  parent_id   = aws_api_gateway_rest_api.demo.root_resource_id
  path_part   = "demo"
  rest_api_id = aws_api_gateway_rest_api.demo.id
}

resource "aws_api_gateway_method" "demo" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.demo.id
  rest_api_id   = aws_api_gateway_rest_api.demo.id
}

resource "aws_api_gateway_integration" "demo" {
  http_method = aws_api_gateway_method.demo.http_method
  resource_id = aws_api_gateway_resource.demo.id
  rest_api_id = aws_api_gateway_rest_api.demo.id
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "demo" {
  rest_api_id = aws_api_gateway_rest_api.demo.id
  resource_id = aws_api_gateway_resource.demo.id
  http_method = aws_api_gateway_method.demo.http_method

  status_code = 200

}

resource "aws_api_gateway_integration_response" "demo" {
  rest_api_id = aws_api_gateway_rest_api.demo.id
  resource_id = aws_api_gateway_resource.demo.id
  http_method = aws_api_gateway_method.demo.http_method

  status_code = aws_api_gateway_method_response.demo.status_code

  response_templates = {
    "application/json" = jsonencode({
      "whoami" = "I am API Gateway!"
      "details" = {
        "account_id"   = "$context.accountId"
        "api_id"       = "$context.apiId"
        "request_id"   = "$context.requestId"
        "request_time" = "$context.requestTime"
      }
    })
  }
}

resource "aws_api_gateway_deployment" "demo" {
  rest_api_id = aws_api_gateway_rest_api.demo.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api_policy.demo.id,
      aws_api_gateway_resource.demo.id,
      aws_api_gateway_method.demo.id,
      aws_api_gateway_integration.demo.id,
      aws_api_gateway_method_response.demo.id,
      aws_api_gateway_integration_response.demo.id,
    ]))
  }
}

resource "aws_api_gateway_stage" "demo" {
  deployment_id = aws_api_gateway_deployment.demo.id
  rest_api_id   = aws_api_gateway_rest_api.demo.id
  stage_name    = "demo"
}

locals {
  exec_api_endpoint = format(
    "https://%s.execute-api.%s.amazonaws.com",
    aws_api_gateway_rest_api.demo.id,
    var.region,
  )
}

output "apigw" {
  value = {
    name = aws_api_gateway_rest_api.demo.name
    id   = aws_api_gateway_rest_api.demo.id
    type = var.apigw_private ? "private" : "regional"
    url  = local.exec_api_endpoint
    mock = format("%s/%s/%s",
      local.exec_api_endpoint,
      aws_api_gateway_stage.demo.stage_name,
      aws_api_gateway_resource.demo.path_part,
    )
  }
}
