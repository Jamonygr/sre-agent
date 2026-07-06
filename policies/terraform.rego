package terraform

approved_regions := {"westus2", "eastus", "eastus2", "westeurope", "northeurope", "canadacentral", "global"}

tag_required_types := {
  "azurerm_application_insights_workbook",
  "azurerm_automation_account",
  "azurerm_automation_runbook",
  "azurerm_log_analytics_workspace",
  "azurerm_monitor_action_group",
  "azurerm_monitor_activity_log_alert",
  "azurerm_monitor_data_collection_rule",
  "azurerm_monitor_metric_alert",
  "azurerm_monitor_scheduled_query_rules_alert_v2",
  "azurerm_network_interface",
  "azurerm_network_security_group",
  "azurerm_public_ip",
  "azurerm_resource_group",
  "azurerm_virtual_machine_extension",
  "azurerm_virtual_network",
  "azurerm_windows_virtual_machine",
}

has_tags(after) {
  tags := object.get(after, "tags", null)
  tags != null
  count(tags) > 0
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.change.actions[_] == "create"
  tag_required_types[resource.type]
  not has_tags(resource.change.after)
  msg := sprintf("Resource %s must have tags", [resource.address])
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.change.actions[_] == "create"
  location := lower(resource.change.after.location)
  location != ""
  not approved_regions[location]
  msg := sprintf("Resource %s is in unsupported region %s", [resource.address, location])
}

warn[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_public_ip"
  resource.change.actions[_] == "create"
  msg := sprintf("Public IP %s is being created; confirm this is intentional for the lab scenario", [resource.address])
}
