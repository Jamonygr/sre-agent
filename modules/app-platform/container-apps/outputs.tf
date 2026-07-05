output "environment_id" {
  description = "Container Apps environment ID."
  value       = azurerm_container_app_environment.this.id
}

output "environment_name" {
  description = "Container Apps environment name."
  value       = azurerm_container_app_environment.this.name
}

output "id" {
  description = "Container App ID."
  value       = azurerm_container_app.this.id
}

output "name" {
  description = "Container App name."
  value       = azurerm_container_app.this.name
}

output "fqdn" {
  description = "Container App latest revision FQDN."
  value       = azurerm_container_app.this.latest_revision_fqdn
}
