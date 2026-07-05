# Scenario: Update Compliance Dashboard

## Goal

Confirm that update and change telemetry is available for the lab VMs.

## When To Use

Run this after deploying the `lab` or `full` profile and waiting for Azure Monitor Agent data collection to start.

## Prerequisites

- `deploy_monitoring = true`
- `deploy_azure_monitor_agent = true`
- `deploy_data_collection_rules = true`
- `deploy_update_management = true`
- `deploy_workbooks = true`

## Steps

1. Deploy with `environments/lab.tfvars` or `environments/full.tfvars`.
2. Open Azure Update Manager and review the lab VMs.
3. Open the `SRE Agent Azure Lab - Update Compliance` workbook.
4. Change a monitored Windows setting, service state, or installed feature.
5. Query recent change data:

```kusto
ConfigurationChange
| order by TimeGenerated desc
| take 50
```

## Expected Result

Update Manager shows the lab VMs, the workbook opens, and change data appears after the collection delay.

## Success Criteria

- VMs appear in Azure Update Manager.
- The update compliance workbook opens successfully.
- `ConfigurationChange` returns data after a test change.

## Cleanup And Notes

- Revert any temporary service or feature change used for testing.
- Change tracking data can take time to appear after the first deployment.
