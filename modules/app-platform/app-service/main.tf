resource "azurerm_service_plan" "this" {
  name                = var.plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  worker_count        = var.worker_count
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                                           = var.app_name
  resource_group_name                            = var.resource_group_name
  location                                       = var.location
  service_plan_id                                = azurerm_service_plan.this.id
  https_only                                     = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  tags                                           = var.tags

  app_settings = merge(
    {
      APP_PLATFORM_LAB_SERVICE = "app-service"
    },
    var.app_settings
  )

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on               = var.always_on
    ftps_state              = "Disabled"
    http2_enabled           = true
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
  }
}
