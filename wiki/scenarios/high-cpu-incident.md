# Scenario: High CPU Incident

## Goal

Generate temporary CPU load and validate the VM CPU metric alert and workbook signal.

## Trigger

```powershell
.\scripts\Invoke-SreIncident.ps1 -Scenario HighCpu -Environment lab -CpuMinutes 10
```

## Validate

1. Open the SRE workbook or Azure Monitor metrics for the target VM.
2. Confirm CPU rises above `vm_cpu_threshold`.
3. Confirm `alert-vm-cpu-*` exists in the SRE resource group.
4. Review alert state after the evaluation window.

## Notes

CPU load is temporary and ends after `CpuMinutes`.
