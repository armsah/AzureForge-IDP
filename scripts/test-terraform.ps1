$ErrorActionPreference = "Stop"

$terraformRoots = @(
    "infra/modules/resource-group",
    "infra/modules/identity",
    "infra/modules/monitoring",
    "infra/examples/foundation"
)

Write-Host "Checking Terraform formatting..."
terraform fmt -check -recursive infra

foreach ($root in $terraformRoots) {
    Write-Host ""
    Write-Host "==> $root"

    Push-Location $root
    try {
        terraform init -backend=false -input=false
        terraform validate
        terraform test
    }
    finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "P2 Terraform validation and tests passed."
