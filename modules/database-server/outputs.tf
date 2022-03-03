output "mysql_server_name" {
  value = azurerm_mysql_server.mysql_server.name
}

output "mysql_server_name_fqdn" {
  value = azurerm_mysql_server.mysql_server.fqdn
}

output "mysql_server_name_username" {
  value = "${azurerm_mysql_server.mysql_server.administrator_login}@${azurerm_mysql_server.mysql_server.name}"
}

output "mysql_server_name_database" {
  value = azurerm_mysql_server.mysql_server.name
}
