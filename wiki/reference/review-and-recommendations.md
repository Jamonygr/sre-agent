# Review And Recommendations

Last reviewed: 2026-07-05.

## Current Status

The lab was scaffolded from the local Azure operations lab patterns, then refocused into the SRE Agent Azure Lab.

| Area | Status | Notes |
| --- | --- | --- |
| Terraform formatting | Passed | `terraform fmt -recursive` |
| Terraform initialization | Passed | `terraform init -backend=false -reconfigure` |
| Terraform validation | Passed | `terraform validate` |
| Terratest compile | Passed | `GOTOOLCHAIN=local go test -v -run '^$' ./...` from `tests/` |
| `cheap-lab` plan | Passed | Temp local-backend plan via `Invoke-LocalPlan.ps1`; 60 to add, 0 to change, 0 to destroy |

## Before First Apply

- Configure remote state before using CI/CD apply or destroy.
- Set `TF_VAR_admin_password` locally or `ADMIN_PASSWORD` in GitHub secrets for reusable VM login.
- Start with `cheap-lab`.
- Keep `enable_alert_runbook_webhooks = false` until guided remediation has been tested manually.
- Restrict `allowed_http_source_ips` and `allowed_rdp_source_ips` for shared demos.

## Before Demo

- Add at least one `alert_email_receivers` entry.
- Run `Invoke-SreLabValidation.ps1`.
- Trigger `IisOutage` and remediate with `Restart-IIS-LabTargets`.
- Trigger `CollectDiagnostics` and review Automation job output.
- Destroy unused environments after validation.

## Future Extensions

- Optional AI incident summarization can be added later behind a feature flag.
- Bastion/private-only access can replace public IIS testing paths.
- Sentinel or Defender for Cloud can extend the SRE signal path.
- Logic Apps can add approval workflows before runbook execution.
