# Scenario: VM Health Monitoring

## Goal

Validate native Windows VM health visibility through Azure Monitor Agent, Data Collection Rules, metric alerts, and KQL alerts.

## Steps

1. Deploy `cheap-lab` or `lab`.
2. Run `.\scripts\Invoke-SreLabValidation.ps1 -Environment lab`.
3. Open the Log Analytics workspace in the SRE resource group.
4. Query `Heartbeat`, `Perf`, and `Event`.
5. Open alert rules in the SRE resource group.
6. Review the SRE workbook or dashboard when enabled.

## Useful Queries

```kql
Heartbeat
| summarize LastSeen=max(TimeGenerated) by Computer
```

```kql
Perf
| where ObjectName == "LogicalDisk"
| where CounterName == "% Free Space"
| summarize MinFree=min(CounterValue) by Computer, InstanceName
```

```kql
Event
| where TimeGenerated > ago(1h)
| where EventLevel <= 2 or EventLevelName in ("Critical", "Error")
| summarize Count=count() by Computer, EventLevelName
```
