# Generic AI/SaaS Template Signatures

Concrete signatures that indicate a design jumped straight to visual polish
without a structural design pass, or defaulted to a generic AI-generator
template. Flag any match as a finding.

---

## Application / Dashboard Signature

| Signature | Test | Severity |
|---|---|---|
| Dashboard built entirely from floating rounded cards | Is there any grouping, division, or hierarchy beyond "put it in a card"? | High |
| Every content type wrapped in an identical card component | Do unrelated content types (text, table, single metric) get the same container? | Medium |
| Oversized hero/header area with no functional content | Does the top of the screen show identity/status data, or just decoration? | Medium |
| Heavy use of glassmorphism / translucent panels | Any functional reason (e.g. overlay context) or purely decorative? | Medium |
| Icon in front of every heading/label | Does the icon aid recognition, or is it decorative padding? | Low |
| Large gradient accents with no status/branding meaning | Does the gradient encode information, or is it filler? | Medium |
| Excessive whitespace with no hierarchy purpose | Is whitespace used to separate meaning, or just to look "clean"? | Low |
| Numerous badges/pills with low information value | Does the badge state change and matter to the user? | Low |
| Fake or placeholder metrics presented as real data | Would removing the metric change any user decision? | High |

## Marketing/Content Page Signature

| Signature | Test | Severity |
|---|---|---|
| Hero -> Logo Strip -> 3 Feature Cards -> Stats -> Testimonials -> CTA -> Footer | Does the page follow this exact generic sequence regardless of actual content? | High |
| Every section in its own rounded container | Is there deliberate variation in section density/layout, or a repeated template block? | Medium |
| Section content genuinely determined by communication goal | Or could sections be reordered/removed without loss of meaning? | Medium |

---

## Structural-Skip Detection

Independent of visual signatures, check whether structure was skipped entirely:

- No evidence of an information hierarchy (everything rendered with equal
  visual weight) → structure phase likely skipped.
- Navigation model not traceable to a Navigation Map (items feel ad hoc)
  → structure phase likely skipped.
- Screens/dialogs exist with no clear primary task → Screen Inventory likely
  skipped.
- UI elements present with no traceable requirement, task, or workflow behind
  them → see traceability check.

When several structural-skip signals combine with a generic-template
signature, report a single **Critical** finding: "design appears to have
skipped the structural phase and gone directly to visual template
application," with the specific signatures as supporting evidence.
