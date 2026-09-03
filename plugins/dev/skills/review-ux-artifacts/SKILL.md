---
name: dev-review-ux-artifacts
description: >
  Structural UX/UI audit grounded in Jesse James Garrett's "The Elements of
  User Experience" (5-plane model) and Rosenfeld/Morville/Arango's
  "Information Architecture for the Web and Beyond", plus a practice-based
  anti-generic-AI-visual-design checklist. Audits whether an existing design
  or interface has a traceable information architecture behind it, whether
  every UI element traces back to a requirement/task/workflow, and whether
  the visual layer defaulted to a generic AI-generator/SaaS-template look
  (glassmorphism, card-for-everything dashboards, hero-logo-strip-3-cards
  marketing pages) instead of a structure-driven design. Use this skill when
  the user asks "does this look AI-generated", "review the information
  architecture", "why does every screen look like a generic dashboard",
  "audit this UI for unnecessary elements", "is this structurally sound or
  just styled". Distinct from dev-review-ux, which audits Human-AI-Interaction
  trust/onboarding/feedback design for AI-powered features (HAX/PAIR/CHI2024/
  NNG) — this skill owns information architecture and anti-generic-visual-
  design audits for business and enterprise UI.
---

# UX Review — Structural Artifacts & Anti-AI Visual Audit

Evaluates whether an interface has a traceable structure behind it, and
whether its visual layer is a deliberate, structure-driven design or a
generic AI/SaaS-template default. Every finding cites the specific element,
signature, or missing artifact.

---

## Core Philosophy (Garrett · Rosenfeld/Morville/Arango)

> "You can't build the skeleton of a product until you know what its
> structure will be." — Jesse James Garrett

If everything is visually important, nothing is. A mature interface makes
work easier, not a demonstration that it was designed. This review checks
both structure (is there a defensible information architecture) and surface
(does the visual layer serve that structure, or override it with decoration).

---

## Step 0 — Determine Context & Audit Scope

**Auto-discovery: what has been provided?**

| Input Type | Approach |
|---|---|
| Screenshot / mockup | Analyze directly; describe UI elements and structure |
| Code (HTML/JSX/templates) | Read and derive structure and component usage |
| Design spec / existing `design-ux-artifacts.md` | Compare implementation against the documented artifacts |
| Verbally described feature | Use description as basis; mark assumptions |

Report concisely what was detected:
`Type: Enterprise dashboard | Structural artifacts found: none | Phase: Production`.

If a `design-ux-artifacts.md` exists in the project, read it first — it is
the source of truth for what each element is supposed to trace back to.

---

## Step 1 — Four Audit Dimensions

Work through all four dimensions. Findings in this format:

```text
[Dimension] Title · Severity (Critical/High/Medium/Low) · Finding · Fix
```

Severity definition:
- **Critical** — Interface has no discoverable structure, or is a wholesale
  generic-template copy with no adaptation to actual content
- **High** — Significant structural gap or template signature that will
  visibly hurt daily usability or credibility
- **Medium** — Improvement recommended; no immediate harm
- **Low** — Cosmetic, or only relevant at scale

### Dimension 1 — Anti-AI Visual Audit

Classify every card, rounded container, icon, badge, pill, gradient, large
heading, decorative element, and shadow as: structurally necessary /
functionally useful / informational / branding / decorative only. Recommend
removing or simplifying decorative-only elements unless a strong reason is
given. Format and classification rules: `references/anti-ai-audit-classification.md`.

### Dimension 2 — Requirement → UI Traceability

For each significant UI element, attempt to trace it to a task, information
requirement, workflow, or constraint. Elements with no traceable reason are
flagged as likely unnecessary — recommend confirming before removal, not
auto-deleting. Rules: `references/anti-ai-audit-classification.md`.

### Dimension 3 — Generic AI/SaaS Template Detection

Check for the tell-tale signatures: dashboards built entirely from floating
rounded cards, hero→logo-strip→3-feature-cards→stats→testimonials→CTA→footer
marketing pages, repeated "title+subtitle+3 cards" sections, fake/placeholder
metrics. Full signature list with severity: `references/generic-ai-template-signatures.md`.

### Dimension 4 — Structure-Before-Styling Check

Determine whether structural artifacts (information architecture, user
flows, wireframe) exist or were evidently followed before visual polish was
applied. Signals that structure was skipped: everything rendered with equal
visual weight (no information hierarchy), ad hoc navigation not traceable to
a navigation model, screens/dialogs with no clear primary task. When
combined with a Dimension 3 finding, escalate to a single Critical finding
per `references/generic-ai-template-signatures.md`.

---

## Step 2 — UX Critique for Non-Trivial Issues

For findings beyond a simple classification table, use:

```text
Issue: ...
Impact: ...
Severity: Critical / High / Medium / Low
Recommendation: ...
```

Evaluate by: severity of consequence · frequency · user impact · fix
complexity.

---

## Step 3 — Consolidate Findings

1. Sort all findings by severity (Critical → Low)
2. Assign a traffic light per dimension: 🟢 / 🟡 / 🔴
3. List Top-3 Quick Wins separately (high impact, low effort)
4. Mark findings without a concrete file/screen reference as `[Assumption - to be verified]`

---

## Step 4 — Write Report

Output to `./review-ux-artifacts-report.md`:

```markdown
# UX Structural Review: [Product / Feature Name]
Date: YYYY-MM-DD
Framework basis: Garrett 5-plane model · IA for the Web and Beyond · Anti-AI visual checklist

## Detected Context
[Type, structural artifacts found (if any), phase]

## Traffic Light Overview
| Dimension | Status | #Critical | #High | Most notable finding |
|---|---|---|---|---|
| Anti-AI Visual Audit | ... | ... | ... | ... |
| Requirement -> UI Traceability | ... | ... | ... | ... |
| Generic AI/SaaS Template Detection | ... | ... | ... | ... |
| Structure-Before-Styling | ... | ... | ... | ... |

## Top-3 Quick Wins
1. [Title] · Effort: S (<30min) · [concrete fix]
2. ...
3. ...

## Full Finding List

### Critical
- **Title** · Finding: ... · Fix: ... · Reference: [dimension/signature]

### High
### Medium
### Low

## Element Classification Table
| Element | Classification | Keep? | Reason |

## Not Evaluated / Assumptions
- [To be verified]: ...

---
*Generated with AI assistance (Claude Code + dev-best-practices plugin).
Structural findings should be validated with actual users before large-scale rework.*
```

---

## Rules

- No speculative findings — only with a concrete reference to the submitted
  design/code or a clearly demonstrable gap. Mark uncertain items as
  `[to be verified]`.
- Do not auto-remove flagged elements — report first, implement on request.
- For AI-feature trust/onboarding/dark-pattern findings (chat vs. GUI
  validation, confidence display, ELIZA effect, etc.) — defer to
  `dev:review-ux`; do not duplicate that scope here.
- Explicitly mention what works well — this is a structural review, not a
  pure defect list.

## Reference Files

- `references/anti-ai-audit-classification.md` — element classification scheme, UX critique format, traceability check
- `references/generic-ai-template-signatures.md` — concrete generic-template signatures with severity, structural-skip detection
