# =============================================================================
# SRE AGENT WINDOWS VM LAB - ROOT ORCHESTRATION
# Platform Core | Network | Windows Targets | SRE Telemetry | Runbooks
# Update Management | Backup | Governance | Incident Lab
# =============================================================================

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }
    recovery_service {
      purge_protected_items_from_vault_on_destroy          = true
      vm_backup_stop_protection_and_retain_data_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "random_password" "admin_password" {
  length           = 20
  special          = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!@#%&*()-_=+[]{}:?,."
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# =============================================================================
# PLATFORM CORE - RESOURCE GROUPS
# =============================================================================

module "rg_network" {
  source   = "./modules/resource-group"
  name     = "rg-network-${local.base_name}"
  location = var.location
  tags     = local.common_tags
}

module "rg_windows" {
  source   = "./modules/resource-group"
  name     = "rg-windows-${local.base_name}"
  location = var.location
  tags     = local.common_tags
}

module "rg_apps" {
  source = "./modules/resource-group"
  count  = local.deploy_app_platform_targets ? 1 : 0

  name     = "rg-apps-${local.base_name}"
  location = var.location
  tags     = local.common_tags
}

module "rg_sre" {
  source   = "./modules/resource-group"
  name     = "rg-sre-${local.base_name}"
  location = var.location
  tags     = local.common_tags
}

module "rg_governance" {
  source   = "./modules/resource-group"
  name     = "rg-governance-${local.base_name}"
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# NETWORK OPS
# =============================================================================

module "hub_vnet" {
  source = "./modules/networking/vnet"

  name                = "vnet-hub-${local.base_name}"
  resource_group_name = module.rg_network.name
  location            = var.location
  address_space       = var.hub_address_space
  tags                = local.common_tags
}

module "management_vnet" {
  source = "./modules/networking/vnet"

  name                = "vnet-management-${local.base_name}"
  resource_group_name = module.rg_network.name
  location            = var.location
  address_space       = var.management_address_space
  tags                = local.common_tags
}

module "workload_vnet" {
  source = "./modules/networking/vnet"

  name                = "vnet-workload-${local.base_name}"
  resource_group_name = module.rg_network.name
  location            = var.location
  address_space       = var.workload_address_space
  tags                = local.common_tags
}

module "hub_ops_nsg" {
  source = "./modules/networking/nsg"

  name                = "nsg-hub-ops-${local.base_name}"
  resource_group_name = module.rg_network.name
  location            = var.location
  security_rules      = {}
  tags                = local.common_tags
}

module "management_nsg" {
  source = "./modules/networking/nsg"

  name                = "nsg-management-${local.base_name}"
  resource_group_name = module.rg_network.name
  location            = var.location
  security_rules = length(var.allowed_rdp_source_ips) > 0 ? {
    allow-rdp = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefixes    = var.allowed_rdp_source_ips
      destination_address_prefix = "*"
      description                = "Allow trusted RDP to management targets"
    }
  } : {}
  tags = local.common_tags
}

module "workload_web_nsg" {
  source = "./modules/networking/nsg"

  name                = "nsg-workload-web-${local.base_name}"
  resource_group_name = module.rg_network.name
  location            = var.location
  security_rules = merge(
    {
      allow-http = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefixes    = var.allowed_http_source_ips
        destination_address_prefix = "*"
        description                = "Allow HTTP to IIS scenario targets"
      }
    },
    length(var.allowed_rdp_source_ips) > 0 ? {
      allow-rdp = {
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefixes    = var.allowed_rdp_source_ips
        destination_address_prefix = "*"
        description                = "Allow trusted RDP to IIS targets"
      }
    } : {}
  )
  tags = local.common_tags
}

module "workload_app_nsg" {
  source = "./modules/networking/nsg"

  name                = "nsg-workload-app-${local.base_name}"
  resource_group_name = module.rg_network.name
  location            = var.location
  security_rules      = {}
  tags                = local.common_tags
}

module "hub_ops_subnet" {
  source = "./modules/networking/subnet"

  name                             = "snet-hub-ops"
  resource_group_name              = module.rg_network.name
  virtual_network_name             = module.hub_vnet.name
  address_prefixes                 = [var.hub_ops_subnet_prefix]
  network_security_group_id        = module.hub_ops_nsg.id
  associate_network_security_group = true
}

module "management_subnet" {
  source = "./modules/networking/subnet"

  name                             = "snet-management"
  resource_group_name              = module.rg_network.name
  virtual_network_name             = module.management_vnet.name
  address_prefixes                 = [var.management_subnet_prefix]
  network_security_group_id        = module.management_nsg.id
  associate_network_security_group = true
}

module "workload_web_subnet" {
  source = "./modules/networking/subnet"

  name                             = "snet-workload-web"
  resource_group_name              = module.rg_network.name
  virtual_network_name             = module.workload_vnet.name
  address_prefixes                 = [var.workload_web_subnet_prefix]
  network_security_group_id        = module.workload_web_nsg.id
  associate_network_security_group = true
}

module "workload_app_subnet" {
  source = "./modules/networking/subnet"

  name                             = "snet-workload-app"
  resource_group_name              = module.rg_network.name
  virtual_network_name             = module.workload_vnet.name
  address_prefixes                 = [var.workload_app_subnet_prefix]
  network_security_group_id        = module.workload_app_nsg.id
  associate_network_security_group = true
}

resource "azurerm_virtual_network_peering" "hub_to_management" {
  name                         = "peer-hub-to-management-${local.environment}"
  resource_group_name          = module.rg_network.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.management_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [
    module.hub_ops_subnet,
    module.management_subnet,
    module.firewall,
    module.vpn_gateway
  ]
}

resource "azurerm_virtual_network_peering" "management_to_hub" {
  name                         = "peer-management-to-hub-${local.environment}"
  resource_group_name          = module.rg_network.name
  virtual_network_name         = module.management_vnet.name
  remote_virtual_network_id    = module.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [
    azurerm_virtual_network_peering.hub_to_management
  ]
}

resource "azurerm_virtual_network_peering" "hub_to_workload" {
  name                         = "peer-hub-to-workload-${local.environment}"
  resource_group_name          = module.rg_network.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.workload_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [
    azurerm_virtual_network_peering.management_to_hub,
    module.workload_web_subnet,
    module.workload_app_subnet
  ]
}

resource "azurerm_virtual_network_peering" "workload_to_hub" {
  name                         = "peer-workload-to-hub-${local.environment}"
  resource_group_name          = module.rg_network.name
  virtual_network_name         = module.workload_vnet.name
  remote_virtual_network_id    = module.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [
    azurerm_virtual_network_peering.hub_to_workload
  ]
}

# Optional expensive network controls.
module "firewall" {
  source = "./modules/networking/firewall"
  count  = var.deploy_firewall ? 1 : 0

  name_suffix              = local.base_name
  resource_group_name      = module.rg_network.name
  location                 = var.location
  virtual_network_name     = module.hub_vnet.name
  firewall_subnet_prefix   = var.hub_firewall_subnet_prefix
  management_subnet_prefix = var.hub_firewall_management_subnet_prefix
  firewall_sku_tier        = var.firewall_sku_tier
  tags                     = local.common_tags
}

module "vpn_gateway" {
  source = "./modules/networking/vpn-gateway"
  count  = var.deploy_vpn_gateway ? 1 : 0

  name_suffix           = local.base_name
  resource_group_name   = module.rg_network.name
  location              = var.location
  virtual_network_name  = module.hub_vnet.name
  gateway_subnet_prefix = var.hub_gateway_subnet_prefix
  vpn_gateway_sku       = var.vpn_gateway_sku
  enable_bgp            = var.enable_bgp
  tags                  = local.common_tags
}

# =============================================================================
# WINDOWS TARGETS
# =============================================================================

module "jumpbox" {
  source = "./modules/compute/windows-vm"
  count  = var.deploy_windows_targets && var.deploy_jumpbox ? 1 : 0

  name                        = "vmjump${local.vm_name_suffix}"
  resource_group_name         = module.rg_windows.name
  location                    = var.location
  subnet_id                   = module.management_subnet.id
  vm_size                     = var.jumpbox_vm_size
  admin_username              = var.admin_username
  admin_password              = local.effective_admin_password
  enable_public_ip            = var.enable_jumpbox_public_ip
  install_azure_monitor_agent = var.deploy_monitoring && var.deploy_azure_monitor_agent
  install_dependency_agent    = var.deploy_monitoring && var.deploy_vm_insights
  role                        = "jumpbox"
  tags                        = merge(local.common_tags, { Role = "Jumpbox" })
}

module "iis_web_servers" {
  source = "./modules/compute/iis-web-server"
  for_each = var.deploy_windows_targets && var.deploy_iis_farm ? {
    for index in range(var.iis_server_count) : format("iis%02d", index + 1) => index + 1
  } : {}

  name                        = format("vmiis%02d%s", each.value, local.vm_name_suffix)
  resource_group_name         = module.rg_windows.name
  location                    = var.location
  subnet_id                   = module.workload_web_subnet.id
  vm_size                     = var.iis_vm_size
  admin_username              = var.admin_username
  admin_password              = local.effective_admin_password
  enable_public_ip            = var.enable_iis_public_ip
  install_azure_monitor_agent = var.deploy_monitoring && var.deploy_azure_monitor_agent
  install_dependency_agent    = var.deploy_monitoring && var.deploy_vm_insights
  lab_title                   = "SRE Agent Azure Lab IIS Target ${each.value}"
  tags                        = merge(local.common_tags, { Role = "IIS", PatchGroup = var.default_patch_group })
}

module "domain_controller" {
  source = "./modules/compute/windows-vm"
  count  = var.deploy_windows_targets && var.deploy_domain_controller ? 1 : 0

  name                        = "vmdc01${local.vm_name_suffix}"
  resource_group_name         = module.rg_windows.name
  location                    = var.location
  subnet_id                   = module.management_subnet.id
  vm_size                     = var.vm_size
  admin_username              = var.admin_username
  admin_password              = local.effective_admin_password
  enable_public_ip            = false
  install_azure_monitor_agent = var.deploy_monitoring && var.deploy_azure_monitor_agent
  install_dependency_agent    = var.deploy_monitoring && var.deploy_vm_insights
  role                        = "domain-controller"
  custom_script               = "Rename-Computer -NewName 'dc01-${local.environment}' -Force"
  tags                        = merge(local.common_tags, { Role = "DomainController" })
}

module "sql_vm" {
  source = "./modules/compute/windows-vm"
  count  = var.deploy_windows_targets && var.deploy_sql_vm ? 1 : 0

  name                        = "vmsql01${local.vm_name_suffix}"
  resource_group_name         = module.rg_windows.name
  location                    = var.location
  subnet_id                   = module.workload_app_subnet.id
  vm_size                     = var.vm_size
  admin_username              = var.admin_username
  admin_password              = local.effective_admin_password
  enable_public_ip            = false
  install_azure_monitor_agent = var.deploy_monitoring && var.deploy_azure_monitor_agent
  install_dependency_agent    = var.deploy_monitoring && var.deploy_vm_insights
  role                        = "sql-file-server"
  tags                        = merge(local.common_tags, { Role = "SqlFileServer" })
}

# =============================================================================
# MODERN APP PLATFORM TARGETS
# =============================================================================

module "aks" {
  source = "./modules/app-platform/aks"
  count  = var.deploy_aks ? 1 : 0

  name                       = "aks-${local.base_name}"
  dns_prefix                 = local.app_dns_prefix
  resource_group_name        = coalesce(local.app_resource_group_name, "")
  location                   = var.location
  node_count                 = var.aks_node_count
  node_vm_size               = var.aks_node_vm_size
  os_disk_size_gb            = var.aks_os_disk_size_gb
  azure_policy_enabled       = var.aks_azure_policy_enabled
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tags                       = merge(local.common_tags, { Role = "AKS" })
}

module "app_service" {
  source = "./modules/app-platform/app-service"
  count  = var.deploy_app_service ? 1 : 0

  plan_name           = "asp-web-${local.base_name}"
  app_name            = "app-${local.base_name}-${local.app_global_suffix}"
  resource_group_name = coalesce(local.app_resource_group_name, "")
  location            = var.location
  sku_name            = var.app_service_plan_sku_name
  always_on           = var.app_service_always_on
  tags                = merge(local.common_tags, { Role = "AppService" })
}

module "container_apps" {
  source = "./modules/app-platform/container-apps"
  count  = var.deploy_container_apps ? 1 : 0

  environment_name           = "cae-${local.base_name}"
  container_app_name         = "ca-${local.base_name}"
  resource_group_name        = coalesce(local.app_resource_group_name, "")
  location                   = var.location
  log_analytics_workspace_id = local.log_analytics_workspace_id
  image                      = var.container_app_image
  min_replicas               = var.container_app_min_replicas
  max_replicas               = var.container_app_max_replicas
  tags                       = merge(local.common_tags, { Role = "ContainerApps" })
}

module "functions" {
  source = "./modules/app-platform/functions"
  count  = var.deploy_functions ? 1 : 0

  plan_name            = "asp-func-${local.base_name}"
  function_app_name    = "func-${local.base_name}-${local.app_global_suffix}"
  storage_account_name = local.function_storage_name
  resource_group_name  = coalesce(local.app_resource_group_name, "")
  location             = var.location
  sku_name             = var.function_app_plan_sku_name
  node_version         = var.function_app_node_version
  tags                 = merge(local.common_tags, { Role = "Functions" })
}

# =============================================================================
# MONITORING, UPDATE MANAGEMENT, DASHBOARDS
# =============================================================================

module "log_analytics" {
  source = "./modules/monitoring/log-analytics"
  count  = var.deploy_monitoring && var.deploy_log_analytics ? 1 : 0

  name                = "log-${local.base_name}"
  resource_group_name = module.rg_sre.name
  location            = var.location
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.log_daily_quota_gb
  tags                = local.common_tags
}

module "data_collection" {
  source = "./modules/monitoring/data-collection-rule"
  count  = var.deploy_monitoring && var.deploy_log_analytics && var.deploy_data_collection_rules ? 1 : 0

  name                       = "dcr-vm-ops-${local.base_name}"
  resource_group_name        = module.rg_sre.name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics[0].id
  target_resource_ids        = local.monitored_vm_ids_by_key
  enable_change_tracking     = var.deploy_change_tracking
  tags                       = local.common_tags
}

module "alerts" {
  source = "./modules/monitoring/alerts"
  count  = var.deploy_monitoring && var.deploy_alerts ? 1 : 0

  name_suffix                          = local.base_name
  resource_group_name                  = module.rg_sre.name
  location                             = var.location
  monitored_vm_ids                     = local.monitored_vm_ids
  log_analytics_workspace_id           = var.deploy_monitoring && var.deploy_log_analytics ? module.log_analytics[0].id : null
  subscription_id                      = local.effective_subscription_id
  email_receivers                      = var.alert_email_receivers
  additional_action_group_ids          = local.remediation_action_group_ids
  deploy_log_query_alerts              = var.deploy_log_query_alerts && var.deploy_log_analytics
  deploy_activity_log_alerts           = var.deploy_activity_log_alerts
  deploy_service_health_alerts         = var.deploy_service_health_alerts
  deploy_resource_health_alerts        = var.deploy_resource_health_alerts
  deploy_advisor_recommendation_alerts = var.deploy_advisor_recommendation_alerts
  resource_health_resource_groups = concat(
    [
      module.rg_network.name,
      module.rg_windows.name,
      module.rg_sre.name,
      module.rg_governance.name
    ],
    local.deploy_app_platform_targets ? [local.app_resource_group_name] : []
  )
  resource_health_resource_types   = var.resource_health_alert_resource_types
  resource_health_current_statuses = var.resource_health_alert_current_statuses
  vm_cpu_threshold                 = var.vm_cpu_threshold
  vm_availability_threshold        = var.vm_availability_threshold
  disk_free_percent_threshold      = var.disk_free_percent_threshold
  critical_event_threshold         = var.critical_event_threshold
  tags                             = local.common_tags
}

module "update_management" {
  source = "./modules/update-management"
  count  = var.deploy_update_management ? 1 : 0

  name_suffix                   = local.base_name
  resource_group_name           = module.rg_sre.name
  location                      = var.location
  target_vm_ids                 = local.monitored_vm_ids_by_key
  deploy_dynamic_scope          = var.deploy_update_dynamic_scopes
  dynamic_scope_subscription_id = local.effective_subscription_id
  dynamic_scope_resource_group  = module.rg_windows.name
  dynamic_scope_tag_name        = "PatchGroup"
  dynamic_scope_tag_values      = [var.default_patch_group]
  patch_start_date_time         = var.patch_start_date_time
  patch_duration                = var.patch_duration
  patch_time_zone               = var.patch_time_zone
  patch_recur_every             = var.patch_recur_every
  patch_reboot_setting          = var.patch_reboot_setting
  windows_classifications       = var.patch_windows_classifications
  linux_classifications         = var.patch_linux_classifications
  tags                          = local.common_tags
}

module "workbooks" {
  source = "./modules/monitoring/workbooks"
  count  = var.deploy_monitoring && var.deploy_log_analytics && var.deploy_workbooks ? 1 : 0

  resource_group_name        = module.rg_sre.name
  location                   = var.location
  environment                = local.environment
  log_analytics_workspace_id = module.log_analytics[0].id
  tags                       = local.common_tags
}

module "dashboard" {
  source = "./modules/monitoring/dashboard"
  count  = var.deploy_monitoring && var.deploy_log_analytics && var.deploy_portal_dashboards ? 1 : 0

  name_suffix                = local.base_name
  resource_group_name        = module.rg_sre.name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics[0].id
  action_group_id            = var.deploy_alerts ? module.alerts[0].action_group_id : null
  tags                       = local.common_tags
}

module "managed_grafana" {
  source = "./modules/monitoring/managed-grafana"
  count  = var.deploy_managed_grafana ? 1 : 0

  name                = "graf-${local.base_name}"
  resource_group_name = module.rg_sre.name
  location            = var.location
  tags                = local.common_tags
}

# =============================================================================
# AUTOMATION, BACKUP, GOVERNANCE, COST
# =============================================================================

module "sre_agent" {
  source = "./modules/sre-agent"
  count  = var.deploy_sre_agent ? 1 : 0

  name_suffix                = local.base_name
  resource_group_name        = module.rg_sre.name
  location                   = var.location
  managed_scope_ids          = { windows = module.rg_windows.id }
  target_resource_group_name = module.rg_windows.name
  enable_alert_runbook_webhooks = (
    var.enable_alert_runbook_webhooks &&
    var.deploy_monitoring &&
    var.deploy_alerts
  )
  enable_scheduled_startstop = var.enable_scheduled_startstop
  webhook_expiry_time        = var.alert_runbook_webhook_expiry_time
  tags                       = local.common_tags
}

module "backup" {
  source = "./modules/backup"
  count  = var.deploy_backup ? 1 : 0

  name_suffix           = local.base_name
  resource_group_name   = module.rg_sre.name
  location              = var.location
  protected_vm_ids      = local.monitored_vm_ids_by_key
  backup_time           = var.backup_time
  retention_daily_count = var.backup_retention_days
  tags                  = local.common_tags
}

module "policy" {
  source = "./modules/policy"
  count  = var.deploy_policy ? 1 : 0

  name_suffix = local.base_name
  resource_group_ids = merge(
    {
      network    = module.rg_network.id
      windows    = module.rg_windows.id
      sre        = module.rg_sre.id
      governance = module.rg_governance.id
    },
    local.deploy_app_platform_targets ? { apps = local.app_resource_group_id } : {}
  )
  allowed_locations = var.policy_allowed_locations
  required_tags     = var.policy_required_tags
}

module "cost_management" {
  source = "./modules/cost-management"
  count  = var.deploy_cost_management ? 1 : 0

  name              = "budget-${local.base_name}"
  resource_group_id = module.rg_sre.id
  amount            = var.cost_budget_amount
  start_date        = var.budget_start_date
  end_date          = var.budget_end_date
  contact_emails    = [for receiver in var.alert_email_receivers : receiver.email_address]
}
