variable "name" {
  description = "VM name."
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

variable "subnet_id" {
  description = "Subnet ID."
  type        = string
}

variable "private_ip_address" {
  description = "Optional static private IP."
  type        = string
  default     = null
}

variable "vm_size" {
  description = "VM size."
  type        = string
}

variable "admin_username" {
  description = "Admin username."
  type        = string
}

variable "admin_password" {
  description = "Admin password."
  type        = string
  sensitive   = true
}

variable "enable_public_ip" {
  description = "Create a public IP."
  type        = bool
  default     = false
}

variable "install_azure_monitor_agent" {
  description = "Install Azure Monitor Agent."
  type        = bool
  default     = true
}

variable "install_dependency_agent" {
  description = "Install dependency agent."
  type        = bool
  default     = false
}

variable "custom_script" {
  description = "Optional PowerShell script to execute."
  type        = string
  default     = null
}

variable "role" {
  description = "Role label."
  type        = string
  default     = "windows-vm"
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}

