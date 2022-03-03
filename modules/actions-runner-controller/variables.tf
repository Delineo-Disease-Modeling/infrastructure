variable "github_registration_pat" {
  type        = string
  sensitive   = true
  description = "The Github personal access token to use when registering the Actions Runner"
}

variable "webhook_shared_secret" {
  type        = string
  sensitive   = true
  description = "A secret shared with the control plane repository to authenticate webhook events."
}
