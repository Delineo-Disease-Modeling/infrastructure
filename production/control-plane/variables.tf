variable "github_admin_pat" {
  type        = string
  sensitive   = true
  description = "A GitHub personal access token for updating repository secrets"
  default     = "Delineo-Disease-Modeling"
}

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

variable "github_organization" {
  default     = "Delineo-Disease-Modeling"
  type        = string
  description = "A GitHub organization containing the control_plane repo"
}

variable "build_container_user" {
  default     = "DelineoCovidUI"
  type        = string
  description = "A GitHub user for pushing Docker images"
}

variable "proxy_url" {
  default     = "delineo-web-prod.uksouth.azurecontainer.io"
  type        = string
  description = "The externally visible URL for the service (including protocol)"
}
