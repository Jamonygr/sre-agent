package terraform

approved_regions := {"westus2", "eastus", "eastus2", "westeurope", "northeurope", "canadacentral"}

deny[msg] {
  resource := input.resource_changes[_]
  resource.change.actions[_] == "create"
  not resource.change.after.tags
  msg := sprintf("Resource %s must have tags", [resource.address])
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.change.actions[_] == "create"
  location := lower(resource.change.after.location)
  location != ""
  not approved_regions[location]
  msg := sprintf("Resource %s is in unsupported region %s", [resource.address, location])
}

warn[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_public_ip"
  resource.change.actions[_] == "create"
  msg := sprintf("Public IP %s is being created; confirm this is intentional for the lab scenario", [resource.address])
}

