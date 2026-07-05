variable "name" {
  description = "Workspace name."
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

variable "retention_in_days" {
  description = "Retention in days."
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily quota in GB. Null means uncapped."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}

