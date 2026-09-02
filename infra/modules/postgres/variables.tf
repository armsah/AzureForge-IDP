variable "server_name" {
  description = "Azure Database for PostgreSQL Flexible Server name."
  type        = string

  validation {
    condition = (
      length(var.server_name) >= 3 &&
      length(var.server_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.server_name))
    )
    error_message = "PostgreSQL server name must be 3-63 lowercase letters, numbers, or hyphens and must start and end with a letter or number."
  }
}

variable "database_name" {
  description = "Application database created on the PostgreSQL Flexible Server."
  type        = string

  validation {
    condition     = length(trimspace(var.database_name)) >= 1 && length(var.database_name) <= 63
    error_message = "PostgreSQL database name must be between 1 and 63 characters."
  }
}

variable "resource_group_name" {
  description = "Resource group in which PostgreSQL resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for PostgreSQL resources."
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"

  validation {
    condition     = contains(["13", "14", "15", "16", "17"], var.postgres_version)
    error_message = "PostgreSQL version must be one of 13, 14, 15, 16, or 17."
  }
}

variable "administrator_login" {
  description = "PostgreSQL administrator login name."
  type        = string
  default     = "azureforgeadmin"

  validation {
    condition     = length(trimspace(var.administrator_login)) >= 1
    error_message = "PostgreSQL administrator login cannot be empty."
  }
}

variable "administrator_password" {
  description = "PostgreSQL administrator password supplied by the privileged provisioning workflow."
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "PostgreSQL Flexible Server compute SKU."
  type        = string
  default     = "B_Standard_B1ms"

  validation {
    condition     = length(trimspace(var.sku_name)) > 0
    error_message = "PostgreSQL SKU name cannot be empty."
  }
}

variable "storage_mb" {
  description = "PostgreSQL storage allocation in megabytes."
  type        = number
  default     = 32768

  validation {
    condition     = var.storage_mb >= 32768
    error_message = "PostgreSQL storage must be at least 32768 MB."
  }
}

variable "backup_retention_days" {
  description = "Number of days PostgreSQL backups are retained."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "PostgreSQL backup retention must be between 7 and 35 days."
  }
}

variable "public_network_access_enabled" {
  description = "Whether the PostgreSQL Flexible Server is reachable through its public network endpoint."
  type        = bool
  default     = false
}

variable "tags" {
  description = "AzureForge tags applied to PostgreSQL resources."
  type        = map(string)
}
