# P5 - Provisioning Pull Request

P5 establishes the human review boundary between AzureForge desired-state generation and later privileged infrastructure provisioning.

## Goal

P5 turns validated, deterministic desired state from P4 into a reviewable GitHub pull request.

The workflow is:

```text
AzureForge service specification
        |
        v
P1 validation
        |
        v
P4 deterministic desired state
        |
        v
P5 provisioning branch
        |
        v
provisioning/services/<service>/<environment>.tfvars.json
        |
        v
GitHub pull request
        |
        v
HUMAN REVIEW
```

P5 does not authenticate to Azure and does not provision infrastructure.

## Workflow

The GitHub Actions workflow is:

```text
.github/workflows/p5-provisioning-pr.yml
```

It is manually triggered with `workflow_dispatch`.

The workflow accepts a repository-relative service specification path. The initial P5 implementation restricts input to YAML specifications under:

```text
examples/
```

The default specification is:

```text
examples/pricing-api.yaml
```

## Validation and Generation

Before creating a provisioning change, the workflow:

1. verifies that the requested specification path is allowed and exists;
2. installs .NET 10;
3. builds the AzureForge CLI;
4. runs the .NET test suite;
5. invokes the P4 `generate` command;
6. reads the generated service name and environment;
7. writes deterministic desired state into the provisioning hierarchy.

For `pricing-api`, the generated artifact is:

```text
provisioning/services/pricing-api/dev.tfvars.json
```

## Deterministic Provisioning Identity

The desired-state content determines both the artifact path and provisioning branch.

For `pricing-api` in `dev`:

```text
Artifact:
provisioning/services/pricing-api/dev.tfvars.json

Branch:
azureforge/provision/pricing-api-dev

Pull request title:
provision: pricing-api dev
```

Re-running the workflow for the same service and environment updates the same provisioning branch and open pull request rather than intentionally creating duplicate provisioning requests.

## Human Review Boundary

The generated pull request is the P5 control boundary.

The pull request body records:

- the service name;
- the environment;
- the source service specification;
- the generated desired-state artifact;
- an explicit statement that no infrastructure has been provisioned.

A human must review and merge the provisioning change before later automation may consume it.

P5 does not approve or merge its own pull requests.

## Security Boundary

The P5 workflow requests only repository permissions required to create the provisioning branch and pull request:

```yaml
permissions:
  contents: write
  pull-requests: write
```

P5 does not request:

```text
id-token: write
```

It does not use:

```text
azure/login
ARM_*
AZURE_*
terraform init
terraform plan
terraform apply
```

The workflow therefore has no Azure authentication or Azure provisioning responsibility.

This deliberately separates the developer-facing desired-state workflow from the privileged infrastructure execution path.

## Relationship to P3

P3 established secretless GitHub OIDC authentication for privileged Terraform workflows.

P5 deliberately does not consume that identity.

The separation is:

```text
P5
service intent -> desired state -> pull request -> human review

Later provisioning phase
reviewed desired state -> GitHub OIDC -> Terraform -> Azure
```

This prevents the PR-generation workflow from acquiring infrastructure privileges that it does not require.

## Repository Setting

GitHub repositories can restrict whether GitHub Actions may create pull requests.

The repository must allow GitHub Actions to create pull requests for the P5 workflow to complete successfully.

The workflow itself does not approve or merge pull requests.

## Phase Boundary

P5 creates a reviewable provisioning request only.

It does not:

- authenticate to Azure;
- initialize Terraform;
- generate a Terraform plan;
- apply Terraform;
- create Azure resources;
- approve pull requests;
- merge pull requests.

Container Apps, PostgreSQL, Service Bus, monitoring, policy, and other infrastructure responsibilities remain in later phases.

## Evidence

P5 evidence consists of:

- the checked-in GitHub Actions workflow;
- a successful manual workflow run;
- a generated provisioning branch;
- a generated `.tfvars.json` desired-state artifact;
- an open pull request requiring human review.

## Exit Criterion

P5 exit criterion:

> Human review boundary.

This is demonstrated when AzureForge converts a valid service specification into a deterministic provisioning pull request without authenticating to Azure or applying infrastructure.
