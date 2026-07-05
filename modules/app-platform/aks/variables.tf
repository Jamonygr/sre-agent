variable "name" {
  description = "AKS cluster name."
  type        = string
}

variable "dns_prefix" {
  description = "AKS DNS prefix."
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

variable "node_count" {
  description = "System node pool node count."
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 5 && floor(var.node_count) == var.node_count
    error_message = "AKS node count must be a whole number between 1 and 5."
  }
}

variable "node_vm_size" {
  description = "System node pool VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "os_disk_size_gb" {
  description = "System node pool OS disk size in GB."
  type        = number
  default     = 64

  validation {
    condition     = var.os_disk_size_gb >= 30 && floor(var.os_disk_size_gb) == var.os_disk_size_gb
    error_message = "AKS OS disk size must be a whole number of at least 30 GB."
  }
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy add-on for AKS."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace ID for AKS Container Insights."
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
