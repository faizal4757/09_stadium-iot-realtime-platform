resource "databricks_storage_credential" "stadium_iot_s3" {
  name = "stadium-iot-s3-storage-credential"

  aws_iam_role {
    role_arn = aws_iam_role.stadium_iot_access.arn
  }

  comment = "Storage credential for the Stadium IoT data platform"
}