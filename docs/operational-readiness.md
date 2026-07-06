# Operational Readiness

This lab is shaped as a polished Azure operations sandbox: small enough to deploy for learning, but structured like a serious cloud environment. Use this page before demos, reviews, or handoff.

## Readiness Principles

| Area | What this lab demonstrates | Evidence in the repo |
| --- | --- | --- |
| Reliability | Health signals for VMs and app-platform services, Resource Health alerting, repeatable Terraform plans | `modules/monitoring/alerts`, `resource_health_alert_resource_types`, environment plans |
| Security | Private-by-default RDP, managed identities for compute and automation, disabled basic publishing credentials for App Service and Functions | `allowed_rdp_source_ips`, `modules/sre-agent`, `modules/app-platform` |
| Cost control | Low-cost profiles, disabled premium services by default, budget alerting, scheduled VM start/stop | `environments/cheap-lab.tfvars`, `environments/ado-lab.tfvars`, `modules/cost-management`, `enable_scheduled_startstop` |
| Operational excellence | Quality gate script, runbook remediation, validation script, CI formatting/lint/security scans | `scripts/Invoke-QualityGate.ps1`, `.github/workflows/terraform.yml` |
| Performance efficiency | Small default SKUs, configurable AKS node pool, autoscaling Container Apps replicas | `aks_node_vm_size`, `container_app_min_replicas`, `container_app_max_replicas` |
| Governance | Required tags, allowed locations, naming conventions, policy assignments | `modules/policy`, `wiki/reference/naming-conventions.md` |

## Microsoft Learn Alignment

The lab maps to public Azure architecture guidance without claiming certification or endorsement:

| Guidance | How it shows up here |
| --- | --- |
| [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/) | Reliability, security, cost, operational, and performance checks are visible in code and validation |
| [Azure landing zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/) | Separate network, workload, app, SRE, and governance resource-group roles |
| [Azure resource naming](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) | Consistent prefixes and environment/location suffixes |
| [Azure tagging strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging) | Common tags for ownership, cost, repository, environment, and automation |

## Profiles

| Profile | Intended use | App-platform services | Cost posture |
| --- | --- | --- | --- |
| `cheap-lab` | First review, documentation walk-through, low-cost smoke plan | Off | Lowest |
| `ado-lab` | Low-cost Azure SRE Agent lab with Azure DevOps repo context | Off | Low |
| `dev` | Module validation and CI-friendly planning | Off | Very low |
| `lab` | Full Azure operations demo with Windows and app-platform targets | On | Moderate |
| `full` | Expanded scenario demo with backup and extra targets | On | Highest |

## Quality Gate

Run the local quality gate before pushing:

```powershell
.\scripts\Invoke-QualityGate.ps1
```

For a faster documentation or CI-style pass:

```powershell
.\scripts\Invoke-QualityGate.ps1 -SkipPlans
```

The gate checks formatting, Terraform validation, PowerShell syntax, Terratest compilation, reserved wording, and local no-refresh plans for the core profiles.

## Demo Checklist

1. Choose the profile deliberately.
2. Confirm Azure CLI is logged in and the target subscription is selected.
3. Set `TF_VAR_admin_password` privately or use an ignored `terraform.tfvars`.
4. Run `.\scripts\Invoke-QualityGate.ps1 -PlanProfiles cheap-lab,ado-lab,lab`.
5. Apply only the selected profile.
6. Run `.\scripts\Invoke-SreLabValidation.ps1 -Environment <profile>`.
7. For `lab` and `full`, add `-ValidateAppPlatform` to prove AKS, App Service, Container Apps, and Functions are present.

## Handoff Notes

- Keep public RDP disabled unless a trusted CIDR is provided.
- Keep alert-triggered runbook webhooks disabled until a remediation exercise needs them.
- Keep Azure DevOps validation opt-in. Repository and wiki access are portal connections, not Terraform secrets.
- Keep the preview Azure Monitor connector disabled unless it is the test target; the Log Analytics connector provides the normal lab workspace context.
- Treat Terraform state as sensitive because VM credentials and platform-generated keys can appear in state.
- Start with `cheap-lab` for review, or `ado-lab` when Azure DevOps repo context is part of the demo. Move to `lab` only when app-platform services are needed.
- Destroy temporary deployments when the session is finished.
