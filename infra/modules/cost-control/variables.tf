variable "resource_group_id" {
  description = "Resource group scope where the AzureForge monthly cost budget is enforced."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[^/]+/resourceGroups/[^/]+$",
      var.resource_group_id
    ))
    error_message = "resource_group_id must be a valid Azure resource group resource ID."
  }
}

variable "budget_name" {
  description = "Name of the AzureForge resource-group consumption budget."
  type        = string

  validation {
    condition     = length(trimspace(var.budget_name)) > 0
    error_message = "budget_name must not be empty."
  }
}

variable "monthly_budget_eur" {
  description = "Monthly Azure cost budget in EUR for the service environment."
  type        = number

  validation {
    condition     = var.monthly_budget_eur > 0
    error_message = "monthly_budget_eur must be greater than 0."
  }
}