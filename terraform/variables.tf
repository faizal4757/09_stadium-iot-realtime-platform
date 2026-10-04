variable "aws_region" {
  description = "AWS region for the Stadium IoT platform"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the data platform"
  type        = string
  default     = "stadium-iot-realtime"
}

variable "raw_bucket_name" {
  description = "S3 bucket for raw Stadium IoT events"
  type        = string
}

variable "databricks_bucket_name" {
  description = "S3 bucket for Databricks managed storage"
  type        = string
}

variable "kinesis_stream_name" {
  description = "Name of the Kinesis Data Stream"
  type        = string
  default     = "stadium-iot-events"
}

variable "databricks_trusted_principal_arn" {
  description = "AWS principal ARN provided by Databricks for Unity Catalog role trust"
  type        = string
}

variable "databricks_external_id" {
  description = "External ID provided for the Databricks Unity Catalog trust relationship"
  type        = string
  sensitive   = true
}

variable "firehose_delivery_stream_name" {
  description = "Name of the Kinesis Data Firehose delivery stream"
  type        = string
  default     = "stadium-iot-firehose"
}

variable "firehose_iam_role_name" {
  description = "IAM role assumed by Kinesis Data Firehose"
  type        = string
  default     = "stadium-iot-firehose-access"
}

variable "firehose_s3_prefix" {
  description = "S3 prefix for raw Firehose events"
  type        = string
  default     = "raw/stadium_iot/"
}

variable "firehose_buffer_size_mb" {
  description = "Firehose S3 buffering size in MiB"
  type        = number
  default     = 5
}

variable "firehose_buffer_interval_seconds" {
  description = "Firehose S3 buffering interval in seconds"
  type        = number
  default     = 60
}

variable "firehose_compression" {
  description = "Compression format for Firehose S3 delivery"
  type        = string
  default     = "GZIP"
}