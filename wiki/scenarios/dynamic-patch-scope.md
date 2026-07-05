# Scenario: Dynamic Patch Scope

## Goal

Validate tag-based patch targeting with Azure Update Manager dynamic scopes.

## When To Use

Run this when you want patch assignments to follow VM tags instead of only static VM assignments.

## Prerequisites

- `deploy_update_management = true`
- `deploy_update_dynamic_scopes = true`
- VMs tagged with the configured `default_patch_group`, normally `PatchGroup = "weekend"`.

## Steps

1. Confirm the expected VMs have the `PatchGroup` tag.
2. Confirm non-target VMs do not use the same tag value.
3. Apply or inspect the target profile.
4. Open Azure Update Manager.
5. Review the dynamic scope membership.

## Expected Result

VMs with the matching `PatchGroup` tag are included in the dynamic scope, and non-matching VMs are excluded.

## Success Criteria

- Matching VMs are included.
- Non-matching VMs are excluded.
- The dynamic assignment appears in Update Manager.

## Cleanup And Notes

- Dynamic scopes can target any matching machine in scope, so test tag filters carefully.
- Keep tag naming consistent with the required tag policy.
