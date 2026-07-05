variable "plan_name" {
  description = "App Service plan name."
  type        = string
}

variable "app_name" {
  description = "Linux Web App name."
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

variable "sku_name" {
  description = "App Service plan SKU."
  type        = string
  default     = "B1"
}

variable "worker_count" {
  description = "Optional App Service plan worker count."
  type        = number
  default     = null
}

variable "always_on" {
  description = "Enable Always On for the Web App. Keep false for free/shared SKUs."
  type        = bool
  default     = false
}

variable "app_settings" {
  description = "Additional Web App settings."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
