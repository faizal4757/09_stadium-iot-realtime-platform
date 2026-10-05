resource "aws_glue_registry" "stadium_iot" {
  registry_name = "stadium-iot"

  description = "Schema registry for Stadium IoT sensor events"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_glue_schema" "sensor_event" {
  registry_arn = aws_glue_registry.stadium_iot.arn
  schema_name  = "SensorEvent"

  data_format   = "AVRO"
  compatibility = "BACKWARD"

  schema_definition = file("${path.module}/schemas/sensor_event_v1.avsc")
}