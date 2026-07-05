output "id" {
  description = "Azure Firewall ID."
  value       = azurerm_firewall.this.id
}

output "private_ip_address" {
  description = "Azure Firewall private IP."
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "public_ip_address" {
  description = "Azure Firewall public IP."
  value       = azurerm_public_ip.this.ip_address
}

