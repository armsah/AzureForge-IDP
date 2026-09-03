# AzureForge Portfolio Demo

## Goal

This walkthrough presents AzureForge as an internal developer platform rather than as a collection of Terraform modules.

The core story is:

```text
Application developer
        |
        | declarative service intent
        v
AzureForge
        |
        | validation + deterministic generation
        v
Reviewed infrastructure desired state
        |
        | human approval
        v
Secretless privileged automation
        |
        v
Governed Azure resources
```

A complete demo should take approximately 5–10 minutes.

## 1. Start With the Platform Problem

Explain the problem AzureForge addresses:

Application teams should not need to independently design:

- resource naming;
- Terraform provider layout;
- identity configuration;
- Azure Monitor integration;
- organizational tags;
- approved regions;
- GitHub-to-Azure credential handling;
- standard alerts;
- drift reporting;
- cost controls.

AzureForge provides a governed golden path instead.

## 2. Show the Developer Contract

Open:

```text
examples/pricing-api.yaml
```

Highlight:

```yaml
service:
  name: pricing-api
  owner: commerce-team
  criticality: medium
```

Then show the platform-level choices:

```yaml
compute:
  type: container-apps
  minReplicas: 0
  maxReplicas: 5

security:
  publicIngress: false
  workloadIdentity: true

observability:
  appInsights: true
  alerts: standard

cost:
  monthlyBudgetEur: 80

lifecycle:
  ttlDays: 30
```

Explain that the developer expresses intent without defining Azure resource IDs, Terraform resources, role assignments, monitoring workspaces, policy definitions, or provider authentication.

## 3. Validate the Specification

Run:

```powershell
dotnet run `
  --project .\src\AzureForge.Cli\AzureForge.Cli.csproj `
  -- validate `
  .\examples\pricing-api.yaml
```

Expected:

```text
Valid AzureForge service specification: pricing-api
```

Then explain that invalid policy choices fail before privileged infrastructure execution.

Optional negative demonstration:

```powershell
dotnet run `
  --project .\src\AzureForge.Cli\AzureForge.Cli.csproj `
  -- validate `
  .\tests\AzureForge.Cli.Tests\Fixtures\invalid-policy.yaml
```

## 4. Generate Deterministic Desired State

Run:

```powershell
dotnet run `
  --project .\src\AzureForge.Cli\AzureForge.Cli.csproj `
  -- generate `
  .\examples\pricing-api.yaml `
  --output .\provisioning\services\pricing-api\dev.tfvars.json
```

Open:

```text
provisioning/services/pricing-api/dev.tfvars.json
```

Call out deterministic platform-derived values such as:

```json
"resource_group_name": "rg-pricing-api-dev-weu",
"managed_identity_name": "id-pricing-api-dev",
"log_analytics_workspace_name": "log-pricing-api-dev-weu",
"application_insights_name": "appi-pricing-api-dev"
```

This is the key abstraction boundary:

```text
developer intent
      !=
raw Terraform implementation
```

## 5. Show the Terraform Module Library

Open:

```text
infra/modules
```

Highlight representative modules:

```text
resource-group
identity
container-app
monitoring
observability
postgres
service-bus
governance
cost-control
aks-namespace
```

Then open:

```text
infra/environments/dev/main.tf
```

Explain that AzureForge composes approved platform modules instead of generating arbitrary Terraform resources.

## 6. Explain the Human Review Boundary

Show:

```text
.github/workflows/p5-provisioning-pr.yml
```

Explain:

```text
service specification
        |
        v
generated desired state
        |
        v
GitHub pull request
        |
        v
human review
        |
        v
privileged Terraform execution
```

This is one of the most important security properties of the project.

The developer-facing control plane does not need broad Azure subscription privileges.

## 7. Show Secretless Azure Authentication

Show:

```text
.github/workflows/p3-oidc-smoke.yml
```

Explain that GitHub Actions uses Microsoft Entra workload identity federation.

The standard CI path does not depend on a long-lived Azure client secret.

This gives AzureForge a clean identity boundary:

```text
GitHub repository / environment
        |
        | federated identity
        v
Microsoft Entra ID
        |
        | short-lived token
        v
Azure
```

## 8. Show the Container Apps Golden Path

Show:

```text
.github/workflows/p6-provision-container-app.yml
```

Explain that the platform owns:

