# AzureForge Terraform Modules

P2 introduces the first reusable Terraform building blocks for AzureForge.

| Module | Responsibility |
| --- | --- |
| `resource-group` | Resource group plus approved-region and mandatory-tag validation. |
| `identity` | User-assigned managed identity for secretless workload authentication. |
| `monitoring` | Log Analytics and workspace-based Application Insights baseline. |

Later phases add workload-specific modules rather than placeholders:
- `container-app` — P6
- `service-bus` — P7
- `postgres` — P7

P2 targets Terraform >= 1.7.0 and AzureRM >= 5.2.0, < 6.0.0.
