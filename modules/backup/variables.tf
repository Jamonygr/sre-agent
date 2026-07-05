variable "name_suffix" {
  description = "Name suffix."
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

variable "protected_vm_ids" {
  description = "VM IDs to protect, keyed by stable logical VM name."
  type        = map(string)
  default     = {}
}

variable "backup_time" {
  description = "Daily backup time."
  type        = string
  default     = "23:00"
}

variable "retention_daily_count" {
  description = "Daily retention count."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
