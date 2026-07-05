output "id" {
  description = "Grafana ID."
  value       = azurerm_dashboard_grafana.this.id
}

output "endpoint" {
  description = "Grafana endpoint."
  value       = azurerm_dashboard_grafana.this.endpoint
}

