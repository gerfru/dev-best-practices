---
name: dev:tool-a11y
description: >
  Accessibility audit workflow grounded in WCAG 2.2 (W3C), CMU HCII 05-332
  (Prof. Carrington) and W3C WAI Digital Accessibility Foundations. Covers
  automated audit (axe-core/Lighthouse), keyboard navigation,
  screen reader testing (NVDA, JAWS, VoiceOver) and EU Accessibility Act /
  EN 301 549 / BFSG compliance — including all 9 new WCAG 2.2 SC.
  Use this skill whenever the user wants to audit, test, or improve accessibility
  of a web product, or needs to check EU Accessibility Act / BFSG compliance.
  Trigger: "check accessibility", "WCAG audit", "test screen reader",
  "axe-core", "improve accessibility", "EU Accessibility Act", "BFSG",
  "EN 301 549", "check keyboard navigation", "focus management",
  "check alt text", "is my app accessible", "WCAG 2.2 new criteria",
  "check contrast", "ARIA correct", "skip link missing".
  Covers: WCAG 2.2 audit (A/AA/AAA), automated tests, keyboard navigation,
  screen reader testing, EU Accessibility Act / BFSG / EN 301 549 compliance.
---

# Accessibility Audit (tool-a11y)

Structured accessibility audit workflow — from automated tests to
screen reader testing and EU compliance check. Grounded in WCAG 2.2 and CMU HCII 05-332.

---

## Core Philosophy (WCAG 2.2 + CMU HCII)

> "Accessibility is not a feature — it is a quality attribute. Permanent, temporary,
> and situational disabilities affect everyone at some point."
> — CMU HCII 05-332 (Carrington), Universal Design Principle

Automated tools find ~30% of all accessibility issues. The remaining 70%
require manual testing with keyboard and screen reader. WCAG 2.2 Level AA has been
the legal minimum standard in the EU since June 2025 (Accessibility Act / BFSG).

---

## Step 0 — Clarify Scope

**Questions:**
- What is being audited? (Web app, mobile web, desktop app, document)
- Target WCAG level: A / AA (EU legal standard) / AAA?
- EU Accessibility Act / BFSG relevant? (Product sold in EU, from June 2025)
- WCAG 2.2 or still 2.1? (2.2 is current, 2.1 continues to be recognized)
- Time frame: Quick check (1–2h) or full audit?

---

## Step 1 — Automated Audit

(→ `references/testing-tools.md` for tool comparison)

**1a — axe-core Browser Extension**

- Open pages one by one in the browser
- Launch axe DevTools → "Scan All of My Page"
- Filter findings by severity: Critical → Serious → Moderate → Minor
- Document all findings: SC number, element, description

**1b — Lighthouse Audit**

- Chrome DevTools → Lighthouse → Category: Accessibility → Generate Report
- Note supplementary findings to axe-core (no duplicates)

**Reminder:** Automated tests = ~30% coverage. Steps 2–4 are mandatory.

---

## Step 2 — Keyboard Navigation

Navigate the complete page using only the keyboard (no mouse pointer):

**Checklist:**
- [ ] Tab order logical and predictable? (WCAG 2.4.3)
- [ ] All interactive elements reachable by Tab? (WCAG 2.1.1)
- [ ] Focus indicator visible on every element? (WCAG 2.4.7)
- [ ] Focus not obscured by sticky header/footer? (WCAG 2.4.11 — NEW 2.2)
- [ ] No keyboard trap (Enter/Escape dismisses modals)? (WCAG 2.1.2)
- [ ] Skip link to main content present and functional? (WCAG 2.4.1)
- [ ] All drag & drop actions have keyboard alternative? (WCAG 2.5.7 — NEW 2.2)
- [ ] Click targets at least 24×24px? (WCAG 2.5.8 — NEW 2.2)

---

## Step 3 — Screen Reader Testing

(→ `references/testing-tools.md` for shortcuts and combinations)

Minimum: **NVDA + Chrome**. Additionally: **VoiceOver + Safari** for iOS.

**Test procedure:**
- Headings structure: H key → logical hierarchy H1→H2→H3?
- Landmarks: D key → main, nav, header, footer present?
- Forms: F key → all labels announced? Required fields recognizable?
- Error messages: ARIA live region? Are errors automatically announced?
- Images: Alt text meaningful (not "image123.png")?
- Links: Link text meaningful without context? (no "click here")
- Status messages: Are dynamic updates announced? (WCAG 4.1.3)

---

## Step 4 — Manually Check WCAG 2.2 New SC

(→ `references/wcag-checks.md` for complete list)

Check all 9 new SC in WCAG 2.2 (not detected by axe-core):

| SC | What to check |
|---|---|
| 2.4.11 | Focus indicator not obscured by any element (sticky nav, modals) |
| 2.4.12 | Focus fully visible (AAA) |
| 2.4.13 | Focus indicator: at least 2px border, 3:1 contrast (AAA) |
| 2.5.7 | All drag & drop actions have single-click alternative |
| 2.5.8 | All click targets at least 24×24px (or sufficient spacing) |
| 3.2.6 | Help function (chat, FAQ, phone) always in same location |
| 3.3.7 | No duplicate entry of same data in the same process |
| 3.3.8 | Login/auth does not require memorizing character strings |
| 3.3.9 | Login/auth: no copy-paste restriction (AAA) |

---

## Step 5 — EU Compliance Check

**Relevant when:** Product is offered in the EU and falls under the EU Accessibility Act (Directive 2019/882 / BFSG in DE, effective 28 June 2025).

**Affected:** E-commerce, banking, mobility, telecommunications, e-books, messengers — and all public bodies.

**Requirement:** WCAG 2.2 Level AA via EN 301 549 (European standard).

**EU Compliance Checklist:**
- [ ] WCAG 2.2 AA fully met?
- [ ] Accessibility statement present? (Required: URL + creation date + contact)
- [ ] Feedback mechanism for accessibility problems present?
- [ ] Enforcement authority known? (In DE: market surveillance authority)

---

## Step 6 — Create Report

Sort findings by severity:

| Severity | WCAG Level | Meaning |
|---|---|---|
| Critical (Blocker) | A | Certain user groups completely excluded |
| Serious | A / AA | Significant obstacle for certain groups |
| Moderate | AA | Usable, but with effort |
| Minor | AA / AAA | Comfort issue, no exclusion |

---

## Output — `a11y-audit-report.md`

```markdown
# Accessibility Audit — [Product Name]

**Date:** [Date]
**WCAG Version:** 2.2
**Target Level:** AA
**EU Accessibility Act relevant:** yes/no

## Summary
- Automated tests (axe-core): [X] findings
- Keyboard navigation: [X] findings
- Screen reader (NVDA+Chrome): [X] findings
- WCAG 2.2 new SC: [X] findings
- EU compliance: [met / not met / partial]

## Findings

### Critical (Blocker)
| SC | Element | Description | Recommendation |
|---|---|---|---|
| 1.1.1 | img.logo | No alt text | alt="[Company name] Logo" |

### Serious
| SC | Element | Description | Recommendation |
|---|---|---|---|

### Moderate
| SC | Element | Description | Recommendation |
|---|---|---|---|

## EU Compliance
- [ ] WCAG 2.2 AA met
- [ ] Accessibility statement present
- [ ] Feedback mechanism present
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → WCAG SC + W3C WAI + CMU HCII module
- `references/wcag-checks.md` — Critical SC with level + test method, all 9 new WCAG 2.2 SC
- `references/testing-tools.md` — axe-core / Lighthouse / NVDA / VoiceOver quick reference + audit sequence
