variable "location" {
  type        = string
  description = "The location where resources will be created"
  default     = "UK South"
}

variable "name" {
  type        = string
  description = "The base name to use for all resources created"
}

variable "ui_container_image" {
  type        = string
  description = "The web-ui container image (without registry name or tag) to deploy"
  default     = "covid-policy-modelling/web-ui/web-ui"
}

variable "ui_container_registry" {
  type        = string
  description = "The container registry to fetch the web-ui container image from"
  default     = "ghcr.io"
}

variable "ui_container_registry_user" {
  type        = string
  description = "The user ID to log in to the container image registry"
}

variable "ui_container_registry_password" {
  type        = string
  description = "The password (e.g. GitHub personal access token) to log in to the container image registry"
  sensitive   = true
}

variable "ui_container_image_tag" {
  type        = string
  description = "The version of the web-ui container to deploy"
}

variable "blob_store_account" {
  type        = string
  description = "The blob storage account, which should be in secret storage."
}

variable "blob_store" {
  type        = string
  description = "The blob storage container, which should be in secret storage."
}

variable "blob_store_key" {
  type        = string
  description = "The blob storage account key, which should be in secret storage."
  sensitive   = true
}

variable "control_repo" {
  type        = string
  description = "The name-with-owner of the control plane repo to dispatch to."
}

variable "db" {
  type        = string
  description = "The database name."
}

variable "db_host" {
  type        = string
  description = "The host for the database."
}

variable "db_password" {
  type        = string
  description = "The password for the database."
  sensitive   = true
}

variable "db_username" {
  type        = string
  description = "The username for the database."
}

variable "github_api_pat" {
  type        = string
  description = "The GitHub personal access token for sending repository dispatch requests."
  sensitive   = true
}

variable "github_client_id" {
  type        = string
  description = "The client ID for a GitHub OAuth application."
}

variable "github_client_secret" {
  type        = string
  description = "The client secret for a GitHub OAuth application."
  sensitive   = true
}

variable "oauth_secret" {
  type        = string
  description = "A secret used to sign OAuth state values. Use something such as `openssl rand -hex 32` to generate it."
  sensitive   = true
}

variable "proxy_url" {
  type        = string
  description = "The externally visible URL for the service (excluding protocol)"
}

variable "runner_shared_secret" {
  type        = string
  description = "A secret shared with the control plane repository to authenticate callbacks."
  sensitive   = true
}

variable "session_secret" {
  type        = string
  description = "A secret used to sign session cookies. Use something such as `openssl rand -hex 32` to generate it."
  sensitive   = true
}

variable "ssl_crt" {
  type        = string
  description = "SSL certificate (must be for the expected proxy_url)"
}

variable "ssl_key" {
  type        = string
  description = "SSL private key"
  sensitive   = true
}

variable "letsencrypt_challenge_name" {
  type        = string
  description = "Let's Encrypt HTTP Challenge filename (must be for the expected proxy_url)"
  default     = ""
}

variable "letsencrypt_challenge_value" {
  type        = string
  description = "Let's Encrypt HTTP Challenge value (must be for the expected proxy_url)"
  sensitive   = true
  default     = ""
}
