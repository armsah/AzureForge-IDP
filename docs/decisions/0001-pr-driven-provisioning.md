# ADR-0001: Use Pull-Request-Driven Infrastructure Provisioning

- Status: Accepted
- Date: 2026-08-29

## Context

AzureForge requires a way to provision Azure infrastructure requested through a developer-facing CLI or API.

One option is to grant the AzureForge API broad Azure subscription permissions and allow it to execute Terraform directly.

That approach creates a large authorization boundary around an internet- or network-accessible application service. A defect or compromise in the control API could potentially expose the same privileges used for infrastructure provisioning.

AzureForge also needs infrastructure changes to be reviewable and suitable for policy validation.

## Decision

AzureForge will use a pull-request-driven provisioning model.

The CLI or control API will:

1. validate the requested service specification;
2. generate deterministic desired state;
3. create a GitHub pull request or equivalent provisioning artifact.

A GitHub Actions workflow will perform Terraform operations after the required review and policy checks.

GitHub Actions will authenticate to Azure using Microsoft Entra workload identity federation rather than a stored Azure client secret.

The AzureForge API will not require broad `Owner` or `Contributor` access to Azure subscriptions.

## Consequences

### Positive

- privileged Azure permissions are separated from the developer-facing API;
- infrastructure changes are reviewable;
- Terraform plans can be inspected before apply;
- policy checks can run before privileged execution;
- Git history provides an audit trail;
- GitHub OIDC removes long-lived Azure credentials from CI;
- branch protection and protected environments can provide additional production controls.

### Negative

- provisioning is not instantaneous;
- GitHub becomes part of the platform's critical provisioning path;
- pull-request and workflow lifecycle state must be surfaced to users;
- repository conventions and generated-file ownership must be managed carefully.

## Alternatives Considered

### Direct Terraform execution from the AzureForge API

Rejected for the initial design because it would require significantly more privileged API identity and a larger security boundary.

### Application teams run Terraform manually

Rejected because it does not provide a consistent self-service platform experience and makes policy enforcement and workflow standardization harder.

## Follow-Up

Implementation is introduced across:

- P3 — GitHub OIDC bootstrap;
- P4 — deterministic desired-state generation;
- P5 — pull-request-driven provisioning workflow;
- P9 — policy checks;
- P10 — scheduled drift detection.
