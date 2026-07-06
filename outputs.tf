# =============================================================================
# ROOT OUTPUTS
# =============================================================================

output "resource_group_names" {
  description = "Resource groups created for the SRE agent lab."
  value = merge(
    {
      network    = module.rg_network.name
      windows    = module.rg_windows.name
      sre        = module.rg_sre.name
      governance = module.rg_governance.name
    },
    local.deploy_app_platform_targets ? { apps = module.rg_apps[0].name } : {},
    var.deploy_azure_sre_agent ? { azure_sre_agent = module.azure_sre_agent[0].resource_group_name } : {}
  )
}

output "hub_vnet_id" {
  description = "Hub VNet ID."
  value       = module.hub_vnet.id
}

output "management_vnet_id" {
  description = "Management VNet ID."
  value       = module.management_vnet.id
}

output "workload_vnet_id" {
  description = "Workload VNet ID."
  value       = module.workload_vnet.id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = var.deploy_monitoring && var.deploy_log_analytics ? module.log_analytics[0].id : null
}

output "log_analytics_workspace_guid" {
  description = "Log Analytics workspace GUID."
  value       = var.deploy_monitoring && var.deploy_log_analytics ? module.log_analytics[0].workspace_id : null
}

output "data_collection_rule_ids" {
  description = "Data collection rule IDs."
  value       = var.deploy_monitoring && var.deploy_log_analytics && var.deploy_data_collection_rules ? module.data_collection[0].data_collection_rule_ids : {}
}

output "maintenance_configuration_ids" {
  description = "Azure Update Manager maintenance configuration IDs."
  value       = var.deploy_update_management ? module.update_management[0].maintenance_configuration_ids : {}
}

output "update_assignment_ids" {
  description = "Azure Update Manager VM and dynamic assignment IDs."
  value       = var.deploy_update_management ? module.update_management[0].assignment_ids : {}
}

output "workbook_ids" {
  description = "Azure Workbook IDs."
  value       = var.deploy_monitoring && var.deploy_log_analytics && var.deploy_workbooks ? module.workbooks[0].workbook_ids : {}
}

output "dashboard_id" {
  description = "Azure Portal dashboard ID."
  value       = var.deploy_monitoring && var.deploy_log_analytics && var.deploy_portal_dashboards ? module.dashboard[0].dashboard_id : null
}

output "managed_grafana_endpoint" {
  description = "Azure Managed Grafana endpoint when deployed."
  value       = var.deploy_managed_grafana ? module.managed_grafana[0].endpoint : null
}

output "app_platform_resource_group_name" {
  description = "Resource group for optional AKS, App Service, Container Apps, and Functions targets."
  value       = local.app_resource_group_name
}

output "aks_cluster_name" {
  description = "AKS cluster name when deployed."
  value       = var.deploy_aks ? module.aks[0].name : null
}

output "aks_cluster_fqdn" {
  description = "AKS API server FQDN when deployed."
  value       = var.deploy_aks ? module.aks[0].fqdn : null
}

output "app_service_default_hostname" {
  description = "Azure App Service default hostname when deployed."
  value       = var.deploy_app_service ? module.app_service[0].default_hostname : null
}

output "container_app_fqdn" {
  description = "Azure Container App latest revision FQDN when deployed."
  value       = var.deploy_container_apps ? module.container_apps[0].fqdn : null
}

output "function_app_default_hostname" {
  description = "Azure Functions default hostname when deployed."
  value       = var.deploy_functions ? module.functions[0].default_hostname : null
}

output "action_group_id" {
  description = "Monitor action group ID."
  value       = var.deploy_monitoring && var.deploy_alerts ? module.alerts[0].action_group_id : null
}

output "alert_rule_ids" {
  description = "Monitor alert rule IDs."
  value       = var.deploy_monitoring && var.deploy_alerts ? module.alerts[0].alert_rule_ids : {}
}

output "automation_account_name" {
  description = "SRE Automation Account name."
  value       = var.deploy_sre_agent ? module.sre_agent[0].automation_account_name : null
}

output "sre_agent_runbook_names" {
  description = "SRE agent runbook names."
  value       = var.deploy_sre_agent ? module.sre_agent[0].runbook_names : []
}

output "sre_remediation_action_group_id" {
  description = "Optional remediation action group ID used when alert-to-runbook webhooks are enabled."
  value       = var.deploy_sre_agent ? module.sre_agent[0].remediation_action_group_id : null
}

output "azure_sre_agent_id" {
  description = "Portal-visible Azure SRE Agent resource ID."
  value       = var.deploy_azure_sre_agent ? module.azure_sre_agent[0].agent_id : null
}

output "azure_sre_agent_name" {
  description = "Portal-visible Azure SRE Agent name."
  value       = var.deploy_azure_sre_agent ? module.azure_sre_agent[0].agent_name : null
}

