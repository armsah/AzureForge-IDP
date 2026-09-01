# P2 — Terraform Module Library

## Goal

P2 establishes reusable Terraform modules that encode AzureForge infrastructure defaults behind stable, composable interfaces.

P2 does not provision a complete application service. Container Apps integration is introduced in P6, while optional Service Bus and PostgreSQL capabilities are introduced in P7.

## Modules

- `infra/modules/resource-group`
- `infra/modules/identity`
- `infra/modules/monitoring`

The composition proof is `infra/examples/foundation`.

## Design

Modules expose small input contracts and outputs that downstream modules can consume. Guardrails that belong close to implementation, such as approved regions and mandatory tags, fail before Azure API calls.

The identity module uses a user-assigned managed identity and introduces no client secret.

The monitoring module establishes the reusable Log Analytics and workspace-based Application Insights baseline.

## Testing

P2 uses Terraform native tests with a mocked AzureRM provider. This allows module behavior and composition to be tested without Azure credentials, live resources, or cloud cost.

## Provider Baseline

- Terraform >= 1.7.0
- AzureRM >= 5.2.0, < 6.0.0

## Exit Criterion

P2 is complete when formatting, initialization, validation, module tests, and the foundation composition test all pass.

The composition test is the primary evidence for the phase exit criterion: **modules composable**.
