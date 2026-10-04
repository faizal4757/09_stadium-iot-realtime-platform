resource "aws_kinesis_firehose_delivery_stream" "stadium_iot" {
  name        = var.firehose_delivery_stream_name
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.stadium_iot_events.arn
    role_arn           = aws_iam_role.firehose_access.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_access.arn
    bucket_arn = aws_s3_bucket.raw_data.arn
    prefix     = var.firehose_s3_prefix

    buffering_size     = var.firehose_buffer_size_mb
    buffering_interval = var.firehose_buffer_interval_seconds
    compression_format = var.firehose_compression
  }

  depends_on = [
    aws_iam_role_policy.firehose_access
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}