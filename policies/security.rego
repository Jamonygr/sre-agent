package terraform.security

rdp_destination(after) {
  after.destination_port_range == "3389"
}

rdp_destination(after) {
  after.destination_port_ranges[_] == "3389"
}

internet_source(after) {
  after.source_address_prefix == "0.0.0.0/0"
}

internet_source(after) {
  after.source_address_prefixes[_] == "0.0.0.0/0"
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_network_security_rule"
  resource.change.actions[_] == "create"
  lower(resource.change.after.direction) == "inbound"
  lower(resource.change.after.access) == "allow"
  rdp_destination(resource.change.after)
  internet_source(resource.change.after)
  msg := sprintf("RDP rule %s must not allow 0.0.0.0/0", [resource.address])
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_storage_account"
  resource.change.actions[_] == "create"
  resource.change.after.allow_nested_items_to_be_public == true
  msg := sprintf("Storage account %s must not allow public blob access", [resource.address])
}

warn[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_windows_virtual_machine"
  resource.change.actions[_] == "create"
  not resource.change.after.tags.PatchGroup
  msg := sprintf("VM %s should include PatchGroup tag for update-management scenarios", [resource.address])
}
