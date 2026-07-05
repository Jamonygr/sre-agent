output "policy_definition_ids" {
  description = "Policy definition IDs."
  value = merge(
    { for key, definition in azurerm_policy_definition.require_tag : key => definition.id },
    { allowed_locations = azurerm_policy_definition.allowed_locations.id }
  )
}

output "assignment_ids" {
  description = "Policy assignment IDs."
  value = merge(
    { for key, assignment in azurerm_resource_group_policy_assignment.require_tag : "tag_${key}" => assignment.id },
    { for key, assignment in azurerm_resource_group_policy_assignment.allowed_locations : "locations_${key}" => assignment.id }
  )
}

