terraform {
  backend "azurerm" {
    key = "build.terraform.tfstate.configuration-secrets"
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

data "terraform_remote_state" "configuration" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = "build.terraform.tfstate.configuration"
  }
}

resource "azurerm_key_vault_secret" "secrets" {
  name         = replace(each.key, "_", "-")
  value        = each.value
  key_vault_id = data.terraform_remote_state.configuration.outputs.key_vault_id
  for_each = {
    build_container_pat = var.build_container_pat,
    npm_auth_token      = var.npm_auth_token,
  }
}
