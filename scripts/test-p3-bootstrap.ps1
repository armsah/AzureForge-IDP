$ErrorActionPreference = "Stop"

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed with exit code $LASTEXITCODE"
    }
}

Write-Host "Checking P3 Terraform formatting..."
Invoke-Checked terraform @("fmt", "-check", "-recursive", "infra/bootstrap")

$roots = @(
    "infra/bootstrap/platform",
    "infra/bootstrap/remote-state-smoke"
)

foreach ($root in $roots) {
    Write-Host ""
    Write-Host "==> $root"
    Push-Location $root
    try {
        if ($root -like "*remote-state-smoke") {
            Invoke-Checked terraform @("init", "-backend=false", "-input=false")
        }
        else {
            Invoke-Checked terraform @("init", "-backend=false", "-input=false")
        }
        Invoke-Checked terraform @("validate")
    }
    finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "P3 bootstrap Terraform validation passed."
