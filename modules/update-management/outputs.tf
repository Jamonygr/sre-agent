output "maintenance_configuration_ids" {
  description = "Maintenance configuration IDs."
  value = {
    guest_patch = azurerm_maintenance_configuration.guest_patch.id
  }
}

output "assignment_ids" {
  description = "Maintenance assignment IDs."
  value = merge(
    { for key, assignment in azurerm_maintenance_assignment_virtual_machine.vm : key => assignment.id },
    { for key, assignment in azurerm_maintenance_assignment_dynamic_scope.patch_group : "dynamic_${key}" => assignment.id }
  )
}

