# P1 — CLI Service-Spec Validation

## Goal

P1 turns the P0 service specification into an executable contract.

The AzureForge CLI validates YAML syntax and the initial golden-path rules before any Terraform generation or Azure provisioning occurs.

## Command

```text
azforge validate <spec>
```

During development:

```powershell
dotnet run --project src/AzureForge.Cli -- validate examples/pricing-api.yaml
```

## Validation Layers

P1 performs two validation layers:

1. **Parsing** — YAML must deserialize into the typed AzureForge service model.
2. **Domain/catalog validation** — the resulting service model must conform to the current P1 golden-path constraints.

P1 does not provision resources and does not generate Terraform.

## P1 Catalog Constraints

The initial validator enforces:

- service name uses a lowercase DNS-like naming form;
- owner is required;
- criticality is `low`, `medium`, or `high`;
- runtime is `dotnet`;
- runtime version is `10`;
- compute is `container-apps`;
- `minReplicas >= 0`;
- `maxReplicas` is between 1 and 10;
- `minReplicas <= maxReplicas`;
- Service Bus queue names cannot be empty or duplicated;
- workload identity is mandatory;
- Application Insights is mandatory;
- alert profile is `standard`;
- monthly development budget is greater than zero.

These constraints represent the initial catalog, not permanent Azure-wide limitations. Later phases can move catalog values into configuration while retaining the same validation boundary.

## Exit Codes

| Code | Meaning |
| --- | --- |
| 0 | Valid service specification |
| 2 | Invalid CLI arguments |
| 3 | File not found |
| 4 | Invalid YAML or service specification |

## Exit Criterion

P1 is complete when:

- a valid `pricing-api.yaml` returns exit code `0`;
- malformed YAML is rejected;
- policy-invalid specifications are rejected with useful field-level errors;
- automated parsing and validator tests pass.
