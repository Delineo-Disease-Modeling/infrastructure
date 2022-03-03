variable "location" {
  type        = string
  description = "The location where resources will be created"
  default     = "UK South"
}

variable "name" {
  type        = string
  description = "The base name to use for all resources created"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(any)
}

variable "max_nodes" {
  type        = string
  description = "The maximum number of runner node VMs to have at any one time"
}

variable "vm_sku_name" {
  type        = string
  description = "The VM Sku to use in the VMSS"
}
