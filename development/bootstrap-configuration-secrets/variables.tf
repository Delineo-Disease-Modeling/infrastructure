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

variable "github_container_ui_install_pat" {
  type        = string
  sensitive   = true
  description = "A GitHub personal access token for retrieving Docker images for Container Instances"
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
