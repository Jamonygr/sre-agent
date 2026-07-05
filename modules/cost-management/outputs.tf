output "budget_id" {
  description = "Budget ID."
  value       = azurerm_consumption_budget_resource_group.this.id
}

