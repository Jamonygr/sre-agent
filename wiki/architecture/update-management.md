# Update Management, Backup, And Guardrails

The SRE lab includes optional governance controls around Windows VM operations. These controls are useful for practicing real operating rhythms without turning the lab into a production blueprint.

## Update Manager

When `deploy_update_management = true`, Terraform creates:

- An in-guest patch maintenance configuration.
- Static assignments for deployed lab VMs.
- Optional dynamic scope assignment targeting the `PatchGroup` tag.

Default profile behavior:

| Profile | Update Manager | Dynamic scope |
| --- | --- | --- |
| `cheap-lab` | Off | Off |
| `dev` | On | Off |
| `lab` | On | On |
| `full` | On | On |

## SRE Runbooks

| Runbook | Purpose |
| --- | --- |
| `Restart-IIS-LabTargets` | Restarts W3SVC on VMs tagged `Role = IIS` |
| `Start-StoppedLabVMs` | Starts stopped/deallocated VMs in the Windows resource group |
| `Collect-VMDiagnostics` | Collects service, volume, event, and process snapshots |
| `Cleanup-LabDiskPressure` | Removes lab-generated temporary disk load |
| `Stop-Lab-VMs` | Stops lab VMs for scheduled cost control |

## Backup

`deploy_backup = true` creates a Recovery Services Vault and protects selected VMs. Backup is off in smaller profiles to keep cost and deployment time low.

## Policy And Cost

Optional Policy assignments audit required tags and allowed locations. Cost Management creates a budget on the SRE resource group so the lab can show cost guardrails without applying tenant-wide policy.
