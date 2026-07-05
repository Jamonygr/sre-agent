resource "azurerm_dashboard_grafana" "this" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  grafana_major_version             = 11
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true
  sku                               = "Standard"
  tags                              = var.tags

  identity {
    type = "SystemAssigned"
  }
}
