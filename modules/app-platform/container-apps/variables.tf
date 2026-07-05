variable "environment_name" {
  description = "Container Apps environment name."
  type        = string
}

variable "container_app_name" {
  description = "Container App name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace ID for Container Apps environment logs."
  type        = string
  default     = null
}

variable "image" {
  description = "Container image for the demo Container App."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "target_port" {
  description = "Container ingress target port."
  type        = number
  default     = 80
}

variable "cpu" {
  description = "Container CPU cores."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Container memory."
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Minimum Container App replicas."
  type        = number
  default     = 0

  validation {
    condition     = var.min_replicas >= 0 && floor(var.min_replicas) == var.min_replicas
    error_message = "Container App min replicas must be a whole number of at least 0."
  }
}

variable "max_replicas" {
  description = "Maximum Container App replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.max_replicas >= 1 && floor(var.max_replicas) == var.max_replicas
    error_message = "Container App max replicas must be a whole number of at least 1."
  }
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
