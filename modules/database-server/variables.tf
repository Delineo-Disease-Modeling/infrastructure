variable "location" {
  type        = string
  description = "The location where resources will be created"
  default     = "UK South"
}

variable "name" {
  type        = string
  description = "The base name to use for all resources created"
}

variable "admin_username" {
  type        = string
  description = "The username for an admin to access the DB"
}
variable "sku_name" {
  type        = string
  description = "The sku name to use for the mysql server"
}

variable "db_storage_size_mb" {
  type        = string
  description = "The size of the mysql DB server storage"
}

variable "backup_retention_days" {
  type        = string
  description = "How long to keep DB backups for"
}

variable "mysql_admin_password" {
  type        = string
  description = "The password for admin access to the DB"
  sensitive   = true
}
