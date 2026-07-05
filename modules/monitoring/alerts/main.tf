locals {
  subscription_scope = "/subscriptions/${var.subscription_id}"
  action_group_ids   = concat([azurerm_monitor_action_group.this.id], var.additional_action_group_ids)
}

resource "azurerm_monitor_action_group" "this" {
  name                = "ag-sre-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  short_name          = "sre"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.email_receivers

    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }
}

resource "azurerm_monitor_metric_alert" "vm_cpu" {
  count = length(var.monitored_vm_ids) > 0 ? 1 : 0

  name                     = "alert-vm-cpu-${var.name_suffix}"
  resource_group_name      = var.resource_group_name
  scopes                   = var.monitored_vm_ids
  description              = "Average VM CPU is above the lab threshold."
  severity                 = 2
  frequency                = "PT5M"
  window_size              = "PT15M"
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location
  enabled                  = true
  tags                     = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.vm_cpu_threshold
  }

  dynamic "action" {
    for_each = toset(local.action_group_ids)

    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_metric_alert" "vm_availability" {
  count = length(var.monitored_vm_ids) > 0 ? 1 : 0

  name                     = "alert-vm-availability-${var.name_suffix}"
  resource_group_name      = var.resource_group_name
  scopes                   = var.monitored_vm_ids
  description              = "VM availability metric dropped below the lab threshold."
  severity                 = 1
  frequency                = "PT1M"
  window_size              = "PT5M"
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location
  enabled                  = true
  tags                     = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.vm_availability_threshold
  }

  dynamic "action" {
    for_each = toset(local.action_group_ids)

    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "missing_heartbeat" {
  count = var.deploy_log_query_alerts ? 1 : 0

  name                 = "alert-missing-heartbeat-${var.name_suffix}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [var.log_analytics_workspace_id]
  severity             = 1
  description          = "No VM heartbeat has been seen recently."
  display_name         = "SRE missing heartbeat"
  enabled              = true
  tags                 = var.tags

  criteria {
    query                   = <<-KQL
      Heartbeat
      | where TimeGenerated > ago(30m)
      | summarize LastSeen=max(TimeGenerated) by Computer
      | where LastSeen < ago(10m)
    KQL
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = local.action_group_ids
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "iis_outage" {
  count = var.deploy_log_query_alerts ? 1 : 0

  name                 = "alert-iis-outage-${var.name_suffix}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [var.log_analytics_workspace_id]
  severity             = 2
  description          = "IIS service stop or crash events were detected."
  display_name         = "SRE IIS outage"
  enabled              = true
  tags                 = var.tags

  criteria {
    query                   = <<-KQL
      Event
      | where TimeGenerated > ago(15m)
      | where Source == "Service Control Manager"
      | where EventID in (7031, 7034, 7036)
      | where RenderedDescription has_any ("World Wide Web Publishing Service", "W3SVC")
      | where RenderedDescription has_any ("stopped", "terminated")
    KQL
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = local.action_group_ids
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "disk_pressure" {
  count = var.deploy_log_query_alerts ? 1 : 0

  name                 = "alert-disk-pressure-${var.name_suffix}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [var.log_analytics_workspace_id]
  severity             = 2
  description          = "A Windows VM disk has low free space."
  display_name         = "SRE disk pressure"
  enabled              = true
  tags                 = var.tags

  criteria {
    query                   = <<-KQL
      Perf
      | where TimeGenerated > ago(15m)
      | where ObjectName == "LogicalDisk"
      | where CounterName == "% Free Space"
      | where InstanceName !in ("_Total")
      | summarize MinFreePercent=min(CounterValue) by Computer, InstanceName
      | where MinFreePercent < ${var.disk_free_percent_threshold}
    KQL
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = local.action_group_ids
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "critical_windows_events" {
  count = var.deploy_log_query_alerts ? 1 : 0

  name                 = "alert-critical-events-${var.name_suffix}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [var.log_analytics_workspace_id]
  severity             = 3
  description          = "Critical or error Windows events exceeded the lab threshold."
  display_name         = "SRE critical Windows events"
  enabled              = true
  tags                 = var.tags

  criteria {
    query                   = <<-KQL
      Event
      | where TimeGenerated > ago(15m)
      | where EventLevel <= 2 or EventLevelName in ("Critical", "Error")
      | summarize EventCount=count() by Computer
      | where EventCount >= ${var.critical_event_threshold}
    KQL
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = local.action_group_ids
  }
}

resource "azurerm_monitor_activity_log_alert" "administrative" {
  count = var.deploy_activity_log_alerts ? 1 : 0

  name                = "alert-admin-activity-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [local.subscription_scope]
  description         = "Administrative operations against lab resources."
  enabled             = true
  tags                = var.tags

  criteria {
    category          = "Administrative"
    resource_provider = "Microsoft.Resources"
  }

  dynamic "action" {
    for_each = toset(local.action_group_ids)

    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "service_health" {
  count = var.deploy_service_health_alerts ? 1 : 0

  name                = "alert-service-health-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [local.subscription_scope]
  description         = "Azure service health events affecting operations."
  enabled             = true
  tags                = var.tags

  criteria {
    category = "ServiceHealth"

    service_health {
      events    = ["Incident", "Maintenance", "Informational", "ActionRequired", "Security"]
      locations = [var.location]
    }
  }

  dynamic "action" {
    for_each = toset(local.action_group_ids)

    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "resource_health" {
  count = var.deploy_resource_health_alerts && length(var.resource_health_resource_groups) > 0 ? 1 : 0

  name                = "alert-resource-health-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [local.subscription_scope]
  description         = "Azure Resource Health events affecting lab resources."
  enabled             = true
  tags                = var.tags

  criteria {
    category        = "ResourceHealth"
    resource_groups = var.resource_health_resource_groups
    resource_types  = var.resource_health_resource_types

    resource_health {
      current = var.resource_health_current_statuses
    }
  }

  dynamic "action" {
    for_each = toset(local.action_group_ids)

    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "advisor_recommendation" {
  count = var.deploy_advisor_recommendation_alerts && length(var.resource_health_resource_groups) > 0 ? 1 : 0

  name                = "alert-advisor-recommendation-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [local.subscription_scope]
  description         = "Azure Advisor recommendation events for lab resource groups."
  enabled             = true
  tags                = var.tags

  criteria {
    category        = "Recommendation"
    resource_groups = var.resource_health_resource_groups
  }

  dynamic "action" {
    for_each = toset(local.action_group_ids)

    content {
      action_group_id = action.value
    }
  }
}
