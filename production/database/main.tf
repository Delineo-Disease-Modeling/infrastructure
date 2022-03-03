terraform {
  backend "azurerm" {
    key = "production.terraform.tfstate.database"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.66.0"
    }
    mysql = {
      source  = "petoju/mysql"
      version = "~>2.2.2"
    }
  }
}

data "terraform_remote_state" "database_server" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = "production.terraform.tfstate.database-server"
  }
}

provider "azurerm" {
  features {}
}

provider "mysql" {
  endpoint = data.terraform_remote_state.database_server.outputs.mysql_server_name_fqdn
  username = data.terraform_remote_state.database_server.outputs.mysql_server_name_username
  password = data.azurerm_key_vault_secret.secrets["mysql_admin_password"].value
  tls      = true
}

module "database" {
  source = "../../modules/database"

  name                   = "${var.resource_group_prefix}-database-prod"
  app_username           = "appuser"
  mysql_appuser_password = data.azurerm_key_vault_secret.secrets["mysql_appuser_password"].value
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
    "mysql_appuser_password",
    "mysql_admin_password"
  ])
}
