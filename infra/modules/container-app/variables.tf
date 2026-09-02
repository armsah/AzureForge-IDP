variable "environment_name" {
  description = "Azure Container Apps environment name."
  type        = string

  validation {
    condition     = length(trimspace(var.environment_name)) >= 2 && length(var.environment_name) <= 60
    error_message = "Container Apps environment name must be between 2 and 60 characters."
  }
}

variable "container_app_name" {
  description = "Azure Container App name."
  type        = string

  validation {
    condition     = length(trimspace(var.container_app_name)) >= 2 && length(var.container_app_name) <= 32
    error_message = "Container App name must be between 2 and 32 characters."
  }
}

variable "resource_group_name" {
  description = "Resource group in which Container Apps resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for Container Apps resources."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID used by the Container Apps environment."
  type        = string
}

variable "managed_identity_id" {
  description = "Resource ID of the user-assigned managed identity attached to the Container App."
  type        = string
}

variable "image" {
  description = "Container image deployed by the Container App."
  type        = string
}

variable "target_port" {
  description = "Container port exposed through Container Apps ingress."
  type        = number
  default     = 80

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "Target port must be between 1 and 65535."
  }
}

variable "public_ingress" {
  description = "Whether the Container App ingress is reachable from outside the Container Apps environment."
  type        = bool
  default     = false
}

variable "cpu" {
  description = "CPU cores allocated to the container."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocated to the container."
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Minimum number of Container App replicas."
  type        = number
  default     = 0

  validation {
    condition     = var.min_replicas >= 0
    error_message = "Minimum replicas cannot be negative."
  }
}

variable "max_replicas" {
  description = "Maximum number of Container App replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.max_replicas >= 1
    error_message = "Maximum replicas must be at least 1."
  }
}

variable "tags" {
  description = "AzureForge tags applied to Container Apps resources."
  type        = map(string)
}