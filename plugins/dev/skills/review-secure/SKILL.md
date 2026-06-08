---
name: dev:review-secure
description: >
  Security-focused code review skill grounded in TU Graz ISEC Major curriculum
  and top-university references (Stanford CS255/CS355, MIT 6.566/6.5610, CMU 15-414).
  Use this skill whenever the user shares code and asks for a review, audit, security
  check, vulnerability scan, or wants to know if their code is secure. Also trigger
  for questions like "is this crypto correct?", "can you check my authentication?",
  "review my API", or "is this GDPR-compliant?". Covers all languages (C/C++, Python,
  Java, Go, Rust, JS/TS, and others) and evaluates Security, Code Quality, and
  Compliance (EU AI Act, ISO 27001, DSGVO/GDPR). Always use this
  skill for any security-relevant code review — do not rely on general knowledge alone.
---
# ISEC Code Review Skill

A structured, educational security code review grounded in the TU Graz Information
Security curriculum. Every finding is explained — not just flagged.

---

## Core Philosophy

This is not a linter. The goal is to:

1. **Find** concrete security issues in the code
2. **Explain** the underlying security concept so the user understands *why* it matters
3. **Fix** it with a concrete code suggestion
4. **Link** to the Stanford/MIT course where this concept is taught in depth
5. **Stay interactive** — ask the user if they want deeper dives, not just dump findings

---

## Review Workflow

### Step 1 — Orient

Before reviewing, briefly state:

- What language/framework you detected
- What the code appears to do (1–2 sentences)
- What review dimensions you will apply (Security / Code Quality / Compliance)

Ask the user: **"Anything specific you're worried about, or full scan?"**
If they have a specific concern, prioritize that area first.

### Step 2 — Scan All Three Dimensions

Run through all three dimensions for every review. Load the relevant reference
file for detailed check lists:

- **Security** → `references/security-checks.md`
- **Code Quality** → `references/quality-checks.md`
- **Compliance** → `references/compliance-checks.md`

### Step 3 — Report Findings

For each finding, use the **standard finding format** (see below).
Group findings by severity: Critical → High → Medium → Low → Info.

After listing all findings, ask:

> "Want me to go deeper on any of these? I can explain the full attack scenario,
> show a working exploit example, or walk through the fix in more detail."

### Step 4 — Interactive Follow-up

Respond to follow-up questions using the reference files for depth.
If the user asks "why is X dangerous?" — explain the concept fully, not just repeat the finding.

---

## Standard Finding Format

```text
### [SEVERITY] Finding Title
**Category:** Security | Quality | Compliance
**Location:** file.py, line N (or "general pattern")
**CWE:** CWE-XXX (if applicable)

**What:** One sentence describing what the code does wrong.

**Why it matters:** One paragraph explaining the underlying security concept —
what an attacker can do with this, what the theoretical basis is, and why
the code's current approach fails. No jargon without explanation.

**Fix:**
[Concrete code suggestion or architectural change]

**Learn more:** [Stanford/MIT course link + topic name]
```

**Severity levels:**

| Level       | Meaning                                                                        |
| ----------- | ------------------------------------------------------------------------------ |
| 🔴 CRITICAL | Directly exploitable; confidentiality/integrity/availability at immediate risk |
| 🟠 HIGH     | Exploitable under realistic conditions; significant impact                     |
| 🟡 MEDIUM   | Exploitable with additional conditions; moderate impact                        |
| 🔵 LOW      | Defense-in-depth issue; low direct impact                                      |
| ⚪ INFO     | Best practice / code quality / compliance note                                 |

---

## Security Concept → Reference Mapping

When a finding relates to one of these concepts, always include the corresponding link.
Stanford CS255/CS355, MIT 6.566/6.5610, CMU 15-414, ISEC: `references/curriculum-mapping.md`

---

## Interaction Patterns

### When the user asks "why is X dangerous?"

Explain the full attack scenario. Use the reference files for depth.
Example structure: "Here's what an attacker does step by step: ..."

### When the user asks "how do I fix it properly?"

Give a complete, working code example. Do not give pseudocode unless the
codebase is language-agnostic by nature.

### When the user says "I don't understand [concept]"

Explain it from first principles. Reference the Stanford/MIT course and
offer to walk through it interactively.

### When the user asks "is this GDPR/ISO compliant?"

Use `references/compliance-checks.md` for the specific control mapping.

---

## Output — Report File

Write the complete results to `./review-secure-report.md`:

```markdown
# Security Code Review Report — [Context]
Language: ... | Framework: ... | Date: YYYY-MM-DD

## Overall Assessment
[🔴/🟠/🟡/🟢] — One-sentence rationale

## Findings
### 🔴 Critical (N)
### 🟠 High (N)
### 🟡 Medium (N)
### 🔵 Low / ⚪ Info (N)

## Statistics
| Severity | Security | Quality | Compliance |
|----------|----------|---------|------------|
| 🔴 Critical | N | N | N |
| 🟠 High | N | N | N |
| 🟡 Medium | N | N | N |

## Top 3 Immediate Actions
1. ...
2. ...
3. ...
```

## Report Footer

Every generated report ends with:

```markdown
---
*Generated with AI assistance (Claude Code + dev-best-practices plugin).
Findings should be verified — not a substitute for manual penetration testing.*
```

---

## Reference Files

Load these on demand — do not load all at once:

- `references/security-checks.md` — Full security checklist organized by vulnerability class
- `references/quality-checks.md` — Code quality patterns with security implications
- `references/compliance-checks.md` — GDPR, ISO 27001, EU AI Act control mappings

Load the relevant file(s) when starting the scan of that dimension.
