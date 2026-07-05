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

variable "target_vm_ids" {
  description = "VM IDs assigned directly to the maintenance configuration, keyed by stable logical VM name."
  type        = map(string)
  default     = {}
}

variable "deploy_dynamic_scope" {
  description = "Deploy dynamic scope assignment."
  type        = bool
  default     = true
}

variable "dynamic_scope_subscription_id" {
  description = "Subscription ID used for dynamic scope targeting."
  type        = string
}

variable "dynamic_scope_resource_group" {
  description = "Resource group name used in dynamic scope targeting."
  type        = string
}

variable "dynamic_scope_tag_name" {
  description = "Tag name used by dynamic scope."
  type        = string
  default     = "PatchGroup"
}

variable "dynamic_scope_tag_values" {
  description = "Tag values used by dynamic scope."
  type        = list(string)
  default     = ["weekend"]
}

variable "patch_start_date_time" {
  description = "Patch schedule start date/time."
  type        = string
}

variable "patch_duration" {
  description = "Patch duration."
  type        = string
}

variable "patch_time_zone" {
  description = "Patch time zone."
  type        = string
}

variable "patch_recur_every" {
  description = "Patch recurrence."
  type        = string
}

variable "patch_reboot_setting" {
  description = "Patch reboot setting."
  type        = string
}

variable "windows_classifications" {
  description = "Windows classifications."
  type        = list(string)
  default     = ["Critical", "Security"]
}

variable "linux_classifications" {
  description = "Linux classifications."
  type        = list(string)
  default     = ["Critical", "Security"]
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
