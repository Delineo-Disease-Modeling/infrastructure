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

variable "admin_principal_names" {
  default     = ["jbian6@jh.edu"]
  type        = list(string)
  description = "Principal names of users who can read/update secrets"
}
