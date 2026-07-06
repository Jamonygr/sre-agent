data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  suffix = substr(sha256("${data.azurerm_subscription.current.subscription_id}-${var.resource_group_name}-${var.name}"), 0, 13)

  log_analytics_connector_enabled = var.enable_log_analytics_connector

  connector_definitions = merge(
    var.enable_azure_monitor_connector ? {
      azure-monitor = {
        dataConnectorType = "AzureMonitor"
        dataSource        = data.azurerm_subscription.current.id
        extendedProperties = {
          armResourceId = data.azurerm_subscription.current.id
          lookbackDays  = var.azure_monitor_lookback_days
        }
        identity = "system"
      }
    } : {},
    local.log_analytics_connector_enabled ? {
      log-analytics = {
        dataConnectorType = "LogAnalytics"
        dataSource        = var.log_analytics_workspace_id
        extendedProperties = {
          armResourceId = var.log_analytics_workspace_id
          resource = {
            name = element(split("/", var.log_analytics_workspace_id), length(split("/", var.log_analytics_workspace_id)) - 1)
          }
        }
        identity = "system"
      }
    } : {}
  )
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_user_assigned_identity" "agent" {
  name                = "${var.name}-id-${local.suffix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "agent" {
  name                = "law-${local.suffix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "agent" {
  name                = "ai-${local.suffix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.agent.id
  tags                = var.tags
}

resource "azurerm_role_assignment" "uami_target_reader" {
  for_each = var.managed_resource_group_ids

  scope                            = each.value
  role_definition_name             = "Reader"
  principal_id                     = azurerm_user_assigned_identity.agent.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "uami_target_log_analytics_reader" {
  for_each = var.managed_resource_group_ids

  scope                            = each.value
  role_definition_name             = "Log Analytics Reader"
  principal_id                     = azurerm_user_assigned_identity.agent.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "uami_target_monitoring_reader" {
  for_each = var.managed_resource_group_ids

  scope                            = each.value
  role_definition_name             = "Monitoring Reader"
  principal_id                     = azurerm_user_assigned_identity.agent.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "uami_target_contributor" {
  for_each = var.access_level == "High" ? var.managed_resource_group_ids : {}

  scope                            = each.value
  role_definition_name             = "Contributor"
  principal_id                     = azurerm_user_assigned_identity.agent.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "uami_monitoring_reader" {
  scope                            = azurerm_resource_group.this.id
  role_definition_name             = "Monitoring Reader"
  principal_id                     = azurerm_user_assigned_identity.agent.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "uami_subscription_monitoring_contributor" {
  scope                            = data.azurerm_subscription.current.id
  role_definition_name             = "Monitoring Contributor"
  principal_id                     = azurerm_user_assigned_identity.agent.principal_id
  skip_service_principal_aad_check = true
}

resource "azapi_resource" "agent" {
  schema_validation_enabled = false
  response_export_values    = ["properties.agentEndpoint"]
  type                      = "Microsoft.App/agents@2025-05-01-preview"
  name                      = var.name
  location                  = var.location
  parent_id                 = azurerm_resource_group.this.id
  tags                      = var.tags

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agent.id]
  }

  body = {
    properties = {
      knowledgeGraphConfiguration = {
        identity         = azurerm_user_assigned_identity.agent.id
        managedResources = values(var.managed_resource_group_ids)
      }
      actionConfiguration = {
        accessLevel = var.access_level
        identity    = azurerm_user_assigned_identity.agent.id
        mode        = var.action_mode
      }
      logConfiguration = {
        applicationInsightsConfiguration = {
          appId            = azurerm_application_insights.agent.app_id
          connectionString = azurerm_application_insights.agent.connection_string
        }
      }
      upgradeChannel        = var.upgrade_channel
      monthlyAgentUnitLimit = var.monthly_agent_unit_limit
      defaultModel = {
        provider = var.default_model_provider
        name     = var.default_model_name
      }
      experimentalSettings = {
        EnableWorkspaceTools = true
        EnableHttpTriggers   = true
        EnableV2AgentLoop    = true
      }
    }
  }

  depends_on = [
    azurerm_role_assignment.uami_monitoring_reader,
    azurerm_role_assignment.uami_subscription_monitoring_contributor,
    azurerm_role_assignment.uami_target_reader,
    azurerm_role_assignment.uami_target_log_analytics_reader,
    azurerm_role_assignment.uami_target_monitoring_reader,
    azurerm_role_assignment.uami_target_contributor,
  ]
}

resource "azurerm_role_assignment" "deployer_admin" {
  scope              = azapi_resource.agent.id
  role_definition_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/e79298df-d852-4c6d-84f9-5d13249d1e55"
  principal_id       = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "uami_admin" {
  scope                            = azapi_resource.agent.id
  role_definition_id               = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/e79298df-d852-4c6d-84f9-5d13249d1e55"
  principal_id                     = azurerm_user_assigned_identity.agent.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "smi_target_reader" {
  for_each = var.managed_resource_group_ids

  scope                            = each.value
  role_definition_name             = "Reader"
  principal_id                     = azapi_resource.agent.identity[0].principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "smi_target_log_analytics_reader" {
  for_each = var.managed_resource_group_ids

  scope                            = each.value
  role_definition_name             = "Log Analytics Reader"
  principal_id                     = azapi_resource.agent.identity[0].principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "smi_target_monitoring_reader" {
  for_each = var.managed_resource_group_ids

  scope                            = each.value
  role_definition_name             = "Monitoring Reader"
  principal_id                     = azapi_resource.agent.identity[0].principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "smi_target_contributor" {
  for_each = var.access_level == "High" ? var.managed_resource_group_ids : {}

  scope                            = each.value
  role_definition_name             = "Contributor"
  principal_id                     = azapi_resource.agent.identity[0].principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "smi_subscription_monitoring_contributor" {
  scope                            = data.azurerm_subscription.current.id
  role_definition_name             = "Monitoring Contributor"
  principal_id                     = azapi_resource.agent.identity[0].principal_id
  skip_service_principal_aad_check = true
}

resource "azapi_resource" "connector" {
  for_each                  = local.connector_definitions
  schema_validation_enabled = false
  type                      = "Microsoft.App/agents/connectors@2025-05-01-preview"
  name                      = each.key
  parent_id                 = azapi_resource.agent.id

  body = {
    properties = each.value
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    azurerm_role_assignment.smi_target_reader,
    azurerm_role_assignment.smi_target_log_analytics_reader,
    azurerm_role_assignment.smi_target_monitoring_reader,
    azurerm_role_assignment.smi_target_contributor,
    azurerm_role_assignment.smi_subscription_monitoring_contributor,
  ]
}
