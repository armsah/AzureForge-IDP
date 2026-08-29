# AzureForge Architecture Overview

## Context

AzureForge is an internal developer platform control plane for producing approved Azure infrastructure desired state.

Its core architectural decision is to separate:

1. the developer-facing request path; and
2. the privileged infrastructure execution path.

The AzureForge API or CLI validates and generates desired state. It does not receive broad Azure subscription privileges.

## High-Level Architecture

```text
+----------------------+
| Application Developer|
+----------+-----------+
           |
           | YAML / CLI request
           v
+----------------------+
| AzureForge CLI / API |
+----------+-----------+
           |
           +----------------------+
           |                      |
           v                      v
+------------------+     +-------------------+
| Service Catalog  |     | Platform State    |
| + Guardrails     |     | PostgreSQL        |
+--------+---------+     +-------------------+
         |
         | approved service model
         v
+----------------------+
| Desired-State        |
| Generator            |
+----------+-----------+
           |
           | Terraform configuration
           v
+----------------------+
| GitHub Pull Request  |
+----------+-----------+
           |
           | review + policy checks
           v
+----------------------+
| GitHub Actions       |
+----------+-----------+
           |
           | OIDC federation
           v
+----------------------+
| Microsoft Entra ID   |
+----------+-----------+
           |
           | short-lived Azure token
           v
+----------------------+
| Terraform            |
+----------+-----------+
           |
           v
+----------------------+
| Azure Resources      |
+----------------------+
```

## Components

### CLI

A C# CLI based on `System.CommandLine` accepts service specifications, validates them, and later generates provisioning artifacts.

### Control API

An ASP.NET Core API exposes equivalent platform operations for programmatic use.

The API is a control-plane interface, not a privileged subscription provisioning identity.

### Catalog

The catalog defines approved:

- runtimes;
- runtime versions;
- compute types;
- Azure regions;
- service capabilities;
- SKU profiles;
- observability profiles;
- scaling constraints.

### Platform State

A small PostgreSQL database records platform metadata such as:

- requested services;
- owners;
- environments;
- provisioning status;
- timestamps;
- workflow identifiers;
- platform-generated metadata.

The Terraform state remains separate from AzureForge platform metadata.

### Desired-State Generator

The generator converts a validated service specification into deterministic Terraform environment configuration.

The generator composes approved modules instead of generating arbitrary Terraform resource definitions.

### GitHub

GitHub provides:

- source control;
- pull requests;
- human review;
- policy-check workflows;
- provisioning workflows;
- scheduled drift workflows;
- protected environments.

### Terraform

Terraform modules provide reusable implementations for:

- resource groups;
- identity;
- monitoring;
- Container Apps;
- Service Bus;
- PostgreSQL;
- Storage;
- private endpoints;
- future supported capabilities.

### Microsoft Entra ID

GitHub Actions authenticates to Azure using workload identity federation.

No long-lived Azure client secret is required for the standard CI/CD path.

### Azure Policy

Azure Policy provides authoritative Azure-side enforcement for selected organizational controls such as:

- allowed regions;
- required tags;
- diagnostic requirements;
- prohibited resource configurations.

## Authorization Boundary

The most important security boundary is between desired-state generation and privileged Terraform execution.

```text
AzureForge API
     |
     | no broad subscription Contributor role
     v
Generated desired state
     |
     v
Reviewed pull request
     |
     v
GitHub Actions identity
     |
     | federated short-lived credentials
     v
Azure permissions
```

This design improves auditability and reduces the blast radius of the developer-facing control plane.

## Desired-State Principle

AzureForge records developer intent and generates infrastructure configuration.

The generated Terraform configuration is source-controlled so that:

- changes can be reviewed;
- plans can be inspected;
- drift can be detected;
- rollback history exists;
- infrastructure ownership is visible;
- privileged automation has a clear input boundary.

## Initial Deployment Scope

The first implementation focuses on:

- development environments;
- .NET workloads;
- Azure Container Apps;
- managed identity;
- Azure Monitor;
- optional PostgreSQL;
- optional Service Bus.

Additional capabilities are added only through approved platform modules and catalog entries.

## Future Evolution

Later phases extend the architecture with:

- richer platform state;
- scheduled Terraform plan/drift reporting;
- cost budgets;
- environment TTL;
- production protection;
- optional AKS namespace provisioning;
- service catalog views;
- platform SLOs.
