output "blob_store_name" {
  value = azurerm_storage_container.blob_store.name
}

output "blob_container_resource_manager_id" {
  value = azurerm_storage_container.blob_store.resource_manager_id
}

output "blob_store_account_name" {
  value = azurerm_storage_account.blob_store.name
}

output "blob_storage_primary_key" {
  value     = azurerm_storage_account.blob_store.primary_access_key
  sensitive = true
}

output "blob_storage_primary_connection_string" {
  value     = azurerm_storage_account.blob_store.primary_connection_string
  sensitive = true
}
