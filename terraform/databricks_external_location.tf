resource "databricks_external_location" "stadium_iot_raw" {
  name = "stadium-iot-raw"

  url = "s3://${aws_s3_bucket.raw_data.bucket}/raw/"

  credential_name = databricks_storage_credential.stadium_iot_s3.name

  comment = "Raw Stadium IoT event archive in S3"

  depends_on = [
    aws_iam_role_policy.stadium_iot_s3
  ]
}

resource "databricks_external_location" "stadium_iot_managed" {
  name = "stadium-iot-managed"

  url = "s3://${aws_s3_bucket.databricks_data.bucket}/managed/"

  credential_name = databricks_storage_credential.stadium_iot_s3.name

  comment = "Managed storage location for Stadium IoT catalogs"

  depends_on = [
    aws_iam_role_policy.stadium_iot_s3
  ]
}