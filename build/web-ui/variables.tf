variable "github_admin_pat" {
  type        = string
  sensitive   = true
  description = "A GitHub personal access token for updating repository secrets"
  default     = ""
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
  type        = string
  description = "A GitHub organization containing the web-ui repo"
}

variable "build_container_user" {
  type        = string
  description = "A GitHub user for pushing Docker images"
}
