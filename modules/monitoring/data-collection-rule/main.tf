resource "azurerm_monitor_data_collection_rule" "vm_ops" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Windows"
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = "logAnalytics"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-Event"]
    destinations = ["logAnalytics"]
  }

  dynamic "data_flow" {
    for_each = var.enable_change_tracking ? [1] : []

    content {
      streams      = ["Microsoft-ConfigurationChange", "Microsoft-ConfigurationChangeV2", "Microsoft-ConfigurationData"]
      destinations = ["logAnalytics"]
    }
  }

  data_sources {
    performance_counter {
      name                          = "vm-performance-counters"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\% Committed Bytes In Use",
        "\\LogicalDisk(_Total)\\% Free Space",
        "\\LogicalDisk(*)\\% Free Space",
        "\\Web Service(_Total)\\Current Connections",
        "\\Network Interface(*)\\Bytes Total/sec"
      ]
    }

    windows_event_log {
      name    = "windows-system-events"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "System!*[System[(Level=1 or Level=2 or Level=3)]]",
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }

    dynamic "extension" {
      for_each = var.enable_change_tracking ? [1] : []

      content {
        name           = "change-tracking-inventory"
        streams        = ["Microsoft-ConfigurationChange", "Microsoft-ConfigurationChangeV2", "Microsoft-ConfigurationData"]
        extension_name = "ChangeTracking-Windows"
        extension_json = jsonencode({
          enableFiles     = true
          enableInventory = true
          enableRegistry  = true
          enableServices  = true
          enableSoftware  = true
          fileSettings = {
            fileCollectionFrequency = 2700
          }
          inventorySettings = {
            inventoryCollectionFrequency = 36000
          }
          registrySettings = {
            registryCollectionFrequency = 3000
          }
          servicesSettings = {
            serviceCollectionFrequency = 1800
          }
          softwareSettings = {
            softwareCollectionFrequency = 1800
          }
        })
      }
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "vm" {
  for_each = var.target_resource_ids

  name                    = "dcr-association-${substr(md5(each.value), 0, 8)}"
  target_resource_id      = each.value
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm_ops.id
  description             = "SRE Agent Windows VM Lab VM telemetry collection"
}
