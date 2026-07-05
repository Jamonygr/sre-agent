# =============================================================================
# DEV ENVIRONMENT - LOWEST COST VALIDATION PROFILE
# =============================================================================

environment = "dev"
project     = "sreag"
location    = "westus2"
owner       = "Lab-User"

deploy_monitoring                    = true
deploy_log_analytics                 = true
deploy_azure_monitor_agent           = true
deploy_data_collection_rules         = true
deploy_vm_insights                   = false
deploy_change_tracking               = false
deploy_update_management             = true
deploy_update_dynamic_scopes         = false
deploy_workbooks                     = true
deploy_portal_dashboards             = true
deploy_managed_grafana               = false
deploy_alerts                        = true
deploy_log_query_alerts              = true
deploy_activity_log_alerts           = false
deploy_service_health_alerts         = false
deploy_resource_health_alerts        = true
deploy_advisor_recommendation_alerts = true
deploy_sre_agent                     = true
enable_alert_runbook_webhooks        = false
enable_scheduled_startstop           = false
deploy_backup                        = false
deploy_policy                        = false
deploy_cost_management               = true
deploy_windows_targets               = true
deploy_jumpbox                       = true
deploy_iis_farm                      = false
deploy_domain_controller             = false
deploy_sql_vm                        = false
deploy_firewall                      = false
deploy_vpn_gateway                   = false
deploy_aks                           = false
deploy_app_service                   = false
deploy_container_apps                = false
deploy_functions                     = false

enable_jumpbox_public_ip = false
enable_iis_public_ip     = false
iis_server_count         = 0
vm_size                  = "Standard_B1ms"
jumpbox_vm_size          = "Standard_B1ms"
cost_budget_amount       = 100
