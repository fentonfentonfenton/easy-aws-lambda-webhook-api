data "archive_file" "source_code" {
  source_dir       = "${path.module}/src"
  output_file_mode = "0666"
  output_path      = "${path.module}/source_code.zip"
  type             = "zip"
}

resource "aws_sqs_queue" "default" {
  name = module.this.id

  kms_data_key_reuse_period_seconds = 300
  kms_master_key_id                 = "alias/aws/sqs"

  tags = module.this.tags
}


module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  description = "KMS key for ${module.this.id}"
  context     = module.this.context
}

##### Lambda Function #########################################################

resource "aws_lambda_function" "default" {
  function_name = module.this.id

  filename                       = "${path.module}/source_code.zip"
  source_code_hash               = data.archive_file.source_code.output_base64sha256
  handler                        = "lambda_function.handler"
  // Ignored when
  kms_key_arn                    = module.kms_key.key_arn
  publish                        = true
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.default.arn
  runtime                        = "ruby2.7"
  timeout                        = 5

  dead_letter_config {
    target_arn = aws_sqs_queue.default.arn
  }

  tracing_config {
    mode = "Active"
  }

  # bridgecrew:skip=BC_AWS_GENERAL_65:No VPC needed here.

  tags = module.this.tags
}

### API

resource "aws_apigatewayv2_api" "default" {
  name          = module.this.id
  protocol_type = "HTTP"
  target        = aws_lambda_function.default.arn
  route_key = "ANY /"
  tags = module.this.tags

}


resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = module.this.id
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "apigateway.amazonaws.com"
  
  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.default.execution_arn}/*/*/*"
}

# resource "aws_apigatewayv2_deployment" "default" {
#   api_id      = aws_apigatewayv2_api.default.id

#   lifecycle {
#     create_before_destroy = true
#   }
# }
