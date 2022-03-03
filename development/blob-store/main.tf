terraform {
  backend "azurerm" {
    key = "development.terraform.tfstate.blob-store"
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

module "blob-store" {
  source = "../../modules/blob-store"
  name   = "${var.resource_group_prefix}-model-dev"
}
