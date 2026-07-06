# =============================================================================
# ROOT VARIABLES
# =============================================================================

variable "subscription_id" {
  description = "Azure subscription ID. If null, AzureRM uses the authenticated account context."
  type        = string
  default     = null
}

variable "project" {
  description = "Project naming prefix."
  type        = string
  default     = "sreag"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "lab"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westus2"
}

variable "owner" {
  description = "Owner tag value."
  type        = string
  default     = "Lab-User"
}

variable "repository_url" {
  description = "Git repository URL."
  type        = string
  default     = "https://github.com/Jamonygr/sre-agent"
}

variable "extra_tags" {
  description = "Extra tags to merge into every resource."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.extra_tags :
      !startswith(lower(key), "microsoft") &&
      !startswith(lower(key), "azure") &&
      !startswith(lower(key), "windows")
    ])
    error_message = "extra_tags keys must not start with reserved Azure tag prefixes: microsoft, azure, or windows."
  }
}

variable "admin_username" {
  description = "Admin username for Windows VMs."
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password for Windows VMs. Prefer TF_VAR_admin_password or a private terraform.tfvars file."
  type        = string
  sensitive   = true
  default     = null
}

variable "hub_address_space" {
  description = "Hub VNet address space."
  type        = list(string)
  default     = ["10.40.0.0/16"]

  validation {
    condition     = alltrue([for cidr in var.hub_address_space : can(cidrhost(cidr, 0))])
    error_message = "Every hub address space entry must be a valid CIDR block."
  }
}

variable "hub_ops_subnet_prefix" {
  description = "Hub operations subnet prefix."
  type        = string
  default     = "10.40.1.0/24"

  validation {
    condition     = can(cidrhost(var.hub_ops_subnet_prefix, 0))
    error_message = "Hub operations subnet prefix must be a valid CIDR block."
  }
}

variable "hub_firewall_subnet_prefix" {
  description = "AzureFirewallSubnet prefix."
  type        = string
  default     = "10.40.2.0/24"

  validation {
    condition     = can(cidrhost(var.hub_firewall_subnet_prefix, 0))
    error_message = "Azure Firewall subnet prefix must be a valid CIDR block."
  }
}

variable "hub_firewall_management_subnet_prefix" {
  description = "AzureFirewallManagementSubnet prefix used by Azure Firewall Basic."
  type        = string
  default     = "10.40.4.0/26"

  validation {
    condition     = can(cidrhost(var.hub_firewall_management_subnet_prefix, 0))
    error_message = "Azure Firewall management subnet prefix must be a valid CIDR block."
  }
}

variable "hub_gateway_subnet_prefix" {
  description = "GatewaySubnet prefix."
  type        = string
  default     = "10.40.3.0/24"

  validation {
    condition     = can(cidrhost(var.hub_gateway_subnet_prefix, 0))
    error_message = "Gateway subnet prefix must be a valid CIDR block."
  }
}

variable "management_address_space" {
  description = "Management VNet address space."
  type        = list(string)
  default     = ["10.41.0.0/16"]

  validation {
    condition     = alltrue([for cidr in var.management_address_space : can(cidrhost(cidr, 0))])
    error_message = "Every management address space entry must be a valid CIDR block."
  }
}

variable "management_subnet_prefix" {
  description = "Management subnet prefix."
  type        = string
  default     = "10.41.1.0/24"

  validation {
    condition     = can(cidrhost(var.management_subnet_prefix, 0))
    error_message = "Management subnet prefix must be a valid CIDR block."
  }
}

variable "workload_address_space" {
  description = "Workload VNet address space."
  type        = list(string)
  default     = ["10.42.0.0/16"]

  validation {
    condition     = alltrue([for cidr in var.workload_address_space : can(cidrhost(cidr, 0))])
    error_message = "Every workload address space entry must be a valid CIDR block."
  }
}

variable "workload_web_subnet_prefix" {
  description = "Workload web subnet prefix."
  type        = string
  default     = "10.42.1.0/24"

  validation {
    condition     = can(cidrhost(var.workload_web_subnet_prefix, 0))
    error_message = "Workload web subnet prefix must be a valid CIDR block."
  }
}

