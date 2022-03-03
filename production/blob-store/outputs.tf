output "blob_store_name" {
  value = module.blob-store.blob_store_name
}

output "blob_container_resource_manager_id" {
  value = module.blob-store.blob_container_resource_manager_id
}

output "blob_storage_primary_key" {
  value     = module.blob-store.blob_storage_primary_key
  sensitive = true
}

output "blob_storage_primary_connection_string" {
  value     = module.blob-store.blob_storage_primary_connection_string
  sensitive = true
}

output "blob_store_account_name" {
  value = module.blob-store.blob_store_account_name
}
