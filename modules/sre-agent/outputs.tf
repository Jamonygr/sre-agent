output "automation_account_id" {
  description = "SRE Automation Account ID."
  value       = azurerm_automation_account.this.id
}

output "automation_account_name" {
  description = "SRE Automation Account name."
  value       = azurerm_automation_account.this.name
}

output "runbook_names" {
  description = "Runbook names."
  value = [
    azurerm_automation_runbook.restart_iis.name,
    azurerm_automation_runbook.start_stopped_lab_vms.name,
    azurerm_automation_runbook.collect_vm_diagnostics.name,
    azurerm_automation_runbook.cleanup_disk.name,
    azurerm_automation_runbook.stop_lab_vms.name
  ]
}

output "remediation_action_group_id" {
  description = "Optional action group that invokes SRE runbooks through Automation webhooks."
  value       = var.enable_alert_runbook_webhooks ? azurerm_monitor_action_group.remediation[0].id : null
}

output "webhook_ids" {
  description = "Automation webhook IDs when alert-triggered remediation is enabled."
  value       = { for key, webhook in azurerm_automation_webhook.alert : key => webhook.id }
}
