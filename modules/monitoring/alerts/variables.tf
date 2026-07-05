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

variable "monitored_vm_ids" {
  description = "VM IDs to monitor."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID used by KQL scheduled-query alerts."
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "Subscription ID."
  type        = string
}

variable "email_receivers" {
  description = "Action group email receivers."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "additional_action_group_ids" {
  description = "Additional action group IDs invoked by all alert rules, such as optional SRE remediation receivers."
  type        = list(string)
  default     = []
}

variable "deploy_log_query_alerts" {
  description = "Deploy KQL scheduled-query alert rules."
  type        = bool
  default     = true
}

variable "deploy_activity_log_alerts" {
  description = "Deploy administrative activity log alert."
  type        = bool
  default     = true
}

variable "deploy_service_health_alerts" {
  description = "Deploy service health alert."
  type        = bool
  default     = true
}

variable "deploy_resource_health_alerts" {
  description = "Deploy resource health alert for lab resource groups."
  type        = bool
  default     = true
}

variable "deploy_advisor_recommendation_alerts" {
  description = "Deploy Azure Advisor recommendation activity log alert."
  type        = bool
  default     = true
}

variable "resource_health_resource_groups" {
  description = "Resource groups included in Resource Health and Advisor activity log alerts."
  type        = list(string)
  default     = []
}

variable "resource_health_resource_types" {
  description = "Resource types included in the Resource Health alert."
  type        = list(string)
  default = [
    "Microsoft.Compute/virtualMachines",
    "Microsoft.Network/azureFirewalls",
    "Microsoft.Network/publicIPAddresses",
    "Microsoft.OperationalInsights/workspaces",
    "Microsoft.RecoveryServices/vaults"
  ]
}

variable "resource_health_current_statuses" {
  description = "Current Resource Health statuses that trigger the alert."
  type        = list(string)
  default     = ["Unavailable", "Degraded"]
}

variable "vm_cpu_threshold" {
  description = "CPU threshold."
  type        = number
  default     = 85
}

variable "vm_availability_threshold" {
  description = "VM availability threshold."
  type        = number
  default     = 1
}

variable "disk_free_percent_threshold" {
  description = "Minimum disk free percentage before the disk pressure alert fires."
  type        = number
  default     = 10
}

variable "critical_event_threshold" {
  description = "Critical/error Windows event count before the event alert fires."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
