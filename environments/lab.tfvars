# =============================================================================
# LAB ENVIRONMENT - COST-CONTROLLED MEGA PROFILE
# =============================================================================

environment = "lab"
project     = "sreag"
location    = "westus2"
owner       = "Lab-User"

deploy_monitoring                    = true
deploy_log_analytics                 = true
deploy_azure_monitor_agent           = true
deploy_data_collection_rules         = true
deploy_vm_insights                   = false
deploy_change_tracking               = true
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
deploy_backup                        = false
deploy_policy                        = true
deploy_cost_management               = true
deploy_windows_targets               = true
deploy_jumpbox                       = true
deploy_iis_farm                      = true
deploy_domain_controller             = false
deploy_sql_vm                        = false
deploy_firewall                      = false
deploy_vpn_gateway                   = false
deploy_aks                           = true
deploy_app_service                   = true
deploy_container_apps                = true
deploy_functions                     = true

enable_jumpbox_public_ip    = false
enable_iis_public_ip        = true
iis_server_count            = 1
vm_size                     = "Standard_B2s"
jumpbox_vm_size             = "Standard_B2s"
iis_vm_size                 = "Standard_B1ms"
aks_node_count              = 1
aks_node_vm_size            = "Standard_B2s"
log_retention_days          = 30
log_daily_quota_gb          = 1
cost_budget_amount          = 350
disk_free_percent_threshold = 10
critical_event_threshold    = 5

default_patch_group   = "weekend"
patch_start_date_time = "2026-08-08 02:00"
patch_duration        = "03:00"
patch_time_zone       = "UTC"
patch_recur_every     = "Month Second Saturday"
patch_reboot_setting  = "IfRequired"
