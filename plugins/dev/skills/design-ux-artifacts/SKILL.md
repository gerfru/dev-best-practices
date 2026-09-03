---
name: dev-design-ux-artifacts
description: >
  Structural, artifact-driven UX/UI design workflow grounded in Jesse James
  Garrett's "The Elements of User Experience" (5-plane model: Strategy, Scope,
  Structure, Skeleton, Surface) and Rosenfeld/Morville/Arango's "Information
  Architecture for the Web and Beyond". Produces a traceable chain of
  intermediate artifacts (problem brief, task inventory, domain model,
  information architecture, user flows, wireframes) BEFORE any visual styling,
  and applies an anti-generic-AI-visual-design discipline for enterprise/
  business software. Use this skill when the user wants to design a new
  screen, feature, or application structurally — or asks "design this
  properly, not just make it look nice", "what's the information architecture
  here", "plan the screens/navigation before we build", "avoid a generic
  AI-generated look", "structure before styling". Distinct from dev-design-ux,
  which covers Human-AI-Interaction trust/onboarding/feedback design for
  AI-powered features (HAX/PAIR/CHI2024/NNG) — this skill owns information
  architecture, task/domain modeling, and anti-generic-visual-design for
  business and enterprise UI.
---

# UX Design — Structural Artifacts (IA-based)

Turns a feature idea into a traceable chain of design artifacts before any
visual design happens. Standard: Garrett's 5-plane model + IA for the Web
and Beyond. No screen gets styled until its structure is validated.

---

## Core Philosophy (Garrett · Rosenfeld/Morville/Arango)

> "Each plane depends on the plane below it ... You can't build the skeleton
> of a product until you know what its structure will be." — Jesse James Garrett

Design for the workflow, not for the screenshot. Structure before styling.
Every UI element must trace back to a user task, an information requirement,
a workflow, or a system constraint — never to "making it look modern."

---

## Step 0 — Problem Brief (Strategy plane)

Gather, or ask **once** if missing:

```text
Product / Feature:
Primary Users:
Primary Goal:
Main Tasks:
Business Constraints:
Technical Constraints:
Known Problems:
Open Questions:
Success Criteria:
```

Separate confirmed requirements from assumptions from open questions.
Do not propose any UI solution in this step. Mark gaps as `[Assumption]`.

---

## Step 1 — Model the Domain (Scope plane)

Produce, as applicable:

1. **User/Role Matrix** — if more than one role uses the product, check
   early whether a single interface can even serve all of them.
2. **Task Inventory** — actor, goal, frequency, criticality, required data,
   starting point, expected outcome. Rank by UX importance.
3. **Domain/Entity Model** — entities, key attributes, relationships,
   important actions.

Templates: `references/ia-artifact-templates.md` (sections 2–4).

---

## Step 2 — Structure the Information (Structure plane)

1. **Content Inventory** — every piece of information that must actually be
   displayed, grouped per screen/object (more granular than the entity model).
2. **Information Hierarchy** — Level 1 (always visible) through Level 4
   (on demand). This is what stops AI-generated layouts from rendering
   everything with equal visual weight.
3. **Navigation Map** — classify each nav item as Global / Local /
   Contextual / Utility.
4. **Screen Inventory** — screen, purpose, primary task, entry point. Guards
   against unnecessary screens/dialogs before wireframing.

Templates: `references/ia-artifact-templates.md` (sections 5–8).

---

## Step 3 — Map Flows and Decide Patterns

1. **User Flows** for every critical task — entry point, happy path,
   alternative path, error path, exit state. Check: how many steps, any
   unnecessary navigation or context switches, is the user always oriented.
2. **Interaction Pattern Decision** — for each nontrivial UI decision,
   document candidate patterns, the choice, the reason, and the trade-off.
   Do not invent a new pattern when an established one
   (master-detail, split view, tabs, faceted search, progressive disclosure,
   wizard, inline editing, bulk actions, command palette, drawer) fits.
3. **UX Decision Log** (`DEC-NNN`) — decision, reason, rejected alternatives
   and why. Do not contradict a prior entry without stating why it changed.

Templates: `references/ia-artifact-templates.md` (sections 9–11).

---

## Step 4 — Research (only if patterns are non-obvious)

Search for the **UX problem**, not for visual inspiration:

