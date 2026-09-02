# P6 - Container Apps Golden Path

P6 converts reviewed AzureForge desired state into a deployable Azure Container Apps workload through Terraform and secretless GitHub OIDC authentication.

## Goal

The P6 goal is:

> One reviewed service specification creates the Azure Container Apps golden path.

P6 is the first AzureForge phase that consumes the human-reviewed provisioning artifact produced by P5 and applies application infrastructure to Azure.

## Provisioning Flow

```text
AzureForge service specification
        |
        v
P4 deterministic desired state
        |
        v
P5 provisioning pull request
        |
        v
HUMAN REVIEW + MERGE
        |
        v
provisioning/services/<service>/<environment>.tfvars.json
        |
        v
P6 privileged GitHub workflow
        |
        v
GitHub OIDC
        |
        v
Terraform remote state
        |
        v
Azure Container Apps golden path
```

P6 does not deploy directly from an arbitrary service YAML file. The privileged workflow consumes the reviewed `.tfvars.json` artifact committed through the P5 review boundary.

## Terraform Composition

The initial P6 composition root is:

```text
infra/environments/dev
```

It composes the following reusable modules:

```text
resource-group
identity
monitoring
container-app
```

For the `pricing-api` example, Terraform provisions:

1. Azure Resource Group
2. user-assigned managed identity
3. Log Analytics workspace
4. workspace-based Application Insights
5. Azure Container Apps environment
6. Azure Container App

PostgreSQL and Service Bus requests remain represented in desired state but their provisioning is deferred to P7.

Standard alert implementation remains deferred to P8.

## Container App Module

The reusable module is:

```text
infra/modules/container-app
```

It manages:

- the Container Apps environment;
- the Container App;
- user-assigned managed identity attachment;
- ingress configuration;
- target port;
- minimum and maximum replicas;
- container CPU and memory;
- resource tags.

The initial workload image is:

```text
mcr.microsoft.com/k8se/quickstart:latest
```

Using a public bootstrap image keeps P6 focused on the Container Apps provisioning path without introducing Azure Container Registry build-and-push concerns.

## Ingress

Ingress is driven by AzureForge desired state.

For the initial `pricing-api` specification:

```json
"public_ingress": false
```

Terraform therefore configures:

```text
external_enabled = false
```

The service is not intentionally exposed to the public Internet by P6.

## Workload Identity

The Container App receives the user-assigned managed identity created for the service.

The initial `pricing-api` desired state requires:

```json
"workload_identity": true
```

This establishes the identity foundation for later secretless access to Azure dependencies.

## Remote Terraform State

P6 uses the Azure Blob Storage remote-state infrastructure established in P3.

The Terraform backend authenticates through Microsoft Entra ID rather than storage account keys.

In GitHub Actions, authentication is performed using GitHub OIDC and the federated managed identity established in P3.

State is isolated per service and environment. For the initial `pricing-api` deployment, the state key is:

```text
p6-pricing-api-dev.tfstate
```

## GitHub OIDC

The privileged P6 workflow requests:

```yaml
permissions:
  contents: read
  id-token: write
```

The workflow authenticates to Azure through the federated user-assigned managed identity established in P3.

No Azure client secret is stored in GitHub.

Terraform receives authentication through:

```text
ARM_USE_OIDC
ARM_USE_AZUREAD
ARM_CLIENT_ID
ARM_TENANT_ID
ARM_SUBSCRIPTION_ID
```

## Azure RBAC

The GitHub Terraform identity requires two distinct capabilities:

1. access to Terraform remote state;
2. permission to provision P6 Azure resources.

For the portfolio P6 environment, the identity has:

```text
Storage Blob Data Contributor
```

on the Terraform state container, and:

```text
Contributor
```

at subscription scope for workload provisioning.

`Contributor` allows Terraform to create and manage Azure workload resources but does not grant permission to create or modify Azure RBAC role assignments.

For a production platform, this scope should be reduced through a dedicated landing-zone scope and/or a custom Terraform provisioning role.

The developer-facing P5 workflow does not receive these Azure permissions.

## Privilege Boundary

AzureForge deliberately separates desired-state generation from privileged execution.

```text
P5
repository write + pull-request permissions
NO Azure authentication
NO Terraform apply

P6
repository read
GitHub OIDC
remote Terraform state
privileged Terraform execution
```

A human-reviewed and merged provisioning artifact is therefore required before the P6 workflow can deploy it from the main branch.

## Terraform Validation

The P6 Terraform configuration is validated independently at both levels:

```text
infra/modules/container-app
infra/environments/dev
```

The `pricing-api` desired state produces a Terraform plan containing six Azure resources:

```text
1 Resource Group
1 User Assigned Managed Identity
1 Log Analytics Workspace
1 Application Insights instance
1 Container Apps Environment
1 Container App
```

Expected plan summary:

```text
Plan: 6 to add, 0 to change, 0 to destroy.
```

## GitHub Workflow

The privileged provisioning workflow is:

```text
.github/workflows/p6-provision-container-app.yml
```

It:

1. accepts a reviewed provisioning artifact;
2. restricts input to the `provisioning/services/` hierarchy;
3. verifies that the artifact exists;
4. validates the service name, environment, compute type, and resource group;
5. authenticates to Azure through GitHub OIDC;
6. initializes the Azure Blob Storage Terraform backend;
7. validates the Terraform composition root;
8. creates a saved Terraform plan;
9. applies the saved plan;
10. verifies the resulting Azure Container App.

## Example Service

The initial P6 example is:

```text
pricing-api
```

with:

```text
environment: dev
location: westeurope
compute: container-apps
public ingress: false
workload identity: true
minimum replicas: 0
maximum replicas: 5
```

The generated Azure resource names include:

```text
Resource Group:
rg-pricing-api-dev-weu

Managed Identity:
id-pricing-api-dev

Log Analytics:
log-pricing-api-dev-weu

Application Insights:
appi-pricing-api-dev

Container Apps Environment:
cae-pricing-api-dev-weu

Container App:
pricing-api
```

## Phase Boundary

P6 provisions the Container Apps golden path.

P6 does not yet provision:

- PostgreSQL;
- Service Bus;
- standard alert rules;
- Azure Policy;
- drift detection;
- cost budgets;
- AKS workloads.

Those capabilities remain assigned to later AzureForge phases.

## Evidence

P6 evidence consists of:

- the reusable `container-app` Terraform module;
- the `dev` Terraform composition root;
- successful Terraform validation;
- a six-resource Terraform plan for `pricing-api`;
- the privileged GitHub OIDC provisioning workflow;
- Azure Blob Storage remote Terraform state;
- a successful GitHub Actions provisioning run;
- the resulting Azure Container App and supporting Azure resources.

## Exit Criterion

P6 exit criterion:

> One command/spec creates service.

P6 is complete when the reviewed `pricing-api` desired state is successfully consumed by the privileged GitHub workflow and the Container Apps golden path is provisioned and verified in Azure.
