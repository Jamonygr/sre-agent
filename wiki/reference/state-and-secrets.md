# State and Secrets

## Purpose

This page documents the secret-bearing parts of the lab: Terraform state, VM administrator credentials, GitHub OIDC inputs, and files that must stay out of Git.

## Do Not Commit

Do not commit private `terraform.tfvars`, `.tfstate`, plan files, exported state, keys, certificates, local archives, or source deck files.

## Remote State

Create an Azure Storage account and container for Terraform state:

```powershell
$RESOURCE_GROUP = "rg-terraform-state"
$LOCATION = "westus2"
$STORAGE_ACCOUNT = "stterraformstate$(Get-Random -Maximum 9999)"

az group create --name $RESOURCE_GROUP --location $LOCATION
az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --sku Standard_LRS `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false
az storage container create --name tfstate --account-name $STORAGE_ACCOUNT --auth-mode login
```

Set GitHub secrets:

| Secret | Purpose |
|---|---|
| `TF_STATE_RG` | State resource group. |
| `TF_STATE_SA` | State storage account. |
| `AZURE_CLIENT_ID` | OIDC app registration client ID. |
| `AZURE_TENANT_ID` | Azure tenant ID. |
| `AZURE_SUBSCRIPTION_ID` | Target subscription. |

## VM Credentials

Use one private mechanism for VM administrator credentials:

- `TF_VAR_admin_password`
- ignored local `terraform.tfvars`
- GitHub `ADMIN_PASSWORD` secret mapped to `TF_VAR_admin_password`

If no password is provided, or if the CI secret is blank, Terraform generates one and stores it in state.

## Guardrails

- Treat state as sensitive because generated VM passwords can be recovered from it.
- Limit access to the state storage account, state container, CI artifacts, and local state copies.
- Use a supplied `ADMIN_PASSWORD` for repeatable lab access.
- Leaving the password unset is acceptable for no-login smoke tests, but the generated value still exists in state until state retention is managed.
- Review state access before enabling public IIS or `full` profile infrastructure.

## Related Pages

- [Pipeline](pipeline.md)
- [Variables reference](variables.md)
- [Review and recommendations](review-and-recommendations.md)
