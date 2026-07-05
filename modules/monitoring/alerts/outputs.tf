output "action_group_id" {
  description = "Action group ID."
  value       = azurerm_monitor_action_group.this.id
}

output "alert_rule_ids" {
  description = "Alert rule IDs."
  value = merge(
    { for key, alert in azurerm_monitor_metric_alert.vm_cpu : "vm_cpu_${key}" => alert.id },
    { for key, alert in azurerm_monitor_metric_alert.vm_availability : "vm_availability_${key}" => alert.id },
    { for key, alert in azurerm_monitor_scheduled_query_rules_alert_v2.missing_heartbeat : "missing_heartbeat_${key}" => alert.id },
    { for key, alert in azurerm_monitor_scheduled_query_rules_alert_v2.iis_outage : "iis_outage_${key}" => alert.id },
    { for key, alert in azurerm_monitor_scheduled_query_rules_alert_v2.disk_pressure : "disk_pressure_${key}" => alert.id },
    { for key, alert in azurerm_monitor_scheduled_query_rules_alert_v2.critical_windows_events : "critical_windows_events_${key}" => alert.id },
    { for key, alert in azurerm_monitor_activity_log_alert.administrative : "administrative_${key}" => alert.id },
    { for key, alert in azurerm_monitor_activity_log_alert.service_health : "service_health_${key}" => alert.id },
    { for key, alert in azurerm_monitor_activity_log_alert.resource_health : "resource_health_${key}" => alert.id },
    { for key, alert in azurerm_monitor_activity_log_alert.advisor_recommendation : "advisor_recommendation_${key}" => alert.id }
  )
}
