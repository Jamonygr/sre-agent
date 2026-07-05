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
| `enable_alert_runbook_webhooks` | `false` | Opt in to alert-triggered runbooks |
| `deploy_update_management` | `true` | Create Update Manager maintenance config |
| `deploy_backup` | `false` | Create Recovery Services Vault and protect VMs |
| `deploy_policy` | `true` | Create Policy audit assignments |
| `deploy_cost_management` | `true` | Create budget on SRE resource group |
| `deploy_windows_targets` | `true` | Deploy Windows VM targets |

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
| `dev` | `environments/dev.tfvars` |
| `lab` | `environments/lab.tfvars` |
| `full` | `environments/full.tfvars` |
