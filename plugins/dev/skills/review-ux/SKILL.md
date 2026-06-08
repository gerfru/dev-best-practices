---
name: dev:review-ux
description: >
  Systematic UX audit of an existing product, feature, or design against
  the four canonical Human-AI Interaction frameworks: Microsoft HAX 18 Guidelines
  (Amershi et al., CHI 2019), Google PAIR Guidebook (23 Patterns), CHI 2024
  Generative AI Design Principles (IBM Research, 6 Principles), and Nielsen Norman
  Group AI Design Anti-Patterns.
  Use this skill whenever the user wants to audit, evaluate, or critique existing
  UX/UI — or asks "is this good UX?", "what's wrong with this interface?",
  "review this design", "what dark patterns or AI anti-patterns are here?",
  "is the trust design right?", "UX feedback for my feature", "can you check
  my onboarding flow". Covers all product types: web apps, mobile, AI assistants,
  chatbots, dashboards, internal tools, voice UIs, design mockups.
---

# UX Review (framework-based)

Evaluates existing UX/UI against the canonical HCI frameworks.
TARGET = HAX · PAIR · CHI 2024 · NNG. ACTUAL = the described or submitted design.
Every finding cites the violated guideline.

---

## Step 0 — Determine Context & Audit Scope

**Auto-Discovery: What has been provided?**

| Input Type | Approach |
|-----------|---------|
| Screenshot / Mockup | Analyze directly; describe UI elements |
| Code (HTML/JSX/Templates) | Read and derive UI structure |
| Verbally described feature | Use description as basis; mark assumptions |
| Link to live product (provided by user) | User's description as basis |
| Design spec (Figma export, MD document) | Read and derive structure |

**Infer from context:**
- **AI involvement:** Recommendations / generation / classification / agents present?
  → If yes: apply CHI 2024 + HAX Phase 3+4 fully
- **User type:** Experts / non-experts / mixed → adjust finding complexity level
- **Product phase:** Prototype / Beta / Production → adjust severity threshold
- **Channel:** Web / Mobile / Voice / Dashboard → activate channel-specific guidelines

Report to the user concisely what was detected: `Type: Web App | AI: Recommendation Engine | Users: Consumers | Phase: Production`.

---

## Step 1 — Seven Audit Dimensions

Work through all seven dimensions systematically. Findings in the format:

```text
[G-Code / P-Code] Title · Severity (Critical/High/Medium/Low) · Finding · Fix
```

Severity definition:
- **Critical** — Trust breach, dangerous overreliance, complete disorientation
- **High** — Important guideline violated; measurably harms user experience
- **Medium** — Improvement recommended; no immediate harm
- **Low** — Cosmetic or only relevant at scale

---

### Dimension 1 — Expectations & Mental Models
*HAX G1–G2 · PAIR Ch.2 · CHI 2024 P2 · NNG ELIZA Effect*

Questions:
- Does the interface clearly communicate what the system **can** and **cannot** do? (HAX G1/G2)
- Is there onboarding that answers the four PAIR questions (can / cannot / changes / improve)?
- Are there signs of the ELIZA effect — anthropomorphic language creating false expectations? (NNG)
- For GenAI: Is it communicated that the same inputs can produce variable outputs? (CHI 2024 P4 S1)
- Are there examples or demos that teach effective use? (CHI 2024 P2 S2)

---

### Dimension 2 — Trust & Transparency
*HAX G10–G11 · PAIR P11–P13, Ch.3 · CHI 2024 P3 · NNG*

Questions:
- Is confidence display present? Is the representation format appropriate for this user group? (PAIR P11)
- Are explanations provided for AI decisions? Are they decision-relevant rather than exhaustive? (PAIR P12)
- Is there source transparency for factual claims? (CHI 2024 P3 S2)
- Is the AI's role clearly defined (partner / assistant / tool)? (CHI 2024 P3 S4)
- Is friction present where overreliance would be dangerous? (CHI 2024 P3 S3)
- Does heavy formatting prevent critical evaluation of outputs? (NNG)

---

### Dimension 3 — Feedback & User Control
*HAX G7–G9, G15–G17 · PAIR P15–P18 · CHI 2024 P5*

Questions:
- Can users efficiently **enable** and **dismiss** AI features? (HAX G7/G8)
- Can users efficiently **correct** errors? (HAX G9)
- Is there granular feedback (item-level, not just "thumbs up/down global")? (HAX G15)
- Do users see how their actions **influence** the system? (HAX G16)
- Are there **global controls** for system-wide settings? (HAX G17)
- Is the automation level appropriate for the trust level and risk? (PAIR P14/P17)

---

### Dimension 4 — Error Handling & Graceful Failure
*HAX G9–G11 · PAIR Ch.6 · CHI 2024 P6 · NNG*

