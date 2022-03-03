output "mysql_db_name" {
  value = mysql_database.mysql_database.name
}

output "mysql_db_username" {
  value = mysql_user.appuser.user
}

