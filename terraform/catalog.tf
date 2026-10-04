resource "databricks_catalog" "stadium_iot_dev" {
  name         = "stadium_iot_dev"
  storage_root = "s3://${var.databricks_bucket_name}/managed/stadium_iot_dev"
  comment      = "Stadium IoT development catalog managed by Terraform"

  properties = {
    environment = "dev"
    project     = "stadium_iot"
    managed_by  = "terraform"
  }

  depends_on = [
    databricks_external_location.stadium_iot_managed
  ]
}

resource "databricks_catalog" "stadium_iot_stg" {
  name         = "stadium_iot_stg"
  storage_root = "s3://${var.databricks_bucket_name}/managed/stadium_iot_stg"
  comment      = "Stadium IoT staging catalog managed by Terraform"

  properties = {
    environment = "stg"
    project     = "stadium_iot"
    managed_by  = "terraform"
  }

  depends_on = [
    databricks_external_location.stadium_iot_managed
  ]
}

resource "databricks_catalog" "stadium_iot_prod" {
  name         = "stadium_iot_prod"
  storage_root = "s3://${var.databricks_bucket_name}/managed/stadium_iot_prod"
  comment      = "Stadium IoT production catalog managed by Terraform"

  properties = {
    environment = "prod"
    project     = "stadium_iot"
    managed_by  = "terraform"
  }

  depends_on = [
    databricks_external_location.stadium_iot_managed
  ]
}