variable "workload_app_subnet_prefix" {
  description = "Workload app subnet prefix."
  type        = string
  default     = "10.42.2.0/24"

  validation {
    condition     = can(cidrhost(var.workload_app_subnet_prefix, 0))
    error_message = "Workload app subnet prefix must be a valid CIDR block."
  }
}

# -----------------------------------------------------------------------------
# Feature flags
# -----------------------------------------------------------------------------

variable "deploy_monitoring" {
  description = "Deploy Azure Monitor resources."
  type        = bool
  default     = true
}

variable "deploy_log_analytics" {
  description = "Deploy Log Analytics workspace."
  type        = bool
  default     = true
}

variable "deploy_azure_monitor_agent" {
  description = "Install Azure Monitor Agent on lab VMs."
  type        = bool
  default     = true
}

variable "deploy_data_collection_rules" {
  description = "Deploy Data Collection Rules and associate them to lab VMs."
  type        = bool
  default     = true
}

variable "deploy_vm_insights" {
  description = "Install dependency agent extension to support VM insights-style dependency data."
  type        = bool
  default     = false
}

variable "deploy_change_tracking" {
  description = "Add Change Tracking and Inventory streams to the AMA data collection rule."
  type        = bool
  default     = true
}

variable "deploy_update_management" {
  description = "Deploy Azure Update Manager maintenance configuration and assignments."
  type        = bool
  default     = true
}

variable "deploy_update_dynamic_scopes" {
  description = "Deploy tag-based dynamic maintenance assignment."
  type        = bool
  default     = true
}

variable "deploy_workbooks" {
  description = "Deploy Azure Monitor workbooks."
  type        = bool
  default     = true
}

variable "deploy_portal_dashboards" {
  description = "Deploy Azure Portal dashboard."
  type        = bool
  default     = true
}

variable "deploy_managed_grafana" {
  description = "Deploy Azure Managed Grafana. Off by default due cost/setup overhead."
  type        = bool
  default     = false
}

variable "deploy_alerts" {
  description = "Deploy metric alerts and the primary SRE action group."
  type        = bool
  default     = true
}

variable "deploy_log_query_alerts" {
  description = "Deploy KQL scheduled-query alerts for heartbeat, IIS, disk, and Windows event scenarios."
  type        = bool
  default     = true
}

variable "deploy_activity_log_alerts" {
  description = "Deploy activity log administrative alerts."
  type        = bool
  default     = true
}

variable "deploy_service_health_alerts" {
  description = "Deploy service health alerts."
  type        = bool
  default     = true
}

variable "deploy_resource_health_alerts" {
  description = "Deploy Resource Health alerts for lab resources. Activity Log alerts are free and low overhead."
  type        = bool
  default     = true
}

variable "deploy_advisor_recommendation_alerts" {
  description = "Deploy Azure Advisor recommendation activity log alerts for lab resource groups."
  type        = bool
  default     = true
}

variable "deploy_sre_agent" {
  description = "Deploy the Azure-native SRE agent Automation Account, managed identity, runbooks, and optional remediation action group."
  type        = bool
  default     = true
}

variable "deploy_azure_sre_agent" {
  description = "Deploy a portal-visible Azure SRE Agent resource (Microsoft.App/agents). This is separate from the Automation/runbook SRE lab module."
  type        = bool
  default     = false
}

variable "azure_sre_agent_name" {
  description = "Azure SRE Agent name. When null or empty, Terraform uses sreag-<environment>."
  type        = string
  default     = null

  validation {
    condition = (
      var.azure_sre_agent_name == null ||
      trimspace(var.azure_sre_agent_name) == "" ||
      can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", trimspace(var.azure_sre_agent_name)))
    )
    error_message = "azure_sre_agent_name must be lowercase alphanumeric with optional hyphens, 2-63 characters."
  }
}

variable "azure_sre_agent_location" {
  description = "Azure region for the portal-visible Azure SRE Agent. This can differ from the lab workload region."
  type        = string
  default     = "eastus2"

  validation {
    condition = contains([
      "swedencentral",
      "uksouth",
      "eastus2",
      "australiaeast",
      "francecentral",
      "canadacentral",
      "koreacentral",
    ], lower(replace(var.azure_sre_agent_location, " ", "")))
    error_message = "azure_sre_agent_location must be a currently supported Azure SRE Agent region."
  }
}

