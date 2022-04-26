data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "default" {
  name = module.this.id

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = module.this.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "aws_xray_write_only_access" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

data "aws_iam_policy_document" "dead_letter_queue" {
  statement {
    sid       = "AllowSQSSendMessage"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.default.arn]
  }
}

resource "aws_iam_role_policy" "dead_letter_queue" {
  name   = "AllowSQSSendMessage"
  policy = data.aws_iam_policy_document.dead_letter_queue.json
  role   = aws_iam_role.default.id
}

data "aws_iam_policy_document" "kms_key" {
  statement {
    sid       = "AllowKMSDecrypt"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [module.kms_key.key_id]
  }
}
