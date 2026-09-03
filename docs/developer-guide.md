# AzureForge Developer Guide

## Purpose

AzureForge is an opinionated internal developer platform for provisioning Azure service infrastructure from a small declarative YAML contract.

Application teams describe service intent. AzureForge validates that intent, generates deterministic Terraform desired state, and carries infrastructure changes through a reviewed GitHub pull-request boundary before privileged Terraform execution.

The developer-facing workflow is intentionally separated from Azure subscription privileges.

```text
Developer
   |
   | service specification
   v
AzureForge CLI
   |
   | validation
   v
Deterministic Terraform desired state
   |
   | reviewed artifact
   v
GitHub Pull Request
   |
   | human approval
   v
GitHub Actions
   |
   | OIDC federation
   v
Terraform
   |
   v
Azure
```

## Supported Golden Path

The current AzureForge golden path targets development environments for .NET services running on Azure Container Apps.

The baseline platform can compose:

- Azure resource group;
- user-assigned managed identity;
- Azure Container Apps;
- Log Analytics;
- Application Insights;
- standard observability workbook;
- standard metric alerts;
- Azure Policy governance;
- Azure cost budget;
- optional PostgreSQL Flexible Server;
- optional Azure Service Bus namespace and queues;
- optional governed Kubernetes namespace on an externally managed AKS cluster.

AzureForge also provides:

- deterministic naming;
- required resource tags;
- approved-region enforcement;
- workload identity requirements;
- reviewable Terraform desired state;
- scheduled Terraform drift detection;
- bounded environment TTL configuration.

## Prerequisites

For local validation and generation:

- .NET 10 SDK;
- Terraform compatible with the repository constraint;
- Git;
- PowerShell.

Azure CLI is only required for Azure-connected workflows.

Privileged Azure provisioning is designed to run through GitHub Actions using Microsoft Entra workload identity federation rather than long-lived Azure client secrets.

## Clone the Repository

```powershell
git clone https://github.com/armsah/AzureForge-IDP.git
Set-Location .\AzureForge-IDP
```

## Representative Service Specification

The canonical example is:

```text
examples/pricing-api.yaml
```

Current example:

```yaml
service:
  name: pricing-api
  owner: commerce-team
  criticality: medium

runtime:
  language: dotnet
  version: "10"

compute:
  type: container-apps
  minReplicas: 0
  maxReplicas: 5

data:
  postgres: false

messaging:
  serviceBus:
    queues: []

security:
  publicIngress: false
  workloadIdentity: true

observability:
  appInsights: true
  alerts: standard

kubernetes:
  namespace:
    enabled: false

cost:
  monthlyBudgetEur: 80

lifecycle:
  ttlDays: 30
```

The specification describes service intent rather than low-level Azure resource configuration.

## Validate a Service Specification

Run:

```powershell
dotnet run `
  --project .\src\AzureForge.Cli\AzureForge.Cli.csproj `
  -- validate `
  .\examples\pricing-api.yaml
```

Expected output:

```text
Valid AzureForge service specification: pricing-api
```

Successful validation returns exit code `0`.

Invalid platform policy or malformed YAML is rejected before Terraform desired state is generated.

For example:

```powershell
dotnet run `
  --project .\src\AzureForge.Cli\AzureForge.Cli.csproj `
  -- validate `
  .\tests\AzureForge.Cli.Tests\Fixtures\invalid-policy.yaml
```

## Generate Terraform Desired State

Generate the reviewed Terraform variable artifact:

```powershell
dotnet run `
  --project .\src\AzureForge.Cli\AzureForge.Cli.csproj `
  -- generate `
  .\examples\pricing-api.yaml `
  --output .\provisioning\services\pricing-api\dev.tfvars.json
```

Inspect it:

```powershell
Get-Content .\provisioning\services\pricing-api\dev.tfvars.json
```

The generated artifact is deterministic for the same valid service specification and AzureForge platform version.

Representative fields include:

```json
{
  "service_name": "pricing-api",
  "environment": "dev",
  "location": "westeurope",
  "postgres_enabled": false,
  "service_bus_queues": [],
  "public_ingress": false,
  "workload_identity": true,
  "alerts": "standard",
  "monthly_budget_eur": 80,
  "environment_ttl_days": 30,
  "aks_namespace_enabled": false,
  "aks_namespace_name": null
}
```

