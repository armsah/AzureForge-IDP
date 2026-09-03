# AzureForge Golden Path

## Goal

The AzureForge golden path defines the supported developer experience for provisioning an Azure-hosted service through the platform.

The golden path is intentionally opinionated.

It reduces infrastructure choices where organizational consistency, security, governance, and operability are more valuable than unrestricted infrastructure customization.

Developers describe service intent. AzureForge owns the approved implementation.

## Primary Workload Pattern

The first-class workload is a .NET service running on Azure Container Apps.

The baseline platform composition includes:

- resource group;
- deterministic naming;
- mandatory AzureForge tags;
- Azure Container Apps;
- user-assigned managed identity;
- workload identity;
- Log Analytics;
- Application Insights;
- standard Azure Monitor workbook;
- standard metric alerts;
- Azure Policy governance;
- Azure cost budget;
- Terraform remote state;
- GitHub Actions;
- secretless GitHub-to-Azure OIDC;
- scheduled drift detection.

## Representative Developer Contract

The canonical example is:

```text
examples/pricing-api.yaml
```

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

The developer does not separately specify:

- Terraform resources;
- provider authentication;
- resource-group naming;
- managed-identity implementation;
- Log Analytics wiring;
- Application Insights wiring;
- standard Azure Monitor alerts;
- Azure Policy assignment implementation;
- Terraform backend configuration;
- GitHub-to-Azure credentials;
- required platform tags;
- drift-detection implementation.

## Golden-Path Flow

```text
Developer
   |
   | service specification
   v
AzureForge CLI
   |
   | parse + validate
   v
Platform Guardrails
   |
   | deterministic generation
   v
Terraform desired state
   |
   | source-controlled artifact
   v
GitHub Pull Request
   |
   | human review
   v
GitHub Actions
   |
   | Microsoft Entra OIDC
   v
Terraform
   |
   v
Azure
```

## Step 1 — Describe Service Intent

Developers express what the service requires rather than how Azure resources must be implemented.

Examples include:

- compute type;
- scaling limits;
- PostgreSQL requirement;
- Service Bus queues;
- ingress requirements;
- observability profile;
- cost budget;
- lifecycle intent;
- optional Kubernetes namespace requirement.

## Step 2 — Validate the Specification

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

Unsupported or unsafe requests are rejected before privileged infrastructure execution.

## Step 3 — Generate Deterministic Desired State

Run:

```powershell
dotnet run `
  --project .\src\AzureForge.Cli\AzureForge.Cli.csproj `
  -- generate `
  .\examples\pricing-api.yaml `
  --output .\provisioning\services\pricing-api\dev.tfvars.json
```

The generated Terraform input contains platform-derived values such as:

- deterministic Azure names;
- environment;
- Azure region;
- capability flags;
- monitoring settings;
- budget configuration;
- lifecycle configuration;
- namespace intent;
- required tags.

The same valid service specification and platform version should generate equivalent desired state.

## Step 4 — Review the Infrastructure Request

Generated desired state is intended to pass through GitHub source control and pull-request review.

The developer-facing request does not directly receive broad Azure infrastructure privileges.

This provides a human review boundary before Terraform execution.

## Step 5 — Execute Through the Trusted Path

Privileged workflows authenticate to Azure through Microsoft Entra workload identity federation.

The standard CI path therefore uses short-lived federated credentials rather than a long-lived Azure client secret.

Terraform consumes the reviewed desired-state artifact.

## Optional Capabilities

### PostgreSQL

A developer can request PostgreSQL with:

```yaml
data:
  postgres: true
```

AzureForge determines:

- the approved Terraform module;
- naming;
- diagnostics;
- tags;
- platform defaults.

The canonical portfolio example keeps PostgreSQL disabled to reduce live Azure cost:

```yaml
data:
  postgres: false
```

### Service Bus

A developer can request queues with:

```yaml
messaging:
  serviceBus:
    queues:
      - price-update
```

AzureForge owns the namespace configuration and identity-based access model.

The canonical portfolio example currently keeps the capability disabled:

```yaml
messaging:
  serviceBus:
    queues: []
```

