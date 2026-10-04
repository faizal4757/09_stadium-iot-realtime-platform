
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  stadium_iot_role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/stadium-iot-databricks-access"
}

# --------------------------------------------------
# Databricks IAM role
# --------------------------------------------------

resource "aws_iam_role" "stadium_iot_access" {
  name = "stadium-iot-databricks-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowDatabricksAssumeRole"
        Effect = "Allow"

        Principal = {
          AWS = var.databricks_trusted_principal_arn
        }

        Action = "sts:AssumeRole"

        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.databricks_external_id
          }
        }
      },
      {
        Sid    = "AllowRoleToAssumeItself"
        Effect = "Allow"

        Principal = {
          AWS = local.stadium_iot_role_arn
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Databricks Unity Catalog S3 Access"
  }
}

resource "aws_iam_role_policy" "stadium_iot_s3" {
  name = "stadium-iot-databricks-s3-access"
  role = aws_iam_role.stadium_iot_access.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "FullAccessToStadiumIoTBuckets"
        Effect = "Allow"

        Action = [
          "s3:*"
        ]

        Resource = [
          aws_s3_bucket.raw_data.arn,
          "${aws_s3_bucket.raw_data.arn}/*",
          aws_s3_bucket.databricks_data.arn,
          "${aws_s3_bucket.databricks_data.arn}/*"
        ]
      },
      {
        Sid    = "AllowRoleToAssumeItself"
        Effect = "Allow"

        Action = [
          "sts:AssumeRole"
        ]

        Resource = local.stadium_iot_role_arn
      }
    ]
  })
}

# --------------------------------------------------
# Kinesis Data Firehose IAM role
# --------------------------------------------------

resource "aws_iam_role" "firehose_access" {
  name = var.firehose_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowFirehoseAssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "firehose.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Kinesis Firehose S3 Delivery"
  }
}

# --------------------------------------------------
# Firehose permissions to read Kinesis and write to S3
# --------------------------------------------------

resource "aws_iam_role_policy" "firehose_access" {
  name = "stadium-iot-firehose-policy"
  role = aws_iam_role.firehose_access.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadFromKinesisStream"
        Effect = "Allow"

        Action = [
          "kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards"
        ]

        Resource = aws_kinesis_stream.stadium_iot_events.arn
      },
      {
        Sid    = "AccessRawS3Bucket"
        Effect = "Allow"

        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]

        Resource = aws_s3_bucket.raw_data.arn
      },
      {
        Sid    = "WriteObjectsToRawS3Bucket"
        Effect = "Allow"

        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.raw_data.arn}/*"
      }
    ]
  })
}