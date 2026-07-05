# Scenario: Disk Pressure

## Goal

Create a temporary lab load file and validate the disk-free-space KQL alert.

## Trigger

```powershell
.\scripts\Invoke-SreIncident.ps1 -Scenario DiskPressure -Environment lab -DiskLoadGb 2
```

## Validate

1. Check the `Perf` table for `LogicalDisk` free-space counters.
2. Confirm `SRE disk pressure` scheduled-query alert exists.
3. If enough pressure was generated, review the alert state after the evaluation window.
4. Run `Cleanup-LabDiskPressure` from the SRE Automation Account.

## Cleanup

The cleanup runbook removes `C:\SreIncidentLoad` and common temporary files.
