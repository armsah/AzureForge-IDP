variable "name" {
  description = "Azure resource group name."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) >= 1 && length(var.name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "Azure region for the resource group."
  type        = string

  validation {
    condition     = contains(["westeurope", "northeurope"], lower(var.location))
    error_message = "Location must be one of the AzureForge P2 approved regions: westeurope, northeurope."
  }
}

variable "tags" {
  description = "Mandatory AzureForge tags applied to the resource group."
  type        = map(string)

  validation {
    condition = alltrue([
      for required_tag in ["service", "team", "environment", "managed-by", "criticality"] :
      contains(keys(var.tags), required_tag) && try(trimspace(var.tags[required_tag]) != "", false)
    ])
    error_message = "Tags must include non-empty service, team, environment, managed-by, and criticality values."
  }

  validation {
    condition     = try(var.tags["managed-by"] == "azureforge", false)
    error_message = "The managed-by tag must be 'azureforge'."
  }
}
