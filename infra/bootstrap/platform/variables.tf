variable "subscription_id" {
  description = "Azure subscription ID used for the P3 bootstrap."
  type        = string
}

variable "location" {
  description = "Azure region for bootstrap resources."
  type        = string
  default     = "westeurope"

  validation {
    condition     = contains(["westeurope", "northeurope"], var.location)
    error_message = "AzureForge bootstrap supports westeurope or northeurope."
  }
}

variable "storage_account_name" {
  description = "Globally unique Azure Storage account name for Terraform state. Use 3-24 lowercase letters/numbers."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must contain 3-24 lowercase letters or numbers."
  }
}

variable "github_owner" {
  description = "GitHub repository owner."
  type        = string
  default     = "armsah"
}

variable "github_repository" {
  description = "GitHub repository name."
  type        = string
  default     = "AzureForge-IDP"
}

variable "github_branch" {
  description = "Git branch trusted by the federated identity credential."
  type        = string
  default     = "main"
}
