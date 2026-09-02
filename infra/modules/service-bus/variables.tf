variable "namespace_name" {
  description = "Azure Service Bus namespace name."
  type        = string

  validation {
    condition = (
      length(var.namespace_name) >= 6 &&
      length(var.namespace_name) <= 50 &&
      can(regex("^[A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]$", var.namespace_name))
    )
    error_message = "Service Bus namespace name must be 6-50 characters, start with a letter, end with a letter or number, and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group in which Service Bus resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for Service Bus resources."
  type        = string
}

variable "sku" {
  description = "Azure Service Bus namespace SKU."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Service Bus SKU must be Basic, Standard, or Premium."
  }
}

variable "queue_names" {
  description = "Service Bus queues created in the namespace."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for name in var.queue_names :
      length(trimspace(name)) >= 1 && length(name) <= 260
    ])
    error_message = "Service Bus queue names must be between 1 and 260 characters."
  }
}

variable "tags" {
  description = "AzureForge tags applied to the Service Bus namespace."
  type        = map(string)
}