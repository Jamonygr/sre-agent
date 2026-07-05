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
  description = "Create public IP."
  type        = bool
  default     = true
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

variable "lab_title" {
  description = "IIS landing page title."
  type        = string
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}

