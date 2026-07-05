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

variable "gateway_subnet_prefix" {
  description = "GatewaySubnet prefix."
  type        = string
}

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU."
  type        = string
  default     = "VpnGw1"
}

variable "enable_bgp" {
  description = "Enable BGP."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}

