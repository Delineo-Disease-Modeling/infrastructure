terraform {
  backend "azurerm" {
    key = "production.terraform.tfstate.configuration"
  }
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>1.5.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.66.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "configuration" {
  source                = "../../modules/configuration"
  key_vault_name        = "${var.storage_account_name}-config-prod"
  admin_principal_names = var.admin_principal_names
}
