[CmdletBinding()]
param(
    [string] $Environment = "lab",
    [string] $Project = "sreag",
    [string] $LocationShort = "wus2",
    [string] $AzureSreAgentLocationShort = "eus2",
    [string] $AzureSreAgentName = "",
    [string] $AzureDevOpsRepoName = "",
    [string] $AzureDevOpsRepoUrl = "",
    [switch] $ValidateAppPlatform,
    [switch] $ValidateAzureSreAgent,
    [switch] $ValidateAzureDevOpsRepo,
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

    $ids = az resource list `
        --resource-group $ResourceGroupName `
        --resource-type $ResourceType `
        --query "[].id" `
        -o tsv

    return @($ids | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count
}

function Test-AzResourceExists {
    param(
        [string] $ResourceGroupName,
        [string] $ResourceType,
        [string] $Name
    )

    $id = az resource show `
        --resource-group $ResourceGroupName `
        --resource-type $ResourceType `
        --name $Name `
        --query "id" `
        -o tsv 2>$null

    return -not [string]::IsNullOrWhiteSpace($id)
}

function Get-AzureSreAgentEndpoint {
    param(
        [string] $ResourceGroupName,
        [string] $AgentName
    )

    return az resource show `
        --resource-group $ResourceGroupName `
        --resource-type "Microsoft.App/agents" `
        --name $AgentName `
        --api-version "2025-05-01-preview" `
        --query "properties.agentEndpoint" `
        -o tsv 2>$null
}

function Test-AzureSreAgentRepoConnection {
    param(
        [string] $Endpoint,
        [string] $RepoName,
        [string] $RepoUrl
    )

    if ([string]::IsNullOrWhiteSpace($Endpoint)) {
        return $false
    }

    $token = az account get-access-token --resource "https://azuresre.dev" --query "accessToken" -o tsv 2>$null
    if ([string]::IsNullOrWhiteSpace($token)) {
        return $false
    }

    try {
        $reposUri = "{0}/api/v2/repos" -f $Endpoint.TrimEnd("/")
        $repos = Invoke-RestMethod `
            -Method Get `
            -Uri $reposUri `
            -Headers @{ Authorization = "Bearer $token" } `
            -TimeoutSec 30

        $repoJson = $repos | ConvertTo-Json -Depth 20
        return (
            $repoJson -match [regex]::Escape($RepoName) -and
            $repoJson -match [regex]::Escape($RepoUrl)
        )
    }
    catch {
        Write-Verbose $_.Exception.Message
        return $false
    }
}

if (-not $SkipAzLoginCheck) {
    $account = az account show --query "id" -o tsv 2>$null
    if (-not $account) {
        throw "Azure CLI is not logged in. Run 'az login' first."
    }
}

$script:FailedChecks = 0
$baseName = "{0}-{1}-{2}" -f $Project, $Environment, $LocationShort
$azureSreAgentNameEffective = if ([string]::IsNullOrWhiteSpace($AzureSreAgentName)) { "sreag-$Environment" } else { $AzureSreAgentName }
$azureDevOpsRepoNameEffective = if (-not [string]::IsNullOrWhiteSpace($AzureDevOpsRepoName)) {
    $AzureDevOpsRepoName
}
elseif ($Environment -eq "ado-lab") {
    "Azureboards"
}
else {
    ""
}
$azureDevOpsRepoUrlEffective = if (-not [string]::IsNullOrWhiteSpace($AzureDevOpsRepoUrl)) {
    $AzureDevOpsRepoUrl
}
elseif ($Environment -eq "ado-lab") {
    "https://dev.azure.com/Beyondcloudwithchriz/Azureboards/_git/Azureboards"
}
else {
    ""
}
$azureSreAgentResourceGroup = "rg-sreagent-$Project-$Environment-$AzureSreAgentLocationShort"
$resourceGroups = @{
    Network    = "rg-network-$baseName"
    Windows    = "rg-windows-$baseName"
    Sre        = "rg-sre-$baseName"
    Governance = "rg-governance-$baseName"
}
$appsResourceGroup = "rg-apps-$baseName"

foreach ($entry in $resourceGroups.GetEnumerator()) {
    $exists = az group exists --name $entry.Value | ConvertFrom-Json
    Write-Check -Name "$($entry.Key) resource group exists" -Passed $exists -Detail $entry.Value
}

$appsResourceGroupExists = az group exists --name $appsResourceGroup | ConvertFrom-Json
if ($ValidateAppPlatform -or $appsResourceGroupExists) {
    Write-Check -Name "Apps resource group exists" -Passed $appsResourceGroupExists -Detail $appsResourceGroup

    if ($appsResourceGroupExists) {
        Write-Check -Name "AKS cluster exists" -Passed ((Get-ResourceCount -ResourceGroupName $appsResourceGroup -ResourceType "Microsoft.ContainerService/managedClusters") -gt 0) -Detail $appsResourceGroup
        Write-Check -Name "Container Apps environment exists" -Passed ((Get-ResourceCount -ResourceGroupName $appsResourceGroup -ResourceType "Microsoft.App/managedEnvironments") -gt 0) -Detail $appsResourceGroup
        Write-Check -Name "Container App exists" -Passed ((Get-ResourceCount -ResourceGroupName $appsResourceGroup -ResourceType "Microsoft.App/containerApps") -gt 0) -Detail $appsResourceGroup
        Write-Check -Name "App Service plans exist" -Passed ((Get-ResourceCount -ResourceGroupName $appsResourceGroup -ResourceType "Microsoft.Web/serverfarms") -ge 2) -Detail $appsResourceGroup
        Write-Check -Name "App Service and Function App sites exist" -Passed ((Get-ResourceCount -ResourceGroupName $appsResourceGroup -ResourceType "Microsoft.Web/sites") -ge 2) -Detail $appsResourceGroup
        Write-Check -Name "Function App storage account exists" -Passed ((Get-ResourceCount -ResourceGroupName $appsResourceGroup -ResourceType "Microsoft.Storage/storageAccounts") -gt 0) -Detail $appsResourceGroup
    }
}

Write-Check -Name "Hub VNet exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Network -ResourceType "Microsoft.Network/virtualNetworks") -ge 3) -Detail $resourceGroups.Network
Write-Check -Name "Windows VM targets exist" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Windows -ResourceType "Microsoft.Compute/virtualMachines") -gt 0) -Detail $resourceGroups.Windows
Write-Check -Name "Log Analytics workspace exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.OperationalInsights/workspaces") -gt 0) -Detail $resourceGroups.Sre
Write-Check -Name "Data Collection Rule exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.Insights/dataCollectionRules") -gt 0) -Detail $resourceGroups.Sre
Write-Check -Name "Action Group exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.Insights/actionGroups") -gt 0) -Detail $resourceGroups.Sre
Write-Check -Name "Scheduled query alerts exist" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.Insights/scheduledQueryRules") -gt 0) -Detail $resourceGroups.Sre
Write-Check -Name "SRE Automation Account exists" -Passed ((Get-ResourceCount -ResourceGroupName $resourceGroups.Sre -ResourceType "Microsoft.Automation/automationAccounts") -gt 0) -Detail $resourceGroups.Sre

if ($ValidateAzureSreAgent) {
    $azureSreAgentResourceGroupExists = az group exists --name $azureSreAgentResourceGroup | ConvertFrom-Json
    Write-Check -Name "Azure SRE Agent resource group exists" -Passed $azureSreAgentResourceGroupExists -Detail $azureSreAgentResourceGroup

    if ($azureSreAgentResourceGroupExists) {
        Write-Check -Name "Azure SRE Agent exists" -Passed (Test-AzResourceExists -ResourceGroupName $azureSreAgentResourceGroup -ResourceType "Microsoft.App/agents" -Name $azureSreAgentNameEffective) -Detail $azureSreAgentNameEffective
        Write-Check -Name "Azure SRE Agent identity exists" -Passed ((Get-ResourceCount -ResourceGroupName $azureSreAgentResourceGroup -ResourceType "Microsoft.ManagedIdentity/userAssignedIdentities") -gt 0) -Detail $azureSreAgentResourceGroup
        Write-Check -Name "Azure SRE Agent Application Insights exists" -Passed ((Get-ResourceCount -ResourceGroupName $azureSreAgentResourceGroup -ResourceType "Microsoft.Insights/components") -gt 0) -Detail $azureSreAgentResourceGroup
        Write-Check -Name "Azure SRE Agent telemetry workspace exists" -Passed ((Get-ResourceCount -ResourceGroupName $azureSreAgentResourceGroup -ResourceType "Microsoft.OperationalInsights/workspaces") -gt 0) -Detail $azureSreAgentResourceGroup

        if ($ValidateAzureDevOpsRepo) {
            if ([string]::IsNullOrWhiteSpace($azureDevOpsRepoNameEffective) -or [string]::IsNullOrWhiteSpace($azureDevOpsRepoUrlEffective)) {
                throw "Pass -AzureDevOpsRepoName and -AzureDevOpsRepoUrl when using -ValidateAzureDevOpsRepo outside the ado-lab profile."
            }
            $agentEndpoint = Get-AzureSreAgentEndpoint -ResourceGroupName $azureSreAgentResourceGroup -AgentName $azureSreAgentNameEffective
            Write-Check -Name "Azure DevOps repo connected to Azure SRE Agent" -Passed (Test-AzureSreAgentRepoConnection -Endpoint $agentEndpoint -RepoName $azureDevOpsRepoNameEffective -RepoUrl $azureDevOpsRepoUrlEffective) -Detail $azureDevOpsRepoUrlEffective
        }
    }
}

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
