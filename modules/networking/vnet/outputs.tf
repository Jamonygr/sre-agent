output "id" {
  description = "VNet ID."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "VNet name."
  value       = azurerm_virtual_network.this.name
}

output "address_space" {
  description = "VNet address space."
  value       = azurerm_virtual_network.this.address_space
}

