# Scenario: Backup Validation

## Goal

Validate optional VM protection with a Recovery Services Vault.

## Prerequisites

- `deploy_backup = true`
- At least one Windows VM target deployed

## Steps

1. Apply the `full` profile or another profile with backup enabled.
2. Open the SRE resource group.
3. Confirm the Recovery Services Vault exists.
4. Confirm the daily VM backup policy exists.
5. Confirm selected VMs are protected.
6. Optionally start an on-demand backup and review job status.

## Cost Note

Backup storage can add cost. Keep it off in `cheap-lab`, `dev`, and normal `lab` unless recovery validation is part of the exercise.
