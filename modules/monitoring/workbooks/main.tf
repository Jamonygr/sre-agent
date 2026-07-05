resource "random_uuid" "sre_overview" {}
resource "random_uuid" "updates" {}
resource "random_uuid" "incidents" {}

resource "azurerm_application_insights_workbook" "sre_overview" {
  name                = random_uuid.sre_overview.result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "SRE Agent Azure Lab - Operations Overview"
  tags                = var.tags

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "header"
        content = {
          json = "# SRE Overview\nCentral view for VM health, CPU, memory, disk, and event signals."
        }
      },
      {
        type = 3
        name = "cpu-chart"
        content = {
          version                 = "KqlItem/1.0"
          query                   = "Perf | where ObjectName == 'Processor' and CounterName == '% Processor Time' | summarize AvgCPU = avg(CounterValue) by Computer, bin(TimeGenerated, 5m) | render timechart"
          size                    = 0
          title                   = "CPU Utilization by VM"
          queryType               = 0
          resourceType            = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
      },
      {
        type = 3
        name = "disk-table"
        content = {
          version                 = "KqlItem/1.0"
          query                   = "Perf | where ObjectName == 'LogicalDisk' and CounterName == '% Free Space' | where InstanceName != '_Total' | summarize AvgFreeSpace = avg(CounterValue) by Computer, InstanceName | order by AvgFreeSpace asc"
          size                    = 0
          title                   = "Disk Free Space"
          queryType               = 0
          resourceType            = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
      }
    ]
    isLocked = false
  })
}

resource "azurerm_application_insights_workbook" "updates" {
  name                = random_uuid.updates.result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "SRE Agent Azure Lab - Update Compliance"
  tags                = var.tags

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "header"
        content = {
          json = "# Update Compliance\nUse this workbook with Azure Update Manager and AMA data to review patch state and change activity."
        }
      },
      {
        type = 3
        name = "change-summary"
        content = {
          version                 = "KqlItem/1.0"
          query                   = "ConfigurationChange | summarize Changes = count() by Computer, ChangeCategory, bin(TimeGenerated, 1h) | order by TimeGenerated desc"
          size                    = 0
          title                   = "Recent Configuration Changes"
          queryType               = 0
          resourceType            = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
      }
    ]
    isLocked = false
  })
}

resource "azurerm_application_insights_workbook" "incidents" {
  name                = random_uuid.incidents.result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "SRE Agent Azure Lab - Incident Response"
  tags                = var.tags

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "header"
        content = {
          json = "# Incident Response\nReview VM events and service failures for lab outage exercises."
        }
      },
      {
        type = 3
        name = "critical-events"
        content = {
          version                 = "KqlItem/1.0"
          query                   = "Event | where EventLevelName in ('Error', 'Critical') | summarize Events = count() by Computer, EventLog, Source, bin(TimeGenerated, 30m) | order by TimeGenerated desc"
          size                    = 0
          title                   = "Critical and Error Events"
          queryType               = 0
          resourceType            = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
      }
    ]
    isLocked = false
  })
}
