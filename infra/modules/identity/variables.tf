variable "name" {
  description = "User-assigned managed identity name."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) >= 3 && length(var.name) <= 128
    error_message = "Managed identity name must be between 3 and 128 characters."
  }
}

variable "resource_group_name" {
  description = "Resource group in which the identity is created."
  type        = string
}

variable "location" {
  description = "Azure region for the identity."
  type        = string
}

variable "tags" {
  description = "AzureForge tags applied to the identity."
  type        = map(string)
}
