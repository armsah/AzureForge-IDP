# AzureForge

AzureForge is an opinionated internal developer platform for provisioning production-oriented Azure services through declarative service specifications.

The platform provides a governed golden path for application teams while keeping privileged infrastructure changes reviewable through GitHub pull requests and applying Terraform with federated Azure identity.

## Status

**P6 complete — Azure Container Apps golden path provisioned through reviewed desired state, Terraform remote state, and secretless GitHub OIDC.**

Next implementation phase: **P7 — PostgreSQL and Service Bus provisioning**.

## Current Capabilities

AzureForge currently provides:

- a declarative YAML service specification;
- a .NET 10 C# CLI;
- YAML parsing into a typed service model;
- golden-path and catalog validation;
- field-level validation errors;
- deterministic CLI exit codes;
- automated parser and validator tests;
- reusable Terraform foundation modules;
- native Terraform module tests;
- a tested Terraform composition example.
- deterministic service-spec to Terraform desired-state generation;
- canonical `.tfvars.json` serialization;
- golden-file testing for generated Terraform input.
- GitHub Actions provisioning-request generation;
- deterministic provisioning branches and `.tfvars.json` artifacts;
- pull-request-based human review before privileged infrastructure execution.
- reusable Terraform modules and environment composition;
- Azure Blob Storage remote Terraform state;
- secretless GitHub-to-Azure authentication using OIDC;
- live Azure Container Apps provisioning;
- user-assigned workload identity;
- Log Analytics and Application Insights baseline;
- configurable Container Apps scaling and ingress.

P5 carries deterministic desired state into a reviewable GitHub pull request. After human review and merge, P6 consumes that approved artifact through the privileged GitHub OIDC Terraform workflow.

## CLI

The P1 CLI validates an AzureForge service specification before it reaches later infrastructure-generation stages.

Validate the example service:

```powershell
dotnet run --project ".\src\AzureForge.Cli" -- validate ".\examples\pricing-api.yaml"
```

Expected output:

```text
Valid AzureForge service specification: pricing-api
```

A successful validation returns exit code `0`.

Invalid specifications return field-level validation errors and exit code `4`.

For example:

```powershell
dotnet run --project ".\src\AzureForge.Cli" -- validate ".\tests\AzureForge.Cli.Tests\Fixtures\invalid-policy.yaml"
```

Malformed YAML is also rejected before domain validation.

## Testing

Build the solution:

```powershell
dotnet build
```

Run the automated .NET test suite:

```powershell
dotnet test
```

P1 includes tests covering:

- valid golden-path specifications;
- malformed YAML;
- unsupported runtimes;
- mandatory workload identity;
- invalid replica configuration;
- duplicate Service Bus queues.

Run the P2 Terraform validation suite:

```powershell
.\scripts\test-terraform.ps1
```

## P0 — Platform Definition

The P0 design artifacts establish AzureForge's customers, golden path, guardrails, architecture, and provisioning security boundary.

- [`docs/product-brief.md`](docs/product-brief.md) — internal customers, value proposition, platform boundary, and success criteria.
- [`docs/golden-path.md`](docs/golden-path.md) — initial supported developer experience and service pattern.
- [`docs/guardrails.md`](docs/guardrails.md) — mandatory controls, defaults, and restricted choices.
- [`docs/architecture/overview.md`](docs/architecture/overview.md) — control-plane and provisioning architecture.
- [`docs/decisions/0001-pr-driven-provisioning.md`](docs/decisions/0001-pr-driven-provisioning.md) — security decision for PR-driven provisioning.
- [`examples/pricing-api.yaml`](examples/pricing-api.yaml) — representative AzureForge service specification.

## P1 — Service-Spec Validation CLI

P1 turns the service specification defined in P0 into an executable platform contract.

The implementation includes:

- `System.CommandLine`-based C# CLI;
- YamlDotNet parsing;
- strongly typed service-spec models;
- golden-path domain validation;
- explicit process exit codes;
- xUnit parser and validator tests;
- valid and invalid YAML test fixtures.

See [`docs/p1-cli-validation.md`](docs/p1-cli-validation.md) for the P1 design and validation rules.

## P2 — Terraform Module Library

P2 introduces reusable Terraform modules for the AzureForge infrastructure foundation:

- resource group with approved-region and mandatory-tag validation;
- user-assigned managed identity for secretless workload authentication;
- Log Analytics and workspace-based Application Insights;
- native Terraform tests using mocked AzureRM providers;
- a foundation example proving module-to-module composition without creating live Azure resources.

See [`docs/p2-terraform-modules.md`](docs/p2-terraform-modules.md) and [`infra/modules/README.md`](infra/modules/README.md).

Run the P2 validation suite:

```powershell
.\scripts\test-terraform.ps1
```

The current P2 test suite verifies:

- resource-group validation and metadata rules;
- managed identity configuration;
- monitoring baseline configuration;
- invalid retention handling;
- module-to-module composition.

P2 validation runs without Azure credentials and does not create live Azure resources.

## P3 — Remote State and GitHub OIDC

P3 establishes the remote Terraform state and secretless CI authentication foundation:

- Azure Blob Storage for Terraform remote state;
- blob versioning and delete-retention protection;
- a user-assigned managed identity for GitHub Actions;
- a federated identity credential scoped to the AzureForge repository and trusted branch;
- container-scoped `Storage Blob Data Contributor` access for Terraform state;
- a GitHub Actions OIDC smoke workflow proving Azure login and backend initialization without long-lived credentials.

See [`docs/p3-remote-state-oidc.md`](docs/p3-remote-state-oidc.md).

The GitHub workflow uses short-lived OIDC tokens and does not require an Azure client secret, storage account key, or SAS token.

## P4 - Terraform Variable Generation

