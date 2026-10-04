resource "aws_kinesis_stream" "stadium_iot_events" {
  name        = var.kinesis_stream_name
  shard_count = 1

  retention_period = 24

  tags = {
    Name        = var.kinesis_stream_name
    Project     = "stadium-iot-realtime"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}