- Good: "master detail interface pattern", "enterprise project detail page
  UX", "faceted search UX", "bulk actions UX", "settings navigation pattern"
- Bad: "beautiful dashboard", "modern SaaS UI", "cool admin dashboard"

Analyze structural patterns in mature products (GitHub, Jira, Linear, Notion,
Slack, Figma, Stripe Dashboard) — how they navigate between objects, separate
list/detail, expose frequent actions. Extract the pattern, do not copy the
visual appearance.

Design systems worth consulting for concrete guidance on when (not) to use a
component: see `references/anti-ai-visual-checklist.md`.

---

## Step 5 — Low-Fidelity Wireframe (Skeleton plane)

Text/ASCII schematic only. No color, shadow, radius, illustration, or
branding. A wireframe must answer:

- Where am I? Where do I find X? How do I move between areas?
- What is important vs. secondary? What actions can I take here?

If these questions can't be answered at wireframe fidelity, visual design
will not fix it — go back to Step 2/3.

Also produce at this stage, as applicable:

- **Component Inventory** — check for unnecessary special-purpose components.
- **State Matrix** — loading/empty/error/permission-denied/partial-data/
  success/offline, plus element states (default/hover/focus/selected/
  disabled/read-only/validation-error).
- **Permission Matrix** — action × role, drives visible/disabled UI.
- **Data Density Specification** — target environment, viewport, expected
  visible rows, interaction mode, density.

Templates: `references/ia-artifact-templates.md` (sections 12–16).

---

## Step 6 — Validate Structure Before Styling

Explicitly confirm:

- Does the user find everything they need?
- Is navigation understandable without explanation?
- Are frequent actions reachable quickly?
- Are relationships between objects clear?
- Are there unnecessary steps?
- Is information density appropriate for the target environment?

Do not proceed to visual design until these hold.

---

## Step 7 — Visual Design Constraints (Surface plane, structure-driven)

State constraints before applying any actual color/spacing/component styling:
typography, spacing, containers, radius, shadows, color, icons, animation —
each grounded in a functional reason (see `references/ia-artifact-templates.md`
section 17).

Then apply the anti-generic-AI-visual-design discipline: avoid oversized hero
sections, cards for everything, glassmorphism, decorative gradients/blobs,
giant typography for ordinary content, repeated "title+subtitle+3 cards"
sections, fake metrics, excessive badges/pills. Full checklist:
`references/anti-ai-visual-checklist.md`.

For AI-powered features specifically (trust calibration, onboarding, feedback
design, dark-pattern-free AI UX) — see `dev:design-ux`, which owns that axis.

---

## Step 8 — Requirement → UI Traceability

For every UI element in the resulting design, confirm it traces to a row in:

| Requirement | User Task | Screen | UI Element |
|---|---|---|---|

Any element with no traceable reason is a candidate for removal — flag it
rather than keeping it "because it looks complete."

---

## Output — Design File

Write the result to `./design-ux-artifacts.md`:

```markdown
# UX Artifacts: [Product / Feature Name]
Date: YYYY-MM-DD

## Problem Brief
[confirmed requirements / assumptions / open questions / constraints / success criteria]

## Role Matrix
| Role | Main Goal | Frequent Tasks | Required Information | Permissions |

## Task Inventory
[ranked by UX importance]

## Domain / Entity Model
[entities, attributes, relationships, actions]

## Information Architecture
### Content Inventory
### Information Hierarchy
### Navigation Map
### Screen Inventory

## User Flows
[per critical task: entry point / happy path / alternative path / error path / exit state]

## Interaction Pattern Decisions
[problem / candidates / decision / reason / trade-off]

## UX Decision Log
[DEC-NNN entries]

## Low-Fidelity Wireframe
[ASCII/text, no styling]

## Component Inventory / State Matrix / Permission Matrix / Data Density

## Visual Design Constraints
[stated before applying visual styling]

## Requirement -> UI Traceability
| Requirement | User Task | Screen | UI Element |

## Assumptions & Open Questions
- [Assumption]: ...
- [to verify]: ...

## Next Steps (prioritized)
1. ...
```

## Reference Files

- `references/ia-artifact-templates.md` — concrete template for each of the 18 artifacts
- `references/anti-ai-visual-checklist.md` — generic-AI/SaaS visual anti-patterns to avoid, and what to prefer instead
