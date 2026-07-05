output "vm_id" {
  description = "VM ID."
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "VM name."
  value       = module.vm.vm_name
}

output "private_ip_address" {
  description = "Private IP address."
  value       = module.vm.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address."
  value       = module.vm.public_ip_address
}

output "network_interface_id" {
  description = "NIC ID."
  value       = module.vm.network_interface_id
}

