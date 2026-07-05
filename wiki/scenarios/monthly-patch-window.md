# Scenario: Monthly Patch Window

## Goal

Validate that the lab creates a scheduled guest patch window through Azure Update Manager.

## When To Use

Run this before relying on the lab for patch demonstrations or after changing patch schedule variables.

## Prerequisites

- `deploy_update_management = true`
- At least one lab VM deployed.
- Azure portal access to Azure Update Manager.

## Steps

1. Review `patch_start_date_time`, `patch_duration`, `patch_time_zone`, `patch_recur_every`, and `patch_reboot_setting`.
2. Run a plan with the target profile:

```bash
terraform plan -var-file="environments/lab.tfvars"
```

3. Confirm the guest patch maintenance configuration is present in the plan or deployed environment.
4. Confirm target VMs are assigned to the maintenance configuration.
5. After the maintenance window runs, inspect Azure Update Manager history.

## Expected Result

The maintenance configuration exists, assigned VMs are visible, and patch results appear in Azure Update Manager after the scheduled window.

## Success Criteria

- Maintenance configuration exists.
- Target VMs are assigned.
- Patch history is visible after the maintenance window.

## Cleanup And Notes

- Confirm the schedule timezone before demos.
- Use `dev` first if you only need to validate resource creation.