Developers do not generate arbitrary Terraform resources. AzureForge maps approved service intent into the platform's existing Terraform module composition.

## Provisioning Review Boundary

AzureForge uses a pull-request boundary between developer intent and privileged infrastructure execution.

The provisioning-request workflow is:

```text
.github/workflows/p5-provisioning-pr.yml
```

Its role is to carry deterministic desired state into source control for review.

The security boundary is:

```text
Developer request
      |
      v
Generated desired state
      |
      v
GitHub pull request
      |
      | human review
      v
Privileged workflow
      |
      | OIDC
      v
Azure
```

The developer-facing CLI does not require broad subscription privileges.

## GitHub OIDC

AzureForge's normal CI path authenticates to Azure through Microsoft Entra workload identity federation.

This avoids storing a long-lived Azure client secret for GitHub Actions.

The repository includes an OIDC smoke-test workflow:

```text
.github/workflows/p3-oidc-smoke.yml
```

Privileged provisioning workflows consume reviewed desired state after the GitHub review boundary.

## Container Apps Golden Path

The baseline service compute implementation uses Azure Container Apps.

Provisioning workflow:

```text
.github/workflows/p6-provision-container-app.yml
```

AzureForge controls:

- resource naming;
- resource-group placement;
- workload identity;
- ingress policy;
- scaling limits;
- monitoring integration;
- platform tags.

Application teams specify service-level intent rather than Terraform implementation details.

## Optional PostgreSQL

PostgreSQL can be requested with:

```yaml
data:
  postgres: true
```

The capability is optional.

The current portfolio example keeps it disabled:

```yaml
data:
  postgres: false
```

PostgreSQL administrator credentials are not written into the reviewed service desired-state artifact.

## Optional Service Bus

Queues can be requested through:

```yaml
messaging:
  serviceBus:
    queues:
      - price-update
```

The current portfolio example keeps Service Bus disabled:

```yaml
messaging:
  serviceBus:
    queues: []
```

AzureForge manages the standard namespace configuration and disables local/SAS authentication in favor of identity-based access.

## Observability

AzureForge provides an observable-by-default baseline.

The standard composition includes:

- Log Analytics;
- Application Insights;
- Azure Monitor workbook;
- HTTP 5xx alerting;
- container-restart alerting.

The service contract controls the alert profile:

```yaml
observability:
  appInsights: true
  alerts: standard
```

Supported alert policy values are governed by the service contract rather than arbitrary Terraform inputs.

Relevant workflows include:

```text
.github/workflows/p8-plan-observability.yml
.github/workflows/p8-provision-observability.yml
```

## Governance

AzureForge uses Terraform-managed Azure Policy assignments to enforce platform guardrails.

Current governance includes:

- approved deployment regions;
- mandatory AzureForge resource tags;
- enforced `managed-by=azureforge` ownership marker.

Supported regions are currently:

```text
westeurope
northeurope
```

Governance workflows:

```text
.github/workflows/p9-plan-governance.yml
.github/workflows/p9-provision-governance.yml
```

Unsafe configurations are designed to be rejected before or during authoritative Azure Policy enforcement.

## Drift Detection

AzureForge includes scheduled Terraform drift detection:

```text
.github/workflows/p10-drift-detection.yml
```

The workflow uses Terraform detailed exit-code semantics to distinguish:

- clean reviewed state;
- detected drift;
- execution errors.

Detected drift is reported rather than automatically remediated.

This preserves a human review boundary for infrastructure changes.

## Cost Controls

Each composed development environment can declare a monthly Azure budget:

```yaml
cost:
  monthlyBudgetEur: 80
```

The value is translated into the Terraform cost-control module.

Azure budgets provide cost visibility and alerting. They are not a hard Azure spending shutdown mechanism.

## Environment Lifecycle

The service specification includes bounded lifecycle intent:

```yaml
lifecycle:
  ttlDays: 30
```

AzureForge validates the supported TTL range.

