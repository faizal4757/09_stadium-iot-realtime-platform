data "databricks_current_user" "me" {}

resource "databricks_directory" "stadium_iot" {
  path = "${data.databricks_current_user.me.home}/Stadium IoT Real-Time Platform"
}