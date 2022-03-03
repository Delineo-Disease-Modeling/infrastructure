terraform {
  backend "azurerm" {
    key = "development.terraform.tfstate.actions-runner-aks"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.81.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "actions-runner-aks" {
  source = "../../modules/actions-runner-aks"

  name = "${var.resource_group_prefix}-runner-dev"
  tags = {
    environment = "actionsRunners"
  }
  max_nodes   = 2
  vm_sku_name = "Standard_E2a_v4"
}
