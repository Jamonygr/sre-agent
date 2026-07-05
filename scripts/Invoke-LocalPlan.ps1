[CmdletBinding()]
param(
    [string] $VarFile = "environments/cheap-lab.tfvars"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$tempRoot = Join-Path $env:TEMP ("sre-agent-plan-" + [guid]::NewGuid().ToString("N"))

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    Get-ChildItem -LiteralPath $repoRoot -Force |
        Where-Object { $_.Name -notin @(".terraform", ".git") } |
        Copy-Item -Destination $tempRoot -Recurse -Force

    $backendPath = Join-Path $tempRoot "backend.tf"
    if (Test-Path -LiteralPath $backendPath) {
        Remove-Item -LiteralPath $backendPath -Force
    }

    Push-Location $tempRoot
    terraform init -backend=false -reconfigure
    terraform plan "-var-file=$VarFile" -input=false -lock=false -refresh=false
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
