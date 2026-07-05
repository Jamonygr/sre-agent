output "vault_id" {
  description = "Recovery Services Vault ID."
  value       = azurerm_recovery_services_vault.this.id
}

output "vault_name" {
  description = "Recovery Services Vault name."
  value       = azurerm_recovery_services_vault.this.name
}

output "backup_policy_id" {
  description = "Backup policy ID."
  value       = azurerm_backup_policy_vm.daily.id
}

output "protected_vm_ids" {
  description = "Protected VM resource IDs."
  value       = { for key, protected in azurerm_backup_protected_vm.this : key => protected.id }
}

