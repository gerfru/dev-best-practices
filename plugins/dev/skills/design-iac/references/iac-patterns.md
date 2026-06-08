# IaC Patterns and Anti-Patterns

Source: Kief Morris "Infrastructure as Code", O'Reilly 2021.

## Core Patterns

| Pattern | Description | Anti-Pattern |
|---|---|---|
| **Immutable Infrastructure** | Never change infra resources — always re-provision | Mutable: patching servers via SSH (Config Drift) |
| **Dynamic Infrastructure** | Create/delete resources via API | Static: manual setup, Snowflake Server |
| **Single Source of Truth** | One repo defines desired state — no manual intervention | IaC + parallel manual changes |
| **Idempotent Apply** | Multiple applies → always the same state | Scripts with side effects on re-run |
| **Small Focused Stacks** | One stack per concern (network / compute / app) | Monolithic stack (everything in one) |
| **Composable Modules** | Modules = reusable building blocks with clear inputs/outputs | Copy-Paste IaC |
| **GitOps** | Git = Single Source of Truth, changes only via PR | Direct CLI changes in prod |

**Snowflake Anti-Pattern:** Every server became unique through manual changes — not reproducible, not scalable, not deletable without fear.

---

## Module Design Principles

| Principle | Description |
|---|---|
| Single Responsibility | One module = one clearly scoped concern |
| Stable Interfaces | Input variables and outputs change rarely |
| No Hidden Dependencies | Everything a module needs comes as input |
| Versioning | Version modules via Git tag (no `?ref=main` in prod) |
| Minimal Outputs | Only what downstream modules actually need |

---

## Stack Layering (recommended)

```text
foundation/     # VPC, DNS, Security Groups, IAM base
platform/       # Kubernetes, databases, message queues
services/       # Application infrastructure (per service/team)
```

Each layer has its own state. Services layer references platform outputs via remote state read.

---

## Drift Classification

| Type | Cause | Action |
|---|---|---|
| Config Drift | Manual change after apply | `terraform plan` shows diff, then apply |
| Version Drift | Module version in one env is outdated | Update + apply in all envs |
| Secret Drift | Secrets changed directly, not via IaC | Secrets in secrets manager, reference in IaC |
| Resource Drift | Resource manually deleted | Import or re-provision |
