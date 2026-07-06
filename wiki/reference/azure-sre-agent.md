# Azure SRE Agent Integration

Last verified against Microsoft Learn on 2026-07-06.

This lab can deploy a portal-visible Azure SRE Agent with `deploy_azure_sre_agent = true`. The Terraform deployment creates the agent resource, identities, Application Insights, an agent telemetry workspace, RBAC over the lab resource groups, and an optional Log Analytics connector for persistent workspace context.

## Current Platform Guidance

Azure SRE Agent has built-in Azure capabilities through managed identity and Azure RBAC. It can query Azure Monitor metrics, Log Analytics, Application Insights, Azure Resource Graph, and Azure Resource Manager without requiring a connector for every Azure service. Connectors are still useful when you want persistent context for a specific workspace, external source systems, source code, wikis, notification channels, or custom MCP tools.

Useful Microsoft docs:

| Topic | Link |
| --- | --- |
| Azure SRE Agent overview | <https://learn.microsoft.com/en-us/azure/sre-agent/overview> |
| Connectors overview | <https://learn.microsoft.com/en-us/azure/sre-agent/connectors> |
| API reference | <https://learn.microsoft.com/en-us/azure/sre-agent/api-reference> |
| Azure DevOps connector | <https://learn.microsoft.com/en-us/azure/sre-agent/ado-connector> |
| Azure DevOps wiki knowledge | <https://learn.microsoft.com/en-us/azure/sre-agent/azure-devops-wiki-knowledge> |

## Connector Defaults

| Setting | Default | Why |
| --- | --- | --- |
| `enable_azure_sre_agent_log_analytics_connector` | `true` | Gives the agent persistent context for the lab Log Analytics workspace when the workspace exists. |
| `enable_azure_sre_agent_azure_monitor_connector` | `false` | Azure Monitor querying is already available through built-in Azure tools. The preview `AzureMonitor` connector can show `Status not available for connector type 'AzureMonitor'`, so it is opt-in for explicit connector testing only. |

If the Operations Hub shows `Logs 1 log error` while Connectors shows `log-analytics` as connected, expand Builder > Connectors. A failed `azure-monitor` row usually means the optional preview Azure Monitor connector is present and its status endpoint is not available. Disable `enable_azure_sre_agent_azure_monitor_connector` and apply again, or remove the failed connector from the portal.

## Azure DevOps Is Optional

Terraform does not store or send Azure DevOps PATs. Azure DevOps repo and wiki access is configured after the agent exists, using the Azure SRE Agent portal:

1. Open the agent at `sre.azure.com`.
2. Use Builder > Code Access for repository access.
3. Use Builder > Connectors or Knowledge Sources for Azure DevOps documentation/wiki indexing, depending on the connector available in the portal.
4. Choose OAuth or managed identity for longer-lived access when available. Use PAT for quick tests or service-account scenarios, then rotate the PAT according to your Azure DevOps policy.

The `ado-lab` profile only tags the deployment with Azure DevOps repo context and keeps the same low-cost lab shape. It does not require an Azure DevOps connection to plan, apply, or validate the normal Azure resources.

## Validation

Normal validation does not check Azure DevOps:

```powershell
.\scripts\Invoke-SreLabValidation.ps1 -Environment cheap-lab -ValidateAzureSreAgent
```

Validate Azure DevOps only after you have connected the repo in the portal:

```powershell
.\scripts\Invoke-SreLabValidation.ps1 `
  -Environment cheap-lab `
  -ValidateAzureSreAgent `
  -ValidateAzureDevOpsRepo `
  -AzureDevOpsRepoName Azureboards `
  -AzureDevOpsRepoUrl "https://dev.azure.com/Beyondcloudwithchriz/Azureboards/_git/Azureboards"
```

For `ado-lab`, the validation script defaults to the Azureboards repo values unless you override them.

## Destroy

Destroy the active lab profile when the demo is finished:

```powershell
terraform destroy -auto-approve -var-file=environments/cheap-lab.tfvars
```

For remote-state deployments, use the GitHub Actions `destroy` workflow with `destroy_confirm` set to `DESTROY`, or initialize locally with the same backend key before running destroy.
