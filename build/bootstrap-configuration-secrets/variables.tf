variable "build_container_pat" {
  type        = string
  sensitive   = true
  description = "A GitHub personal access token for pushing Docker images"
}

variable "npm_auth_token" {
  type        = string
  sensitive   = true
  description = "An NPM Auth Token (Automation type) for publishing NPM packages"
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