output "azure_sre_agent_portal_url" {
  description = "Direct Azure SRE Agent portal URL."
  value       = var.deploy_azure_sre_agent ? module.azure_sre_agent[0].agent_portal_url : null
}

output "azure_sre_agent_data_plane_url" {
  description = "Azure SRE Agent data-plane URL."
  value       = var.deploy_azure_sre_agent ? module.azure_sre_agent[0].agent_data_plane_url : null
}

output "azure_sre_agent_resource_group_name" {
  description = "Resource group containing the portal-visible Azure SRE Agent."
  value       = var.deploy_azure_sre_agent ? module.azure_sre_agent[0].resource_group_name : null
}

output "azure_sre_agent_managed_resource_group_ids" {
  description = "Resource group IDs the portal-visible Azure SRE Agent can observe."
  value       = var.deploy_azure_sre_agent ? module.azure_sre_agent[0].managed_resource_group_ids : {}
}

output "backup_vault_name" {
  description = "Recovery Services Vault name."
  value       = var.deploy_backup ? module.backup[0].vault_name : null
}

output "jumpbox_private_ip" {
  description = "Jumpbox private IP."
  value       = var.deploy_windows_targets && var.deploy_jumpbox ? module.jumpbox[0].private_ip_address : null
}

output "jumpbox_public_ip" {
  description = "Jumpbox public IP when enabled."
  value       = var.deploy_windows_targets && var.deploy_jumpbox ? module.jumpbox[0].public_ip_address : null
}

output "iis_public_endpoint" {
  description = "First IIS public endpoint when enabled."
  value       = length(module.iis_web_servers) > 0 && var.enable_iis_public_ip ? "http://${values(module.iis_web_servers)[0].public_ip_address}" : null
}

output "iis_private_ips" {
  description = "IIS private IP addresses."
  value       = { for key, vm in module.iis_web_servers : key => vm.private_ip_address }
}

output "monitored_vm_names" {
  description = "VM names included in monitoring/update scenarios."
  value       = local.monitored_vm_names
}

output "sre_agent_summary" {
  description = "Quick summary of the SRE agent control plane."
  value = {
    monitoring_enabled       = var.deploy_monitoring
    log_query_alerts_enabled = var.deploy_monitoring && var.deploy_alerts && var.deploy_log_query_alerts
    runbook_webhooks_enabled = var.deploy_sre_agent && var.enable_alert_runbook_webhooks
    monitored_vm_count       = length(local.monitored_vm_ids)
    log_analytics_workspace  = var.deploy_monitoring && var.deploy_log_analytics ? module.log_analytics[0].name : null
    automation_account_name  = var.deploy_sre_agent ? module.sre_agent[0].automation_account_name : null
    remediation_action_group = var.deploy_sre_agent ? module.sre_agent[0].remediation_action_group_id : null
    azure_sre_agent_name     = var.deploy_azure_sre_agent ? module.azure_sre_agent[0].agent_name : null
    azure_sre_agent_url      = var.deploy_azure_sre_agent ? module.azure_sre_agent[0].agent_portal_url : null
  }
}

output "app_platform_summary" {
  description = "Quick summary of optional modern app-platform lab targets."
  value = {
    resource_group = local.app_resource_group_name
    aks            = var.deploy_aks ? module.aks[0].name : null
    app_service    = var.deploy_app_service ? module.app_service[0].default_hostname : null
    container_app  = var.deploy_container_apps ? module.container_apps[0].fqdn : null
    functions      = var.deploy_functions ? module.functions[0].default_hostname : null
  }
}

output "connection_info" {
  description = "Quick connection summary."
  value       = <<-EOT
    Jumpbox private IP: ${var.deploy_windows_targets && var.deploy_jumpbox ? module.jumpbox[0].private_ip_address : "not deployed"}
    Jumpbox public IP:  ${var.deploy_windows_targets && var.deploy_jumpbox && var.enable_jumpbox_public_ip ? module.jumpbox[0].public_ip_address : "not enabled"}
    IIS endpoint:       ${length(module.iis_web_servers) > 0 && var.enable_iis_public_ip ? "http://${values(module.iis_web_servers)[0].public_ip_address}" : "not enabled"}
    App Service:        ${var.deploy_app_service ? "https://${module.app_service[0].default_hostname}" : "not deployed"}
    Container App:      ${var.deploy_container_apps ? "https://${module.container_apps[0].fqdn}" : "not deployed"}
    Function App:       ${var.deploy_functions ? "https://${module.functions[0].default_hostname}" : "not deployed"}
    AKS API FQDN:       ${var.deploy_aks ? module.aks[0].fqdn : "not deployed"}
    Log Analytics:      ${var.deploy_monitoring && var.deploy_log_analytics ? module.log_analytics[0].name : "not deployed"}
    Patch group:        ${var.default_patch_group}
    Credentials:        ${var.admin_username} / <password from private tfvars or TF_VAR_admin_password>
  EOT
}
