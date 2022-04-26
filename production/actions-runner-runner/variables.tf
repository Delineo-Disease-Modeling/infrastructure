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

variable "control_repo_nwo" {
  default     = "Delineo-Disease-Modeling/control-plane-production"
  type        = string
  description = "The name (with owner) of the control-plane repo"
}

