module "firewall_subnet" {
  source = "../subnet"

  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.firewall_subnet_prefix]
}

module "firewall_management_subnet" {
  source = "../subnet"
  count  = var.firewall_sku_tier == "Basic" ? 1 : 0

  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [coalesce(var.management_subnet_prefix, "10.40.4.0/26")]
}

resource "azurerm_public_ip" "this" {
  name                = "pip-afw-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "management" {
  count = var.firewall_sku_tier == "Basic" ? 1 : 0

  name                = "pip-afw-mgmt-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "this" {
  name                = "afwp-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.firewall_sku_tier
  tags                = var.tags
}

resource "azurerm_firewall" "this" {
  name                = "afw-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.this.id
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.this.id
  }

  dynamic "management_ip_configuration" {
    for_each = var.firewall_sku_tier == "Basic" ? [1] : []

    content {
      name                 = "management"
      subnet_id            = module.firewall_management_subnet[0].id
      public_ip_address_id = azurerm_public_ip.management[0].id
    }
  }
}
