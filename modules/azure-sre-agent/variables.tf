variable "name" {
  description = "Azure SRE Agent name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.name))
    error_message = "name must be lowercase alphanumeric with optional hyphens, 2-63 characters."
  }
}

variable "resource_group_name" {
  description = "Resource group that contains the Azure SRE Agent and supporting resources."
  type        = string
}

variable "location" {
  description = "Azure SRE Agent region."
  type        = string
}

variable "managed_resource_group_ids" {
  description = "Resource group IDs the Azure SRE Agent can observe."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Existing lab Log Analytics workspace ID to connect to the agent."
  type        = string
  default     = null
  nullable    = true
}

variable "access_level" {
  description = "Azure SRE Agent access level."
  type        = string
  default     = "Low"

  validation {
    condition     = contains(["High", "Low"], var.access_level)
    error_message = "access_level must be High or Low."
  }
}

variable "action_mode" {
  description = "Azure SRE Agent action mode."
  type        = string
  default     = "Review"

  validation {
    condition     = contains(["Review", "Automatic"], var.action_mode)
    error_message = "action_mode must be Review or Automatic."
  }
}

variable "upgrade_channel" {
  description = "Azure SRE Agent runtime upgrade channel."
  type        = string
  default     = "Preview"

  validation {
    condition     = contains(["Stable", "Preview"], var.upgrade_channel)
    error_message = "upgrade_channel must be Stable or Preview."
  }
}

variable "monthly_agent_unit_limit" {
  description = "Monthly active-flow Azure Agent Unit allocation limit."
  type        = number
  default     = 500
}

variable "default_model_provider" {
  description = "Default model provider."
  type        = string
  default     = "MicrosoftFoundry"
}

variable "default_model_name" {
  description = "Default model name."
  type        = string
  default     = "Automatic"
}

variable "azure_monitor_lookback_days" {
  description = "Azure Monitor connector lookback window in days."
  type        = number
  default     = 7
}

variable "enable_azure_monitor_connector" {
  description = "Enable the Azure Monitor connector."
  type        = bool
  default     = true
}

variable "enable_log_analytics_connector" {
  description = "Enable the Log Analytics connector when log_analytics_workspace_id is set."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
