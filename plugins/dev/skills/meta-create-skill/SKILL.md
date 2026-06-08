---
name: dev:meta-create-skill
description: >
  Creates a new skill for this plugin following the established methodology:
  topic → academic research (university curricula + canonical books) → SKILL.md +
  references/. Use this skill when you want to create a new /dev skill.
  Trigger: "create a new skill", "build a new skill", "create skill for X",
  "add a skill", "add skill", "new skill for X".
  Covers: topic clarification, academic research, structure decision,
  writing all files, housekeeping (commands/, meta-help, plugin.json).
---

# Create Skill

Creates a new skill following the established repo methodology:
topic → academic research → SKILL.md + references/ → commands/ → housekeeping.

Every skill has an academic foundation (university course or canonical book).
SKILL.md contains only workflow. Lookup material belongs in references/.

---

## Step 0 — Clarify Topic & Type

**Ask questions:**

1. **Topic:** What should the skill do? One sentence.
2. **Determine type:**

   | Type | When | Examples |
   |---|---|---|
   | `design-*` | Design something from scratch, make decisions | design-api, design-secure, design-ux |
   | `review-*` | Analyze existing work, report findings | review-arch, review-secure, review-ux |
   | `tool-*` | Operational workflow, not design/review | tool-debug, tool-test, tool-style |
   | `meta-*` | Repo or plugin maintenance | meta-install, meta-sync, meta-drift |

3. **Trigger keywords:** What phrases would a user use to invoke this skill? (5–10 examples)
4. **Output:** What does the skill produce? (File, report, analysis, menu?)

→ Only when topic, type, and output are clear: proceed to Step 1.

---

## Step 1 — Academic Research

Goal: anchor the skill in a verifiable academic or canonical source.
Methodology from `docs/academic-basis.md` and `docs/gap-analysis.md`.

### 1a — Search university curricula

Search the course catalogs of these institutions for the topic:

**DACH + Europe:** TU Graz, TU Wien, ETH Zürich, EPFL, NTNU, LMU München, KIT
**UK:** Cambridge, Oxford, Imperial College, Edinburgh
**USA:** Stanford, MIT, CMU, UC Berkeley, Caltech, Harvard, Princeton, Cornell, UW, UT Austin

For each course found, fetch:
- Course number + title + professor
- Complete lecture list (syllabus / schedule page)
- Whether slides/videos are publicly available
- Direct URL

### 1b — Identify canonical books

Check: Is there an industry-standard work that is better than any university course?
(Applies to: SRE → Google SRE Books, CI/CD → Accelerate, Performance → Brendan Gregg)

If yes: book as primary source, university course as secondary deepening.

### 1c — Decide primary source

| Situation | Primary source | Skill description says |
|---|---|---|
| Strong university course exists | Course | `grounded in CMU 17-633` |
| Industry book is better | Book | `grounded in Google SRE Books` |
| Both equally valuable | Both | `grounded in MIT 6.172 and Brendan Gregg` |
| Only framework/standard | Framework | `grounded in WCAG 2.2 / HAX Guidelines` |

### 1d — Summarize research result

Present briefly:
- Primary source (course + professor + URL or book + author)
- Which specific topics/chapters are relevant
- What the course/book does NOT cover (gaps)

→ User confirms the academic basis before proceeding.

---

## Step 2 — Plan Skill Structure

### 2a — Determine SKILL.md content

SKILL.md contains **only workflow** — numbered steps that Claude executes.

What belongs IN SKILL.md:
- Workflow steps (Step 0, Step 1, ...)
- Decision logic (if X then Y)
- Standard finding format (for review-* skills)
- Output format (which file, which structure)
- References to references/ files

What does NOT belong in SKILL.md (→ references/):
- Lookup tables (Concept → course link)
- Checklists (dark patterns, security checks)
- Framework references (HAX Guidelines, WCAG Success Criteria)
- Design token tables, pattern catalogs

### 2b — Plan references/ files

Decide for each lookup table:

| Content | Filename |
|---|---|
| Concept → course/book mapping | `curriculum-mapping.md` |
| Framework quick reference | `frameworks.md` |
| Checklist with severity | `<topic>-checks.md` |
| Design principles | `design-principles.md` |
| Pattern catalog | `<topic>-patterns.md` |

Rule of thumb: If the content is longer than ~15 lines and does not belong to the workflow sequence → separate file.

### 2c — Show and confirm plan

```text
Skill name: <name>
Type: design-* / review-* / tool-* / meta-*
Primary source: <course or book>

SKILL.md:
  - Step 0: ...
  - Step 1: ...
  - Step N: ...
  - Output: <filename>

references/:
  - curriculum-mapping.md
  - <additional files>

commands/<name>.md: yes

Housekeeping:
  - meta-help SKILL.md: add skill entry
  - plugin.json: update description
```

→ User confirms structure before writing.

---

## Step 3 — Write Files

Order: references/ first, then SKILL.md, then commands/.

### 3a — references/ files

Format specification:
```markdown
# <Title>

| Concept | Reference |
|---|---|
| ... | ... |
```

For `curriculum-mapping.md`: concept + link to course/chapter.
For checklists: concept + test + severity.
For frameworks: quick reference of most important points without explanatory text.

### 3b — SKILL.md

Required elements:

```markdown
---
name: <skill-name>
description: >
  <What the skill does>. Grounded in <primary source>.
  Trigger: "<Keyword 1>", "<Keyword 2>", ...
  Covers: <Topics>.
---

# <Title>

<One sentence what this skill does and why.>

---

## Core Philosophy (<Primary source>)

> "<Quote from course/book>" — <Source>

<2–3 sentences why this approach.>

---

## Step 0 — ...
## Step 1 — ...
## Step N — ...

---

## Output — <filename>

<Output format as markdown code block>

## Reference Files

- `references/<file>.md` — <what is in it>
```

### 3c — commands/<name>.md

```markdown
---
name: <skill-name>
description: <Short description for slash command discovery, 1 sentence>
---
```

---

## Step 4 — Housekeeping

After writing the files:

### 4a — Update meta-help

`plugins/dev/skills/meta-help/SKILL.md` — add new skill in the correct category:

```markdown
| `/dev:<name>` | <Short description> |
```

### 4b — Update plugin.json

`plugins/dev/.claude-plugin/plugin.json`:
- `description`: update skill count and list

### 4c — Run validate-skills.sh

```bash
bash scripts/validate-skills.sh
```

Must be green before committing.

### 4d — Completion report

```text
Created:
  - plugins/dev/skills/<name>/SKILL.md
  - plugins/dev/skills/<name>/references/<file>.md  (N files)
  - plugins/dev/commands/<name>.md

Updated:
  - plugins/dev/skills/meta-help/SKILL.md
  - plugins/dev/.claude-plugin/plugin.json

Next step: create branch, commit, open PR.
```

---

## Rules

- Never skip Step 0 — clarify type and output before researching.
- Never skip Step 1 — no skill without a verified academic basis.
- Fetch and verify every academic source directly (no course numbers from memory).
- User confirms research result (Step 1d) and structure plan (Step 2c) before writing.
- SKILL.md contains only workflow — no lookup material.
- Only write after confirmation.
- Always run validate-skills.sh after writing.
