variable "namespace_name" {
  description = "Kubernetes namespace provisioned for the AzureForge service."
  type        = string

  validation {
    condition = (
      length(var.namespace_name) >= 1 &&
      length(var.namespace_name) <= 63 &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace_name))
    )
    error_message = "namespace_name must be a valid Kubernetes DNS label of 1-63 lowercase alphanumeric or hyphen characters."
  }
}

variable "labels" {
  description = "Labels applied to the AzureForge namespace."
  type        = map(string)
  default     = {}
}

variable "quota_cpu_requests" {
  description = "Maximum aggregate CPU requests allowed in the namespace."
  type        = string
  default     = "2"
}

variable "quota_memory_requests" {
  description = "Maximum aggregate memory requests allowed in the namespace."
  type        = string
  default     = "4Gi"
}

variable "quota_cpu_limits" {
  description = "Maximum aggregate CPU limits allowed in the namespace."
  type        = string
  default     = "4"
}

variable "quota_memory_limits" {
  description = "Maximum aggregate memory limits allowed in the namespace."
  type        = string
  default     = "8Gi"
}

variable "quota_pods" {
  description = "Maximum number of pods allowed in the namespace."
  type        = number
  default     = 20

  validation {
    condition     = var.quota_pods >= 1
    error_message = "quota_pods must be greater than or equal to 1."
  }
}

variable "default_cpu_request" {
  description = "Default CPU request assigned to containers that omit one."
  type        = string
  default     = "100m"
}

variable "default_memory_request" {
  description = "Default memory request assigned to containers that omit one."
  type        = string
  default     = "128Mi"
}

variable "default_cpu_limit" {
  description = "Default CPU limit assigned to containers that omit one."
  type        = string
  default     = "500m"
}

variable "default_memory_limit" {
  description = "Default memory limit assigned to containers that omit one."
  type        = string
  default     = "512Mi"
}
