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
      Purpose     = "SRE Agent Windows VM Lab"
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
