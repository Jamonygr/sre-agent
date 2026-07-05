package terraform.naming

warn[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_resource_group"
  resource.change.actions[_] == "create"
  not startswith(resource.change.after.name, "rg-")
  msg := sprintf("Resource group %s should start with rg-", [resource.change.after.name])
}

warn[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_virtual_network"
  resource.change.actions[_] == "create"
  not startswith(resource.change.after.name, "vnet-")
  msg := sprintf("VNet %s should start with vnet-", [resource.change.after.name])
}

warn[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_subnet"
  resource.change.actions[_] == "create"
  name := resource.change.after.name
  not startswith(name, "snet-")
  name != "AzureFirewallSubnet"
  name != "GatewaySubnet"
  msg := sprintf("Subnet %s should start with snet- or use an Azure reserved subnet name", [name])
}

