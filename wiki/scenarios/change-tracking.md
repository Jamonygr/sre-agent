# Scenario: Change Tracking

## Goal

Confirm that AMA-based change tracking data appears after a monitored service, software, or configuration change.

## When To Use

Run this when validating operational visibility beyond basic metrics and events.

## Prerequisites

- `deploy_monitoring = true`
- `deploy_data_collection_rules = true`
- `deploy_change_tracking = true`
- Access to a monitored Windows VM.

## Steps

1. Change a monitored Windows setting, service state, or installed feature.
2. Wait for collection.
3. Query recent changes:

```kusto
ConfigurationChange
| order by TimeGenerated desc
| take 50
```

4. Review the update compliance workbook if deployed.

## Expected Result

Configuration changes appear in Log Analytics after the collection delay.

## Success Criteria

- `ConfigurationChange` returns recent records.
- Records identify the changed computer and category.

## Cleanup And Notes

- Revert any setting or service change used only for testing.
- Collection delay is expected after first deployment and after each change.
