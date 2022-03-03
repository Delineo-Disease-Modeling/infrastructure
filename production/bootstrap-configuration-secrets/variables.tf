variable "github_actions_runner_pat" {
  type        = string
  sensitive   = true
  description = "A GitHub personal access token for registering the actions runner"
}

variable "actions_runner_vm_admin_password" {
  type        = string
  sensitive   = true
  description = "The password for admin access to the VM"
}

variable "github_api_pat" {
  type        = string
  sensitive   = true
  description = "A GitHub personal access token for sending repository dispatch requests."
}

variable "github_container_ui_install_pat" {
  type        = string
  sensitive   = true
  description = "A GitHub personal access token for retrieving Docker images for Container Instances"
}

variable "oauth_client_secret" {
  type        = string
  sensitive   = true
  description = "The client secret for a GitHub OAuth application."
}

variable "oauth_secret" {
  type        = string
  sensitive   = true
  description = "A secret used to sign OAuth state values. Use something such as `openssl rand -hex 32` to generate it."
}

variable "mysql_admin_password" {
  type        = string
  sensitive   = true
  description = "The password for admin access to the DB"
}

variable "mysql_appuser_password" {
  type        = string
  sensitive   = true
  description = "The password for app user access to the DB"
}

variable "runner_shared_secret" {
  type        = string
  sensitive   = true
  description = "A secret shared with the control plane repository to authenticate callbacks."
}

variable "webhook_shared_secret" {
  type        = string
  sensitive   = true
  description = "A secret shared between the control plane repository and actions-runner-aks to authenticate webhook events."
}

variable "session_secret" {
  type        = string
  sensitive   = true
  description = "A secret used to sign session cookies. Use something such as `openssl rand -hex 32` to generate it."
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

variable "certificate_basename" {
  type        = string
  description = "Name (without suffix) of certificate/key and related files"
}