The current implementation treats TTL as reviewed desired-state metadata and validation. It does not automatically destroy environments when the TTL expires.

## Optional Shared AKS Namespace

AzureForge can optionally compose a governed Kubernetes namespace on an externally managed/shared AKS cluster:

```yaml
kubernetes:
  namespace:
    enabled: true
```

When enabled, AzureForge derives the namespace name from `service.name`.

The namespace module manages:

- Kubernetes `Namespace`;
- `ResourceQuota`;
- `LimitRange`;
- AzureForge ownership labels;
- service, team, and environment labels.

AzureForge does not create or own the AKS cluster itself.

The cluster lifecycle belongs to the external/shared infrastructure platform.

Kubernetes authentication is supplied by the trusted Terraform execution environment through kubeconfig rather than being stored in generated developer desired state.

The current portfolio example keeps the capability disabled because no live shared AKS cluster was available when the capability was validated:

```yaml
kubernetes:
  namespace:
    enabled: false
```

P12 evidence is therefore based on mocked Terraform module and composition tests rather than a live cluster apply.

## Run the CLI Tests

```powershell
dotnet test .\tests\AzureForge.Cli.Tests\AzureForge.Cli.Tests.csproj
```

Current validated result at P12 completion:

```text
total: 11
failed: 0
succeeded: 11
```

## Run Terraform Composition Tests

Initialize without the remote backend for local test execution:

```powershell
terraform -chdir=infra\environments\dev init -backend=false
```

Validate:

```powershell
terraform -chdir=infra\environments\dev validate
```

Run composition tests:

```powershell
terraform -chdir=infra\environments\dev test
```

Current validated result at P12 completion:

```text
Success! 14 passed, 0 failed.
```

## Run the AKS Namespace Module Tests

```powershell
terraform -chdir=infra\modules\aks-namespace init -backend=false
terraform -chdir=infra\modules\aks-namespace validate
terraform -chdir=infra\modules\aks-namespace test
```

Current validated result:

```text
Success! 2 passed, 0 failed.
```

If a temporary child-module `.terraform.lock.hcl` is created during isolated testing, remove it afterward because dependency locking is maintained by the root Terraform composition:

```powershell
Remove-Item .\infra\modules\aks-namespace\.terraform.lock.hcl
```

## Terraform Remote State

The development composition declares an Azure Storage backend.

Local validation and mocked tests should normally use:

```powershell
terraform -chdir=infra\environments\dev init -backend=false
```

Privileged remote-state access remains part of the trusted CI execution boundary.

## Safety Model

AzureForge follows several deliberate safety principles:

1. developers describe intent rather than arbitrary infrastructure;
2. supported values are validated against platform policy;
3. generated Terraform desired state is deterministic;
4. desired state is source-controlled;
5. privileged execution occurs after human review;
6. GitHub authenticates to Azure through short-lived federated identity;
7. Azure Policy provides authoritative platform-side enforcement;
8. scheduled drift detection reports unexpected changes without silently repairing them;
9. optional AKS capability reuses externally managed infrastructure instead of creating another cluster.

## Current Portfolio Limitations

AzureForge is a portfolio implementation of an internal developer platform, not a production multi-tenant platform service.

Current deliberate constraints include:

- primary environment is `dev`;
- primary runtime is .NET;
- primary compute platform is Azure Container Apps;
- PostgreSQL and Service Bus are optional;
- lifecycle TTL is validated but not automatically enforced through environment destruction;
- AKS namespace capability was validated through mocked Terraform because no live shared AKS cluster was available during P12;
- no second AKS cluster was created solely for portfolio evidence.

These constraints are documented so that demonstrated behavior is separated from future platform evolution.

## Developer Onboarding Summary

A developer's normal interaction with AzureForge is:

```text
1. Describe service intent in YAML
2. Validate the service specification
3. Generate deterministic Terraform desired state
4. Review the generated artifact
5. Submit infrastructure changes through GitHub
6. Pass the human review boundary
7. Allow trusted GitHub OIDC automation to run Terraform
8. Observe drift, policy, monitoring, and cost controls through the platform
```

The defining platform principle is:

> Developers request capabilities. AzureForge owns the approved infrastructure implementation.
