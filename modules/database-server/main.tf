terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.66.0"
    }
  }
}

resource "azurerm_resource_group" "mysql_server" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_mysql_server" "mysql_server" {
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.mysql_server.name

  sku_name = var.sku_name

  storage_mb                   = var.db_storage_size_mb
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = false

  administrator_login          = var.admin_username
  administrator_login_password = var.mysql_admin_password
  version                      = "8.0"
  ssl_enforcement_enabled      = true
}

resource "azurerm_mysql_firewall_rule" "mysql_server_firewall_rule" {
  name                = "all"
  resource_group_name = azurerm_resource_group.mysql_server.name
  server_name         = azurerm_mysql_server.mysql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
