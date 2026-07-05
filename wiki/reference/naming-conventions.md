# Naming Conventions

Names use this base pattern:

```text
<resource-prefix>-<role>-<project>-<environment>-<location-short>
```

For the default `lab` profile in `westus2`, the base name is:

```text
sreag-lab-wus2
```

## Examples

| Resource | Example |
| --- | --- |
| Network RG | `rg-network-sreag-lab-wus2` |
| Windows RG | `rg-windows-sreag-lab-wus2` |
| SRE RG | `rg-sre-sreag-lab-wus2` |
| Governance RG | `rg-governance-sreag-lab-wus2` |
| Hub VNet | `vnet-hub-sreag-lab-wus2` |
| Workload VNet | `vnet-workload-sreag-lab-wus2` |
| Log Analytics | `log-sreag-lab-wus2` |
| DCR | `dcr-vm-ops-sreag-lab-wus2` |
| SRE Automation Account | `aa-sre-sreag-lab-wus2` |
| Action Group | `ag-sre-sreag-lab-wus2` |

## Tags

Common tags include `Environment`, `Project`, `ManagedBy`, `Purpose`, `Owner`, `CostCenter`, `Repository`, and `PatchGroup`.
