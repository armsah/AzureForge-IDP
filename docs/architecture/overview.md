# AzureForge Architecture Overview

## Context

AzureForge is an opinionated internal developer platform control plane for producing approved Azure infrastructure desired state from a small developer-facing service contract.

The architecture deliberately separates:

1. developer intent;
2. platform validation and desired-state generation;
3. human review;
4. privileged infrastructure execution.

The AzureForge CLI does not require broad Azure subscription privileges.

## High-Level Architecture

```text
+------------------------+
| Application Developer  |
+-----------+------------+
            |
            | YAML service specification
            v
+------------------------+
| AzureForge CLI         |
| C# / .NET              |
+-----------+------------+
            |
            | parse + validate
            v
+------------------------+
| Platform Guardrails    |
| Approved capabilities  |
+-----------+------------+
            |
            | deterministic generation
            v
+------------------------+
| Terraform Desired      |
| State (.tfvars.json)   |
+-----------+------------+
            |
            | source-controlled change
            v
+------------------------+
| GitHub Pull Request    |
+-----------+------------+
            |
            | human review
            v
+------------------------+
| GitHub Actions         |
+-----------+------------+
            |
            | OIDC federation
            v
+------------------------+
| Microsoft Entra ID     |
+-----------+------------+
            |
            | short-lived Azure token
            v
+------------------------+
| Terraform              |
+-----------+------------+
            |
            v
+------------------------+
| Azure Resources        |
+------------------------+
```

## Architectural Layers

### 1. Developer Contract

Developers describe service intent through YAML.

Representative contract:

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

The specification describes required capabilities rather than Terraform implementation details.

### 2. AzureForge CLI

The current developer-facing control plane is the C# CLI in:

```text
src/AzureForge.Cli
```

It is responsible for:

- parsing YAML;
- mapping input into a typed service model;
- validating supported platform policy;
- returning deterministic CLI exit codes;
- generating deterministic Terraform desired state.

The CLI does not directly own privileged Azure deployment credentials.

### 3. Platform Guardrails

AzureForge validates supported service intent before Terraform execution.

Current guardrails include:

- approved runtime and compute patterns;
- allowed Azure regions;
- workload identity requirements;
- supported ingress behavior;
- bounded scaling configuration;
- supported observability profiles;
- cost-budget validation;
- environment TTL validation;
- Kubernetes namespace naming validation.

Azure Policy provides authoritative Azure-side enforcement for selected governance controls.

### 4. Desired-State Generator

The generator converts a valid service specification into deterministic Terraform input.

Representative output:

```text
provisioning/services/pricing-api/dev.tfvars.json
```

The generator derives platform-controlled values including:

- Azure resource names;
- environment;
- Azure region;
- observability configuration;
- optional PaaS capability flags;
- budget configuration;
- lifecycle configuration;
- optional AKS namespace intent;
- required platform tags.

Developers do not generate arbitrary Terraform resources.

### 5. Terraform Composition

Terraform implements approved AzureForge capabilities through reusable modules.

Current module categories include:

- resource groups;
- managed identity;
- Container Apps;
- monitoring;
- observability;
- PostgreSQL;
- Service Bus;
- governance;
- cost controls;
- governed AKS namespaces.

Environment composition lives under:

```text
infra/environments/dev
```

The composition selects and combines approved modules according to generated desired state.

### 6. GitHub Review Boundary

GitHub provides the source-controlled trust boundary between generated desired state and privileged infrastructure execution.

AzureForge uses:

- deterministic provisioning artifacts;
- pull requests;
- human review;
- provisioning workflows;
- governance workflows;
- scheduled drift workflows;
- retained workflow evidence.

The developer-facing CLI is therefore separated from subscription-level infrastructure execution.

## Authorization Boundary

The most important security boundary is:

```text
Developer
    |
    v
AzureForge CLI
    |
    | no broad subscription privilege
    v
Generated desired state
    |
    v
GitHub pull request
    |
    | human review
    v
GitHub Actions
    |
    | workload identity federation
    v
Microsoft Entra ID
    |
    | short-lived token
    v
Azure permissions
```

This architecture reduces the blast radius of the developer-facing control plane and improves auditability.

## Secretless GitHub-to-Azure Authentication

GitHub Actions authenticates to Azure through Microsoft Entra workload identity federation.

The standard CI path therefore does not require a long-lived Azure client secret.

The repository includes:

```text
.github/workflows/p3-oidc-smoke.yml
```

to demonstrate and validate the OIDC trust path.

## Container Apps Golden Path

The first-class compute implementation is Azure Container Apps.

