locals {
  alert_webhook_runbooks = {
    "restart-iis"         = azurerm_automation_runbook.restart_iis.name
    "start-stopped-vms"   = azurerm_automation_runbook.start_stopped_lab_vms.name
    "collect-diagnostics" = azurerm_automation_runbook.collect_vm_diagnostics.name
    "cleanup-disk"        = azurerm_automation_runbook.cleanup_disk.name
  }
}

resource "azurerm_automation_account" "this" {
  name                = "aa-sre-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "Basic"
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "vm_contributor" {
  for_each = var.managed_scope_ids

  scope                = each.value
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}

resource "azurerm_automation_runbook" "restart_iis" {
  name                    = "Restart-IIS-LabTargets"
  resource_group_name     = var.resource_group_name
  location                = var.location
  automation_account_name = azurerm_automation_account.this.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"
  description             = "Restarts IIS on matching lab VMs as an incident remediation exercise."
  tags                    = var.tags

  content = <<-POWERSHELL
    param(
      [Parameter(Mandatory = $false)]
      [string] $ResourceGroupName = "${var.target_resource_group_name}"
    )

    Connect-AzAccount -Identity
    $vms = Get-AzVM -ResourceGroupName $ResourceGroupName | Where-Object { $_.Tags["Role"] -eq "IIS" }
    $script = @(
      'if (Get-Service -Name W3SVC -ErrorAction SilentlyContinue) {',
      '  Start-Service W3SVC -ErrorAction SilentlyContinue',
      '  Restart-Service W3SVC -Force',
      '  Get-Service W3SVC | Select-Object Name, Status',
      '} else {',
      '  Write-Output "W3SVC was not found on this VM."',
      '}'
    ) -join [Environment]::NewLine
    foreach ($vm in $vms) {
      Write-Output "Restarting IIS on $($vm.Name)"
      Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $vm.Name -CommandId "RunPowerShellScript" -ScriptString $script
    }
  POWERSHELL
}

resource "azurerm_automation_runbook" "start_stopped_lab_vms" {
  name                    = "Start-StoppedLabVMs"
  resource_group_name     = var.resource_group_name
  location                = var.location
  automation_account_name = azurerm_automation_account.this.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"
  description             = "Starts stopped or deallocated lab VMs during a VM availability incident."
  tags                    = var.tags

  content = <<-POWERSHELL
    param(
      [Parameter(Mandatory = $false)]
      [string] $ResourceGroupName = "${var.target_resource_group_name}"
    )

    Connect-AzAccount -Identity
    $vms = Get-AzVM -ResourceGroupName $ResourceGroupName -Status
    foreach ($vm in $vms) {
      $powerState = ($vm.Statuses | Where-Object { $_.Code -like "PowerState/*" }).DisplayStatus
      if ($powerState -ne "VM running") {
        Write-Output "Starting $($vm.Name), current state: $powerState"
        Start-AzVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -NoWait
      } else {
        Write-Output "$($vm.Name) is already running."
      }
    }
  POWERSHELL
}

resource "azurerm_automation_runbook" "collect_vm_diagnostics" {
  name                    = "Collect-VMDiagnostics"
  resource_group_name     = var.resource_group_name
  location                = var.location
  automation_account_name = azurerm_automation_account.this.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"
  description             = "Collects a lightweight diagnostics snapshot from lab VMs through Run Command."
  tags                    = var.tags

  content = <<-POWERSHELL
    param(
      [Parameter(Mandatory = $false)]
      [string] $ResourceGroupName = "${var.target_resource_group_name}"
    )

    Connect-AzAccount -Identity
    $script = @(
      '$outputPath = "C:\SreDiagnostics"',
      'New-Item -ItemType Directory -Path $outputPath -Force | Out-Null',
      'Get-Date | Out-File "$outputPath\collected-at.txt"',
      'Get-Service W3SVC -ErrorAction SilentlyContinue | Select-Object Name, Status | Out-File "$outputPath\iis-service.txt"',
      'Get-Volume | Select-Object DriveLetter, FileSystemLabel, SizeRemaining, Size | Out-File "$outputPath\volumes.txt"',
      'Get-EventLog -LogName System -EntryType Error -Newest 20 | Select-Object TimeGenerated, Source, EventID, Message | Out-File "$outputPath\system-errors.txt"',
      'Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 ProcessName, Id, CPU, WorkingSet | Out-File "$outputPath\top-processes.txt"',
      'Get-ChildItem $outputPath | Select-Object Name, Length, LastWriteTime'
    ) -join [Environment]::NewLine
    Get-AzVM -ResourceGroupName $ResourceGroupName | ForEach-Object {
      Write-Output "Collecting diagnostics on $($_.Name)"
      Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $_.Name -CommandId "RunPowerShellScript" -ScriptString $script
    }
  POWERSHELL
}

resource "azurerm_automation_runbook" "cleanup_disk" {
  name                    = "Cleanup-LabDiskPressure"
  resource_group_name     = var.resource_group_name
  location                = var.location
  automation_account_name = azurerm_automation_account.this.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"
  description             = "Performs lab-safe temporary file cleanup on Windows targets during disk pressure scenarios."
  tags                    = var.tags

  content = <<-POWERSHELL
    param(
      [Parameter(Mandatory = $false)]
      [string] $ResourceGroupName = "${var.target_resource_group_name}"
    )

    Connect-AzAccount -Identity
    $script = @(
      '$paths = @($env:TEMP, "C:\Windows\Temp", "C:\SreIncidentLoad")',
      'foreach ($path in $paths) {',
      '  if (Test-Path $path) {',
      '    Write-Output "Cleaning $path"',
      '    Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue |',
      '      Where-Object { -not $_.PSIsContainer } |',
      '      Remove-Item -Force -ErrorAction SilentlyContinue',
      '  }',
      '}',
      'Clear-RecycleBin -Force -ErrorAction SilentlyContinue',
      'Get-Volume | Select-Object DriveLetter, SizeRemaining, Size'
    ) -join [Environment]::NewLine
    Get-AzVM -ResourceGroupName $ResourceGroupName | ForEach-Object {
      Write-Output "Running lab-safe cleanup on $($_.Name)"
      Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $_.Name -CommandId "RunPowerShellScript" -ScriptString $script
    }
  POWERSHELL
}

resource "azurerm_automation_runbook" "stop_lab_vms" {
  name                    = "Stop-Lab-VMs"
  resource_group_name     = var.resource_group_name
  location                = var.location
  automation_account_name = azurerm_automation_account.this.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"
  description             = "Stops all VMs in the Windows lab resource group for scheduled cost control."
  tags                    = var.tags

  content = <<-POWERSHELL
    param(
      [Parameter(Mandatory = $false)]
      [string] $ResourceGroupName = "${var.target_resource_group_name}"
    )

    Connect-AzAccount -Identity
    Get-AzVM -ResourceGroupName $ResourceGroupName | Stop-AzVM -Force -NoWait
  POWERSHELL
}

resource "azurerm_automation_schedule" "weekday_start" {
  count = var.enable_scheduled_startstop ? 1 : 0

  name                    = "Weekday-Start"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  frequency               = "Week"
  interval                = 1
  timezone                = var.schedule_timezone
  start_time              = var.start_time
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  description             = "Start lab VMs on weekdays."
}

resource "azurerm_automation_schedule" "weekday_stop" {
  count = var.enable_scheduled_startstop ? 1 : 0

  name                    = "Weekday-Stop"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  frequency               = "Week"
  interval                = 1
  timezone                = var.schedule_timezone
  start_time              = var.stop_time
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  description             = "Stop lab VMs on weekdays."
}

resource "azurerm_automation_job_schedule" "weekday_start" {
  count = var.enable_scheduled_startstop ? 1 : 0

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  schedule_name           = azurerm_automation_schedule.weekday_start[0].name
  runbook_name            = azurerm_automation_runbook.start_stopped_lab_vms.name
  parameters = {
    resourcegroupname = var.target_resource_group_name
  }
}

resource "azurerm_automation_job_schedule" "weekday_stop" {
  count = var.enable_scheduled_startstop ? 1 : 0

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  schedule_name           = azurerm_automation_schedule.weekday_stop[0].name
  runbook_name            = azurerm_automation_runbook.stop_lab_vms.name
  parameters = {
    resourcegroupname = var.target_resource_group_name
  }
}

resource "azurerm_automation_webhook" "alert" {
  for_each = var.enable_alert_runbook_webhooks ? local.alert_webhook_runbooks : {}

  name                    = "wh-${each.key}-${var.name_suffix}"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  expiry_time             = var.webhook_expiry_time
  enabled                 = true
  runbook_name            = each.value
  parameters = {
    resourcegroupname = var.target_resource_group_name
  }
}

resource "azurerm_monitor_action_group" "remediation" {
  count = var.enable_alert_runbook_webhooks ? 1 : 0

  name                = "ag-sre-remediate-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  short_name          = "srerem"
  tags                = var.tags

  dynamic "automation_runbook_receiver" {
    for_each = azurerm_automation_webhook.alert

    content {
      name                    = "runbook-${automation_runbook_receiver.key}"
      automation_account_id   = azurerm_automation_account.this.id
      runbook_name            = local.alert_webhook_runbooks[automation_runbook_receiver.key]
      webhook_resource_id     = automation_runbook_receiver.value.id
      is_global_runbook       = false
      service_uri             = automation_runbook_receiver.value.uri
      use_common_alert_schema = true
    }
  }
}
