---
name: dev:review-arch
description: >
  Architecture review skill grounded in CMU 17-633 (Architectures for Software
  Systems, Prof. David Garlan) and Martin Fowler's architectural patterns.
  Use this skill whenever the user shares an existing system architecture and wants
  it reviewed, critiqued, or improved. Triggers: "review my architecture", "is this
  a good design?", "we have tech debt", "our system is getting hard to change",
  "can you find coupling problems", "what anti-patterns do you see", "should we
  refactor this", "we need an ADR for this decision". Covers: coupling & cohesion
  analysis, architectural style identification, anti-pattern detection, quality
  attribute assessment, tech debt mapping, and ADR recommendations.
  Always use this skill for any architectural review —
  do not rely on general knowledge alone.
---
# Architecture Review Skill

Structured architectural review grounded in CMU 17-633 (Architectures for Software
Systems). Every finding explains the architectural concept, not just the symptom.

---

## Core Philosophy (CMU 17-633)

> "Architecture is the set of design decisions that, if made incorrectly, will cause
> your project to fail." — David Garlan, CMU

An architecture review is not about finding fault — it is about making design decisions
**explicit**, evaluating them against **quality attributes**, and surfacing **hidden
assumptions** before they become expensive mistakes.

The CMU approach: every design decision has

1. A **driver** (what forced the decision — a quality attribute, constraint, or stakeholder concern)
2. A **style or tactic** chosen to address it
3. **Trade-offs** accepted as a consequence

---

## Review Workflow

### Step 1 — Understand Before Evaluating

Before reviewing, establish:

- **What does this system do?** (mission, users, scale)
- **What are the quality attribute priorities?** (performance, modifiability, availability, security, interoperability)
- **What constraints exist?** (team size, tech stack, budget, regulatory)
- **What is changing or painful?** (where is the team feeling friction?)

Ask the user: *"What's driving this review — is something broken, about to change, or are you planning ahead?"*

### Step 2 — Identify Architectural Structures

Every system has multiple simultaneous structures (CMU 17-633, Bass/Clements/Kazman):

- **Module structure**: how code is divided into implementation units
- **Component-and-connector structure**: how components interact at runtime
- **Allocation structure**: how software maps to hardware/infrastructure/teams

Identify which structure the user has shared and what's missing.

### Step 3 — Apply Review Dimensions

Load the relevant reference files:

- `references/anti-patterns.md` — architectural anti-patterns with CMU/Fowler grounding
- `references/quality-attributes.md` — quality attribute tactics, trade-offs, and ADR format

### Step 4 — Report Findings + ADR Recommendations

For each significant finding, use the **standard finding format** below.
After findings, offer ADR drafts for the most important decisions.

---

## Standard Finding Format

```text
### [SEVERITY] Finding: [Short Title]
**Category:** Coupling | Cohesion | Anti-Pattern | Quality Attribute | Tech Debt
**Location:** [Component, layer, or interface name]

**What:** One sentence describing what the architecture does.

**Why it matters:** One paragraph — what architectural principle is violated,
what will go wrong as the system grows, what quality attribute is at risk.
Concrete: "This means that every time X changes, Y must also change."

**Recommendation:** Specific structural change or refactoring direction.

**ADR needed:** Yes/No — and why this decision should be documented.

**Reference:** [CMU 17-633 topic / Fowler pattern / Martin Fowler blog link]
```

**Severity levels:**

| Level       | Meaning                                                            |
| ----------- | ------------------------------------------------------------------ |
| 🔴 CRITICAL | Active pain; system cannot evolve or scale without addressing this |
| 🟠 HIGH     | Will cause significant problems within 1-2 major features          |
| 🟡 MEDIUM   | Accumulating debt; manageable now but costly later                 |
| 🔵 LOW      | Best practice gap; low immediate risk                              |
| ⚪ INFO     | Observation worth noting; no immediate action needed               |

---

## Architectural Concept → Reference Mapping

CMU 17-633, Martin Fowler Patterns, MIT 6.5840: `references/curriculum-mapping.md`

---

## Interaction Patterns

### When user shares a diagram or description

Start with: "Let me identify the architectural structure you've described and the
implicit quality attribute priorities before evaluating."

### When user asks "is this good?"

"Good relative to what? Tell me what's most important — modifiability, performance,
team autonomy, or something else — and I'll evaluate against that."

### When user asks about a specific anti-pattern

Explain it from first principles using the CMU vocabulary: what architectural
property it violates, what the consequence is, what the fix looks like.

### When to recommend an ADR

Any time a finding involves a non-obvious trade-off where a future team member
might question "why did they do it this way?" That's an ADR moment.

---

## Output — Report File

Write the complete result to `./review-arch-report.md`:

```markdown
# Architecture Review Report — [System Name]
Stack: ... | Scope: ... | Date: YYYY-MM-DD

## Overall Assessment
[🔴/🟠/🟡/🟢] — One-sentence rationale

## Findings
### 🔴 Critical (N)
### 🟠 High (N)
### 🟡 Medium (N)
### 🔵 Low / ⚪ Info (N)

## Statistics
| Severity | Count |
|----------|-------|
| 🔴 Critical | N |
| 🟠 High | N |
| 🟡 Medium | N |
| 🔵 Low | N |

## Top 3 Immediate Actions
1. ...
2. ...
3. ...

## ADR Recommendations
[Which decisions should be documented]

---
*Created with AI assistance (Claude Code + dev-best-practices plugin).
Findings are to be verified — not a substitute for manual architecture reviews.*
```

## Reference Files

- `references/anti-patterns.md` — Big Ball of Mud, God Service, Chatty APIs, Shared DB, coupling types
- `references/quality-attributes.md` — ATAM, quality attribute scenarios, tactics catalog, ADR format & examples
