# AzureForge Golden Path

## Goal

The AzureForge golden path defines the default, supported way for application teams to provision a new Azure-hosted service.

The golden path is intentionally opinionated. It reduces infrastructure choices where the organization benefits from consistency while exposing a small number of service-level decisions to developers.

## Initial Workload Pattern

The first-class workload is a .NET service running on Azure Container Apps.

Supported workload forms:

- HTTP API;
- background worker.

The baseline service includes:

- resource group;
- standard naming;
- mandatory tags;
- Azure Container Apps;
- managed identity;
- RBAC;
- Azure Monitor integration;
- Log Analytics;
- Application Insights;
- diagnostic settings;
- GitHub Actions;
- Terraform;
- environment configuration;
- operational documentation skeleton.

## Optional Capabilities

A service may request approved optional capabilities.

### PostgreSQL

Azure Database for PostgreSQL may be provisioned when:

```yaml
data:
  postgres: true
```

AzureForge determines the approved Terraform module, naming, defaults, diagnostics, tags, and supported SKU/profile.

### Service Bus

Azure Service Bus may be requested through the service specification.

Example:

```yaml
messaging:
  serviceBus:
    queues:
      - price-update
```

AzureForge owns the namespace configuration and common operational defaults while the application team selects required entities.

### Storage

Azure Storage may be exposed as an approved optional capability in later implementation phases.

## Example Developer Experience

A developer describes the required service:

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
  postgres: true

messaging:
  serviceBus:
    queues:
      - price-update

security:
  publicIngress: false
  workloadIdentity: true

observability:
  appInsights: true
  alerts: standard

cost:
  monthlyBudgetEur: 80
```

The developer should not need to separately decide:

- resource-group naming;
- managed-identity implementation;
- Azure Monitor wiring;
- Terraform provider layout;
- GitHub-to-Azure credential storage;
- standard tags;
- standard diagnostic settings;
- baseline policy controls.

## Golden-Path Flow

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
Terraform desired state
   |
   | pull request
   v
Review + Policy Checks
   |
   v
GitHub Actions
   |
   | Azure workload identity federation
   v
Terraform
   |
   v
Azure
```

## Developer Experience Principles

### Intent over implementation

The service specification describes required capabilities rather than low-level Azure resource configuration.

### Secure by default

Public exposure, long-lived credentials, and unrestricted RBAC are not defaults.

### Observable by default

Supported services receive the standard monitoring and diagnostic baseline without additional developer configuration.

### Reviewable by default

Infrastructure changes are represented as source-controlled desired state and pass through a pull-request boundary.

### Deterministic generation

The same valid service specification and platform version should produce equivalent desired state.

### Escape hatches are explicit

Unsupported requirements are not silently converted into arbitrary Terraform. They require a platform-level decision or separate infrastructure path.

## Initial Constraints

For the initial implementation:

- primary environment: `dev`;
- primary runtime: `.NET`;
- primary compute: `container-apps`;
- supported data option: PostgreSQL;
- supported messaging option: Service Bus;
- public ingress: disabled by default;
- workload identity: required;
- provisioning: pull-request driven;
- infrastructure: Terraform.

The platform catalog will evolve in later phases, but the service specification remains the customer-facing contract.
