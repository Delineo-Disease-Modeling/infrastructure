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

variable "resource_group_prefix" {
  default     = "delineo"
  type        = string
  description = "Short prefix used in resource group / storage account names. These should be meaningful to your deployment, as they are used in some resource names which need to be *globally* unique in Azure"
}

variable "ui_container_registry_user" {
  default     = "DelineoCovidUI"
  type        = string
  description = "The user ID to log in to the container image registry"
}

variable "control_repo" {
  default     = "Delineo-Disease-Modeling/control-plane-production"
  type        = string
  description = "The name-with-owner of the control plane repo to dispatch to."
}

variable "github_client_id" {
  default     = "b5015380a6627df0cc4c"
  type        = string
  description = "The client ID for a GitHub OAuth application."
}

variable "proxy_url" {
  default     = "delineo-web-prod.uksouth.azurecontainer.io"
  type        = string
  description = "The externally visible URL for the service (excluding protocol)"
}

variable "letsencrypt_challenge_name" {
  default     = "JCs1hfo4rNz_GChunB916QO0wgZ9mIfTXuZupOXkfmE"
  type        = string
  description = "Let's Encrypt HTTP Challenge filename (must be for the expected proxy_url)"
}

variable "letsencrypt_challenge_value" {
  default     = "JCs1hfo4rNz_GChunB916QO0wgZ9mIfTXuZupOXkfmE.EeVgBZrSuHXuq3WhWkIbg0c7iI4E0dZ80J0qvviAyow"
  type        = string
  description = "Let's Encrypt HTTP Challenge value (must be for the expected proxy_url)"
  sensitive   = true
}
