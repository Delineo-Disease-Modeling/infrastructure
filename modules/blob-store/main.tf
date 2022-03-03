terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.66.0"
    }
  }
}

resource "azurerm_resource_group" "blob_store" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_storage_account" "blob_store" {
  name                     = "${replace(var.name, "-", "")}act"
  resource_group_name      = azurerm_resource_group.blob_store.name
  location                 = azurerm_resource_group.blob_store.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "blob_store" {
  name                  = "${var.name}-storage-container"
  storage_account_name  = azurerm_storage_account.blob_store.name
  container_access_type = "private"
}

data "azurerm_subscription" "primary" {
}

data "azurerm_role_definition" "builtin" {
  name = "Storage Blob Data Contributor"
}
