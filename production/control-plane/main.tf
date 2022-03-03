terraform {
  backend "azurerm" {
    key = "production.terraform.tfstate.control-plane"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.66.0"
    }
    github = {
      source  = "integrations/github"
      version = "~>4.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "github" {
  token        = var.github_admin_pat
  organization = var.github_organization
}

locals {
  repo_name = "control-plane-production"
}

module "control-plane" {
  source = "../../modules/control-plane"

  repo_name               = local.repo_name
  api_shared_secret       = data.azurerm_key_vault_secret.secrets["runner_shared_secret"].value
  azure_storage_account   = data.terraform_remote_state.blob_store.outputs.blob_store_account_name
  azure_storage_container = data.terraform_remote_state.blob_store.outputs.blob_store_name
  azure_storage_key       = data.terraform_remote_state.blob_store.outputs.blob_storage_primary_key
  gpr_user                = var.build_container_user
  gpr_pat                 = data.azurerm_key_vault_secret.secrets["github_container_ui_install_pat"].value
  keep_artifacts          = "log"
  runner_version          = "1.2.1"
  webhook_server_address  = data.terraform_remote_state.actions_runner_controller.outputs.github_webhook_server_address
  webhook_shared_secret   = data.azurerm_key_vault_secret.secrets["webhook_shared_secret"].value
}

resource "github_actions_secret" "production_server_url" {
  repository      = "control-plane-production"
  secret_name     = "STAGING_SERVER_URL"
  plaintext_value = var.proxy_url
}

data "terraform_remote_state" "actions_runner_controller" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = "production.terraform.tfstate.actions-runner-controller"
  }
}

data "terraform_remote_state" "blob_store" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = "production.terraform.tfstate.blob-store"
  }
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
    "github_container_ui_install_pat",
    "runner_shared_secret",
    "webhook_shared_secret",
  ])
}
