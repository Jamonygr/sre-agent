resource "azurerm_policy_definition" "require_tag" {
  for_each = toset(var.required_tags)

  name         = "sreag-require-tag-${lower(each.value)}-${var.name_suffix}"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "SRE Agent Azure Lab require tag ${each.value}"
  description  = "Requires tag ${each.value} on resources in the SRE agent lab."

  metadata = jsonencode({
    category = "Tags"
  })

  parameters = jsonencode({
    tagName = {
      type = "String"
      metadata = {
        displayName = "Tag Name"
      }
      defaultValue = each.value
    }
  })

  policy_rule = jsonencode({
    if = {
      field  = "[concat('tags[', parameters('tagName'), ']')]"
      exists = "false"
    }
    then = {
      effect = "audit"
    }
  })
}

resource "azurerm_policy_definition" "allowed_locations" {
  name         = "sreag-allowed-locations-${var.name_suffix}"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "SRE Agent Azure Lab allowed locations"
  description  = "Audits resources outside approved lab regions."

  metadata = jsonencode({
    category = "General"
  })

  parameters = jsonencode({
    listOfAllowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
      }
      defaultValue = var.allowed_locations
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "location"
          exists = "true"
        },
        {
          field = "location"
          notIn = "[parameters('listOfAllowedLocations')]"
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

locals {
  required_tag_assignments = merge([
    for rg_key, rg_id in var.resource_group_ids : {
      for tag_name in var.required_tags : "${rg_key}-${tag_name}" => {
        resource_group_id = rg_id
        tag_name          = tag_name
      }
    }
  ]...)
}

resource "azurerm_resource_group_policy_assignment" "require_tag" {
  for_each = local.required_tag_assignments

  name                 = substr("pa-req-${lower(each.value.tag_name)}-${var.name_suffix}", 0, 64)
  resource_group_id    = each.value.resource_group_id
  policy_definition_id = azurerm_policy_definition.require_tag[each.value.tag_name].id
  display_name         = "Require tag ${each.value.tag_name}"

  parameters = jsonencode({
    tagName = {
      value = each.value.tag_name
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  for_each = var.resource_group_ids

  name                 = substr("pa-locations-${var.name_suffix}", 0, 64)
  resource_group_id    = each.value
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  display_name         = "Allowed locations"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}
