[CmdletBinding()]
param(
    [string[]] $PlanProfiles = @("cheap-lab", "ado-lab", "lab"),
    [switch] $SkipPlans,
    [switch] $SkipGoCompile
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$forbiddenPattern = "[mM][vV][pP]"

function Invoke-Step {
    param(
        [string] $Name,
        [scriptblock] $ScriptBlock
    )

    Write-Host "==> $Name"
    & $ScriptBlock
    Write-Host "    ok"
}

Push-Location $repoRoot
try {
    Invoke-Step -Name "Reserved wording scan" -ScriptBlock {
        $matches = git grep -I -n -E $forbiddenPattern -- . ":!.git" ":!.terraform" 2>$null
        if ($matches) {
            $matches | ForEach-Object { Write-Host $_ }
            throw "Reserved wording found in tracked files."
        }
    }

    Invoke-Step -Name "Terraform format" -ScriptBlock {
        terraform fmt -check -recursive
    }

    Invoke-Step -Name "Terraform init without backend" -ScriptBlock {
        terraform init -backend=false -reconfigure
    }

    Invoke-Step -Name "Terraform validate" -ScriptBlock {
        terraform validate
    }

    Invoke-Step -Name "PowerShell parser checks" -ScriptBlock {
        Get-ChildItem -LiteralPath (Join-Path $repoRoot "scripts") -Filter *.ps1 |
            ForEach-Object {
                $tokens = $null
                $errors = $null
                [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref] $tokens, [ref] $errors) | Out-Null
                if ($errors.Count -gt 0) {
                    throw "$($_.Name): $($errors.Message -join '; ')"
                }
            }
    }

    if (-not $SkipGoCompile) {
        Invoke-Step -Name "Terratest compile check" -ScriptBlock {
            Push-Location (Join-Path $repoRoot "tests")
            try {
                go test -v -run '^$' -count=0 ./...
            }
            finally {
                Pop-Location
            }
        }
    }

    Invoke-Step -Name "TFLint" -ScriptBlock {
        tflint --init
        tflint --recursive `
            --disable-rule=terraform_required_version `
            --disable-rule=terraform_required_providers `
            --disable-rule=terraform_unused_declarations
    }

    if (-not $SkipPlans) {
        foreach ($profile in $PlanProfiles) {
            Invoke-Step -Name "Local no-refresh plan ($profile)" -ScriptBlock {
                & (Join-Path $repoRoot "scripts\Invoke-LocalPlan.ps1") -VarFile "environments/$profile.tfvars" | Out-Host
            }
        }
    }

    Write-Host "Quality gate passed."
}
finally {
    Pop-Location
}
