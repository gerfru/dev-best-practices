---
name: design-cicd
description: >
  CI/CD Pipeline Design grounded in "Accelerate" (Forsgren/Humble/Kim, IT Revolution 2018)
  und "Continuous Delivery" (Humble/Farley, Addison-Wesley 2010). Deckt Pipeline-Architektur,
  Deployment-Strategien (Blue-Green, Canary, Feature Flags), Environment-Design,
  DORA-Metriken und Trunk-Based Development ab.
  Use this skill whenever the user wants to design or improve a CI/CD pipeline,
  deployment process, release strategy, or software delivery workflow.
  Trigger: "CI/CD einrichten", "Deployment-Strategie", "Pipeline aufbauen",
  "Blue-Green Deployment", "Canary Release", "Feature Flags einrichten",
  "DORA Metriken verbessern", "Trunk-Based Development", "Zero-Downtime Deploy",
  "Release-Strategie", "wie deploye ich sicher", "Staging-Umgebung aufsetzen",
  "Deployment Frequency erhoehen", "GitHub Actions Pipeline", "rollback strategie".
  Deckt ab: Pipeline-Architektur, Deployment-Strategien, Environment-Design,
  DORA-Metriken (Deployment Frequency / Lead Time / CFR / MTTR), Trunk-Based Development.
---

# CI/CD Pipeline Design

Entwirft eine Deployment-Pipeline und Release-Strategie — grounded in "Accelerate" und
"Continuous Delivery". Ziel: hohe Deployment-Frequenz bei niedrigem Change-Failure-Rate
(DORA Elite Performance).

---

## Core Philosophy ("Accelerate")

> "The key to moving faster is to get smaller batch sizes and shorter feedback cycles."
> — Forsgren/Humble/Kim, Accelerate (2018)

Schnelle Deployments und hohe Stabilität schließen sich nicht aus — Elite-Teams erreichen
beides gleichzeitig. Trunk-Based Development, automatisierte Tests und Deployment Automation
sind die stärksten empirischen Prädiktoren für hohe DORA-Performance.

---

## Schritt 0 — Kontext klären

**Fragen:**
- Team-Größe und Deployment-Frequenz heute (täglich / wöchentlich / monatlich)?
- Stack: Sprache, Framework, Container (Docker/K8s), Cloud-Provider?
- Aktueller Deployment-Prozess: manuell / halb-automatisiert / vollautomatisch?
- Bestehende CI/CD Tools: GitHub Actions, GitLab CI, Jenkins, CircleCI, ...?
- Deployment-Target: Kubernetes, VMs, Serverless, PaaS?
- Kritikalität: Downtime akzeptabel oder Zero-Downtime Pflicht?

→ DORA-Baseline schätzen (Schritt 5 verfeinert sie).

---

## Schritt 1 — Pipeline-Architektur

**1a — Stages definieren**

Standard-Pipeline (anpassen an Stack):
```text
Commit → Build → Unit Tests → Integration Tests → Staging Deploy →
Acceptance Tests → Prod Deploy → Smoke Tests
```

Prinzipien:
- Jede Stage gibt schnelles Feedback (fail fast)
- Unit Tests: < 5 min (sonst aufteilen)
- Integration Tests: < 15 min (parallel laufen lassen)
- Kein manueller Schritt vor Prod (außer expliziter Approval bei high-risk)

**1b — Parallelisierung**

- Unit Tests + Lint + Security Scan → parallel
- Integration Tests nach erfolgreichem Build → parallel wo möglich
- Build-Cache: Dependencies cachen (npm ci, pip, Maven) → 60–80% schneller

**1c — Artifact Management**

- Einmal bauen, überall deployen (kein Re-Build pro Environment)
- Artifact versionieren mit Git SHA oder Semantic Version
- Container Images: in Registry pushen, per Tag promoten (nicht re-bauen)

---

## Schritt 2 — Test-Strategie in der Pipeline

**Gate-Logik:** Welche Tests müssen wo grün sein?

| Stage | Tests | Gate (blockiert Pipeline?) |
|---|---|---|
| Commit | Unit Tests, Linting, Type Check | Ja |
| Integration | API-Tests, DB-Tests, Service-Tests | Ja |
| Staging | Acceptance Tests, E2E Smoke Tests | Ja |
| Prod | Post-Deploy Smoke Tests | Rollback wenn rot |

Faustregel: Unit Tests in der Commit-Stage, alles was externe Dependencies braucht erst danach.

---

