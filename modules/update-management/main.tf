resource "azurerm_maintenance_configuration" "guest_patch" {
  name                     = "mc-guestpatch-${var.name_suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  tags                     = var.tags

  window {
    start_date_time = var.patch_start_date_time
    duration        = var.patch_duration
    time_zone       = var.patch_time_zone
    recur_every     = var.patch_recur_every
  }

  install_patches {
    reboot = var.patch_reboot_setting

    windows {
      classifications_to_include = var.windows_classifications
    }

    linux {
      classifications_to_include = var.linux_classifications
    }
  }
}

resource "azurerm_maintenance_assignment_virtual_machine" "vm" {
  for_each = var.target_vm_ids

  location                     = var.location
  maintenance_configuration_id = azurerm_maintenance_configuration.guest_patch.id
  virtual_machine_id           = each.value
}

resource "azurerm_maintenance_assignment_dynamic_scope" "patch_group" {
  count = var.deploy_dynamic_scope ? 1 : 0

  name                         = "ma-dynamic-${var.name_suffix}"
  maintenance_configuration_id = azurerm_maintenance_configuration.guest_patch.id

  filter {
    locations       = [var.location]
    resource_groups = [var.dynamic_scope_resource_group]
    resource_types  = ["Microsoft.Compute/virtualMachines"]
    os_types        = ["Windows"]
    tag_filter      = "All"

    tags {
      tag    = var.dynamic_scope_tag_name
      values = var.dynamic_scope_tag_values
    }
  }
}
