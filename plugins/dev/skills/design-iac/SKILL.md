---
name: dev:design-iac
description: >
  Infrastructure as Code Design grounded in "Infrastructure as Code" (Kief Morris,
  O'Reilly 2021) and NTNU IIKG3005 (the only dedicated academic IaC course worldwide).
  Covers IaC principles (Immutable Infrastructure, Idempotency, Single Source of Truth),
  module design, state management, drift detection, GitOps workflow, and testing.
  Use this skill whenever the user wants to design or improve Infrastructure as Code,
  set up Terraform/Pulumi/CDK, or establish a GitOps workflow.
  Trigger: "set up Infrastructure as Code", "build Terraform", "IaC Design",
  "module structure for Terraform", "State Management", "set up GitOps",
  "Drift Detection", "test IaC with Terratest", "version cloud infrastructure",
  "Immutable Infrastructure", "we have Config Drift", "IaC Best Practices".
  Covers: IaC principles, module design, state management (remote backend, locking),
  drift detection, GitOps workflow, testing (Terratest, static analysis).
  Note: Norwegian/German-language sources are valid inputs — Claude processes them regardless of language.
---

# Infrastructure as Code Design

Designs an IaC architecture from module design to GitOps workflow — grounded in
Kief Morris "Infrastructure as Code" and NTNU IIKG3005.

---

## Core Philosophy (Kief Morris)

> "Treating infrastructure as code means applying software engineering practices —
> version control, testing, code review — to infrastructure definitions."
> — Kief Morris, Infrastructure as Code (2021)

Immutable Infrastructure and Single Source of Truth eliminate Config Drift.
GitOps makes every infrastructure state reproducible, reviewable, and rollbackable.

---

## Step 0 — Clarify Context

**Questions:**
- Cloud provider: AWS / GCP / Azure / Multi-Cloud / On-Prem?
- IaC tool: Terraform / OpenTofu / Pulumi / CDK / Ansible?
- Team size and maturity: IaC experience present?
- Existing setup: manually provisioned / partially IaC / no IaC?
- CI/CD: GitHub Actions / GitLab CI / Jenkins / Terraform Cloud?
- Compliance requirements: PCI-DSS, SOC2, ISO 27001?

---

## Step 1 — Anchor IaC Principles

(→ `references/iac-patterns.md`)

**1a — Check Immutable Infrastructure**

Are servers still being modified manually after provisioning?
→ If yes: Snowflake Anti-Pattern — create a plan for Immutability.

**1b — Define Single Source of Truth**

- Where does the IaC code live? (Git repo structure)
- Are there parallel manual changes? → stop them
- Everything that defines infrastructure state must be in the repo

**1c — Identify Anti-Patterns**

Checklist: Config Drift / Snowflake Server / Copy-Paste IaC / Monolithic Stack / local state in prod

---

## Step 2 — Module Design

**2a — Plan Stack Layering**

```text
foundation/   # VPC, DNS, IAM base, Security Groups
platform/     # Kubernetes, databases, queues, caches
services/     # Application infrastructure (per service or team)
```

Each layer = its own state, its own apply cycle.

**2b — Draw Module Boundaries**

Per module: Single Responsibility (one clearly scoped concern).
Define inputs/outputs explicitly — no hidden dependencies.

**2c — Module Versioning**

Reference modules via Git tag:
```text
source = "git::https://github.com/org/infra-modules//network?ref=v2.3.0"
```
No `?ref=main` in prod environments.

---

## Step 3 — State Management

(→ `references/state-management.md`)

**3a — Choose Remote Backend**

AWS → S3 + DynamoDB. GCP → GCS. Azure → Blob Storage. Multi-Cloud → Terraform Cloud.
Never local state in staging or prod.

**3b — State Security**

- Enable encryption at rest + in transit
- Least Privilege: only CI/CD pipeline + admins
- Enable state locking (prevents parallel applies)
- Versioning in backend (S3 Versioning, GCS Versioning)

**3c — Workspace Strategy**

Recommendation: Separate state paths per environment:
```text
s3://infra-state/envs/dev/terraform.tfstate
s3://infra-state/envs/staging/terraform.tfstate
s3://infra-state/envs/prod/terraform.tfstate
```

---

## Step 4 — Drift Detection and Remediation

**4a — Detect Drift**

`terraform plan` as a scheduled job (daily) — alert when output != "No changes".
Tools: Driftctl, Terraform Cloud Drift Detection, AWS Config.

**4b — Classify Drift** (→ `references/iac-patterns.md`)

Intentional drift (external change intended) vs. unintentional drift (manual intervention).

**4c — Process Fix**

Root cause: who made manual changes and why?
Solution: Break-glass process for emergencies (allowed, but documented and tracked).

---

## Step 5 — GitOps Workflow

**5a — Branch Strategy**

```text
feature/* → main: PR with plan output as comment
main → staging: automatic (after PR merge)
staging → prod: manual approval gate
```

**5b — Plan Output in PR**

CI comments `terraform plan` diff in every PR.
Reviewers see exactly what changes — no blind merges.

**5c — Apply Strategy**

- Staging: automatic after merge
- Prod: manual approval (min. 1 reviewer) + automatic apply
- Rollback: re-apply previous commit (not `terraform destroy`)

---

## Step 6 — Testing

(→ `references/iac-patterns.md` for drift tests)

**6a — Static Analysis**

- `terraform validate` — syntax errors
- `terraform fmt --check` — formatting
- `tflint` — best-practice violations
- `checkov` / `tfsec` — security misconfigurations

**6b — Unit Tests (Terratest)**

```go
// Example: Terratest checks if S3 bucket was created
terraform.InitAndApply(t, terraformOptions)
bucketID := terraform.Output(t, terraformOptions, "bucket_id")
aws.AssertS3BucketExists(t, "us-east-1", bucketID)
```

**6c — Contract Tests**

Validate outputs of a module against the expected structure.
Ensures downstream modules don't break.

---

## Output — `iac-design.md`

```markdown
# IaC Design — [Project Name]

## Stack Layering
| Stack | Purpose | State Path |
|---|---|---|
| foundation | VPC, IAM | s3://state/foundation/ |
| platform | K8s, DB | s3://state/platform/ |
| services | App infra | s3://state/services/ |

## Modules
| Module | Inputs | Outputs | Version |
|---|---|---|---|
| network | cidr, region | vpc_id, subnet_ids | v1.2.0 |

## State Backend
- Provider: [S3+DynamoDB / GCS / TF Cloud]
- Encryption: yes
- Locking: yes
- Workspace strategy: [separate paths / workspaces]

## GitOps Workflow
- Plan in PR: yes
- Apply Staging: automatic after merge
- Apply Prod: manual approval

## Testing
- Static: tflint + checkov
- Unit: Terratest
- Drift Detection: [daily / Terraform Cloud]
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → Kief Morris chapter + NTNU IIKG3005
- `references/iac-patterns.md` — Core patterns vs. anti-patterns, module design, drift classification
- `references/state-management.md` — Remote backends, security, workspace strategy, import workflow
