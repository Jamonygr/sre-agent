output "data_collection_rule_ids" {
  description = "Data collection rule IDs."
  value = {
    vm_ops = azurerm_monitor_data_collection_rule.vm_ops.id
  }
}

output "association_ids" {
  description = "DCR association IDs."
  value       = { for key, association in azurerm_monitor_data_collection_rule_association.vm : key => association.id }
}

