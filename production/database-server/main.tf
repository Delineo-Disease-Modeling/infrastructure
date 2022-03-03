terraform {
  backend "azurerm" {
    key = "production.terraform.tfstate.database-server"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.66.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "database-server" {
  source = "../../modules/database-server"

  name                  = "${var.resource_group_prefix}-database-prod"
  mysql_admin_password  = data.azurerm_key_vault_secret.secrets["mysql_admin_password"].value
  sku_name              = "B_Gen5_1"
  admin_username        = "covid19-db-admin"
  db_storage_size_mb    = 5120 #1GB
  backup_retention_days = 7

  # Previous production instance had:
  # sku_name = "GP_Gen5_8"
  # db_storage_size_mb = 1048576 #1TB
}

data "terraform_remote_state" "configuration" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = "production.terraform.tfstate.configuration"
  }
}

data "azurerm_key_vault_secret" "secrets" {
  name         = replace(each.key, "_", "-")
  key_vault_id = data.terraform_remote_state.configuration.outputs.key_vault_id
  for_each = toset([
    "mysql_admin_password"
  ])
}
