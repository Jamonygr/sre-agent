locals {
  dashboard_lenses = {
    "0" = {
      order = 0
      parts = {
        "0" = {
          position = {
            x       = 0
            y       = 0
            rowSpan = 4
            colSpan = 6
          }
          metadata = {
            inputs = [
              {
                name  = "resourceTypeMode"
                value = "workspace"
              },
              {
                name  = "ComponentId"
                value = var.log_analytics_workspace_id
              },
              {
                name  = "Query"
                value = "Perf | where ObjectName == 'Processor' and CounterName == '% Processor Time' | summarize avg(CounterValue) by bin(TimeGenerated, 5m)"
              },
              {
                name  = "ControlType"
                value = "FrameControlChart"
              }
            ]
            type = "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart"
          }
        }
        "1" = {
          position = {
            x       = 6
            y       = 0
            rowSpan = 4
            colSpan = 6
          }
          metadata = {
            inputs = [
              {
                name  = "resourceTypeMode"
                value = "workspace"
              },
              {
                name  = "ComponentId"
                value = var.log_analytics_workspace_id
              },
              {
                name  = "Query"
                value = "Event | where EventLevelName in ('Error','Critical') | summarize count() by EventLog, bin(TimeGenerated, 1h)"
              },
              {
                name  = "ControlType"
                value = "FrameControlChart"
              }
            ]
            type = "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart"
          }
        }
      }
    }
  }
}

resource "azurerm_portal_dashboard" "this" {
  name                = "dash-ops-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dashboard_properties = jsonencode({
    lenses   = local.dashboard_lenses
    metadata = { model = {} }
  })
}
