# AzureForge Guardrails

## Purpose

AzureForge guardrails define the organizational constraints applied to services created through the platform.

Guardrails are divided into:

- **mandatory controls** — requirements that cannot be disabled by normal service configuration;
- **defaults** — secure or operationally preferred values that may support an approved override;
- **restricted choices** — values selected from a platform-maintained catalog.

The implementation of these controls is introduced incrementally across P1-P13.

## Mandatory Controls

### Managed workload identity

Supported workloads use managed identity or workload identity.

Long-lived Azure client secrets are not part of the golden path.

Expected enforcement:

- service-spec validation;
- Terraform module design;
- GitHub OIDC for CI/CD.

### Mandatory tags

Every supported resource must include, where the Azure resource type supports tagging:

- `service`;
- `team`;
- `environment`;
- `managed-by`;
- `criticality`.

Recommended value:

```text
managed-by = azureforge
```

Expected enforcement:

- Terraform module inputs;
- Terraform checks;
- Azure Policy where appropriate.

### Standard naming

Resources follow AzureForge naming conventions.

Application teams provide semantic identifiers such as service and environment names but do not directly construct resource names.

Expected enforcement:

- generation logic;
- Terraform locals/modules.

### Reviewed privileged changes

Privileged infrastructure changes must be represented by reviewed desired state before application.

Expected enforcement:

- pull requests;
- GitHub branch protection;
- CODEOWNERS/review rules where appropriate;
- protected GitHub environments for production in later phases.

### Remote Terraform state

Provisioned infrastructure uses approved remote Terraform state rather than local state.

Expected enforcement:

- P3 bootstrap;
- generated backend configuration.

### Observability baseline

Supported services receive standard logging, diagnostics, and monitoring integration.

Expected enforcement:

- Terraform modules;
- policy checks;
- P8 monitoring configuration.

## Defaults

### Public ingress

Default:

```yaml
security:
  publicIngress: false
```

Public ingress must be explicitly requested and may be restricted by policy.

### Application Insights

Default:

```yaml
observability:
  appInsights: true
```

Disabling platform monitoring is not part of the initial golden path.

### Standard alerts

Default:

```yaml
observability:
  alerts: standard
```

Alert profiles are controlled by the platform catalog.

### Development scaling

Development workloads should use conservative scaling defaults.

Example:

```yaml
compute:
  minReplicas: 0
  maxReplicas: 5
```

Limits will be validated against catalog rules.

### Development budget

Development environments should declare or inherit a monthly budget.

Budget automation is introduced in P11.

## Restricted Choices

### Azure regions

Services may deploy only to approved regions.

The exact allow-list is environment/platform configuration rather than an arbitrary service-spec value.

Example initial catalog:

```text
westeurope
northeurope
```

The final allow-list should reflect the organization hosting the platform.

### Compute

Initial approved compute:

```text
container-apps
```

AKS namespace support is optional and introduced later in P12.

### Runtime

Initial approved runtime:

```text
dotnet
```

Supported runtime versions are maintained by the catalog.

### Data services

Initial approved relational database capability:

```text
postgres
```

AzureForge controls allowed SKUs, networking options, backups, diagnostics, and other baseline settings.

### Messaging

Initial approved messaging capability:

```text
servicebus
```

AzureForge controls namespace-level configuration and supported entity defaults.

## Prohibited Golden-Path Configurations

The following are outside the standard AzureForge path:

- arbitrary Azure regions;
- arbitrary Azure SKUs;
- subscription-wide workload permissions;
- stored Azure client secrets for GitHub Actions;
- local Terraform state for managed environments;
- missing mandatory ownership tags;
- unsupported compute targets;
- arbitrary raw Terraform supplied through a service specification;
- bypassing the pull-request provisioning boundary;
- unmanaged infrastructure that pretends to be AzureForge-managed.

## Guardrail Enforcement Layers

AzureForge uses defense in depth.

```text
Service Spec
    |
    v
Schema / CLI Validation
    |
    v
Catalog Constraints
    |
    v
Generated Terraform
    |
    v
Terraform / Policy Checks
    |
    v
Pull Request Review
    |
    v
Azure Policy
```

Not every guardrail needs to exist at every layer. Controls should be placed where they provide useful early feedback and authoritative enforcement.

## Phase Mapping

| Guardrail | Primary implementation phase |
| --- | --- |
| Service-spec validation | P1 |
| Approved module composition | P2 |
| Secretless GitHub authentication | P3 |
| Deterministic desired state | P4 |
| Human review boundary | P5 |
| Container Apps defaults | P6 |
| PaaS catalog constraints | P7 |
| Monitoring baseline | P8 |
| Azure Policy/tag/region checks | P9 |
| Drift detection | P10 |
| Cost and TTL controls | P11 |
| Optional AKS constraints | P12 |
