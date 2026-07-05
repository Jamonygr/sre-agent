output "id" {
  description = "Linux Web App ID."
  value       = azurerm_linux_web_app.this.id
}

output "name" {
  description = "Linux Web App name."
  value       = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  description = "Linux Web App default hostname."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "service_plan_id" {
  description = "App Service plan ID."
  value       = azurerm_service_plan.this.id
}
