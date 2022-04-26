variable "repo_name" {
  type        = string
  description = "The name (*without* owner) of the control-plane repo"
}

variable "api_shared_secret" {
  type        = string
  sensitive   = true
  description = "A secret shared with the web-ui to authenticate callbacks."
}

variable "azure_storage_account" {
  type        = string
  description = "The blob storage account, which should be in secret storage."
}

variable "azure_storage_container" {
  type        = string
  description = "The blob storage container, which should be in secret storage."
}

variable "azure_storage_key" {
  type        = string
  description = "The blob storage account key, which should be in secret storage."
}

variable "gpr_pat" {
  type        = string
  description = "A GitHub personal access token for retrieving Docker images for Container Instances"
  sensitive   = true
}

variable "gpr_user" {
  type        = string
  description = "A GitHub username for retrieving Docker images for Container Instances"
}

variable "keep_artifacts" {
  type        = string
  description = "A comma-separated list of GitHub Actions for each build: input,output,log"
}

variable "proxy_url" {
  type        = string
  description = "The externally visible URL for the service (including protocol)"
  default     = ""
}

variable "runner_version" {
  type        = string
  description = "Version of model-runner package to install"
}

variable "webhook_server_address" {
  type        = string
  description = "URL of actions-runner webhook server"
}

variable "webhook_shared_secret" {
  type        = string
  sensitive   = true
  description = "A secret shared with the actions-runner to authenticate webhook events."
}
