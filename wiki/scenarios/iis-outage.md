# Scenario: IIS Outage

## Goal

Stop IIS on a Windows target, observe the signal, and restart it through the SRE runbook.

## Prerequisites

- `deploy_windows_targets = true`
- `deploy_iis_farm = true`
- `deploy_monitoring = true`
- `deploy_sre_agent = true`

## Trigger

```powershell
.\scripts\Invoke-SreIncident.ps1 -Scenario IisOutage -Environment lab
```

## Validate

1. Confirm the target VM shows W3SVC stopped.
2. Check Log Analytics for Service Control Manager events.
3. Confirm the `SRE IIS outage` scheduled-query alert exists.
4. Run `Restart-IIS-LabTargets` from the Automation Account.
5. Confirm W3SVC returns to `Running`.

## Cleanup

```powershell
.\scripts\Invoke-SreIncident.ps1 -Scenario CollectDiagnostics -Environment lab
```