variable "azure_sre_agent_access_level" {
  description = "Azure SRE Agent access level. Low keeps investigation read-only; High allows privileged actions."
  type        = string
  default     = "Low"

  validation {
    condition     = contains(["High", "Low"], var.azure_sre_agent_access_level)
    error_message = "azure_sre_agent_access_level must be High or Low."
  }
}

variable "azure_sre_agent_action_mode" {
  description = "Azure SRE Agent action mode. Review requires human approval; Automatic lets the agent act independently."
  type        = string
  default     = "Review"

  validation {
    condition     = contains(["Review", "Automatic"], var.azure_sre_agent_action_mode)
    error_message = "azure_sre_agent_action_mode must be Review or Automatic."
  }
}

variable "azure_sre_agent_model_provider" {
  description = "Default model provider for Azure SRE Agent."
  type        = string
  default     = "MicrosoftFoundry"

  validation {
    condition     = contains(["MicrosoftFoundry", "Anthropic"], var.azure_sre_agent_model_provider)
    error_message = "azure_sre_agent_model_provider must be MicrosoftFoundry or Anthropic."
  }
}

variable "azure_sre_agent_model_name" {
  description = "Default model name for Azure SRE Agent. Automatic lets the platform choose the default model for the provider."
  type        = string
  default     = "Automatic"
}

variable "azure_sre_agent_monthly_unit_limit" {
  description = "Monthly active-flow Azure Agent Unit allocation limit for Azure SRE Agent."
  type        = number
  default     = 500

  validation {
    condition     = var.azure_sre_agent_monthly_unit_limit >= 500 && var.azure_sre_agent_monthly_unit_limit <= 1000000
    error_message = "azure_sre_agent_monthly_unit_limit must be between 500 and 1000000."
  }
}

variable "azure_sre_agent_monitor_lookback_days" {
  description = "Azure Monitor connector alert lookback window in days for Azure SRE Agent."
  type        = number
  default     = 7

  validation {
    condition     = var.azure_sre_agent_monitor_lookback_days >= 1 && var.azure_sre_agent_monitor_lookback_days <= 30
    error_message = "azure_sre_agent_monitor_lookback_days must be between 1 and 30."
  }
}

variable "enable_azure_sre_agent_azure_monitor_connector" {
  description = "Create the preview Azure Monitor connector subresource for Azure SRE Agent. Keep false unless testing the connector explicitly; the agent can query Azure Monitor through built-in Azure tools."
  type        = bool
  default     = false
}

variable "enable_azure_sre_agent_log_analytics_connector" {
  description = "Create a Log Analytics connector for Azure SRE Agent when the lab workspace exists, giving the agent persistent workspace context in addition to built-in Azure log querying."
  type        = bool
  default     = true
}

variable "enable_alert_runbook_webhooks" {
  description = "Create Automation webhooks and a remediation action group so alerts can invoke safe lab runbooks. Disabled by default."
  type        = bool
  default     = false
}

variable "enable_scheduled_startstop" {
  description = "Deploy scheduled VM start/stop runbook schedules."
  type        = bool
  default     = true
}

variable "deploy_backup" {
  description = "Deploy Recovery Services Vault and protect selected VMs."
  type        = bool
  default     = false
}

variable "deploy_policy" {
  description = "Deploy Azure Policy guardrails."
  type        = bool
  default     = true
}

variable "deploy_cost_management" {
  description = "Deploy cost budget alert."
  type        = bool
  default     = true
}

variable "deploy_windows_targets" {
  description = "Deploy Windows VM targets for SRE incident scenarios."
  type        = bool
  default     = true
}

variable "deploy_jumpbox" {
  description = "Deploy a Windows jumpbox VM."
  type        = bool
  default     = true
}

variable "deploy_iis_farm" {
  description = "Deploy IIS web server VMs."
  type        = bool
  default     = true
}

variable "deploy_domain_controller" {
  description = "Deploy a Windows domain-controller-style target VM."
  type        = bool
  default     = false
}

variable "deploy_sql_vm" {
  description = "Deploy a Windows SQL/file-server-style target VM."
  type        = bool
  default     = false
}

