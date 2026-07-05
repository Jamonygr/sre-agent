output "id" {
  description = "VPN Gateway ID."
  value       = azurerm_virtual_network_gateway.this.id
}

output "public_ip_address" {
  description = "VPN Gateway public IP."
  value       = azurerm_public_ip.this.ip_address
}

