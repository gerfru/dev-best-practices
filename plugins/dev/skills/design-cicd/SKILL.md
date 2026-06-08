---
name: dev:design-cicd
description: >
  CI/CD Pipeline Design grounded in "Accelerate" (Forsgren/Humble/Kim, IT Revolution 2018)
  and "Continuous Delivery" (Humble/Farley, Addison-Wesley 2010). Covers pipeline architecture,
  deployment strategies (Blue-Green, Canary, Feature Flags), environment design,
  DORA metrics, and Trunk-Based Development.
  Use this skill whenever the user wants to design or improve a CI/CD pipeline,
  deployment process, release strategy, or software delivery workflow.
  Trigger: "set up CI/CD", "deployment strategy", "build a pipeline",
  "Blue-Green Deployment", "Canary Release", "set up Feature Flags",
  "improve DORA metrics", "Trunk-Based Development", "Zero-Downtime Deploy",
  "release strategy", "how do I deploy safely", "set up staging environment",
  "increase deployment frequency", "GitHub Actions pipeline", "rollback strategy".
  Covers: pipeline architecture, deployment strategies, environment design,
  DORA metrics (Deployment Frequency / Lead Time / CFR / MTTR), Trunk-Based Development.
---

# CI/CD Pipeline Design

Designs a deployment pipeline and release strategy — grounded in "Accelerate" and
"Continuous Delivery". Goal: high deployment frequency with low change failure rate
(DORA Elite Performance).

---

## Core Philosophy ("Accelerate")

> "The key to moving faster is to get smaller batch sizes and shorter feedback cycles."
> — Forsgren/Humble/Kim, Accelerate (2018)

Fast deployments and high stability are not mutually exclusive — elite teams achieve
both simultaneously. Trunk-Based Development, automated testing, and deployment automation
are the strongest empirical predictors of high DORA performance.

---

## Step 0 — Clarify Context

**Questions:**
- Team size and current deployment frequency (daily / weekly / monthly)?
- Stack: language, framework, containers (Docker/K8s), cloud provider?
- Current deployment process: manual / semi-automated / fully automated?
- Existing CI/CD tools: GitHub Actions, GitLab CI, Jenkins, CircleCI, ...?
- Deployment target: Kubernetes, VMs, Serverless, PaaS?
- Criticality: is downtime acceptable or is Zero-Downtime required?

→ Estimate DORA baseline (Step 5 refines it).

---

## Step 1 — Pipeline Architecture

**1a — Define Stages**

Standard pipeline (adapt to stack):
```text
Commit → Build → Unit Tests → Integration Tests → Staging Deploy →
Acceptance Tests → Prod Deploy → Smoke Tests
```

Principles:
- Each stage gives fast feedback (fail fast)
- Unit Tests: < 5 min (split up if longer)
- Integration Tests: < 15 min (run in parallel)
- No manual step before Prod (except explicit approval for high-risk)

**1b — Parallelization**

- Unit Tests + Lint + Security Scan → parallel
- Integration Tests after successful build → parallel where possible
- Build cache: cache dependencies (npm ci, pip, Maven) → 60–80% faster

**1c — Artifact Management**

- Build once, deploy everywhere (no re-build per environment)
- Version artifacts with Git SHA or Semantic Version
- Container images: push to registry, promote by tag (don't rebuild)

---

## Step 2 — Test Strategy in the Pipeline

**Gate logic:** Which tests must pass where?

| Stage | Tests | Gate (blocks pipeline?) |
|---|---|---|
| Commit | Unit Tests, Linting, Type Check | Yes |
| Integration | API Tests, DB Tests, Service Tests | Yes |
| Staging | Acceptance Tests, E2E Smoke Tests | Yes |
| Prod | Post-Deploy Smoke Tests | Rollback if red |

Rule of thumb: Unit Tests in the Commit stage, anything requiring external dependencies only after.

---

## Step 3 — Choose a Deployment Strategy

(→ `references/deployment-strategies.md` for full comparison and decision tree)

**Quick decision:**
- Downtime acceptable → Recreate (Non-Prod only)
- Breaking change or uncertain feature → Feature Flag
- Granular rollout feedback needed → Canary
- Fast traffic-switch rollback → Blue-Green
- Standard case with health checks → Rolling Update

**Feature Flag recommendation:** With > 1 deployment/week, always plan for a feature flag system.

---

## Step 4 — Environment Design

**4a — Environment Parity**

Dev = Staging = Prod (same container images, same config structure).
Differences only in values (credentials, URLs), never in structure.

**4b — Number of Environments**

| Team Size | Recommendation |
|---|---|
| Solo / Small | Dev (local) + Prod |
| Medium | Dev + Staging + Prod |
| Large / Enterprise | Dev + Staging + Pre-Prod + Prod (+ Feature Envs optional) |

**4c — Secrets Management**

- Never put secrets in Git or Docker images
- Secrets manager: Vault, AWS Secrets Manager, GitHub Actions Secrets
- Rotation: automated where possible

---

## Step 5 — DORA Baseline and Goals

(→ `references/dora-metrics.md`)

**Measure or estimate current metrics:**
- Deployment Frequency: How often do you deploy to Prod today?
- Lead Time: How long from commit to Prod (typical)?
- CFR: How often does a deployment cause an incident?
- MTTR: How long does it take to recover from a Prod incident?

**Target values:** Next DORA category as a 6-month goal.

**Measures from DORA research (strongest levers):**
1. Trunk-Based Development (Step 6)
2. Test Automation (Step 2)
3. Deployment Automation (Step 1)
4. Monitoring & Observability (→ design-observability)

---

## Step 6 — Trunk-Based Development

(→ `references/dora-metrics.md` for background)

**Branch strategy:**
- Main/Trunk: always deployable (CI must be green)
- Feature branches: maximum 1–2 days lifespan
- No long-lived feature branches (> 3 days = merge pain risk)

**Identify feature flag needs:**
- Which current features require long-lived branches?
- Convert these to feature flags → then short branches become possible

**Merge strategy:**
- Squash merge for feature branches (clean history)
- Conventional Commits for automatic changelog / Semantic Versioning

---

## Output — `cicd-design.md`

```markdown
# CI/CD Design — [Project Name]

## Pipeline Architecture
Commit → Build ([X] min) → Tests ([Y] min) → Staging → Acceptance → Prod

## Deployment Strategy
[Blue-Green / Canary / Feature Flags / Rolling] — Rationale: [...]

## Environments
| Environment | Purpose | Deploy Trigger |
|---|---|---|
| Dev | Feature development | Automatically on push |
| Staging | Pre-Prod validation | Automatically on PR merge |
| Prod | Live | Automatically after staging gate |

## DORA Baseline
| Metric | Current | Goal (6 months) |
|---|---|---|
| Deployment Frequency | [X/week] | [Y/day] |
| Lead Time | [X days] | [Y h] |
| CFR | [X%] | [< 5%] |
| MTTR | [X h] | [< 1h] |

## Trunk-Based Development
- Branch strategy: [...]
- Feature Flags: [which features, which tool]

## Secrets Management
- Tool: [Vault / AWS Secrets Manager / ...]
- Rotation: [automatic / manual]
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → book chapter (Accelerate, Continuous Delivery)
- `references/deployment-strategies.md` — Strategy comparison + decision tree + Canary rollout plan
- `references/dora-metrics.md` — 4 Key Metrics + benchmarks + 24 DORA Capabilities + Trunk-Based Dev
