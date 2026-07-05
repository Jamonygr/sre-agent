# =============================================================================
# CHEAP LAB ENVIRONMENT - COST-SAFE REVIEW PROFILE
# =============================================================================

environment = "cheap-lab"
project     = "sreag"
location    = "westus2"
owner       = "Lab-User"

deploy_monitoring                    = true
deploy_log_analytics                 = true
deploy_azure_monitor_agent           = true
deploy_data_collection_rules         = true
deploy_vm_insights                   = false
deploy_change_tracking               = false
deploy_update_management             = false
deploy_update_dynamic_scopes         = false
deploy_workbooks                     = true
deploy_portal_dashboards             = false
deploy_managed_grafana               = false
deploy_alerts                        = true
deploy_log_query_alerts              = true
deploy_activity_log_alerts           = false
deploy_service_health_alerts         = false
deploy_resource_health_alerts        = true
deploy_advisor_recommendation_alerts = false
deploy_sre_agent                     = true
enable_alert_runbook_webhooks        = false
enable_scheduled_startstop           = false
deploy_backup                        = false
deploy_policy                        = false
deploy_cost_management               = true
deploy_windows_targets               = true
deploy_jumpbox                       = true
deploy_iis_farm                      = true
deploy_domain_controller             = false
deploy_sql_vm                        = false
deploy_firewall                      = false
deploy_vpn_gateway                   = false

enable_jumpbox_public_ip = false
enable_iis_public_ip     = true
iis_server_count         = 1
vm_size                  = "Standard_B1ms"
jumpbox_vm_size          = "Standard_B1ms"
iis_vm_size              = "Standard_B1ms"
log_retention_days       = 30
log_daily_quota_gb       = 1
cost_budget_amount       = 75

default_patch_group = "weekend"
