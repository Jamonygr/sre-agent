[CmdletBinding()]
param(
    [string] $Environment = "lab",
    [string] $Project = "sreag",
    [string] $LocationShort = "wus2",
    [switch] $SkipAzLoginCheck
)

$ErrorActionPreference = "Stop"

function Write-Check {
    param(
        [string] $Name,
        [bool] $Passed,
        [string] $Detail = ""
    )

    $status = if ($Passed) { "PASS" } else { "FAIL" }
    $message = "[{0}] {1}" -f $status, $Name
    if ($Detail) {
        $message = "{0} - {1}" -f $message, $Detail
    }
    Write-Host $message

    if (-not $Passed) {
        $script:FailedChecks++
    }
}

function Get-ResourceCount {
    param(
        [string] $ResourceGroupName,
        [string] $ResourceType
    )

    $count = az resource list `
        --resource-group $ResourceGroupName `
        --resource-type $ResourceType `
        --query "length(@)" `
        -o tsv

    if ([string]::IsNullOrWhiteSpace($count)) {
        return 0
    }
    return [int] $count
}

if (-not $SkipAzLoginCheck) {
    $account = az account show --query "id" -o tsv 2>$null
    if (-not $account) {
        throw "Azure CLI is not logged in. Run 'az login' first."
    }
}

$script:FailedChecks = 0
$baseName = "{0}-{1}-{2}" -f $Project, $Environment, $LocationShort
$resourceGroups = @{
    Network    = "rg-network-$baseName"
    Windows    = "rg-windows-$baseName"
    Sre        = "rg-sre-$baseName"
    Governance = "rg-governance-$baseName"
}

foreach ($entry in $resourceGroups.GetEnumerator()) {
    $exists = az group exists --name $entry.Value | ConvertFrom-Json
    Write-Check -Name "$($entry.Key) resource group exists" -Passed $exists -Detail $entry.Value
}

Write-Check -Name "Hub VNet exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Network -ResourceType "Microsoft.Network/virtualNetworks") -ge 3) -Detail $resourceGroups.Network
Write-Check -Name "Windows VM targets exist" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Windows -ResourceType "Microsoft.Compute/virtualMachines") -gt 0) -Detail $resourceGroups.Windows
Write-Check -Name "Log Analytics workspace exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.OperationalInsights/workspaces") -gt 0) -Detail $resourceGroups.Sre
Write-Check -Name "Data Collection Rule exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.Insights/dataCollectionRules") -gt 0) -Detail $resourceGroups.Sre
Write-Check -Name "Action Group exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.Insights/actionGroups") -gt 0) -Detail $resourceGroups.Sre
Write-Check -Name "Scheduled query alerts exist" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.Insights/scheduledQueryRules") -gt 0) -Detail $resourceGroups.Sre
Write-Check -Name "SRE Automation Account exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.Automation/automationAccounts") -gt 0) -Detail $resourceGroups.Sre

$automationAccount = az automation account list `
    --resource-group $resourceGroups.Sre `
    --query "[0].name" `
    -o tsv

$runbooks = @()
if ($automationAccount) {
    $runbooks = az automation runbook list `
        --resource-group $resourceGroups.Sre `
        --automation-account-name $automationAccount `
        --query "[].name" `
        -o tsv
}

foreach ($expected in @("Restart-IIS-LabTargets", "Start-StoppedLabVMs", "Collect-VMDiagnostics", "Cleanup-LabDiskPressure")) {
    Write-Check -Name "Runbook $expected exists" -Passed ($runbooks -contains $expected)
}

$vmNames = az vm list --resource-group $resourceGroups.Windows --query "[].name" -o tsv
$amaExtensions = @()
foreach ($vm in $vmNames) {
    $amaExtensions += az vm extension list `
        --resource-group $resourceGroups.Windows `
        --vm-name $vm `
        --query "[?name=='AzureMonitorWindowsAgent'].name" `
        -o tsv
}

Write-Check -Name "Azure Monitor Agent extensions exist" -Passed (($amaExtensions | Measure-Object).Count -gt 0)

if ($script:FailedChecks -gt 0) {
    throw "$script:FailedChecks validation check(s) failed."
}

Write-Host "SRE Agent Azure Lab validation passed for $baseName."
