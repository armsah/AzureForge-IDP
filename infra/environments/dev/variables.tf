variable "service_name" {
  description = "AzureForge service name."
  type        = string
}

variable "team" {
  description = "Team owning the service."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = var.environment == "dev"
    error_message = "This composition root supports the dev environment only."
  }
}

variable "location" {
  description = "Azure deployment region."
  type        = string

  validation {
    condition     = contains(["westeurope", "northeurope"], lower(var.location))
    error_message = "Location must be westeurope or northeurope."
  }
}

variable "resource_group_name" {
  description = "Generated Azure resource group name."
  type        = string
}

variable "managed_identity_name" {
  description = "Generated managed identity name."
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Generated Log Analytics workspace name."
  type        = string
}

variable "application_insights_name" {
  description = "Generated Application Insights name."
  type        = string
}

variable "runtime_language" {
  description = "Service runtime language."
  type        = string
}

variable "runtime_version" {
  description = "Service runtime version."
  type        = string
}

variable "compute_type" {
  description = "AzureForge compute type."
  type        = string

  validation {
    condition     = var.compute_type == "container-apps"
    error_message = "The current golden path supports compute_type = container-apps only."
  }
}

variable "min_replicas" {
  description = "Minimum Container App replicas."
  type        = number
}

variable "max_replicas" {
  description = "Maximum Container App replicas."
  type        = number

  validation {
    condition     = var.max_replicas >= var.min_replicas
    error_message = "max_replicas must be greater than or equal to min_replicas."
  }
}

variable "postgres_enabled" {
  description = "Whether the PostgreSQL capability is enabled."
  type        = bool
}

variable "postgres_administrator_password" {
  description = "PostgreSQL administrator password supplied by the privileged provisioning workflow."
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition = (
      !var.postgres_enabled ||
      try(length(var.postgres_administrator_password) >= 12, false)
    )
    error_message = "postgres_administrator_password must contain at least 12 characters when PostgreSQL is enabled."
  }
}

variable "service_bus_queues" {
  description = "Requested Service Bus queues."
  type        = list(string)

  validation {
    condition = alltrue([
      for name in var.service_bus_queues :
      length(trimspace(name)) >= 1
    ])
    error_message = "Service Bus queue names cannot be empty."
  }
}

variable "public_ingress" {
  description = "Whether the Container App has external ingress."
  type        = bool
}

variable "workload_identity" {
  description = "Whether workload identity is enabled."
  type        = bool

  validation {
    condition     = var.workload_identity
    error_message = "The current golden path requires workload_identity = true."
  }
}

variable "application_insights_enabled" {
  description = "Whether Application Insights is enabled."
  type        = bool
}

variable "alerts" {
  description = "AzureForge alert policy applied to the service."
  type        = string

  validation {
    condition     = contains(["none", "standard"], var.alerts)
    error_message = "alerts must be either none or standard."
  }
}

variable "monthly_budget_eur" {
  description = "Requested monthly budget in EUR. Budget enforcement is deferred to P11."
  type        = number
}

variable "tags" {
  description = "AzureForge generated resource tags."
  type        = map(string)
}
