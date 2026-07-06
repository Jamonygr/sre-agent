# Variables Reference

The main controls live in `variables.tf`, `terraform.tfvars.example`, and `environments/*.tfvars`.

## Core

| Variable | Default | Purpose |
| --- | --- | --- |
| `project` | `sreag` | Naming prefix |
| `environment` | `lab` | Profile/environment name |
| `location` | `westus2` | Azure region |
| `owner` | `Lab-User` | Owner tag |
| `repository_url` | GitHub repo URL | Repository tag |

## Feature Flags

| Variable | Default | Purpose |
| --- | --- | --- |
| `deploy_monitoring` | `true` | Enable Azure Monitor resources |
| `deploy_log_analytics` | `true` | Create Log Analytics workspace |
| `deploy_azure_monitor_agent` | `true` | Install AMA on Windows VMs |
| `deploy_data_collection_rules` | `true` | Associate DCRs to VMs |
| `deploy_alerts` | `true` | Create action group and metric alerts |
| `deploy_log_query_alerts` | `true` | Create KQL incident alerts |
| `deploy_workbooks` | `true` | Create SRE workbook |
| `deploy_sre_agent` | `true` | Create Automation Account and runbooks |
| `deploy_azure_sre_agent` | `false` | Create a portal-visible Azure SRE Agent (`Microsoft.App/agents`) |
| `enable_azure_sre_agent_log_analytics_connector` | `true` | Add persistent Log Analytics workspace context to the Azure SRE Agent when the workspace exists |
| `enable_azure_sre_agent_azure_monitor_connector` | `false` | Opt in to the preview Azure Monitor connector subresource |
| `enable_alert_runbook_webhooks` | `false` | Opt in to alert-triggered runbooks |
| `deploy_update_management` | `true` | Create Update Manager maintenance config |
| `deploy_backup` | `false` | Create Recovery Services Vault and protect VMs |
| `deploy_policy` | `true` | Create Policy audit assignments |
| `deploy_cost_management` | `true` | Create budget on SRE resource group |
| `deploy_windows_targets` | `true` | Deploy Windows VM targets |
| `deploy_aks` | `false` | Deploy Azure Kubernetes Service |
| `deploy_app_service` | `false` | Deploy Azure App Service |
| `deploy_container_apps` | `false` | Deploy Azure Container Apps |
| `deploy_functions` | `false` | Deploy Azure Functions |

## Azure SRE Agent

| Variable | Default | Purpose |
| --- | --- | --- |
| `azure_sre_agent_name` | `sreag-<environment>` | Portal-visible Azure SRE Agent name |
| `azure_sre_agent_location` | `eastus2` | Azure SRE Agent region |
| `azure_sre_agent_access_level` | `Low` | Read-only investigation by default |
| `azure_sre_agent_action_mode` | `Review` | Require human review for actions |
| `azure_sre_agent_model_provider` | `MicrosoftFoundry` | Default model provider |
| `azure_sre_agent_model_name` | `Automatic` | Let the platform select the model |
| `azure_sre_agent_monthly_unit_limit` | `500` | Lowest active-flow AAU allocation limit |
| `azure_sre_agent_monitor_lookback_days` | `7` | Lookback window used only when the preview Azure Monitor connector is enabled |

Azure DevOps repository and wiki connections are optional and are configured in the Azure SRE Agent portal after deployment. Terraform tags `ado-lab` with repo context, but it does not store PATs or require a DevOps connection for normal validation.

## VM And Access

| Variable | Default | Purpose |
| --- | --- | --- |
| `iis_server_count` | `1` | Number of IIS target VMs |
| `jumpbox_vm_size` | `Standard_B2s` | Jumpbox size |
| `iis_vm_size` | `Standard_B1ms` | IIS target size |
| `enable_jumpbox_public_ip` | `false` | Public IP for jumpbox |
| `enable_iis_public_ip` | `true` | Public IP for IIS HTTP testing |
| `allowed_rdp_source_ips` | `[]` | Trusted public RDP CIDRs |
| `allowed_http_source_ips` | `["0.0.0.0/0"]` | HTTP source CIDRs |

## App Platform Targets

| Variable | Default | Purpose |
| --- | --- | --- |
| `aks_node_count` | `1` | AKS system node pool size |
| `aks_node_vm_size` | `Standard_B2s` | AKS system node VM size |
| `aks_azure_policy_enabled` | `false` | Enable Azure Policy add-on for AKS |
| `app_service_plan_sku_name` | `B1` | Linux App Service plan SKU |
| `function_app_plan_sku_name` | `Y1` | Linux Function App plan SKU |
| `function_app_node_version` | `20` | Function App Node.js runtime |
| `container_app_image` | Microsoft sample image | Demo Container App image |
| `container_app_min_replicas` | `0` | Minimum Container App replicas |
| `container_app_max_replicas` | `1` | Maximum Container App replicas |

## SRE Thresholds

| Variable | Default | Purpose |
| --- | --- | --- |
| `vm_cpu_threshold` | `85` | CPU metric alert threshold |
| `vm_availability_threshold` | `1` | VM availability metric threshold |
| `disk_free_percent_threshold` | `10` | KQL disk free-space threshold |
| `critical_event_threshold` | `5` | KQL Windows event count threshold |
| `log_daily_quota_gb` | `1` | Log Analytics daily cap |
| `alert_email_receivers` | `[]` | Action group and budget email receivers |

## Profiles

| Profile | File |
| --- | --- |
| `cheap-lab` | `environments/cheap-lab.tfvars` |
| `ado-lab` | `environments/ado-lab.tfvars` |
| `dev` | `environments/dev.tfvars` |
| `lab` | `environments/lab.tfvars` |
| `full` | `environments/full.tfvars` |
