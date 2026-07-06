# Monitoring And Dashboards

The lab uses Azure Monitor Agent and Data Collection Rules for Windows telemetry. Azure Monitor detects incidents with both platform metrics and KQL scheduled-query alerts.

<p align="center">
  <img src="../images/telemetry-remediation-flow.svg" alt="Telemetry and remediation flow" width="1000" />
</p>

## Telemetry Sources

| Source | Destination | Used for |
| --- | --- | --- |
| VM platform metrics | Azure Monitor metrics | CPU and VM availability alerts |
| `Microsoft-Perf` | Log Analytics `Perf` table | CPU, memory, disk free space, IIS connection counters |
| `Microsoft-Event` | Log Analytics `Event` table | Service Control Manager and critical/error Windows events |
| Heartbeat | Log Analytics `Heartbeat` table | Missing heartbeat detection |
| Change tracking streams | Log Analytics | Optional configuration-change visibility |

## Azure SRE Agent Log Context

When `deploy_azure_sre_agent = true`, the portal-visible agent can use built-in Azure tools to query Azure Monitor and Log Analytics through managed identity and RBAC. The lab also enables `enable_azure_sre_agent_log_analytics_connector = true` by default so the agent has persistent context for the lab workspace.

Keep `enable_azure_sre_agent_azure_monitor_connector = false` unless you are testing that preview connector directly. A failed `azure-monitor` connector can make the Operations Hub Logs tile red even while the `log-analytics` connector is healthy.

## Alert Rules

| Alert | Type | Signal |
| --- | --- | --- |
| VM CPU | Metric | `Percentage CPU` above `vm_cpu_threshold` |
| VM availability | Metric | `VmAvailabilityMetric` below threshold |
| Missing heartbeat | KQL | A VM stopped sending heartbeat recently |
| IIS outage | KQL | W3SVC stop/termination events |
| Disk pressure | KQL | Logical disk free space below `disk_free_percent_threshold` |
| Critical Windows events | KQL | Error or critical event count above `critical_event_threshold` |

## Action Groups

The primary action group handles email and normal alert routing. When `enable_alert_runbook_webhooks = true`, Terraform also creates a remediation action group in the SRE agent module and attaches it to alerts.

Keep webhook remediation off until you are ready to demonstrate self-healing behavior. The safer default is guided remediation: review the alert, inspect telemetry, then run the right runbook.

## Workbooks

The workbook module provides an operator view over the workspace. Use it alongside Log Analytics queries while running `Invoke-SreIncident.ps1` scenarios.
