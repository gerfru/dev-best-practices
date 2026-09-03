# Anti-AI Visual Audit — Element Classification

Classification scheme for the per-element Anti-AI Audit (Dimension 1 of the
review). Apply to every card, rounded container, icon, badge, pill, gradient,
large heading, decorative element, and shadow found in the design.

---

## Classification Categories

| Category | Definition | Recommended Action |
|---|---|---|
| Structurally necessary | Removing it breaks layout comprehension or grouping that reflects the domain model | Keep |
| Functionally useful | Enables or clarifies an action or interaction | Keep |
| Informational | Conveys data the user needs (status, count, relationship) | Keep, but check it's not over-styled |
| Branding | Deliberate, consistent brand expression (not filler) | Keep if consistent with a documented brand system |
| Decorative only | No functional, informational, or brand reason found | Remove or simplify unless a strong reason is given |

## Audit Table Format

| Element | Classification | Keep? | Reason |
|---|---|---|---|
| Project card | Informational | Keep | Represents one distinct entity from the domain model |
| Gradient header | Decorative only | Remove | No status or branding meaning |
| Status pill | Informational | Keep | Encodes state that changes and matters |
| Risk icon | Decorative only (low value) | Remove | Icon doesn't aid recognition beyond the label |

---

## UX Critique Entry Format

```text
Issue: [what is wrong]
Impact: [consequence for the user or the interface]
Severity: Critical / High / Medium / Low
Recommendation: [concrete fix]
```

Evaluate severity by combining: Severity of consequence · Frequency of
occurrence · User impact · Fix complexity. A low-severity, high-frequency
issue can outrank a high-severity, rare one for prioritization purposes —
call this out explicitly when it applies.

---

## Requirement -> UI Traceability Check

For each UI element under review, attempt to find a row that justifies it:

| Requirement | User Task | Screen | UI Element |
|---|---|---|---|

If no row can be constructed for an element even after checking the product's
stated requirements and tasks, flag it explicitly:

```text
[UI Element] has no traceable requirement, task, workflow, or constraint.
Likely candidate for removal — confirm with the team before deleting.
```

Do not flag elements required for legal/accessibility/compliance reasons
even if no product requirement mentions them explicitly (e.g. focus
indicators, skip links).
