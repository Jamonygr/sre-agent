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

variable "managed_scope_ids" {
  description = "Scopes where the automation identity can manage VMs, keyed by stable logical scope name."
  type        = map(string)
  default     = {}
}

variable "target_resource_group_name" {
  description = "Resource group containing lab VMs."
  type        = string
}

variable "enable_scheduled_startstop" {
  description = "Enable start/stop schedules."
  type        = bool
  default     = true
}

variable "enable_alert_runbook_webhooks" {
  description = "Create Automation webhooks and a remediation action group for alert-triggered runbooks."
  type        = bool
  default     = false
}

variable "webhook_expiry_time" {
  description = "RFC3339 expiry timestamp for alert-triggered Automation webhooks."
  type        = string
  default     = "2027-07-01T00:00:00Z"
}

variable "schedule_timezone" {
  description = "Automation schedule timezone."
  type        = string
  default     = "UTC"
}

variable "start_time" {
  description = "RFC3339 start schedule time."
  type        = string
  default     = "2026-08-01T08:00:00Z"
}

variable "stop_time" {
  description = "RFC3339 stop schedule time."
  type        = string
  default     = "2026-08-01T19:00:00Z"
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
