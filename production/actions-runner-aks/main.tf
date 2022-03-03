terraform {
  backend "azurerm" {
    key = "production.terraform.tfstate.actions-runner-aks"
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

  name = "${var.resource_group_prefix}-runner-prod"
  tags = {
    environment = "actionsRunners"
  }
  max_nodes   = 4
  vm_sku_name = "Standard_E2a_v4"
}