variable "deploy_firewall" {
  description = "Deploy Azure Firewall. Expensive; disabled by default."
  type        = bool
  default     = false
}

variable "deploy_vpn_gateway" {
  description = "Deploy VPN Gateway. Expensive; disabled by default."
  type        = bool
  default     = false
}

variable "deploy_aks" {
  description = "Deploy an Azure Kubernetes Service cluster as a modern app-platform lab target."
  type        = bool
  default     = false
}

variable "deploy_app_service" {
  description = "Deploy an Azure App Service Linux Web App as a modern app-platform lab target."
  type        = bool
  default     = false
}

variable "deploy_container_apps" {
  description = "Deploy Azure Container Apps environment and sample app as a modern app-platform lab target."
  type        = bool
  default     = false
}

variable "deploy_functions" {
  description = "Deploy an Azure Functions Linux Function App as a modern app-platform lab target."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Compute, app platform, and access
# -----------------------------------------------------------------------------

variable "vm_size" {
  description = "Default VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "jumpbox_vm_size" {
  description = "Jumpbox VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "iis_vm_size" {
  description = "IIS VM size."
  type        = string
  default     = "Standard_B1ms"
}

variable "iis_server_count" {
  description = "Number of IIS web servers."
  type        = number
  default     = 1

  validation {
    condition     = var.iis_server_count >= 0 && var.iis_server_count <= 10 && floor(var.iis_server_count) == var.iis_server_count
    error_message = "IIS server count must be a whole number between 0 and 10."
  }
}

variable "enable_jumpbox_public_ip" {
  description = "Create a public IP for the jumpbox."
  type        = bool
  default     = false
}

variable "enable_iis_public_ip" {
  description = "Create public IPs for IIS web servers."
  type        = bool
  default     = true
}

variable "allowed_rdp_source_ips" {
  description = "CIDRs allowed to RDP to public Windows VMs."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.allowed_rdp_source_ips : can(cidrhost(cidr, 0))])
    error_message = "Every allowed RDP source must be a valid CIDR block."
  }

  validation {
    condition     = var.allow_public_rdp_from_internet || !contains(var.allowed_rdp_source_ips, "0.0.0.0/0")
    error_message = "Public RDP from 0.0.0.0/0 is blocked by default. Use trusted CIDRs or set allow_public_rdp_from_internet=true for a short-lived lab exception."
  }
}

variable "allow_public_rdp_from_internet" {
  description = "Break-glass override for 0.0.0.0/0 RDP."
  type        = bool
  default     = false
}

variable "allowed_http_source_ips" {
  description = "CIDRs allowed to reach IIS over HTTP."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.allowed_http_source_ips : can(cidrhost(cidr, 0))])
    error_message = "Every allowed HTTP source must be a valid CIDR block."
  }
}

variable "aks_node_count" {
  description = "AKS system node pool node count."
  type        = number
  default     = 1

  validation {
    condition     = var.aks_node_count >= 1 && var.aks_node_count <= 5 && floor(var.aks_node_count) == var.aks_node_count
    error_message = "AKS node count must be a whole number between 1 and 5."
  }
}

variable "aks_node_vm_size" {
  description = "AKS system node pool VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "aks_os_disk_size_gb" {
  description = "AKS system node pool OS disk size in GB."
  type        = number
  default     = 64

  validation {
    condition     = var.aks_os_disk_size_gb >= 30 && floor(var.aks_os_disk_size_gb) == var.aks_os_disk_size_gb
    error_message = "AKS OS disk size must be a whole number of at least 30 GB."
  }
}

variable "aks_azure_policy_enabled" {
  description = "Enable Azure Policy add-on for AKS."
  type        = bool
  default     = false
}

variable "app_service_plan_sku_name" {
  description = "App Service Linux plan SKU."
  type        = string
  default     = "B1"
}

variable "app_service_always_on" {
  description = "Enable Always On for App Service. Keep false when using free or shared SKUs."
  type        = bool
  default     = false
}

variable "function_app_plan_sku_name" {
  description = "Linux Function App plan SKU."
  type        = string
  default     = "Y1"
}

variable "function_app_node_version" {
  description = "Linux Function App Node.js runtime version."
  type        = string
  default     = "20"
}

