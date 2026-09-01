# P4 - Terraform Variable Generation

P4 turns a validated AzureForge service specification into deterministic Terraform input variables.

## Goal

P4 establishes a deterministic transformation between the developer-facing AzureForge service specification and the Terraform inputs consumed by later provisioning phases.

The transformation is:

```text
YAML service specification
        |
        v
parse
        |
        v
validate
        |
        v
TerraformDesiredStateGenerator
        |
        v
deterministic .tfvars.json
```

P4 performs no Azure API calls and creates no infrastructure.

## Implementation

The C# CLI contains a Terraform desired-state generation layer:

- `TerraformDesiredState` defines the typed Terraform input contract.
- `TerraformDesiredStateGenerator` maps a validated `ServiceSpec` into desired state.
- `TerraformDesiredStateSerializer` emits canonical snake_case JSON.
- the `generate` CLI command validates the service specification before producing output.

Example:

```powershell
dotnet run --project .\src\AzureForge.Cli -- generate `
  .\examples\pricing-api.yaml `
  --output .\generated\pricing-api.tfvars.json
```

## Platform Defaults

The current service specification does not expose environment or Azure region as developer-controlled fields.

P4 therefore applies platform-owned defaults:

- environment: `dev`
- Azure region: `westeurope`

These defaults preserve the initial AzureForge dev-first golden path and approved-region guardrails.

## Naming

For a service named `pricing-api`, P4 deterministically generates:

```text
Resource group:        rg-pricing-api-dev-weu
Managed identity:      id-pricing-api-dev
Log Analytics:         log-pricing-api-dev-weu
Application Insights:  appi-pricing-api-dev
```

## Mandatory Tags

Generated desired state includes the AzureForge mandatory metadata:

```text
criticality
environment
managed-by
service
team
```

`managed-by` is fixed to `azureforge`.

## Determinism

P4 controls ordering where source input could otherwise produce unstable output.

Service Bus queue names are sorted using ordinal ordering before serialization. Tags are stored in a sorted dictionary. JSON property names use snake_case and serialization uses a stable typed desired-state model.

Repeated generation from the same valid specification therefore produces byte-identical output.

A manual SHA-256 verification against `pricing-api.yaml` produced identical hashes across consecutive generations.

## Golden Tests

The P4 test suite includes a checked-in golden fixture:

```text
tests/AzureForge.Cli.Tests/Fixtures/Golden/pricing-api.tfvars.json
```

The golden test:

1. parses the representative `pricing-api.yaml` service specification;
2. generates Terraform desired state;
3. serializes it;
4. compares the result with the checked-in golden file.

A separate test verifies deterministic Service Bus queue ordering.

The full .NET test suite currently passes with 9 tests.

## Validation Boundary

The `generate` command reuses the P1 service-spec validation layer.

Invalid specifications do not produce Terraform desired state.

For the existing `invalid-policy.yaml` fixture:

- validation reports the policy violations;
- the command exits with the `InvalidSpec` exit code;
- no `.tfvars.json` output file is written.

This prevents invalid developer intent from crossing the platform contract into the Terraform provisioning layer.

## Phase Boundary

P4 produces desired-state input only.

It does not:

- open provisioning pull requests;
- execute Terraform plans or applies;
- provision Container Apps;
- provision PostgreSQL;
- provision Service Bus;
- call Azure APIs.

Those responsibilities belong to later AzureForge phases.

## Exit Criterion

P4 exit criterion:

> Deterministic desired state.

This is demonstrated by golden-file tests and byte-identical repeated generation.
