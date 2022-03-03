terraform {
  backend "azurerm" {
    key = "production.terraform.tfstate.configuration-secrets"
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
    key                  = "production.terraform.tfstate.configuration"
  }
}

locals {
  secrets = {
    github_actions_runner_pat        = var.github_actions_runner_pat
    actions_runner_vm_admin_password = var.actions_runner_vm_admin_password
    github_api_pat                   = var.github_api_pat
    github_container_ui_install_pat  = var.github_container_ui_install_pat
    oauth_client_secret              = var.oauth_client_secret
    oauth_secret                     = var.oauth_secret
    mysql_admin_password             = var.mysql_admin_password
    mysql_appuser_password           = var.mysql_appuser_password
    runner_shared_secret             = var.runner_shared_secret
    session_secret                   = var.session_secret
    webhook_shared_secret            = var.webhook_shared_secret
    web_ui_crt                       = file("${path.module}/${var.certificate_basename}.pem")
    web_ui_crt_key                   = file("${path.module}/${var.certificate_basename}-key.pem")
  }
}

resource "azurerm_key_vault_secret" "secrets" {
  name         = replace(each.key, "_", "-")
  value        = sensitive(each.value)
  key_vault_id = data.terraform_remote_state.configuration.outputs.key_vault_id
  for_each     = nonsensitive({ for k, v in local.secrets : k => v if v != null })
}
