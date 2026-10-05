resource "aws_iam_role" "iot_lambda" {
  name = "stadium-iot-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "iot_lambda" {
  name = "stadium-iot-lambda-policy"
  role = aws_iam_role.iot_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ]

        Resource = aws_kinesis_stream.stadium_iot_events.arn
      },

      {
        Effect = "Allow"

        Action = [
          "glue:GetSchemaVersion"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "iot_lambda" {
  name              = "/aws/lambda/stadium-iot-ingestion"
  retention_in_days = 7
}

resource "aws_lambda_function" "iot_ingestion" {
  function_name = "stadium-iot-ingestion"

  role = aws_iam_role.iot_lambda.arn

  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"

  filename         = "${path.module}/lambda/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda.zip")

  timeout     = 30
  memory_size = 256

  depends_on = [
    aws_cloudwatch_log_group.iot_lambda
  ]
}

resource "aws_lambda_permission" "iot_core" {
  statement_id = "AllowIoTCoreInvoke"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.iot_ingestion.function_name

  principal = "iot.amazonaws.com"

  source_arn = aws_iot_topic_rule.stadium_iot.arn
}

resource "aws_iot_topic_rule" "stadium_iot" {
  name        = "stadium_iot_ingestion"
  enabled     = true
  sql         = "SELECT * FROM 'stadium/iot/events'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.iot_ingestion.arn
  }
}