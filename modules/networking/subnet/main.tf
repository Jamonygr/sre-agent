resource "azurerm_subnet" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes
  service_endpoints    = var.service_endpoints
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count = var.associate_network_security_group ? 1 : 0

  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = var.network_security_group_id
}
