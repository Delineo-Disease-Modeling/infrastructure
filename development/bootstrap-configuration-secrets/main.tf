terraform {
  backend "azurerm" {
    key = "development.terraform.tfstate.configuration-secrets"
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
    key                  = "development.terraform.tfstate.configuration"
  }
}

resource "azurerm_key_vault_secret" "secrets" {
  name         = replace(each.key, "_", "-")
  value        = each.value
  key_vault_id = data.terraform_remote_state.configuration.outputs.key_vault_id
  for_each = {
    github_actions_runner_pat        = var.github_actions_runner_pat,
    actions_runner_vm_admin_password = var.actions_runner_vm_admin_password,
    github_container_ui_install_pat  = var.github_container_ui_install_pat,
    runner_shared_secret             = var.runner_shared_secret,
    webhook_shared_secret            = var.webhook_shared_secret,
  }
}
