output "id" {
  description = "Linux Function App ID."
  value       = azurerm_linux_function_app.this.id
}

output "name" {
  description = "Linux Function App name."
  value       = azurerm_linux_function_app.this.name
}

output "default_hostname" {
  description = "Linux Function App default hostname."
  value       = azurerm_linux_function_app.this.default_hostname
}

output "service_plan_id" {
  description = "Function App service plan ID."
  value       = azurerm_service_plan.this.id
}

output "storage_account_id" {
  description = "Function App storage account ID."
  value       = azurerm_storage_account.this.id
}
