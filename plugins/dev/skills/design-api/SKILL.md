---
name: dev:design-api
description: >
  API contract design skill grounded in CMU 17-625 (API Design, Swarnalatha Ashok /
  Bradley Schmerl) and Google API Design Guide. Use this skill whenever the user
  wants to design, review, or evolve an API. Triggers: "design an API for X",
  "review my REST API", "should I use REST or GraphQL or gRPC", "how do I version
  this API", "will this change break existing clients", "design the contract for
  this service", "what's wrong with my API design", "how do I document this API".
  Covers: REST, GraphQL, gRPC design; API versioning strategies; breaking vs
  non-breaking change analysis; OpenAPI/Protobuf contracts; API usability
  principles. Always use this skill for API design questions.
---
# API Design Skill

Structured API design review grounded in CMU 17-625 (API Design).
Every recommendation explains the design principle and the trade-off.

---

## Core Philosophy (CMU 17-625)

> "Design APIs that are easy to use and difficult to misuse."
> — CMU 17-625 course principle

APIs are products, not implementation details. A bad API:

- Forces clients to work around its limitations
- Leaks implementation details that constrain future changes
- Provides multiple ways to do the same thing (confusion)
- Is easy to call incorrectly (wrong parameters, wrong order)

The goal: **a pit of success** — the natural way to use the API is the correct way.

---

## Step 0 — Choose the Right API Style

Before designing, establish which style fits.

Quick decision matrix:

| If you need...                                                | Use        |
| ------------------------------------------------------------- | ---------- |
| Standard CRUD over HTTP, broad client compatibility           | REST       |
| Flexible querying, multiple clients with different data needs | GraphQL    |
| High-performance, internal service-to-service, streaming      | gRPC       |
| Real-time bidirectional communication                         | WebSockets |
| Simple event notification                                     | Webhooks   |

---

## Review Workflow

### Step 1 — Understand the Context

- Who are the API consumers? (internal services, mobile apps, third-party developers)
- What are the primary use cases? (top 3-5 operations that 80% of calls will make)
- What are the stability requirements? (how long must existing clients be supported?)
- What is the team's operational model? (can they support versioned endpoints long-term?)

Ask: *"Who will call this API, and what will they be trying to accomplish?"*

### Step 2 — Review the Contract

Load `references/rest-design.md` for REST APIs.
For GraphQL or gRPC: apply the API design principles below directly.

### Step 3 — Breaking Change Analysis

Load `references/versioning-breaking-changes.md` for every change to an existing API.

### Step 4 — Report Findings

---

## Standard Finding Format

```text
### [SEVERITY] API Finding: [Short Title]
**Category:** Naming | Resource Model | Contract | Versioning | Security | Usability
**Location:** [Endpoint, type, or field]

**What:** What the current design does.

**Why it matters:** One paragraph — what design principle is violated, what
problem this causes for API consumers. "This means that a client must..."

**Recommendation:** Specific change with example (show the before/after).

**Breaking change?** Yes / No / Depends — and why.

**Reference:** [CMU 17-625 / Google API Design Guide / REST constraint]
```

---

## API Design Principles (CMU 17-625)

**Usability:** The API should be learnable, memorable, and efficient.

- Consistent naming across all resources and operations
- Predictable behavior — similar inputs produce similar outputs
- Self-documenting names — no need to look up what `usr_flg` means

**Correctness:** The API should make incorrect use difficult.

- Required fields should be required (not silently ignored or defaulted)
- Validate inputs and return meaningful error messages
- Idempotent operations should be explicitly idempotent (PUT, DELETE)

**Evolvability:** The API should be able to grow without breaking existing clients.

- Additive changes only in minor versions
- Never remove or rename fields in a stable API
- Use extensibility points from day one (not after clients are locked in)

**Consistency:** The API should follow consistent conventions throughout.

- Same thing should always be named the same way (`user_id` not `userId` in one place, `user.id` in another)
- Same patterns for pagination, filtering, error responses, timestamps

---

## Concept → Reference Mapping

Google API Design Guide, CMU 17-625, OWASP API Security: `references/curriculum-mapping.md`

---

## Output — Design File

Write the result to `./design-api.md`:

```markdown
# API Design: [Service/Context]
Style: REST / GraphQL / gRPC | Date: YYYY-MM-DD

## Decisions
| Decision | Choice | Rationale | Reference |
|---|---|---|---|

## Contract Overview
[Resources, endpoints, or schema types]

## Breaking Change Analysis
[If existing API — what breaks, what is safe]

## Assumptions & Open Questions

---
## ✅ Setup Todo
- [ ] ...

## 📋 Next Steps (prioritized)
1. ...
```

## Reference Files

- `references/rest-design.md` — REST resource modeling, naming, HTTP semantics, errors, pagination
- `references/versioning-breaking-changes.md` — Versioning strategies, breaking change catalog (REST, GraphQL, gRPC)
