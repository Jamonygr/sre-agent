# Architecture Overview

SRE Agent Windows VM Lab uses Terraform to create a small, repeatable Azure environment for Windows VM incident response. The design is intentionally modular so `cheap-lab` can stay small while `full` can add more targets, backup, and optional network controls.

<p align="center">
  <img src="../images/architecture-overview.svg" alt="SRE Agent Windows VM Lab architecture" width="1000" />
</p>

## Resource Groups

| Resource group role | Main resources |
| --- | --- |
| `network` | Hub, management, and workload VNets, subnets, NSGs, peering, optional Firewall/VPN |
| `windows` | Jumpbox, IIS VM targets, optional domain-controller-style and SQL/file targets |
| `sre` | Log Analytics, Data Collection Rules, alerts, Workbooks, dashboard, SRE Automation Account, optional Backup |
| `governance` | Optional Azure Policy assignments and supporting guardrails |

## Target Topology

- Management VNet hosts the jumpbox.
- Workload VNet hosts one or more IIS Windows VMs.
- Hub, management, and workload VNets are peered for lab connectivity.
- Windows targets receive Azure Monitor Agent when monitoring is enabled.
- Public IIS access is controlled by `allowed_http_source_ips`; public RDP is disabled unless trusted CIDRs are supplied.

## SRE Control Plane

The SRE resource group owns the operational layer:

| Area | Resources |
| --- | --- |
| Telemetry | Log Analytics workspace, Data Collection Rule, DCR associations |
| Detection | VM CPU and availability metric alerts, KQL alerts for heartbeat, IIS outage, disk pressure, and critical Windows events |
| Visibility | Workbooks and optional Azure Portal dashboard |
| Remediation | Automation Account, managed identity, runbooks, optional alert webhooks |
| Governance | Update Manager, Policy, budget, optional VM backup |

## Design Defaults

- Terraform is the source of truth for infrastructure.
- Azure Monitor Agent replaces legacy monitoring agents.
- Alert-triggered runbooks are disabled by default.
- Expensive services stay behind feature flags.
- VM credentials are generated or supplied privately and should not be committed.
