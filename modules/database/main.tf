terraform {
  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = ">=2.2.2"
    }
  }
}

resource "mysql_database" "mysql_database" {
  name = "${var.name}_db"
}

resource "mysql_user" "appuser" {
  user               = var.app_username
  host               = "%"
  plaintext_password = var.mysql_appuser_password
}

resource "mysql_grant" "appuser" {
  user     = mysql_user.appuser.user
  host     = "%"
  database = mysql_database.mysql_database.name
  privileges = [
    "SELECT", "INSERT", "UPDATE", "DELETE", "CREATE", "DROP",
    "REFERENCES", "INDEX", "ALTER",
    "CREATE TEMPORARY TABLES", "LOCK TABLES", "EXECUTE",
    "CREATE VIEW", "SHOW VIEW", "CREATE ROUTINE",
    "ALTER ROUTINE", "TRIGGER"
  ]
}