The platform owns standard infrastructure decisions such as:

- resource naming;
- workload identity;
- ingress defaults;
- replica constraints;
- monitoring integration;
- tags;
- Terraform composition.

The application team expresses only service-level intent.

## Optional PaaS Capabilities

### PostgreSQL

Azure Database for PostgreSQL Flexible Server can be enabled through the service specification.

AzureForge controls the Terraform implementation and naming conventions.

Credentials are supplied through the trusted execution path rather than committed into reviewed developer desired state.

### Service Bus

Azure Service Bus can be enabled by declaring required queues.

AzureForge owns standard namespace configuration and uses identity-based access rather than local/SAS authentication.

## Observable-by-Default Architecture

AzureForge composes:

- Log Analytics;
- Application Insights;
- Azure Monitor workbooks;
- HTTP 5xx alerting;
- container restart alerting.

The developer selects an approved observability profile instead of wiring monitoring infrastructure manually.

## Governance Architecture

AzureForge manages Azure Policy definitions and assignments through reviewed Terraform.

Current governance includes:

- deployment-region restrictions;
- mandatory platform tags;
- `managed-by=azureforge` ownership enforcement.

Azure Policy acts as authoritative platform-side enforcement.

## Drift Detection

Scheduled Terraform plan execution compares deployed infrastructure with reviewed desired state.

The drift workflow uses Terraform detailed exit codes to distinguish:

- clean state;
- infrastructure drift;
- execution errors.

Drift is surfaced to operators but is not automatically remediated.

This preserves the same review boundary used for normal infrastructure changes.

## Cost and Lifecycle Architecture

AzureForge composes a per-environment Azure budget from:

```yaml
cost:
  monthlyBudgetEur: 80
```

The budget provides cost visibility and alerting rather than a hard spending shutdown mechanism.

Lifecycle intent is expressed through:

```yaml
lifecycle:
  ttlDays: 30
```

TTL values are validated by the platform.

The current implementation does not automatically destroy an environment when the TTL expires.

## Shared AKS Ownership Boundary

AzureForge can compose namespace-level platform resources into an externally managed/shared AKS cluster.

```text
Externally managed AKS platform
            |
            | cluster lifecycle
            v
       Shared AKS cluster
            |
            | referenced by AzureForge
            v
+-------------------------------+
| AzureForge namespace capability|
+-------------------------------+
| Namespace                     |
| ResourceQuota                 |
| LimitRange                    |
| AzureForge ownership labels   |
+-------------------------------+
```

AzureForge does not own the AKS cluster lifecycle.

When enabled, it manages only:

- Kubernetes `Namespace`;
- `ResourceQuota`;
- `LimitRange`;
- platform labels.

Kubernetes authentication is supplied by the trusted Terraform execution environment through kubeconfig and is not generated as part of developer desired state.

The P12 implementation was validated with mocked Terraform tests because no live shared AKS cluster was available at that stage.

## Terraform State Boundary

Terraform infrastructure state is separate from developer service specifications and generated platform metadata.

The development environment uses an Azure Storage remote backend for privileged execution.

Local validation and mocked testing can initialize with:

```powershell
terraform -chdir=infra\environments\dev init -backend=false
```

This avoids requiring personal developer access to the privileged Terraform state backend.

## Desired-State Principle

AzureForge treats generated infrastructure configuration as source-controlled desired state.

This provides:

- reviewable changes;
- deterministic inputs;
- inspectable Terraform plans;
- drift detection;
- rollback history;
- visible infrastructure ownership;
- a clear privileged-execution boundary.

## Current Scope

The portfolio implementation currently focuses on:

- development environments;
- .NET services;
- Azure Container Apps;
- managed identity;
- Azure Monitor;
- optional PostgreSQL;
- optional Service Bus;
- Azure Policy governance;
- drift detection;
- Azure cost budgets;
- bounded lifecycle intent;
- optional shared-AKS namespace provisioning.

## Deliberate Constraints

AzureForge is a portfolio internal-developer-platform implementation rather than a production multi-tenant platform service.

Current deliberate limitations include:

- primary environment is `dev`;
- primary runtime is .NET;
- primary compute is Azure Container Apps;
- environment TTL does not yet trigger automatic destruction;
- shared AKS namespace reuse was validated with Terraform mocks because no live shared AKS cluster was available during P12;
- no second AKS cluster was provisioned solely for portfolio evidence.

These constraints separate demonstrated platform behavior from future production evolution.

## Architecture Principle

The central AzureForge architecture principle is:

> Developers request approved capabilities. AzureForge owns the implementation, review boundary, governance, and trusted execution path.
