variable "name" {
  description = "Subnet name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "virtual_network_name" {
  description = "Virtual network name."
  type        = string
}

variable "address_prefixes" {
  description = "Subnet prefixes."
  type        = list(string)
}

variable "network_security_group_id" {
  description = "Optional NSG ID to associate."
  type        = string
  default     = null
}

variable "associate_network_security_group" {
  description = "Create the NSG association. Keep separate from the NSG ID so planning does not depend on apply-time IDs."
  type        = bool
  default     = false
}

variable "service_endpoints" {
  description = "Service endpoints."
  type        = list(string)
  default     = []
}