Questions:
- Are AI error states communicated to the user in an understandable way?
- Is there a seamless fallback to manual control when automation fails? (PAIR P18)
- Is uncertainty made visible — or are uncertain outputs presented confidently? (CHI 2024 P6 S1)
- Are "Edit / Regenerate / Undo" paths available for AI outputs? (CHI 2024 P6 S3)
- Are there feedback channels when users identify an error? (CHI 2024 P6 S4)
- Does the system conservatively restrict actions when uncertain? (HAX G10)

---

### Dimension 5 — Long-term & Adaptation
*HAX G12–G18*

Questions:
- Does the system retain relevant context from earlier sessions? (HAX G12)
- Does the system learn from user behavior? Is this communicated? (HAX G13)
- Are updates/changes to behavior or capabilities communicated? (HAX G18)
- Are system updates introduced gradually, not abruptly? (HAX G14)
- Are there mechanisms for users to manage their history or learned preferences?

---

### Dimension 6 — Anti-Pattern Check
*NNG · PAIR P1–P3 · CHI 2024 P1*

Checklist — report every identified anti-pattern as a finding:

| Anti-Pattern | Test |
|-------------|------|
| Technology-first: AI without validated user problem | Is there a concrete user problem behind the feature? |
| "Powered by AI" as value prop | Is user benefit shown or just the technology? |
| Chat-default without validation | Is chat the right model for this task? |
| Broad unscoped AI | Are capability boundaries clearly defined and communicated? |
| No prompt support | Do users have help formulating requests? |
| Over-anthropomorphization | Does language/design suggest false human-likeness? |
| Heavy formatting over accuracy | Does polished output prevent critical evaluation? |
| No feedback channel | Can users report and correct system errors? |
| Proactive at wrong timing | Does the system interrupt ongoing tasks? (HAX G3) |
| Overreliance without friction | Are critical decisions sufficiently slowed down? |

---

### Dimension 7 — Dark Patterns & Ethical Design
*EU Digital Services Act · GDPR Art. 7 · FTC Guidelines*

Distinction from Dimension 6: Dimension 6 checks poor AI UX.
Dimension 7 checks intentional manipulation of the user — independent of AI involvement.

Full checklist with severity and EU/FTC references: `references/dark-patterns.md`

---

## Step 2 — Consolidate Findings

1. Sort all findings by **severity** (Critical → Low)
2. Assign a **traffic light** per dimension: 🟢 / 🟡 / 🔴
3. Separately list Top-3 Quick Wins (high impact, low effort)
4. Mark findings without a file/screen reference as `[Assumption - to be verified]`

---

## Step 3 — Write Report

Output to `./review-ux-report.md`:

```markdown
# UX Review: [Product / Feature Name]
Date: YYYY-MM-DD
Framework basis: HAX (18 Guidelines) · PAIR (23 Patterns) · CHI 2024 (6 Principles) · NNG

## Detected Context
[Type, AI involvement, user type, phase, channel]

## Traffic Light Overview
| Dimension | Status | #Critical | #High | Most violated guideline |
|-----------|--------|-----------|-------|------------------------|
| Expectations & Mental Models | 🟡 | 0 | 1 | HAX G1: Capabilities not communicated |
| Trust & Transparency | 🔴 | 1 | 2 | NNG: Over-anthropomorphization |
| Feedback & Control | 🟢 | 0 | 0 | — |
| Error Handling | 🟡 | 0 | 1 | PAIR P18: No manual fallback |
| Long-term & Adaptation | 🟢 | 0 | 0 | — |
| AI Anti-Pattern Check | 🔴 | 1 | 1 | Chat-default without validation |
| Dark Patterns | 🟢 | 0 | 0 | — |

## Top-3 Quick Wins
1. [Title] · [HAX/PAIR/CHI code] · Effort: S (<30min) · [concrete fix]
2. …
3. …

## Full Finding List

### Critical
- [G-Code] **Title** · Finding: … · Fix: … · Reference: HAX G11

### High
- …

### Medium
- …

### Low
- …

## Not Evaluated / Assumptions
- [To be verified]: …

---
*Generated with AI assistance (Claude Code + dev-best-practices plugin).
Findings should be verified — not a substitute for manual usability testing with real users.*
```

---

## Rules

- No speculative findings. Only with concrete reference to the submitted design or
  a clearly demonstrable gap. Mark uncertain items as `[to be verified]`.
- Every finding names the specific violated guideline (HAX G-No. / PAIR P-No. / CHI P-No. / NNG), not just a generic principle.
- **Do not auto-fix anything.** Report first, then implement on request.
- Accessibility problems that violate the EU Accessibility Act / BFSG → always report as **High** or **Critical**.
- Do not double-report anti-patterns: Dimension 6 = AI UX Anti-Patterns, Dimension 7 = Manipulation / Dark Patterns — these two categories are deliberately separate.
- Explicitly mention positive findings — what works well and why. A UX review is not a pure bug report.

---

## Framework Quick Reference

Quick reference for all four frameworks (HAX · PAIR · CHI 2024 · NNG): `references/frameworks.md`
