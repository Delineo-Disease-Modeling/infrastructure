terraform {
  backend "azurerm" {
    key = "development.terraform.tfstate.actions-runner-controller"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.81.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "actions_runner_aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = "development.terraform.tfstate.actions-runner-aks"
  }
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

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.host
    username               = data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.username
    password               = data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.password
    client_certificate     = base64decode(data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }

  host                   = data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.host
  username               = data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.username
  password               = data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.password
  client_certificate     = base64decode(data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.actions_runner_aks.outputs.kube_config.0.cluster_ca_certificate)
}

module "actions-runner-controller" {
  source = "../../modules/actions-runner-controller"

  github_registration_pat = data.azurerm_key_vault_secret.secrets["github_actions_runner_pat"].value
  webhook_shared_secret   = data.azurerm_key_vault_secret.secrets["webhook_shared_secret"].value
}

data "azurerm_key_vault_secret" "secrets" {
  name         = replace(each.key, "_", "-")
  key_vault_id = data.terraform_remote_state.configuration.outputs.key_vault_id
  for_each = toset([
    "github_actions_runner_pat",
    "webhook_shared_secret",
  ])
}
