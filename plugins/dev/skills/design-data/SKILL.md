---
name: design-data
description: >
  Data model design skill grounded in CMU 15-445 (Database Systems, Prof. Andy Pavlo)
  and Stanford CS245. Use this skill whenever the user needs to design or review a
  database schema, choose between SQL and NoSQL, decide on normalization level,
  plan indexing strategy, or make Event Sourcing / CQRS decisions. Triggers:
  "design a schema for X", "should I normalize this?", "which index should I add?",
  "SQL or NoSQL?", "should I use event sourcing?", "my queries are slow", "how do I
  model this relationship", "CQRS for this use case", "partitioning strategy".
  Covers: relational modeling, normalization, indexing, query optimization,
  NoSQL trade-offs, Event Sourcing, CQRS, sharding. Always use this skill for
  data modeling decisions.
---
# Data Model Skill

Structured data modeling grounded in CMU 15-445 (Database Systems, Andy Pavlo).
Every recommendation explains the trade-off, not just the rule.

---

## Core Philosophy (CMU 15-445)

> "The database is the most important part of your system. Get it wrong,
> and you pay the cost forever." — Andy Pavlo, CMU 15-445

Data modeling decisions are among the hardest to reverse. A table structure
chosen today will constrain queries, performance, and evolution for years.
Understand the trade-off before optimizing — optimize for the wrong thing
and you've made it worse.

---

## Step 0 — Understand the Access Patterns

Before designing a schema, establish:

1. **What are the primary queries?** (80% of your traffic will be 5-10 queries)
2. **What is the read/write ratio?** (OLTP: high writes; OLAP: heavy reads)
3. **What are the cardinality and selectivity of key fields?** (informs indexing)
4. **What are the consistency requirements?** (ACID? Eventual? Per entity?)
5. **What is the scale?** (thousands of rows? Billions?)

*"Schema design without knowing the access patterns is premature optimization
in the wrong direction."* — CMU 15-445

---

## Review Workflow

### Step 1 — Model Review

Evaluate relational schemas: apply normalization rules and check for anomalies.
For NoSQL choices: evaluate the access pattern fit against document, key-value,
column-family, or graph models.

### Step 2 — Normalization Assessment

Load `references/normalization-indexing.md` — evaluate normalization level and trade-offs.

### Step 3 — Index Strategy

Load `references/normalization-indexing.md` — identify missing, redundant, or wrong indexes.

### Step 4 — Advanced Patterns

Load `references/event-sourcing-cqrs.md` when the user asks about Event Sourcing or CQRS.

---

## Standard Finding Format

```text
### [SEVERITY] Data Model Finding: [Short Title]
**Category:** Schema | Normalization | Index | Query | Consistency | Pattern Choice

**What:** What the current design does.

**Why it matters:** One paragraph — what problem this causes, what query will be
slow, what data anomaly can occur, what migration will be painful later.

**Recommendation:** Specific schema change, index definition, or pattern.
Include DDL examples where helpful.

**Trade-off:** What you give up by making this change.

**Reference:** [CMU 15-445 Lecture / Andy Pavlo / Fowler / specific concept]
```

---

## Concept → Reference Mapping

CMU 15-445, Fowler EventSourcing/CQRS, DynamoDB: `references/curriculum-mapping.md`

---

## Output — Design-Datei

Schreibe das Ergebnis nach `./design-data.md`:

```markdown
# Data Model: [Domäne/Kontext]
DB: ... | Datum: YYYY-MM-DD

## Entscheidungen
| Entscheidung | Wahl | Begründung | Referenz |
|---|---|---|---|

## Schema
[DDL oder ER-Diagramm-Beschreibung]

## Index-Strategie
[Pro Index: Typ | Spalten | Begründung | Trade-off]

## Annahmen & offene Punkte

---
## ✅ Setup-Todo
- [ ] ...

## 📋 Nächste Schritte (priorisiert)
1. ...
```

## Reference Files

- `references/normalization-indexing.md` — 1NF-BCNF normalization, when to denormalize,
  B-Tree/Hash/Composite/Covering/Partial indexes, index anti-patterns
- `references/event-sourcing-cqrs.md` — Event Sourcing, CQRS, when they help/hurt,
  event store design, snapshot strategy
