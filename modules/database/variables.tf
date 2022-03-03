variable "name" {
  type        = string
  description = "The base name to use for all resources created"
}

variable "app_username" {
  type        = string
  description = "The username for an appuser to access the DB"
}

variable "mysql_appuser_password" {
  type        = string
  description = "The password for app user access to the DB"
  sensitive   = true
}
