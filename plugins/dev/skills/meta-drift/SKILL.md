---
name: dev:meta-drift
description: Compares the dev-best-practices block in a project CLAUDE.md with the current state of the rule files and shows what is missing, outdated, or newly added. Use this skill whenever the user wants to update their project rules, check if rules are still current, or sync a CLAUDE.md with the latest best practices; triggers for "update rules", "are my rules still current", "drift", "sync CLAUDE.md", "update rules".
---

# Check Drift

Compares what is in the target project with what our rule files currently define.
Shows the delta — without automatically overwriting.

## Step 0 — Load Sources

1. **Current state (TARGET):** Rule files from `${CLAUDE_PLUGIN_ROOT}/rules/`
   - `essential-rules.md` — always
   - `app-rules.md`, `github-rules.md`, `architecture-rules.md` — only if present in the project block

2. **Project state (ACTUAL):** Read `CLAUDE.md` in the target project
   - Extract block between `DEV-BEST-PRACTICES:START` and `DEV-BEST-PRACTICES:END`
   - If no marker: check entire `CLAUDE.md` for best-practices content
   - If no `CLAUDE.md`: redirect to `install-rules`

3. **Read version from marker** (if present):
   ```text
   <!-- Version: essential-rules.md @ 2024-01-15 -->
   ```
   → How old is the installed version?

## Step 1 — Delta Analysis

Compare structurally on three levels:

**Missing sections** (in TARGET, not in ACTUAL):
- New sections added after the last install
- Sections that would be relevant for this stack but are missing

**Outdated content** (in ACTUAL, changed or removed in TARGET):
- Rules that have changed in content (e.g., tool change: `eslint` → `biome`)
- Rules that were deleted because outdated
- Version-specific rules that no longer apply (e.g., deprecated APIs)

**Preserve project exceptions** (in ACTUAL, not in TARGET — intentional):
- `[Exception: …]` blocks
- Project-specific additions
- These are never counted as "drift"

## Step 2 — Output Rule Inventory

Overview of the overall state:

```text
## Rule Inventory — [Project name]

| File              | Installed   | Current | Status       |
|-------------------|-------------|---------|--------------|
| essential-rules   | 2024-01-15  | today   | ⚠ outdated  |
| app-rules         | —           | —       | ✗ missing   |
| github-rules      | 2024-01-15  | today   | ✓ current   |
| architecture-rules| —           | —       | ✗ missing   |

Project exceptions: 2 (will not be touched)
```

## Step 3 — Delta Report

```text
## Rules Drift Report — [Project name]

### Missing Sections (new since last install)
- [Section name] in essential-rules.md → [brief description of what is new]

### Outdated Rules
- [Rule] → was: "[old value]" / now: "[new value]"
  Reason: [why changed]

### Recommendation
[ ] Perform update — X sections affected, effort: S/M
[ ] Only adopt critical changes (security, breaking changes)
[ ] Review manually due to project exceptions

### Next Step
`/dev-best-practices:install-rules` with `--update` to update the block.
Project exceptions are preserved.
```

## Rules
- Never change anything automatically — report only.
- Never count project-specific exceptions and additions as drift.
- If no `DEV-BEST-PRACTICES:START` marker is present: explicitly point out
  that update tracking is only possible after `install-rules`.
- For very old states (>6 months): mark security-relevant changes as `[CRITICAL]`.
