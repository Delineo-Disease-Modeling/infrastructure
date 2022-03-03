variable "key_vault_name" {
  type        = string
  description = "Name of the key vault to contain secrets"
}

variable "admin_principal_names" {
  type        = list(any)
  description = "Principal names of users who can read/update secrets"
}