### Governed AKS Namespace

A service can request a namespace on an externally managed/shared AKS cluster:

```yaml
kubernetes:
  namespace:
    enabled: true
```

When enabled, AzureForge derives the namespace name from `service.name`.

AzureForge manages:

- Kubernetes `Namespace`;
- `ResourceQuota`;
- `LimitRange`;
- service label;
- team label;
- environment label;
- AzureForge ownership label.

AzureForge does not provision or own the AKS cluster itself.

The current portfolio example keeps this capability disabled:

```yaml
kubernetes:
  namespace:
    enabled: false
```

P12 validated the namespace capability through mocked Terraform tests because no live shared AKS cluster was available.

## Observable by Default

The standard service baseline includes:

- Log Analytics;
- Application Insights;
- Azure Monitor workbook;
- HTTP 5xx metric alerts;
- container restart alerts.

The service controls the supported alert profile through:

```yaml
observability:
  appInsights: true
  alerts: standard
```

Developers do not need to assemble the baseline monitoring stack themselves.

## Governed by Default

AzureForge combines pre-execution validation with authoritative Azure Policy enforcement.

Current governance includes:

- approved regions;
- required resource tags;
- required `managed-by=azureforge` ownership marker.

This creates two enforcement layers:

```text
Developer request
      |
      v
AzureForge validation
      |
      v
Reviewed Terraform
      |
      v
Azure Policy
      |
      v
Azure resource
```

## Cost-Aware by Default

Each environment can declare:

```yaml
cost:
  monthlyBudgetEur: 80
```

AzureForge composes the corresponding Azure budget through Terraform.

Budgets provide cost tracking and alerting. They do not automatically stop all Azure spending.

## Lifecycle-Aware by Default

Each environment declares bounded lifecycle intent:

```yaml
lifecycle:
  ttlDays: 30
```

AzureForge validates the supported TTL range.

The current implementation does not automatically destroy the environment when the TTL expires.

This limitation is explicit rather than implied.

## Drift-Visible by Default

AzureForge runs scheduled Terraform drift detection against reviewed desired state.

Drift detection distinguishes:

- infrastructure matching reviewed state;
- detected drift;
- Terraform execution errors.

Detected drift is reported instead of automatically remediated.

This keeps infrastructure correction subject to the normal review path.

## Developer Experience Principles

### Intent over implementation

The service specification describes capabilities rather than low-level Azure configuration.

### Secure by default

Public ingress and long-lived CI credentials are not platform defaults.

### Identity first

AzureForge favors workload identity and Microsoft Entra federation over stored secrets.

### Observable by default

Supported services receive the standard monitoring baseline without additional developer infrastructure work.

### Governed by default

Platform validation and Azure Policy enforce supported boundaries.

### Reviewable by default

Infrastructure desired state is source-controlled and reviewed before privileged Terraform execution.

### Deterministic by default

Equivalent validated service intent produces equivalent platform desired state.

### Cost-aware by default

Budget intent is part of the service contract.

### Drift-visible by default

Unexpected infrastructure changes are surfaced rather than silently ignored or automatically repaired.

### Shared infrastructure is reused deliberately

AzureForge can manage namespace-level AKS resources without taking ownership of the shared cluster lifecycle.

### Escape hatches are explicit

Unsupported requirements are not silently translated into arbitrary Terraform.

They require a platform-level decision or a separate infrastructure path.

## Current Golden-Path Constraints

The current portfolio implementation intentionally limits the supported surface:

- environment: `dev`;
- runtime: .NET;
- compute: Azure Container Apps;
- supported data option: PostgreSQL;
- supported messaging option: Service Bus;
- supported shared-cluster capability: governed AKS namespace;
- public ingress disabled by default;
- workload identity required;
- provisioning driven through reviewed GitHub workflows;
- infrastructure implemented with Terraform;
- environment TTL validated but not automatically enforced through deletion.

These constraints keep the golden path clear and demonstrate platform ownership rather than unconstrained infrastructure generation.

## Golden-Path Principle

> Application teams choose approved capabilities. AzureForge standardizes how those capabilities are implemented, governed, reviewed, observed, and operated.
