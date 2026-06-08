---
name: dev:meta-sync
description: Checks whether the compact claude/*.md rule files still reflect the essence of the detailed reference/*.md — finds sections that are new/changed in reference/ but not yet transferred to claude/. Use this skill for maintaining this dev-best-practices repo itself; triggers for "synchronize rules", "update reference", "claude/ sync", "are the rules still current", repo maintenance. ONLY for the dev-best-practices repo itself — not for other projects.
---

# Doc Sync (repo-internal)

This skill is for maintaining the dev-best-practices repo itself.
Standard: `reference/*.md` are the detailed source (master).
`claude/*.md` are the condensed derivation (derived).

## Step 0 — Load File Pair Mapping

| Reference (Master) | Claude (Derived) |
|---|---|
| `reference/app-best-practices.md` | `claude/app-rules.md` |
| `reference/github-best-practices.md` | `claude/github-rules.md` |
| `reference/architecture-best-practices.md` | `claude/architecture-rules.md` |

`claude/essential-rules.md` is standalone — it distills from all three.
It is checked separately: does it contain the most important points from all three derived files?

## Step 1 — Pairwise Analysis

For each file pair (can be read in parallel):

**What to look for:**

1. **New sections in reference missing in claude:**
   - Heading in `reference/` with no counterpart in `claude/`
   - New tools / frameworks mentioned (e.g. Biome, Bun, uv, Ruff)
   - New compliance requirements (ASVS 5.0 changes, new OWASP items)

2. **Outdated rules in claude:**
   - Recommendations in `claude/` that were withdrawn or changed in `reference/`
   - Deprecated tools still in `claude/`
   - Version numbers that are no longer correct

3. **Quality of condensation:**
   - Is the essence correctly captured or is an important nuance missing?
   - Has a section in `claude/` grown too long (>20% of the reference section)?
   - Does `claude/` still contain explanations that belong only in `reference/`?

## Step 2 — Essential-Rules Cross-Check

Check `essential-rules.md` separately:

1. Does it contain at least one point from each main section of the three `claude/` files?
2. Are there new security/architecture rules in `claude/` that are missing from `essential-rules.md` but belong there?
3. Is `essential-rules.md` still under ~100 lines? (Goal: compact enough for CLAUDE.md)

## Step 3 — Sync Report

```text
## Doc Sync Report

### app-rules.md
✓ Current: [X sections]
⚠ New in reference, missing in claude:
  - [Section] — [what was added, 1 sentence]
⚠ Outdated in claude:
  - [Rule/Tool] — [what changed]

### github-rules.md
[same structure]

### architecture-rules.md
[same structure]

### essential-rules.md Cross-Check
✓ Covers all core sections
⚠ Missing: [new critical rule that should be included]
ℹ Size: [current line count] / Target: <100 lines

---
### Recommended Changes (prioritized)
1. [CRITICAL] [File] — [what and why critical]
2. [NORMAL] [File] — [what]
3. [MINOR] [File] — [what]

Total effort: S/M/L
```

## Step 4 — Implement Changes (only on request)

If the user wants to make the changes:
1. Show for each change: current text → proposed new text
2. User confirms per change or for all
3. Only write confirmed changes

## Rules
- No automatic changes without confirmation.
- `reference/` is never changed — only `claude/` and `essential-rules.md`.
- Preserve condensation: `claude/` files should stay concise. Do not copy over long explanations.
- Content correctness over completeness: better to omit a rule than condense it incorrectly.
