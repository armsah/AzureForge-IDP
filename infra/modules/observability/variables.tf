variable "resource_group_name" {
  description = "Resource group containing the service observability resources."
  type        = string
}

variable "location" {
  description = "Azure region for observability resources."
  type        = string
}

variable "container_app_id" {
  description = "Resource ID of the Azure Container App monitored by the standard observability baseline."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.App/containerApps/[^/]+$",
      var.container_app_id
    ))
    error_message = "container_app_id must be a valid Azure Container App resource ID."
  }
}

variable "container_app_name" {
  description = "Name of the Azure Container App displayed in observability resources."
  type        = string

  validation {
    condition     = length(var.container_app_name) >= 2 && length(var.container_app_name) <= 32
    error_message = "container_app_name must contain between 2 and 32 characters."
  }
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace queried by the service workbook."
  type        = string
}

variable "alert_policy" {
  description = "AzureForge alert policy applied to the service."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["none", "standard"], var.alert_policy)
    error_message = "alert_policy must be either none or standard."
  }
}

variable "workbook_name" {
  description = "Display name of the Azure Monitor workbook."
  type        = string

  validation {
    condition     = length(trimspace(var.workbook_name)) > 0
    error_message = "workbook_name must not be empty."
  }
}

variable "tags" {
  description = "AzureForge tags applied to observability resources."
  type        = map(string)
}
