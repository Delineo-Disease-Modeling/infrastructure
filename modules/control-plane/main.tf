terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~>4.5.1"
    }
  }
}

resource "github_actions_secret" "api_shared_secret" {
  repository      = var.repo_name
  secret_name     = "API_SHARED_SECRET"
  plaintext_value = var.api_shared_secret
}

resource "github_actions_secret" "azure_storage_account" {
  repository      = var.repo_name
  secret_name     = "AZURE_STORAGE_ACCOUNT"
  plaintext_value = var.azure_storage_account
}

resource "github_actions_secret" "azure_storage_container" {
  repository      = var.repo_name
  secret_name     = "AZURE_STORAGE_CONTAINER"
  plaintext_value = var.azure_storage_container
}

resource "github_actions_secret" "azure_storage_key" {
  repository      = var.repo_name
  secret_name     = "AZURE_STORAGE_KEY"
  plaintext_value = var.azure_storage_key
}

resource "github_actions_secret" "gpr_pat" {
  repository      = var.repo_name
  secret_name     = "GPR_PAT"
  plaintext_value = var.gpr_pat
}

resource "github_actions_secret" "gpr_user" {
  repository      = var.repo_name
  secret_name     = "GPR_USER"
  plaintext_value = var.gpr_user
}

resource "github_actions_secret" "keep_artifacts" {
  repository      = var.repo_name
  secret_name     = "KEEP_ARTIFACTS"
  plaintext_value = var.keep_artifacts
}

resource "github_actions_secret" "runner_version" {
  repository      = var.repo_name
  secret_name     = "RUNNER_VERSION"
  plaintext_value = var.runner_version
}

resource "github_repository_webhook" "actions_runner" {
  repository = var.repo_name
  configuration {
    url    = "http://${var.webhook_server_address}"
    secret = var.webhook_shared_secret
  }
  events = [
    "workflow_job",
  ]
}
