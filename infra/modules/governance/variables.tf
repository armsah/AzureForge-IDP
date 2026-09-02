variable "resource_group_id" {
  description = "Resource group scope where AzureForge governance policies are assigned."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[^/]+/resourceGroups/[^/]+$",
      var.resource_group_id
    ))
    error_message = "resource_group_id must be a valid Azure resource group resource ID."
  }
}

variable "allowed_locations" {
  description = "Azure regions approved by the AzureForge golden path."
  type        = set(string)

  default = [
    "westeurope",
    "northeurope"
  ]

  validation {
    condition = (
      length(var.allowed_locations) > 0 &&
      alltrue([
        for location in var.allowed_locations :
        contains(["westeurope", "northeurope"], lower(location))
      ])
    )
    error_message = "Allowed locations must contain only AzureForge-approved regions: westeurope and northeurope."
  }
}

variable "required_tags" {
  description = "AzureForge tags that every taggable service resource must contain."
  type        = set(string)

  default = [
    "service",
    "team",
    "environment",
    "managed-by",
    "criticality"
  ]

  validation {
    condition = (
      length(setsubtract(
        var.required_tags,
        toset([
          "service",
          "team",
          "environment",
          "managed-by",
          "criticality"
        ])
      )) == 0 &&
      length(setsubtract(
        toset([
          "service",
          "team",
          "environment",
          "managed-by",
          "criticality"
        ]),
        var.required_tags
      )) == 0
    )

    error_message = "Required tags must match the AzureForge governance contract: service, team, environment, managed-by, and criticality."
  }
}

variable "managed_by_value" {
  description = "Required value of the AzureForge managed-by tag."
  type        = string
  default     = "azureforge"

  validation {
    condition     = var.managed_by_value == "azureforge"
    error_message = "managed_by_value must be 'azureforge'."
  }
}
