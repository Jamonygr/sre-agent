variable "name_suffix" {
  description = "Name suffix."
  type        = string
}

variable "resource_group_ids" {
  description = "Resource group IDs for policy assignments, keyed by stable logical group name."
  type        = map(string)
}

variable "allowed_locations" {
  description = "Allowed locations."
  type        = list(string)
}

variable "required_tags" {
  description = "Required tag names."
  type        = list(string)
}
