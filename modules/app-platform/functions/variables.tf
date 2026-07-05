variable "plan_name" {
  description = "Function App service plan name."
  type        = string
}

variable "function_app_name" {
  description = "Linux Function App name."
  type        = string
}

variable "storage_account_name" {
  description = "Function App storage account name."
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
  description = "Function App service plan SKU."
  type        = string
  default     = "Y1"
}

variable "node_version" {
  description = "Function App Node.js runtime version."
  type        = string
  default     = "20"
}

variable "app_settings" {
  description = "Additional Function App settings."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