## Schritt 3 — Deployment-Strategie wählen

(→ `references/deployment-strategies.md` für vollständigen Vergleich und Entscheidungsbaum)

**Kurzentscheidung:**
- Downtime akzeptabel → Recreate (nur Non-Prod)
- Breaking Change oder unsicheres Feature → Feature Flag
- Granulares Rollout-Feedback nötig → Canary
- Schneller Traffic-Switch Rollback → Blue-Green
- Standard-Fall mit Health Checks → Rolling Update

**Feature Flag Empfehlung:** Bei > 1 Deployment/Woche immer ein Feature-Flag-System einplanen.

---

## Schritt 4 — Environment-Design

**4a — Environment-Parity**

Dev = Staging = Prod (gleiche Container-Images, gleiche Config-Struktur).
Unterschiede nur in Werten (Credentials, URLs), nie in Struktur.

**4b — Environment-Anzahl**

| Team-Größe | Empfehlung |
|---|---|
| Solo / Klein | Dev (lokal) + Prod |
| Mittel | Dev + Staging + Prod |
| Groß / Enterprise | Dev + Staging + Pre-Prod + Prod (+ Feature-Envs optional) |

**4c — Secrets Management**

- Niemals Secrets in Git oder Docker Images
- Secrets-Manager: Vault, AWS Secrets Manager, GitHub Actions Secrets
- Rotation: automatisiert wenn möglich

---

## Schritt 5 — DORA-Baseline und Ziele

(→ `references/dora-metrics.md`)

**Aktuelle Metriken messen oder schätzen:**
- Deployment Frequency: Wie oft deployt ihr heute in Prod?
- Lead Time: Wie lange von Commit bis Prod (typisch)?
- CFR: Wie oft verursacht ein Deployment einen Incident?
- MTTR: Wie lange braucht ihr um einen Prod-Incident zu beheben?

**Zielwerte:** Nächste DORA-Kategorie als 6-Monats-Ziel.

**Maßnahmen aus DORA-Forschung (stärkste Hebel):**
1. Trunk-Based Development (Schritt 6)
2. Test Automation (Schritt 2)
3. Deployment Automation (Schritt 1)
4. Monitoring & Observability (→ design-observability)

---

## Schritt 6 — Trunk-Based Development

(→ `references/dora-metrics.md` für Hintergrund)

**Branch-Strategie:**
- Main/Trunk: immer deploybar (CI muss grün sein)
- Feature Branches: maximal 1–2 Tage Lebensdauer
- Kein Long-Lived Feature-Branch (> 3 Tage = Merge-Schmerz-Risiko)

**Feature-Flag-Bedarf identifizieren:**
- Welche aktuellen Features brauchen Long-Lived Branches?
- Diese auf Feature Flags umstellen → dann kurze Branches möglich

**Merge-Strategie:**
- Squash Merge für Feature Branches (saubere History)
- Conventional Commits für automatisches Changelog / Semantic Versioning

---

## Output — `cicd-design.md`

```markdown
# CI/CD Design — [Projekt-Name]

## Pipeline-Architektur
Commit → Build ([X] min) → Tests ([Y] min) → Staging → Acceptance → Prod

## Deployment-Strategie
[Blue-Green / Canary / Feature Flags / Rolling] — Begründung: [...]

## Environments
| Environment | Zweck | Deploy-Trigger |
|---|---|---|
| Dev | Feature-Entwicklung | Automatisch bei Push |
| Staging | Pre-Prod Validation | Automatisch bei PR-Merge |
| Prod | Live | Automatisch nach Staging-Gate |

## DORA Baseline
| Metric | Aktuell | Ziel (6 Monate) |
|---|---|---|
| Deployment Frequency | [X/Woche] | [Y/Tag] |
| Lead Time | [X Tage] | [Y h] |
| CFR | [X%] | [< 5%] |
| MTTR | [X h] | [< 1h] |

## Trunk-Based Development
- Branch-Strategie: [...]
- Feature Flags: [welche Features, welches Tool]

## Secrets Management
- Tool: [Vault / AWS Secrets Manager / ...]
- Rotation: [automatisch / manuell]
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → Buch-Kapitel (Accelerate, Continuous Delivery)
- `references/deployment-strategies.md` — Strategie-Vergleich + Entscheidungsbaum + Canary Rollout-Plan
- `references/dora-metrics.md` — 4 Key Metrics + Benchmarks + 24 DORA Capabilities + Trunk-Based Dev
