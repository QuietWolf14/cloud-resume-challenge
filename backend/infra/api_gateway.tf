data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  my_region = data.aws_region.current.id
  account_id = data.aws_caller_identity.current.account_id
}

// Start with creating the API entry

resource "aws_api_gateway_rest_api" "crc" {
  name = "visitor-count-api"
  description = "Proxy to handle requests to visitor count API"
}

resource "aws_api_gateway_resource" "crc" {
  path_part   = "{proxy+}"
  parent_id   = aws_api_gateway_rest_api.crc.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.crc.id
}

resource "aws_api_gateway_method" "crc-get" {
  rest_api_id   = aws_api_gateway_rest_api.crc.id
  resource_id   = aws_api_gateway_resource.crc.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "crc-opt" {
  rest_api_id   = aws_api_gateway_rest_api.crc.id
  resource_id   = aws_api_gateway_resource.crc.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

// Create the integration
resource "aws_api_gateway_integration" "crc-get" {
  rest_api_id             = aws_api_gateway_rest_api.crc.id
  resource_id             = aws_api_gateway_resource.crc.id
  http_method             = aws_api_gateway_method.crc-get.http_method
  integration_http_method = "POST" // Can only use POST for Lambda integration
  type                    = "AWS_PROXY" // Needed for Lambda integration
  uri                     = aws_lambda_function.default.invoke_arn
}

resource "aws_api_gateway_integration" "crc-opt" {
  rest_api_id             = aws_api_gateway_rest_api.crc.id
  resource_id             = aws_api_gateway_resource.crc.id
  http_method             = aws_api_gateway_method.crc-opt.http_method
  //integration_http_method = "POST"
  type                    = "MOCK"
  uri                     = aws_lambda_function.default.invoke_arn
}

// Create resource for API deployment
resource "aws_api_gateway_deployment" "crc" {
  rest_api_id = aws_api_gateway_rest_api.crc.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.crc.id,
      aws_api_gateway_method.crc-get.id,
      aws_api_gateway_integration.crc-get.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "crc" {
  deployment_id = aws_api_gateway_deployment.crc.id
  rest_api_id   = aws_api_gateway_rest_api.crc.id
  stage_name    = "visitor_count_stage"
}

// Add  Access-Control-Allow-Origin to default response headers for 4XX and 5XX error responses here
resource "aws_api_gateway_gateway_response" "four_hundo" {
  rest_api_id   = aws_api_gateway_rest_api.crc.id
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_gateway_response" "five_hundo" {
  rest_api_id   = aws_api_gateway_rest_api.crc.id
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "api_gw_crc" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${local.my_region}:${local.account_id}:${aws_api_gateway_rest_api.crc.id}/*/${aws_api_gateway_method.crc-get.http_method}${aws_api_gateway_resource.crc.path}"
}

resource "aws_cloudwatch_log_group" "visitor-count" {
  name = "/aws/api_gw_crc/${aws_api_gateway_rest_api.crc.name}"

  retention_in_days = 30
}