# AzureForge Product Brief

## Purpose

AzureForge is an internal developer platform (IDP) for provisioning production-oriented Azure services through a small, opinionated service specification.

The platform reduces repeated infrastructure work for application teams by providing an approved golden path for common Azure service patterns. Instead of requiring every team to independently design resource groups, identities, monitoring, CI/CD, tagging, messaging, data services, and security controls, AzureForge converts developer intent into deterministic infrastructure configuration.

AzureForge is designed as a control plane for desired state. It does not directly hold broad subscription-level provisioning permissions. Privileged Terraform operations are executed by reviewed GitHub workflows using federated identity.

## Problem

Application teams repeatedly solve the same Azure infrastructure problems:

- resource naming and resource-group layout;
- identity and RBAC;
- monitoring and diagnostics;
- database and messaging provisioning;
- CI/CD configuration;
- mandatory tags;
- security defaults;
- cost controls;
- infrastructure documentation.

When each team implements these concerns independently, the organization accumulates inconsistent infrastructure, duplicated effort, configuration drift, security exceptions, and operational overhead.

AzureForge standardizes this work while retaining a small set of explicit developer choices.

## Internal Customers

### Primary Customer

The primary customer is an application development team building and operating Azure-hosted services.

A typical customer:

- owns one or more APIs or background workers;
- primarily develops application code rather than Azure platform infrastructure;
- needs a repeatable way to create a compliant development environment;
- should not need deep expertise in Terraform, Entra ID, Azure Policy, GitHub OIDC, or Azure Monitor;
- remains responsible for the application and service-specific operational behavior.

### Platform Owner

The platform engineering team owns AzureForge.

The platform team is responsible for:

- maintaining the service specification contract;
- maintaining approved infrastructure modules;
- maintaining platform guardrails;
- maintaining the provisioning workflow;
- maintaining standard observability and security defaults;
- documenting platform capabilities;
- evolving the golden path without requiring application teams to redesign infrastructure.

## Value Proposition

AzureForge lets an application team describe what it needs rather than how every Azure resource should be implemented.

A developer expresses intent such as:

- service name and owner;
- runtime;
- compute type;
- required data capabilities;
- required messaging capabilities;
- ingress requirements;
- observability level;
- expected cost envelope.

AzureForge translates that intent into approved, reviewable, deterministic Terraform desired state.

## Initial Golden Path

The initial golden path targets a .NET service deployed to Azure Container Apps.

The baseline includes:

- Azure resource group;
- mandatory tags;
- Azure Container Apps compute;
- managed identity;
- least-privilege RBAC;
- Key Vault references where secrets are required;
- Log Analytics;
- Application Insights;
- standard diagnostic settings;
- GitHub Actions workflow;
- Terraform-based infrastructure;
- pull-request review before privileged provisioning;
- environment-specific configuration;
- README/runbook skeleton.

Optional approved capabilities include:

- Azure Database for PostgreSQL;
- Azure Service Bus;
- Azure Storage.

The initial environment focus is `dev`.

## Supported Service Types

The first supported workload patterns are:

1. HTTP API hosted on Azure Container Apps.
2. Background worker hosted on Azure Container Apps.

AKS is not part of the primary P0 golden path. An AKS namespace template may be introduced later as an optional extension without changing the core AzureForge provisioning model.

## Developer-Controlled Choices

Developers may select or provide:

- service name;
- owning team;
- service criticality;
- supported runtime and version;
- approved compute target;
- scaling values within allowed limits;
- optional PostgreSQL capability;
- optional Service Bus queues/topics;
- optional Storage capability;
- whether public ingress is required, subject to policy;
- standard observability profile;
- development cost budget.

These choices are intentionally constrained to options represented in the approved platform catalog.

## Platform-Controlled Decisions

AzureForge owns or constrains:

- resource naming conventions;
- mandatory tagging;
- approved Azure regions;
- approved Azure SKUs;
- workload identity mechanism;
- Terraform module composition;
- remote state strategy;
- CI/CD authentication mechanism;
- diagnostic settings;
- monitoring baseline;
- required security controls;
- infrastructure repository layout;
- policy checks;
- production review requirements.

## Security Model

AzureForge follows a pull-request-driven provisioning model.

The AzureForge CLI or control API:

1. accepts a service specification;
2. validates it against the platform catalog and guardrails;
3. generates deterministic Terraform configuration;
4. creates a pull request or provisioning artifact.

The AzureForge API is not granted unrestricted `Owner` or `Contributor` permissions over Azure subscriptions.

Privileged Terraform operations are performed by GitHub Actions using Azure workload identity federation. This separates the developer-facing control plane from the privileged infrastructure execution boundary.

## Self-Service Boundary

AzureForge provides self-service for approved service patterns.

Self-service does not mean unrestricted Azure resource creation. Requests outside the supported catalog require either:

- a change to the platform catalog;
- an explicit platform engineering review;
- or an independently managed infrastructure path outside AzureForge.

## Non-Goals

AzureForge is not initially intended to be:

- a replacement for the Azure Portal;
- a generic Terraform execution service;
- a system for arbitrary Azure resource provisioning;
- a full developer portal such as Backstage;
- a Kubernetes platform;
- a secrets-management system;
- a general-purpose workflow engine;
- a mechanism for giving application teams subscription-wide Azure permissions;
- a system for bypassing infrastructure review or policy controls.

## Ownership Model

The platform team owns AzureForge and its golden-path implementation.

Application teams own:

- application source code;
- application behavior;
- service-specific configuration;
- application-level SLOs;
- service-specific operational response.

The platform team owns the common infrastructure contract and baseline operational controls.

## Success Criteria

P0 is successful when AzureForge has an unambiguous internal customer and platform boundary.

The platform should make it possible for a developer to describe a supported Azure service using a small specification and receive deterministic, reviewable infrastructure without needing to understand the implementation details of every underlying Azure resource.

Longer-term platform success can be measured using:

- provisioning workflow success rate;
- median provisioning time;
- percentage of services using the golden path;
- policy compliance rate;
- drift rate;
- onboarding time for a new service;
- number of infrastructure exceptions requiring platform-team intervention.
