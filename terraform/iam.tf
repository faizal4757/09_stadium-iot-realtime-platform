
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  stadium_iot_role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/stadium-iot-databricks-access"
}

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