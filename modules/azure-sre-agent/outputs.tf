output "agent_id" {
  description = "Azure SRE Agent resource ID."
  value       = azapi_resource.agent.id
}

output "agent_name" {
  description = "Azure SRE Agent name."
  value       = azapi_resource.agent.name
}

output "agent_portal_url" {
  description = "Direct Azure SRE Agent portal URL."
  value       = "https://sre.azure.com/#/agent/${data.azurerm_subscription.current.subscription_id}/${azurerm_resource_group.this.name}/${var.name}"
}

output "agent_data_plane_url" {
  description = "Azure SRE Agent data-plane URL."
  value       = try(azapi_resource.agent.output.properties.agentEndpoint, null)
}

output "resource_group_name" {
  description = "Azure SRE Agent resource group name."
  value       = azurerm_resource_group.this.name
}

output "managed_identity_id" {
  description = "User-assigned managed identity ID used by the Azure SRE Agent."
  value       = azurerm_user_assigned_identity.agent.id
}

output "managed_resource_group_ids" {
  description = "Resource group IDs the Azure SRE Agent can observe."
  value       = var.managed_resource_group_ids
}