variable "container_app_image" {
  description = "Container image for the demo Azure Container App."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_app_min_replicas" {
  description = "Minimum replicas for the demo Azure Container App."
  type        = number
  default     = 0

  validation {
    condition     = var.container_app_min_replicas >= 0 && floor(var.container_app_min_replicas) == var.container_app_min_replicas
    error_message = "Container App min replicas must be a whole number of at least 0."
  }
}

variable "container_app_max_replicas" {
  description = "Maximum replicas for the demo Azure Container App."
  type        = number
  default     = 1

  validation {
    condition     = var.container_app_max_replicas >= 1 && floor(var.container_app_max_replicas) == var.container_app_max_replicas
    error_message = "Container App max replicas must be a whole number of at least 1."
  }
}

# -----------------------------------------------------------------------------
# Monitoring, update, automation, backup, governance
# -----------------------------------------------------------------------------

variable "log_retention_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && floor(var.log_retention_days) == var.log_retention_days
    error_message = "Log Analytics retention must be a whole number of at least 30 days."
  }
}

variable "log_daily_quota_gb" {
  description = "Log Analytics daily quota in GB. Null means no explicit cap."
  type        = number
  default     = 1

  validation {
    condition     = var.log_daily_quota_gb == null || var.log_daily_quota_gb >= 0
    error_message = "Log Analytics daily quota must be null or a non-negative number."
  }
}

variable "alert_email_receivers" {
  description = "Email receivers for action group and budgets."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "vm_cpu_threshold" {
  description = "VM CPU alert threshold."
  type        = number
  default     = 85

  validation {
    condition     = var.vm_cpu_threshold > 0 && var.vm_cpu_threshold <= 100
    error_message = "VM CPU threshold must be greater than 0 and less than or equal to 100."
  }
}

variable "vm_availability_threshold" {
  description = "VM availability alert threshold."
  type        = number
  default     = 1

  validation {
    condition     = var.vm_availability_threshold >= 0 && var.vm_availability_threshold <= 1
    error_message = "VM availability threshold must be between 0 and 1."
  }
}

variable "disk_free_percent_threshold" {
  description = "Log-query alert threshold for minimum free disk percentage."
  type        = number
  default     = 10

  validation {
    condition     = var.disk_free_percent_threshold >= 0 && var.disk_free_percent_threshold <= 100
    error_message = "Disk free percent threshold must be between 0 and 100."
  }
}

variable "critical_event_threshold" {
  description = "Number of critical/error Windows events in the alert window that triggers the event alert."
  type        = number
  default     = 5

  validation {
    condition     = var.critical_event_threshold >= 1 && floor(var.critical_event_threshold) == var.critical_event_threshold
    error_message = "Critical event threshold must be a whole number of at least 1."
  }
}

variable "resource_health_alert_resource_types" {
  description = "Azure resource types included in Resource Health alerting."
  type        = list(string)
  default = [
    "Microsoft.Compute/virtualMachines",
    "Microsoft.ContainerService/managedClusters",
    "Microsoft.App/containerApps",
    "Microsoft.App/managedEnvironments",
    "Microsoft.Web/sites",
    "Microsoft.Web/serverfarms",
    "Microsoft.Network/azureFirewalls",
    "Microsoft.Network/publicIPAddresses",
    "Microsoft.OperationalInsights/workspaces",
    "Microsoft.RecoveryServices/vaults"
  ]

  validation {
    condition     = length(var.resource_health_alert_resource_types) > 0
    error_message = "At least one Resource Health alert resource type is required."
  }
}

variable "resource_health_alert_current_statuses" {
  description = "Resource Health current statuses that trigger alerting."
  type        = list(string)
  default     = ["Unavailable", "Degraded"]

  validation {
    condition     = length(var.resource_health_alert_current_statuses) > 0 && alltrue([for status in var.resource_health_alert_current_statuses : contains(["Available", "Unavailable", "Degraded", "Unknown"], status)])
    error_message = "Resource Health statuses must be one of Available, Unavailable, Degraded, or Unknown."
  }
}

variable "default_patch_group" {
  description = "Default PatchGroup tag value used by dynamic Update Manager scopes."
  type        = string
  default     = "weekend"
}

variable "patch_start_date_time" {
  description = "Patch schedule start date/time in yyyy-MM-dd HH:mm format."
  type        = string
  default     = "2026-08-08 02:00"

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}$", var.patch_start_date_time))
    error_message = "Patch start date/time must use yyyy-MM-dd HH:mm format."
  }
}

