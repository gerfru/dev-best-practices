# Quality Attributes & ADR Reference

---

## Quality Attribute Scenarios (CMU 17-633, BCK Ch.3)

A quality attribute scenario has six parts:

1. **Stimulus source** — who/what triggers it (user, attacker, developer, system)
2. **Stimulus** — the event (request, failure, change request, attack)
3. **Environment** — normal operation, peak load, after failure, under development
4. **Artifact** — what part of the system is affected
5. **Response** — what the system does
6. **Response measure** — how we measure success (latency, availability %, deployment time)

---

## Quality Attribute Tactics Catalog (CMU 17-633 L10, BCK Ch.4-9)

### Availability Tactics

**Fault detection:**

- Ping/echo: one component periodically pings another; timeout = fault
- Heartbeat: component proactively sends heartbeats; absence = fault
- Exception detection: catch and classify exceptions

**Fault recovery:**

- Active redundancy: multiple instances run in parallel; failover is instant (hot standby)
- Passive redundancy: backup instance syncs state periodically; failover takes time (warm standby)
- Spare: cold standby; must be started on failure (cheapest but slowest)
- Rollback: revert to a known-good state (requires state checkpointing)
- Retry with exponential backoff: transient faults resolve themselves

**Fault prevention:**

- Transaction: atomic all-or-nothing operations prevent partial failures
- Circuit breaker: stop calling a failing service after N failures; retry after timeout
  [Fowler: CircuitBreaker](https://martinfowler.com/bliki/CircuitBreaker.html)

---

### Modifiability Tactics

**Reduce coupling:**

- Encapsulate: hide implementation behind an interface
- Use intermediary: add an indirection layer (broker, adapter, facade)
- Restrict dependencies: only allow specific dependency relationships (enforced by build system)
- Abstract common services: extract repeated logic into a shared service

**Increase cohesion:**

- Split module: separate concerns that change for different reasons
- Redistribute responsibilities: move behavior to where the data lives

**Defer binding:**

- Configuration files: change behavior without recompilation
- Feature flags: turn features on/off at runtime without deployment
- Plugin architecture: extend behavior without modifying core

---

### Performance Tactics

**Control resource demand:**

- Increase efficiency: better algorithms, data structures
- Reduce computational overhead: caching, precomputation
- Manage event rate: rate limiting, load shedding
- Control sampling frequency: trade accuracy for throughput

**Manage resources:**

- Introduce concurrency: process independent tasks in parallel
- Maintain multiple copies: replicas for read scalability
- Increase available resources: horizontal or vertical scaling
- Schedule resources: priority queues, work stealing

---

### ATAM — Architecture Tradeoff Analysis Method (CMU 17-633 L15)

ATAM is a structured evaluation process. Key steps relevant to a review:

1. **Present the architecture** — describe key design decisions and rationale
2. **Identify quality attribute requirements** — as measurable scenarios
3. **Map decisions to quality attributes** — which decision serves which attribute
4. **Identify sensitivity points** — decisions that significantly affect one quality attribute
5. **Identify trade-off points** — decisions that affect multiple quality attributes in opposing ways
6. **Identify risks** — architectural decisions that may not satisfy requirements
7. **Identify non-risks** — good decisions worth explicitly acknowledging

---

## Architecture Decision Record (ADR) Reference

### When to Write an ADR (CMU 17-633 L17, Michael Keeling)

Write an ADR when:

- The decision has significant and long-lasting consequences
- It's non-obvious — a future team member would reasonably ask "why?"
- It involves a trade-off where other valid options exist
- It constrains future decisions

Do NOT write an ADR for:

- Implementation details within a component
- Obvious choices with no real alternatives
- Decisions that will clearly be revisited soon

### ADR Format (MADR — Markdown Architectural Decision Record)

```markdown
# ADR-NNNN: [Short title, present tense imperative: "Use X for Y"]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-MMMM]

## Date
YYYY-MM-DD

## Context
What is the issue we're deciding about? What forces are at play?
(business constraints, quality attribute requirements, technical context)

## Decision Drivers
* [driver 1 — quality attribute scenario or constraint]
* [driver 2]
* [driver 3]

## Considered Options
* Option A — [one-line description]
* Option B — [one-line description]
* Option C — [one-line description]

## Decision Outcome
Chosen option: **Option X**, because [justification — which drivers it best satisfies].

### Positive Consequences
* [consequence 1]
* [consequence 2]

### Negative Consequences (accepted trade-offs)
* [trade-off 1]
* [trade-off 2]

## Pros and Cons of the Options

### Option A
* ✅ [pro]
* ✅ [pro]
* ❌ [con]

### Option B
* ✅ [pro]
* ❌ [con]
* ❌ [con]
```

### ADR Example: Choosing Between Microservices and Modular Monolith

```markdown
# ADR-0012: Use Modular Monolith Architecture for Initial Launch

## Status
Accepted — 2025-01-15

## Context
We are building a new B2B SaaS product with a team of 6 engineers.
We need to make an early decision on deployment architecture.

## Decision Drivers
* Team autonomy is not yet a concern (one team owns everything)
* We need to ship an MVP within 3 months
* Operational simplicity is critical — no dedicated DevOps engineer
* The domain boundaries are not yet well-understood

## Considered Options
* Microservices from day one
* Modular monolith with clear internal boundaries
* Traditional unstructured monolith

## Decision Outcome
Chosen option: **Modular monolith**, because it provides future flexibility (modules
can become services later) without the operational complexity of microservices at
a stage where team autonomy is not yet a bottleneck.

### Positive Consequences
* Single deployment unit; simple CI/CD
* In-process communication — no network overhead or distributed transaction complexity
* Modules enforce internal structure without service mesh overhead

### Negative Consequences
* Independent deployability not possible per module
* Technology diversity not possible
* Will require a migration when team grows past ~20 engineers

## Supersession trigger
Revisit when: (a) team grows to 3+ teams needing independent deployability,
or (b) a specific module has dramatically different scaling needs.
```
