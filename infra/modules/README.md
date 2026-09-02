# AzureForge Terraform Modules

AzureForge uses reusable Terraform modules as the infrastructure building blocks behind its golden paths.

| Module           | Responsibility                                                                                                                 | Phase |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------ | ----- |
| `resource-group` | Resource group plus approved-region and mandatory-tag validation.                                                              | P2    |
| `identity`       | User-assigned managed identity for secretless workload authentication.                                                         | P2    |
| `monitoring`     | Log Analytics and workspace-based Application Insights baseline.                                                               | P2    |
| `container-app`  | Azure Container Apps environment and Container App with managed identity, ingress policy, scaling, and workload configuration. | P6    |

Later phases add additional workload-specific modules:

- `service-bus` — P7
- `postgres` — P7

## Container Apps Golden Path

P6 introduces the `container-app` module.

The module provisions:

- an Azure Container Apps environment;
- an Azure Container App;
- a user-assigned managed identity attachment;
- configurable internal or external ingress;
- configurable minimum and maximum replicas;
- a single active revision;
- AzureForge resource tags.

The P6 `dev` composition root combines this module with the existing resource-group, identity, and monitoring modules.

```text
infra/environments/dev
        |
        +-- resource-group
        +-- identity
        +-- monitoring
        +-- container-app
```