variable "patch_duration" {
  description = "Patch maintenance window duration in HH:mm format."
  type        = string
  default     = "03:00"

  validation {
    condition     = can(regex("^\\d{2}:\\d{2}$", var.patch_duration))
    error_message = "Patch duration must use HH:mm format."
  }
}

variable "patch_time_zone" {
  description = "Patch schedule timezone."
  type        = string
  default     = "UTC"
}

variable "patch_recur_every" {
  description = "Patch schedule recurrence."
  type        = string
  default     = "Month Second Saturday"
}

variable "patch_reboot_setting" {
  description = "Patch reboot behavior: IfRequired, Never, or Always."
  type        = string
  default     = "IfRequired"

  validation {
    condition     = contains(["IfRequired", "Never", "Always"], var.patch_reboot_setting)
    error_message = "Patch reboot setting must be IfRequired, Never, or Always."
  }
}

variable "patch_windows_classifications" {
  description = "Windows patch classifications included in the maintenance configuration."
  type        = list(string)
  default     = ["Critical", "Security", "UpdateRollup"]
}

variable "patch_linux_classifications" {
  description = "Linux patch classifications included in the maintenance configuration."
  type        = list(string)
  default     = ["Critical", "Security"]
}

variable "alert_runbook_webhook_expiry_time" {
  description = "RFC3339 expiry timestamp for optional alert-to-runbook Automation webhooks."
  type        = string
  default     = "2027-07-01T00:00:00Z"

  validation {
    condition     = can(formatdate("YYYY-MM-DD", var.alert_runbook_webhook_expiry_time))
    error_message = "Alert runbook webhook expiry time must be a valid RFC3339 timestamp."
  }
}

variable "backup_time" {
  description = "Daily VM backup time."
  type        = string
  default     = "23:00"

  validation {
    condition     = can(regex("^\\d{2}:\\d{2}$", var.backup_time))
    error_message = "Backup time must use HH:mm format."
  }
}

variable "backup_retention_days" {
  description = "Daily backup retention count."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && floor(var.backup_retention_days) == var.backup_retention_days
    error_message = "Backup retention days must be a whole number of at least 1."
  }
}

variable "cost_budget_amount" {
  description = "Monthly budget amount."
  type        = number
  default     = 250

  validation {
    condition     = var.cost_budget_amount > 0
    error_message = "Cost budget amount must be greater than 0."
  }
}

variable "budget_start_date" {
  description = "Budget start date in RFC3339 format."
  type        = string
  default     = "2026-07-01T00:00:00Z"

  validation {
    condition     = can(formatdate("YYYY-MM-DD", var.budget_start_date))
    error_message = "Budget start date must be a valid RFC3339 timestamp."
  }
}

variable "budget_end_date" {
  description = "Budget end date in RFC3339 format."
  type        = string
  default     = "2036-07-01T00:00:00Z"

  validation {
    condition     = can(formatdate("YYYY-MM-DD", var.budget_end_date))
    error_message = "Budget end date must be a valid RFC3339 timestamp."
  }
}

variable "policy_allowed_locations" {
  description = "Locations allowed by the optional policy assignment."
  type        = list(string)
  default     = ["westus2", "eastus", "eastus2", "westeurope", "northeurope"]

  validation {
    condition     = length(var.policy_allowed_locations) > 0
    error_message = "At least one allowed policy location is required."
  }
}

variable "policy_required_tags" {
  description = "Required tag names enforced by optional policy assignment."
  type        = list(string)
  default     = ["Environment", "Project", "Owner", "PatchGroup"]

  validation {
    condition     = length(var.policy_required_tags) > 0
    error_message = "At least one required policy tag is required."
  }
}

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Firewall SKU tier must be Basic, Standard, or Premium."
  }
}

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU."
  type        = string
  default     = "VpnGw1"
}

variable "enable_bgp" {
  description = "Enable BGP on VPN Gateway."
  type        = bool
  default     = false
}
