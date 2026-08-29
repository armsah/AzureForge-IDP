# AzureForge

AzureForge is an opinionated internal developer platform for provisioning production-oriented Azure services through declarative service specifications.

The platform provides a governed golden path for application teams while keeping privileged infrastructure changes reviewable through GitHub pull requests and applying Terraform with federated Azure identity.

## Status

Current implementation phase: **P0 — Platform definition, golden path, and guardrails**.

## P0 Documentation

- [`docs/product-brief.md`](docs/product-brief.md) — internal customers, value proposition, platform boundary, and success criteria.
- [`docs/golden-path.md`](docs/golden-path.md) — initial supported developer experience and service pattern.
- [`docs/guardrails.md`](docs/guardrails.md) — mandatory controls, defaults, and restricted choices.
- [`docs/architecture/overview.md`](docs/architecture/overview.md) — control-plane and provisioning architecture.
- [`docs/decisions/0001-pr-driven-provisioning.md`](docs/decisions/0001-pr-driven-provisioning.md) — security decision for PR-driven provisioning.
- [`examples/pricing-api.yaml`](examples/pricing-api.yaml) — representative future AzureForge service specification.

## Roadmap

- [x] P0 — Define platform customers, golden path, and guardrails
- [ ] P1 — Build C# CLI that validates YAML service specs
- [ ] P2 — Create Terraform module library
- [ ] P3 — Bootstrap remote state and GitHub OIDC
- [ ] P4 — Build service-spec to Terraform variable generation
- [ ] P5 — Generate pull request or artifact for provisioning
- [ ] P6 — Provision Container Apps golden path
- [ ] P7 — Add optional Service Bus/PostgreSQL modules
- [ ] P8 — Add monitoring and standard alerts
- [ ] P9 — Add Azure Policy/tag/region checks
- [ ] P10 — Add drift detection and scheduled plan
- [ ] P11 — Add cost controls and environment TTL
- [ ] P12 — Add optional AKS namespace template
- [ ] P13 — Polish documentation and onboarding demo
