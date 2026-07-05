variable "name" {
  description = "NSG name."
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

variable "security_rules" {
  description = "Security rules keyed by rule name."
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefixes    = list(string)
    destination_address_prefix = string
    description                = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}

