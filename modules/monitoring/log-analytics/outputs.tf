output "id" {
  description = "Workspace ID."
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "Workspace name."
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "Workspace GUID."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

