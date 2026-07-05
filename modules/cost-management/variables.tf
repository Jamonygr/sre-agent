variable "name" {
  description = "Budget name."
  type        = string
}

variable "resource_group_id" {
  description = "Budget resource group scope."
  type        = string
}

variable "amount" {
  description = "Budget amount."
  type        = number
}

variable "start_date" {
  description = "Budget start date."
  type        = string
}

variable "end_date" {
  description = "Budget end date."
  type        = string
}

variable "contact_emails" {
  description = "Budget contact emails."
  type        = list(string)
  default     = []
}

