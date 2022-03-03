terraform {
  backend "azurerm" {
    key = "production.terraform.tfstate.actions-runner-runner"
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.5.1"
    }
  }
}

data "terraform_remote_state" "actions_runner_aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = "production.terraform.tfstate.actions-runner-aks"
  }
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

module "actions-runner-runner" {
  source = "../../modules/actions-runner-runner"

  control_repo_nwo = var.control_repo_nwo
  namespace        = data.terraform_remote_state.actions_runner_controller.outputs.namespace
  runner_version   = "v0.0.1"
  max_runners      = 18
}
