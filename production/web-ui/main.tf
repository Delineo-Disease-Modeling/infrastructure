terraform {
  backend "azurerm" {
    key = "production.terraform.tfstate.web-ui"
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
  organization = "covid-policy-modelling"
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

data "terraform_remote_state" "database_server" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = "production.terraform.tfstate.database-server"
  }
}

data "terraform_remote_state" "database" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = "production.terraform.tfstate.database"
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

module "web-ui" {
  source = "../../modules/web-ui"

  name                           = "${var.resource_group_prefix}-web-prod"
  ui_container_image_tag         = "v0.0.15"
  ui_container_registry_user     = var.ui_container_registry_user
  ui_container_registry_password = data.azurerm_key_vault_secret.secrets["github_container_ui_install_pat"].value
  blob_store_account             = data.terraform_remote_state.blob_store.outputs.blob_store_account_name
  blob_store                     = data.terraform_remote_state.blob_store.outputs.blob_store_name
  blob_store_key                 = data.terraform_remote_state.blob_store.outputs.blob_storage_primary_key
  control_repo                   = var.control_repo
  db                             = data.terraform_remote_state.database.outputs.mysql_db_name
  db_host                        = data.terraform_remote_state.database_server.outputs.mysql_server_name_fqdn
  db_password                    = data.azurerm_key_vault_secret.secrets["mysql_appuser_password"].value
  db_username                    = data.terraform_remote_state.database.outputs.mysql_db_username
  github_api_pat                 = data.azurerm_key_vault_secret.secrets["github_api_pat"].value
  github_client_id               = var.github_client_id
  github_client_secret           = data.azurerm_key_vault_secret.secrets["oauth_client_secret"].value
  oauth_secret                   = data.azurerm_key_vault_secret.secrets["oauth_secret"].value
  proxy_url                      = var.proxy_url
  runner_shared_secret           = data.azurerm_key_vault_secret.secrets["runner_shared_secret"].value
  session_secret                 = data.azurerm_key_vault_secret.secrets["session_secret"].value
  letsencrypt_challenge_name     = var.letsencrypt_challenge_name
  letsencrypt_challenge_value    = var.letsencrypt_challenge_value
  ssl_crt                        = data.azurerm_key_vault_secret.secrets["web_ui_crt"].value
  ssl_key                        = data.azurerm_key_vault_secret.secrets["web_ui_crt_key"].value
}

data "azurerm_key_vault_secret" "secrets" {
  name         = replace(each.key, "_", "-")
  key_vault_id = data.terraform_remote_state.configuration.outputs.key_vault_id
  for_each = toset([
    "github_api_pat",
    "github_container_ui_install_pat",
    "oauth_client_secret",
    "oauth_secret",
    "mysql_appuser_password",
    "runner_shared_secret",
    "session_secret",
    "web_ui_crt",
    "web_ui_crt_key",
  ])
}
