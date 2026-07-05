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

variable "virtual_network_name" {
  description = "Hub VNet name."
  type        = string
}

variable "firewall_subnet_prefix" {
  description = "AzureFirewallSubnet prefix."
  type        = string
}

variable "management_subnet_prefix" {
  description = "AzureFirewallManagementSubnet prefix for Azure Firewall Basic."
  type        = string
  default     = null
}

variable "firewall_sku_tier" {
  description = "Firewall SKU tier."
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
