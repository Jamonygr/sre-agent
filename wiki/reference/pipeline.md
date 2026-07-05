# Pipeline

The GitHub Actions workflow in `.github/workflows/terraform.yml` follows the same pattern as the other labs.

## Workflow Actions

| Stage | What it does |
| --- | --- |
| Format and validate | `terraform fmt`, backend-free init, `terraform validate`, Terratest compile |
| Security scans | Gitleaks, tfsec, Checkov |
| Lint | TFLint |
| Plan | Azure login through OIDC, Terraform plan, plan artifact upload |
| Policy | Conftest/OPA checks against `tfplan.json` |
| Apply | Manual workflow dispatch, Terraform apply, Terratest smoke tests |
| Destroy | Manual workflow dispatch with `DESTROY` confirmation |

## Workflow Inputs

| Input | Values |
| --- | --- |
| `environment` | `cheap-lab`, `dev`, `lab`, `full` |
| `action` | `plan`, `apply`, `destroy` |
| `destroy_confirm` | Must be `DESTROY` for destroy |

## Required Secrets

| Secret | Purpose |
| --- | --- |
| `AZURE_CLIENT_ID` | Federated identity client ID |
| `AZURE_TENANT_ID` | Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Subscription ID |
| `TF_STATE_RG` | Remote state resource group |
| `TF_STATE_SA` | Remote state storage account |
| `ADMIN_PASSWORD` | Windows VM admin password |

Local validation can use `terraform init -backend=false -reconfigure` for `terraform validate`. For a backend-free no-apply graph plan, use `.\scripts\Invoke-LocalPlan.ps1 -VarFile environments/cheap-lab.tfvars`; the helper copies the repo to a temporary folder and removes `backend.tf` only in that temporary copy.
