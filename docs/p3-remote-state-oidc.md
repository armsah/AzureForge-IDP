# P3 — Remote Terraform State and GitHub OIDC

## Goal

P3 establishes AzureForge's privileged CI authentication boundary and remote Terraform state foundation.

The phase creates:

- an Azure resource group dedicated to bootstrap resources;
- an Azure Storage account and private blob container for Terraform state;
- blob versioning and seven-day delete retention;
- a user-assigned managed identity for GitHub Actions;
- a federated identity credential trusting only the `main` branch of `armsah/AzureForge-IDP`;
- a container-scoped `Storage Blob Data Contributor` role assignment;
- a GitHub Actions smoke workflow that proves OIDC login and AzureRM backend initialization without secrets.

## Security model

AzureForge does not store an Azure client secret, storage account key, or SAS token in GitHub.

GitHub Actions requests an OIDC token from GitHub's token service. Microsoft Entra ID validates the federated credential subject and exchanges that token for a short-lived Azure access token.

The P3 identity is intentionally limited to Terraform state access. Subscription-level deployment permissions are not granted in P3; later provisioning phases must add only the permissions they require.

## Bootstrap sequence

The state store cannot use itself before it exists. Therefore `infra/bootstrap/platform` begins with local Terraform state and creates the remote-state infrastructure and GitHub identity.

After creation, later Terraform roots use the AzureRM backend with Microsoft Entra authentication. The `remote-state-smoke` root exists only to prove backend access from GitHub OIDC.

The local bootstrap state file must never be committed. Retain it securely until the bootstrap root is migrated or deliberately restructured in a later phase.

## Required local prerequisites

- Terraform >= 1.7
- Azure CLI authenticated with `az login`
- access to create resource groups, storage, managed identities, federated identity credentials, and role assignments in the target subscription

## GitHub repository variables

Configure these as GitHub Actions repository variables, not secrets:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TF_STATE_STORAGE_ACCOUNT`

These values identify Azure resources; they are not passwords.

## P3 verification

Local validation:

```powershell
.\scripts\test-p3-bootstrap.ps1
```

Azure bootstrap:

```powershell
cd .\infra\bootstrap\platform
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
# Edit terraform.tfvars before continuing.
terraform init
terraform plan
terraform apply
terraform output
```

Then configure the four GitHub repository variables using the Terraform outputs plus the tenant/subscription IDs.

Run the `P3 OIDC smoke test` workflow manually in GitHub Actions.

P3 is complete when the workflow's Azure login succeeds and `terraform init` initializes the Azure Blob backend using OIDC with no long-lived Azure credential.
