# =============================================================================
# LOCAL VALUES
# =============================================================================

locals {
  environment = lower(var.environment)
  project     = lower(var.project)

  normalized_location = lower(replace(var.location, " ", ""))

  location_short_map = {
    westeurope         = "weu"
    northeurope        = "neu"
    eastus             = "eus"
    eastus2            = "eus2"
    westus             = "wus"
    westus2            = "wus2"
    centralus          = "cus"
    canadacentral      = "cac"
    uksouth            = "uks"
    ukwest             = "ukw"
    germanywestcentral = "gwc"
  }

  location_short = lookup(local.location_short_map, local.normalized_location, substr(local.normalized_location, 0, 4))

  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
      Purpose     = "SRE Agent Azure Lab"
      Owner       = var.owner
      CostCenter  = "Learning"
      Repository  = var.repository_url
      PatchGroup  = var.default_patch_group
    },
    var.extra_tags
  )

  effective_subscription_id = coalesce(var.subscription_id, data.azurerm_client_config.current.subscription_id)
  effective_admin_password  = try(trimspace(var.admin_password), "") == "" ? random_password.admin_password.result : var.admin_password

  base_name = "${local.project}-${local.environment}-${local.location_short}"

  vm_name_environment = substr(replace(local.environment, "-", ""), 0, 4)
  vm_name_suffix      = "${local.vm_name_environment}${local.location_short}"

  deploy_app_platform_targets = var.deploy_aks || var.deploy_app_service || var.deploy_container_apps || var.deploy_functions
  app_resource_group_name     = local.deploy_app_platform_targets ? module.rg_apps[0].name : null
  app_resource_group_id       = local.deploy_app_platform_targets ? module.rg_apps[0].id : null
  app_name_safe_base          = replace("${local.project}${local.environment}${local.location_short}", "/[^a-z0-9]/", "")
  app_global_suffix           = random_string.suffix.result
  app_dns_prefix              = substr("aks${local.app_name_safe_base}", 0, 54)
  function_storage_name       = substr("stfn${local.app_name_safe_base}${local.app_global_suffix}", 0, 24)
  log_analytics_workspace_id  = var.deploy_monitoring && var.deploy_log_analytics ? module.log_analytics[0].id : null

  monitored_vm_ids_by_key = merge(
    var.deploy_windows_targets && var.deploy_jumpbox ? { jumpbox = module.jumpbox[0].vm_id } : {},
    var.deploy_windows_targets && var.deploy_domain_controller ? { domain_controller = module.domain_controller[0].vm_id } : {},
    var.deploy_windows_targets && var.deploy_sql_vm ? { sql_vm = module.sql_vm[0].vm_id } : {},
    { for key, vm in module.iis_web_servers : key => vm.vm_id }
  )

  monitored_vm_ids = values(local.monitored_vm_ids_by_key)

  monitored_vm_names = concat(
    var.deploy_windows_targets && var.deploy_jumpbox ? [module.jumpbox[0].vm_name] : [],
    var.deploy_windows_targets && var.deploy_domain_controller ? [module.domain_controller[0].vm_name] : [],
    var.deploy_windows_targets && var.deploy_sql_vm ? [module.sql_vm[0].vm_name] : [],
    [for vm in module.iis_web_servers : vm.vm_name]
  )

  remediation_action_group_ids = (
    var.deploy_sre_agent &&
    var.enable_alert_runbook_webhooks
  ) ? [module.sre_agent[0].remediation_action_group_id] : []
}
