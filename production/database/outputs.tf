output "mysql_db_name" {
  value = module.database.mysql_db_name
}

output "mysql_db_username" {
  value = "${module.database.mysql_db_username}@${data.terraform_remote_state.database_server.outputs.mysql_server_name}"
}
