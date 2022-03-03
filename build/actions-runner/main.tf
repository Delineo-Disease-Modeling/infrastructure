terraform {
  backend "azurerm" {
    key = "build.terraform.tfstate.actions-runner"
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

resource "github_actions_secret" "gpr_user" {
  repository      = "model-runner"
  secret_name     = "GPR_USER"
  plaintext_value = var.build_container_user
}

resource "github_actions_secret" "gpr_pat" {
  repository      = "model-runner"
  secret_name     = "GPR_PAT"
  plaintext_value = data.azurerm_key_vault_secret.secrets["build_container_pat"].value
}

resource "github_actions_secret" "npm_auth_token" {
  repository      = "model-runner"
  secret_name     = "NPM_AUTH_TOKEN"
  plaintext_value = data.azurerm_key_vault_secret.secrets["npm_auth_token"].value
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

data "azurerm_key_vault_secret" "secrets" {
  name         = replace(each.key, "_", "-")
  key_vault_id = data.terraform_remote_state.configuration.outputs.key_vault_id
  for_each = toset([
    "build_container_pat",
    "npm_auth_token"
  ])
}
