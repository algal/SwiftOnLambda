resource "aws_iam_role" "iam_for_api_gateway" {
    name = "iam_for_api_gateway"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
    name   = "lambda_policy"
    role   = "${aws_iam_role.iam_for_api_gateway.name}"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_api_gateway_rest_api" "swift_lambda" {
  name = "SwiftLambda"
}

resource "aws_api_gateway_resource" "swift_lambda_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.swift_lambda.id}"
  parent_id = "${aws_api_gateway_rest_api.swift_lambda.root_resource_id}"
  path_part = "helloworld"
}

resource "aws_api_gateway_method" "swift_lambda_get" {
  rest_api_id = "${aws_api_gateway_rest_api.swift_lambda.id}"
  resource_id = "${aws_api_gateway_resource.swift_lambda_resource.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "swift_lambda_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.swift_lambda.id}"
  resource_id = "${aws_api_gateway_resource.swift_lambda_resource.id}"
  http_method = "${aws_api_gateway_method.swift_lambda_get.http_method}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.swift_lambda.arn}/invocations"
  integration_http_method = "POST"
  credentials = "${aws_iam_role.iam_for_api_gateway.arn}"
  passthrough_behavior = "WHEN_NO_TEMPLATES"
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id                 = "${aws_api_gateway_rest_api.swift_lambda.id}"
  resource_id                 = "${aws_api_gateway_resource.swift_lambda_resource.id}"
  http_method                 = "${aws_api_gateway_method.swift_lambda_get.http_method}"
  status_code                 = "200"
  response_parameters         = { "method.response.header.Location" = true }
}

resource "aws_api_gateway_integration_response" "test_IntegrationResponse" {
  rest_api_id                 = "${aws_api_gateway_rest_api.swift_lambda.id}"
  resource_id                 = "${aws_api_gateway_resource.swift_lambda_resource.id}"
  http_method                 = "${aws_api_gateway_method.swift_lambda_get.http_method}"
  status_code                 = "${aws_api_gateway_method_response.200.status_code}"
  depends_on                  = ["aws_api_gateway_integration.swift_lambda_integration"]
  response_parameters = { "method.response.header.Location" = "integration.response.body.location" }
}

resource "aws_api_gateway_deployment" "swift_lambda_deployment" {
  depends_on = ["aws_api_gateway_method.swift_lambda_get", "aws_api_gateway_integration.swift_lambda_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.swift_lambda.id}"
  stage_name = "dev"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = "${aws_lambda_function.swift_lambda.arn}"
  statement_id = "8529a029b00c3d2c9efe1fc876c07c6c"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.swift_lambda.id}/*/${aws_api_gateway_integration.swift_lambda_integration.integration_http_method}${aws_api_gateway_resource.swift_lambda_resource.path}"
}

