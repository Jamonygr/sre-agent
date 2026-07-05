variable "name" {
  description = "Data collection rule name."
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
  description = "Log Analytics workspace resource ID."
  type        = string
}

variable "target_resource_ids" {
  description = "VM or Arc machine IDs to associate, keyed by stable logical target name."
  type        = map(string)
  default     = {}
}

variable "enable_change_tracking" {
  description = "Enable Change Tracking and Inventory streams."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
