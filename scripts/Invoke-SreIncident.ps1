[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("IisOutage", "HighCpu", "DiskPressure", "StopVm", "CollectDiagnostics")]
    [string] $Scenario,

    [string] $Environment = "lab",
    [string] $Project = "sreag",
    [string] $LocationShort = "wus2",
    [string] $VmName,
    [int] $CpuMinutes = 10,
    [int] $DiskLoadGb = 2
)

$ErrorActionPreference = "Stop"

function Get-TargetVmName {
    param([string] $WindowsResourceGroup)

    if ($VmName) {
        return $VmName
    }

    $name = az vm list `
        --resource-group $WindowsResourceGroup `
        --query "[?tags.Role=='IIS'] | [0].name" `
        -o tsv

    if (-not $name) {
        $name = az vm list --resource-group $WindowsResourceGroup --query "[0].name" -o tsv
    }

    if (-not $name) {
        throw "No VM found in $WindowsResourceGroup."
    }
    return $name
}

function Invoke-RunCommand {
    param(
        [string] $WindowsResourceGroup,
        [string] $TargetVm,
        [string] $Script
    )

    if ($PSCmdlet.ShouldProcess($TargetVm, $Scenario)) {
        az vm run-command invoke `
            --resource-group $WindowsResourceGroup `
            --name $TargetVm `
            --command-id RunPowerShellScript `
            --scripts $Script `
            -o table
    }
}

$baseName = "{0}-{1}-{2}" -f $Project, $Environment, $LocationShort
$windowsRg = "rg-windows-$baseName"
$sreRg = "rg-sre-$baseName"
$targetVm = Get-TargetVmName -WindowsResourceGroup $windowsRg

switch ($Scenario) {
    "IisOutage" {
        Invoke-RunCommand -WindowsResourceGroup $windowsRg -TargetVm $targetVm -Script "Stop-Service W3SVC -Force; Get-Service W3SVC | Select-Object Name,Status"
    }
    "HighCpu" {
        $script = @"
`$end = (Get-Date).AddMinutes($CpuMinutes)
while ((Get-Date) -lt `$end) {
  1..50000 | ForEach-Object { [math]::Sqrt(`$_) } | Out-Null
}
"@
        Invoke-RunCommand -WindowsResourceGroup $windowsRg -TargetVm $targetVm -Script $script
    }
    "DiskPressure" {
        $bytes = [int64] $DiskLoadGb * 1GB
        $script = @"
New-Item -ItemType Directory -Path C:\SreIncidentLoad -Force | Out-Null
`$path = "C:\SreIncidentLoad\load.bin"
`$fs = [System.IO.File]::Open(`$path, [System.IO.FileMode]::Create)
try { `$fs.SetLength($bytes) } finally { `$fs.Close() }
Get-Item `$path | Select-Object FullName, Length
"@
        Invoke-RunCommand -WindowsResourceGroup $windowsRg -TargetVm $targetVm -Script $script
    }
    "StopVm" {
        if ($PSCmdlet.ShouldProcess($targetVm, "Stop VM")) {
            az vm stop --resource-group $windowsRg --name $targetVm -o table
        }
    }
    "CollectDiagnostics" {
        $accountName = az automation account list --resource-group $sreRg --query "[0].name" -o tsv
        if (-not $accountName) {
            throw "No Automation Account found in $sreRg."
        }

        if ($PSCmdlet.ShouldProcess($accountName, "Start Collect-VMDiagnostics")) {
            az automation runbook start `
                --automation-account-name $accountName `
                --resource-group $sreRg `
                --name "Collect-VMDiagnostics" `
                --parameters "resourcegroupname=$windowsRg" `
                -o table
        }
    }
}

Write-Host "Scenario '$Scenario' submitted for VM '$targetVm' in $windowsRg."
