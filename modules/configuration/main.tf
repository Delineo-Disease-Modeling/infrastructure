terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=1.5.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.66.0"
    }
  }
}

data "azurerm_resource_group" "terraform" {
  name = "terraform"
}

data "azurerm_client_config" "current" {}

data "azuread_users" "admins" {
  user_principal_names = var.admin_principal_names
}

resource "azurerm_key_vault" "configuration" {
  name                = var.key_vault_name
  location            = data.azurerm_resource_group.terraform.location
  resource_group_name = data.azurerm_resource_group.terraform.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  dynamic "access_policy" {
    for_each = data.azuread_users.admins.users
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = access_policy.value.object_id

      secret_permissions = [
        "list",
        "set",
        "get",
        "delete",
        "purge",
        "recover"
      ]
    }
  }
}
