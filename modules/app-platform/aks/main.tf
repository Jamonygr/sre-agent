resource "azurerm_kubernetes_cluster" "this" {
  name                              = var.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.dns_prefix
  sku_tier                          = "Free"
  role_based_access_control_enabled = true
  azure_policy_enabled              = var.azure_policy_enabled
  local_account_disabled            = false
  tags                              = var.tags

  default_node_pool {
    name                   = "system"
    node_count             = var.node_count
    vm_size                = var.node_vm_size
    os_disk_size_gb        = var.os_disk_size_gb
    node_public_ip_enabled = false
    tags                   = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id == null ? [] : [var.log_analytics_workspace_id]

    content {
      log_analytics_workspace_id      = oms_agent.value
      msi_auth_for_monitoring_enabled = true
    }
  }
}
