variable "resource_group_name" {
  type        = string
  description = "Resource group name containing Terraform state"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name containing Terraform state"
}

variable "container_name" {
  type        = string
  description = "Container name containing Terraform state"
}

variable "resource_group_prefix" {
  default     = "delineo"
  type        = string
  description = "Short prefix used in resource group / storage account names. These should be meaningful to your deployment, as they are used in some resource names which need to be *globally* unique in Azure"
}
