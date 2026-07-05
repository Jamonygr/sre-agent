output "vm_id" {
  description = "VM ID."
  value       = azurerm_windows_virtual_machine.this.id
}

output "vm_name" {
  description = "VM name."
  value       = azurerm_windows_virtual_machine.this.name
}

output "principal_id" {
  description = "System-assigned managed identity principal ID."
  value       = azurerm_windows_virtual_machine.this.identity[0].principal_id
}

output "private_ip_address" {
  description = "Private IP address."
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address."
  value       = var.enable_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "network_interface_id" {
  description = "NIC ID."
  value       = azurerm_network_interface.this.id
}