- Container Apps environment composition;
- workload identity;
- ingress defaults;
- replica constraints;
- monitoring integration;
- naming;
- tags.

The application team owns service intent.

## 9. Show Optional Capabilities

Open the service specification and explain:

PostgreSQL:

```yaml
data:
  postgres: false
```

Service Bus:

```yaml
messaging:
  serviceBus:
    queues: []
```

These can be enabled independently.

The Terraform composition tests cover:

- PostgreSQL only;
- Service Bus only;
- both capabilities;
- neither capability.

## 10. Show Observable-by-Default Behavior

Show:

```text
infra/modules/observability
```

and:

```text
.github/workflows/p8-provision-observability.yml
```

Explain that the standard platform baseline includes:

- Azure Monitor workbook;
- HTTP 5xx alerting;
- restart alerting;
- Log Analytics;
- Application Insights.

The service chooses a supported observability profile rather than building monitoring from scratch.

## 11. Show Policy Guardrails

Show:

```text
infra/modules/governance
```

Explain the current controls:

- deployment limited to approved Azure regions;
- required platform tags;
- `managed-by=azureforge`;
- Azure Policy authoritative enforcement.

Relevant workflows:

```text
.github/workflows/p9-plan-governance.yml
.github/workflows/p9-provision-governance.yml
```

Mention that unsafe configurations were validated through negative Azure Policy tests during P9.

## 12. Show Drift Detection

Show:

```text
.github/workflows/p10-drift-detection.yml
```

Explain Terraform detailed exit codes:

```text
0 = reviewed desired state matches infrastructure
2 = drift/change detected
other = execution failure
```

Drift is surfaced in GitHub rather than automatically repaired.

This preserves reviewability.

## 13. Show Cost and Lifecycle Controls

In the service spec:

```yaml
cost:
  monthlyBudgetEur: 80

lifecycle:
  ttlDays: 30
```

Explain:

- AzureForge composes a per-environment Azure budget;
- lifecycle TTL is bounded by platform validation;
- TTL is currently desired-state metadata, not automatic destruction.

This demonstrates cost awareness without overstating automation.

## 14. Show Shared AKS Reuse

Show:

```text
infra/modules/aks-namespace
```

Then the service contract:

```yaml
kubernetes:
  namespace:
    enabled: false
```

Explain that when enabled AzureForge manages:

- `Namespace`;
- `ResourceQuota`;
- `LimitRange`;
- platform ownership labels.

The AKS cluster itself remains externally managed.

Architecture:

```text
Shared AKS platform
      |
      | externally managed cluster
      v
AzureForge namespace capability
      |
      +-- Namespace
      +-- ResourceQuota
      +-- LimitRange
```

No second AKS cluster was created for Project 3.

Because the original shared AKS cluster was no longer live at P12 completion, this capability is demonstrated with mocked Terraform tests rather than a live apply.

## 15. Show the Test Evidence

CLI:

```powershell
dotnet test .\tests\AzureForge.Cli.Tests\AzureForge.Cli.Tests.csproj
```

Validated result:

```text
11 passed
0 failed
```

Environment composition:

```powershell
terraform -chdir=infra\environments\dev test
```

Validated result:

```text
14 passed
0 failed
```

AKS namespace module:

```powershell
terraform -chdir=infra\modules\aks-namespace test
```

Validated result:

```text
2 passed
0 failed
```

## 16. Close With the Platform Architecture

Summarize AzureForge as four layers:

```text
1. Developer contract
   YAML service specification

2. Platform control plane
   C# validation + deterministic generation

3. Review and trust boundary
   GitHub pull request + OIDC

4. Infrastructure implementation
   Terraform modules + Azure Policy + Azure services
```

The portfolio value is not that AzureForge provisions individual Azure resources.

The portfolio value is that it demonstrates an internal platform model with:

- product thinking;
- developer abstraction;
- deterministic infrastructure generation;
- composable Terraform;
- secretless CI authentication;
- human approval;
- governance;
- observability;
- drift visibility;
- cost controls;
- shared-platform reuse.

## Suggested Closing Statement

AzureForge demonstrates how an internal developer platform can reduce cognitive load for application teams while preserving infrastructure governance, auditability, and security boundaries.

Developers request approved capabilities through a small service contract. AzureForge converts those requests into deterministic, reviewable infrastructure desired state and leaves privileged execution to a trusted federated automation path.