P4 turns a validated AzureForge service specification into deterministic Terraform input variables.

The implementation includes:

- a typed Terraform desired-state model;
- deterministic mapping from validated service specifications;
- platform-owned defaults for the initial `dev` environment and `westeurope` region;
- AzureForge resource naming and mandatory tag generation;
- stable ordering for Service Bus queues and tags;
- canonical snake_case JSON serialization;
- a `generate` CLI command that writes `.tfvars.json`;
- golden-file tests proving generated desired state remains stable.

Example:

```powershell
dotnet run --project .\src\AzureForge.Cli -- generate `
  .\examples\pricing-api.yaml `
  --output .\generated\pricing-api.tfvars.json
```

See [`docs/p4-terraform-variable-generation.md`](docs/p4-terraform-variable-generation.md).

P4 performs no Azure API calls and creates no infrastructure. The generated file is the deterministic desired-state input consumed by later provisioning phases.

## P5 - Provisioning Pull Request

P5 turns deterministic AzureForge desired state into a reviewable provisioning pull request.

The GitHub Actions workflow:

- accepts an AzureForge service specification through `workflow_dispatch`;
- builds and tests the AzureForge CLI;
- invokes the P4 desired-state generator;
- writes the result under `provisioning/services/<service>/<environment>.tfvars.json`;
- uses a deterministic provisioning branch per service and environment;
- creates or updates a GitHub pull request for human review.

For the representative `pricing-api` service:

```text
Source:
examples/pricing-api.yaml

Artifact:
provisioning/services/pricing-api/dev.tfvars.json

Branch:
azureforge/provision/pricing-api-dev

Pull request:
provision: pricing-api dev
```

The P5 workflow has repository permissions for branch and pull-request creation only:

```yaml
permissions:
  contents: write
  pull-requests: write
```

It does not request GitHub OIDC tokens, authenticate to Azure, execute Terraform, approve its own pull requests, or merge them.

See [`docs/p5-provisioning-pr.md`](docs/p5-provisioning-pr.md).

The pull request therefore forms the human review boundary between developer intent and later privileged Azure provisioning.

## P6 — Container Apps Golden Path

P6 converts the human-reviewed desired state produced by P5 into live Azure infrastructure.

The privileged provisioning workflow is:

```text
.github/workflows/p6-provision-container-app.yml
```

The deployment boundary is:

```text
service specification
        ↓
deterministic desired state
        ↓
provisioning pull request
        ↓
HUMAN REVIEW + MERGE
        ↓
GitHub Actions
        ↓
GitHub OIDC
        ↓
Terraform remote state
        ↓
Azure Container Apps
```

The initial `pricing-api` deployment provisions:

- Azure Resource Group;
- user-assigned managed identity;
- Log Analytics workspace;
- workspace-based Application Insights;
- Azure Container Apps environment;
- Azure Container App.

The reusable Container Apps module is located at:

```text
infra/modules/container-app
```

The initial environment composition root is:

```text
infra/environments/dev
```

The privileged workflow uses the federated GitHub identity established in P3. No Azure client secret is stored in GitHub.

Terraform state is stored in Azure Blob Storage using Microsoft Entra ID authentication.

The P5 workflow retains repository and pull-request permissions only and does not authenticate to Azure. Privileged Terraform execution occurs only after the generated provisioning artifact has crossed the human review and merge boundary.

For the portfolio environment, the Terraform GitHub identity has `Contributor` at subscription scope for workload provisioning and `Storage Blob Data Contributor` on the Terraform state container. A production implementation should reduce this deployment scope through a dedicated landing-zone scope and/or custom provisioning role.

The initial `pricing-api` deployment was successfully provisioned in `westeurope` with:

```text
Resource Group:
rg-pricing-api-dev-weu

Managed Identity:
id-pricing-api-dev

Log Analytics:
log-pricing-api-dev-weu

Application Insights:
appi-pricing-api-dev

Container Apps Environment:
cae-pricing-api-dev-weu

Container App:
pricing-api
```

The Container App was verified in Azure with:

```text
provisioningState: Succeeded
```

The initial service uses internal ingress:

```text
public_ingress = false
```

PostgreSQL and Service Bus remain deferred to P7.

Detailed P6 design and evidence:

```text
docs/p6-container-app-golden-path.md
```

## Architecture Direction

AzureForge separates the developer-facing control plane from privileged infrastructure execution.

```text
Developer
    |
    | service specification
    v
AzureForge CLI / API
    |
    | validation
    v
Catalog + Guardrails
    |
    | deterministic generation
    v
Terraform Desired State
    |
    | pull request
    v
Review + Policy Checks
    |
    v
GitHub Actions
    |
    | workload identity federation
    v
Terraform
    |
    v
Azure
```

The AzureForge API is not intended to hold broad Azure subscription `Owner` or `Contributor` permissions. Privileged Terraform operations will execute through reviewed GitHub workflows using federated identity.

## Roadmap

- [x] P0 — Define platform customers, golden path, and guardrails
- [x] P1 — Build C# CLI that validates YAML service specs
- [x] P2 — Create Terraform module library
- [x] P3 — Bootstrap remote state and GitHub OIDC
- [x] P4 — Build service-spec to Terraform variable generation
- [x] P5 — Generate pull request or artifact for provisioning
- [x] P6 — Provision Container Apps golden path
- [ ] P7 — Add optional Service Bus/PostgreSQL modules
- [ ] P8 — Add monitoring and standard alerts
- [ ] P9 — Add Azure Policy/tag/region checks
- [ ] P10 — Add drift detection and scheduled plan
- [ ] P11 — Add cost controls and environment TTL
- [ ] P12 — Add optional AKS namespace template
- [ ] P13 — Polish documentation and onboarding demo
