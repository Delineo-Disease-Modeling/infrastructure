terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.81.0"
    }
  }
}

resource "azurerm_resource_group" "aks" {
  name     = "${var.name}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name}-aks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${replace(var.name, "-", "")}aks"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_B2s"
    node_count = 1
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "standard" {
  name                  = "standard"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.vm_sku_name
  enable_auto_scaling   = true
  min_count             = 0
  max_count             = var.max_nodes

  tags = var.tags
}
