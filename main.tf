provider "aws" {
  region = "us-east-1"
}

# DynamoDB Table
resource "aws_dynamodb_table" "event_data" {
  name           = "EventTable"
  hash_key       = "eventId"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "eventId"
    type = "S"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "LambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })

  # Permissions for DynamoDB and CloudWatch
  inline_policy {
    name = "LambdaPolicy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem"],
          Effect   = "Allow",
          Resource = aws_dynamodb_table.event_data.arn
        },
        {
          Action   = ["logs:CreateLogStream", "logs:PutLogEvents"],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }
}

# Lambda Functions
resource "aws_lambda_function" "invoice_lambda" {
  function_name    = "InvoiceLambda"
  handler          = "invoice_lambda.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_role.arn
  filename         = "functions/invoice_lambda.zip"
}

resource "aws_lambda_function" "payment_lambda" {
  function_name    = "PaymentLambda"
  handler          = "payment_lambda.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_role.arn
  filename         = "functions/payment_lambda.zip"
}

# EventBridge Rules
resource "aws_cloudwatch_event_rule" "invoice_rule" {
  name        = "InvoiceRule"
  description = "Routes Invoice events"
  event_pattern = jsonencode({
    source = ["custom.invoice"]
  })
}

resource "aws_cloudwatch_event_rule" "payment_rule" {
  name        = "PaymentRule"
  description = "Routes Payment events"
  event_pattern = jsonencode({
    source = ["custom.payment"]
  })
}

# EventBridge Targets
resource "aws_cloudwatch_event_target" "invoice_target" {
  rule      = aws_cloudwatch_event_rule.invoice_rule.name
  target_id = "InvoiceLambdaTarget"
  arn       = aws_lambda_function.invoice_lambda.arn
}

resource "aws_cloudwatch_event_target" "payment_target" {
  rule      = aws_cloudwatch_event_rule.payment_rule.name
  target_id = "PaymentLambdaTarget"
  arn       = aws_lambda_function.payment_lambda.arn
}

# Lambda Permissions for EventBridge
resource "aws_lambda_permission" "allow_eventbridge_invoice" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invoice_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoice_rule.arn
}

resource "aws_lambda_permission" "allow_eventbridge_payment" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.payment_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.payment_rule.arn
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "LambdaErrorAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.invoice_lambda.function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttling_alarm" {
  alarm_name          = "DynamoDBThrottlingAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    TableName = aws_dynamodb_table.event_data.name
  }
}
