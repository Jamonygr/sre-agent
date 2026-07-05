# =============================================================================
# FULL ENVIRONMENT - HIGHER COST DEMO PROFILE
# =============================================================================

environment = "full"
project     = "sreag"
location    = "westus2"
owner       = "Lab-User"

deploy_monitoring                    = true
deploy_log_analytics                 = true
deploy_azure_monitor_agent           = true
deploy_data_collection_rules         = true
deploy_vm_insights                   = true
deploy_change_tracking               = false
deploy_update_management             = true
deploy_update_dynamic_scopes         = true
deploy_workbooks                     = true
deploy_portal_dashboards             = true
deploy_managed_grafana               = false
deploy_alerts                        = true
deploy_log_query_alerts              = true
deploy_activity_log_alerts           = true
deploy_service_health_alerts         = true
deploy_resource_health_alerts        = true
deploy_advisor_recommendation_alerts = true
deploy_sre_agent                     = true
enable_alert_runbook_webhooks        = false
enable_scheduled_startstop           = true
deploy_backup                        = true
deploy_policy                        = true
deploy_cost_management               = true
deploy_windows_targets               = true
deploy_jumpbox                       = true
deploy_iis_farm                      = true
deploy_domain_controller             = true
deploy_sql_vm                        = true
deploy_firewall                      = true
deploy_vpn_gateway                   = false

enable_jumpbox_public_ip = false
enable_iis_public_ip     = true
iis_server_count         = 2
vm_size                  = "Standard_B2s"
jumpbox_vm_size          = "Standard_B2s"
iis_vm_size              = "Standard_B1ms"
log_retention_days       = 30
log_daily_quota_gb       = 2
cost_budget_amount       = 600
firewall_sku_tier        = "Basic"
