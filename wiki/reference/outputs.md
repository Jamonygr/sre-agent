# Outputs Reference

| Output | Purpose |
| --- | --- |
| `resource_group_names` | Names of the network, windows, sre, and governance resource groups |
| `hub_vnet_id` | Hub VNet resource ID |
| `management_vnet_id` | Management VNet resource ID |
| `workload_vnet_id` | Workload VNet resource ID |
| `log_analytics_workspace_id` | Log Analytics workspace resource ID |
| `log_analytics_workspace_guid` | Workspace GUID |
| `data_collection_rule_ids` | DCR IDs |
| `alert_rule_ids` | Metric and KQL alert IDs |
| `action_group_id` | Primary notification action group |
| `sre_remediation_action_group_id` | Optional alert-to-runbook action group |
| `automation_account_name` | SRE Automation Account name |
| `sre_agent_runbook_names` | Runbooks created by the SRE agent module |
| `backup_vault_name` | Recovery Services Vault name when backup is enabled |
| `iis_public_endpoint` | First IIS HTTP endpoint when public IPs are enabled |
| `iis_private_ips` | IIS private IPs keyed by target |
| `monitored_vm_names` | VM names included in monitoring/update scenarios |
| `sre_agent_summary` | Compact summary of monitoring, alert, runbook, and VM counts |
| `connection_info` | Human-readable connection summary |
