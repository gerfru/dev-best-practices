---
name: design-migration
description: >
  Migration planning skill grounded in MIT 6.5840 (Distributed Systems, Morris/
  Kaashoek/Zeldovich) and Martin Fowler's migration patterns. Use this skill
  whenever the user needs to plan a migration: Monolith→Microservices,
  v1→v2 API, database schema migration, zero-downtime deployment, technology
  stack migration, or data migration at scale. Triggers: "how do I migrate from X
  to Y", "zero downtime migration", "monolith to microservices", "how to migrate
  the database without downtime", "blue-green deployment", "strangler fig",
  "how do I break this apart safely", "migration strategy". Always use this skill
  for migration planning — these decisions have high failure risk and must be
  approached systematically.
---
# Migration Plan Skill

Structured migration planning grounded in MIT 6.5840 and Fowler's patterns.
Every migration plan must address: correctness, rollback, observability, and risk.

---

## Core Philosophy

> "Never do a big-bang migration." — Martin Fowler

The safest migrations are:

1. **Incremental**: small steps that can be individually verified and rolled back
2. **Observable**: metrics and logs that confirm the migration is working
3. **Reversible**: every step has a rollback path
4. **Parallel**: new and old systems run simultaneously until confidence is established

---

## Step 0 — Understand the Migration

Before planning, establish:

- **What is migrating?** (code, data, API contract, infrastructure, process)
- **What is the risk tolerance?** (can we have 30s downtime? Zero downtime mandatory?)
- **What is the rollback strategy?** (if we must revert, what's the cost?)
- **What dependencies exist?** (other teams, external clients, downstream systems)
- **What does "done" look like?** (how will we know the migration succeeded?)

Ask: *"What happens if this migration goes wrong at the worst possible moment?"*

---

## Migration Types

Load `references/migration-patterns.md` — covers all migration types:

- **Monolith → Microservices**: Strangler Fig, seam identification, data decoupling
- **Database schema migration**: Zero-downtime schema changes, expand-contract pattern
- **Distributed systems concepts**: Consistency, CAP theorem, Saga pattern, 2PC

---

## Universal Migration Principles (MIT 6.5840)

### 1. Consistency First

From MIT 6.5840: consistency is the hardest problem in distributed systems.
During migration, two systems temporarily hold the same data.
Plan for: what happens when they disagree?

### 2. Observe Before You Act

Before migrating traffic, establish a baseline:

- What is the current latency, error rate, throughput?
- What are the current SLOs?
- You cannot know if the migration succeeded without a baseline.

### 3. The Dual-Write Period is Dangerous

Writing to both old and new systems simultaneously introduces:

- Two-phase commit problem (what if one write succeeds and the other fails?)
- Data divergence risk
- Doubled write latency

Plan explicitly for how long dual-write runs and how you detect/resolve divergence.

### 4. Dark Launch

Route traffic to the new system in shadow mode (reads only, no writes committed)
and compare responses with the old system. Measure divergence before going live.

---

## Output — Design-Datei

Schreibe das Ergebnis nach `./design-migration.md`:

```markdown
# Migration Plan: [Titel]
Von: ... → Nach: ... | Datum: YYYY-MM-DD

## Entscheidungen
| Entscheidung | Wahl | Begründung | Referenz |
|---|---|---|---|

## Scope
Was migriert; was explizit NICHT in dieser Migration.

## Risiko-Assessment
| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|---|---|---|---|

## Migrationsphasen
[Phase-by-phase: Was ändert sich | Verifikation | Rollback]

## Rollback-Strategie
[Abbruchkriterium + Rollback-Schritte]

## Erfolgskriterien
- Error rate < X%
- P99 < Xms
- Daten konsistent verifiziert

## Annahmen & offene Punkte

---
## ✅ Setup-Todo
- [ ] ...

## 📋 Nächste Schritte (priorisiert)
1. ...
```

---

## Concept → Reference Mapping

| Concept                  | Reference                                                                                   |
| ------------------------ | ------------------------------------------------------------------------------------------- |
| Strangler Fig pattern    | [Fowler: StranglerFigApplication](https://martinfowler.com/bliki/StranglerFigApplication.html) |
| Branch by Abstraction    | [Fowler: BranchByAbstraction](https://martinfowler.com/bliki/BranchByAbstraction.html)         |
| Expand-contract pattern  | [Fowler: ParallelChange](https://martinfowler.com/bliki/ParallelChange.html)                   |
| Blue-green deployment    | [Fowler: BlueGreenDeployment](https://martinfowler.com/bliki/BlueGreenDeployment.html)         |
| Feature flags            | [Fowler: FeatureToggle](https://martinfowler.com/articles/feature-toggles.html)                |
| Distributed transactions | [MIT 6.5840 — Two-Phase Commit](https://pdos.csail.mit.edu/6.824/)                            |
| CAP theorem              | [MIT 6.5840 — Consistency](https://pdos.csail.mit.edu/6.824/)                                 |
| Saga pattern             | [Richardson: Saga Pattern](https://microservices.io/patterns/data/saga.html)                   |
| Event sourcing migration | [Fowler: EventSourcing](https://martinfowler.com/eaaDev/EventSourcing.html)                    |

---

## Reference Files

- `references/migration-patterns.md` — Strangler Fig, seam finding, zero-downtime DB migration,
  CAP theorem, consistency models, 2PC, Saga pattern
