output "web_ui_fqdn" {
  value = azurerm_container_group.web_ui.fqdn
}

output "resource_group_name" {
  value = azurerm_resource_group.web_ui.name
}

output "container_group_name" {
  value = azurerm_container_group.web_ui.name
}

output "container_name" {
  value = azurerm_container_group.web_ui.container[0].name
}
