# Scenario: Automation Remediation

## Goal

Validate that the SRE Automation Account can remediate lab incidents without stored VM credentials.

## Prerequisites

- `deploy_sre_agent = true`
- Automation Account managed identity exists.
- Managed identity has VM Contributor on the Windows resource group.

## Runbooks

| Runbook | Use |
| --- | --- |
| `Restart-IIS-LabTargets` | Restart W3SVC on IIS targets |
| `Start-StoppedLabVMs` | Start stopped or deallocated lab VMs |
| `Collect-VMDiagnostics` | Collect service, event, volume, and process snapshots |
| `Cleanup-LabDiskPressure` | Remove lab-generated temporary disk load |
| `Stop-Lab-VMs` | Stop lab VMs for cost control |

## Steps

1. Open the SRE Automation Account in `rg-sre-<base>`.
2. Review the runbooks and managed identity role assignment.
3. Start a test runbook with the Windows resource group parameter.
4. Review job output and job status.
5. Confirm the target VM or IIS state changed.

## Optional Alert Webhooks

Set `enable_alert_runbook_webhooks = true` only for a controlled self-healing demo. The default is guided remediation.
