---
name: dev-meta-install
description: Adds the dev best practices rules as a structured block to the CLAUDE.md (or, for Copilot CLI, optionally .github/copilot-instructions.md) of a target project — or updates an existing block. Can also copy the skill library itself into a project for standalone GitHub Copilot CLI discovery. Use this skill whenever the user wants to add or update best-practice rules in a project, or wants these skills available under GitHub Copilot CLI; triggers for "set up rules", "install rules", "update rules", "CLAUDE.md setup", "update best practices", "update rules", "install for copilot", "copilot cli setup", "standalone skills".
---

# Install Rules

Inserts `essential-rules.md` (or selected sections) as a dedicated block into a
target project's instructions file — or updates an existing block in-place.
Existing project context and project exceptions are never overwritten.
Can also copy the skill library into a project for tools without a plugin/marketplace
mechanism (Copilot CLI standalone mode).

## Step 0 — Determine Target & Mode

1. **Determine target** (flag `--target claude|copilot-cli`, default `claude`):
   - `--target claude` (default): write into `./CLAUDE.md` — unchanged, existing behavior.
   - `--target copilot-cli`: write into `./CLAUDE.md` as well by default — GitHub Copilot
     CLI reads `CLAUDE.md` directly as a first-class instructions file, so no separate
     file is needed. If the user passes `--copilot-native`, write into
     `./.github/copilot-instructions.md` instead (same block format), for projects that
     want a Copilot-idiomatic file and don't use Claude Code at all.
   - **If both `./CLAUDE.md` (with an existing `DEV-BEST-PRACTICES` block) and
     `./.github/copilot-instructions.md` would end up existing at once:** warn the user
     explicitly in the Step 3 preview — GitHub Copilot CLI defines no precedence order
     between multiple instruction files and only warns to "avoid conflicting
     instructions," so duplicated blocks across two files should be a deliberate choice,
     not an accident.

2. **Locate target file** (per the resolved target/flag above).

3. **Determine mode:**

   | Situation | Mode |
   |---|---|
   | Target file not present | **Create new** |
   | Target file without `DEV-BEST-PRACTICES:START` marker | **Initial install** |
   | Target file with `DEV-BEST-PRACTICES:START` marker | **Update** |
   | `--force` flag | **Update** even without marker (regenerate block) |

4. **Determine scope** (default: `--essential`):
   - `--essential` → only `essential-rules.md` (~80 lines, recommended)
   - `--full` → all four rule files (essential + app + github + architecture)
   - `--section <name>` → individual section, e.g. `--section security`
   - `--update` → use same scope as last install (read from marker)

   If no specification and update mode: retain the scope documented in the marker.

5. **Standalone skills mode** (`--target copilot-cli --standalone-skills`): skip
   rules-block installation entirely and go to Step 4 instead — this mode copies the
   skill library itself rather than the rules text.

## Step 1 — Prepare Rules

1. Read the chosen rule files from `../../rules/`
2. For `--section`: extract the relevant section
3. Check if rules fit the detected stack:
   - Python project without TypeScript → mark TypeScript-specific rules as `[optional]`
   - No frontend → skip frontend/CSS sections
   - Solo project → note ASVS L1 as default

## Step 2a — Initial Install

**Block format:**
```markdown
<!-- DEV-BEST-PRACTICES:START — update via /dev-best-practices:install-rules -->
<!-- Version: essential-rules.md @ <date> | Scope: essential | Target: claude|copilot-cli -->

## Dev Best Practices

[Content of rule files]

<!-- DEV-BEST-PRACTICES:END -->
```

**Insert position:**
- After the project-specific context (architecture, commands)
- Before project-specific exceptions if present
- Never in the middle of an existing section

## Step 2b — Update (block already present)

1. **Save project exceptions:** Everything inside the block that begins with `[Exception:`
   or was manually annotated → store temporarily

2. **Replace old block:** Replace exactly the text between `DEV-BEST-PRACTICES:START` and
   `DEV-BEST-PRACTICES:END` (including markers) with the new block

3. **Restore project exceptions:** Insert saved exceptions at the end of the new block
   (before `DEV-BEST-PRACTICES:END`), with comment `<!-- Project exceptions -->`

4. **Update version marker:**
   ```text
   <!-- Version: essential-rules.md @ <new date> | Scope: essential | Target: claude|copilot-cli | Previous: <old date> -->
   ```

**What is never touched during an update:**
- Everything outside the marker comments
- `[Exception: …]` blocks inside the old block
- Project description, commands, architecture notes

## Step 3 — Preview & Confirmation

**Show before writing:**

```text
Mode: [Initial install / Update]
Target: claude | copilot-cli
File: ./CLAUDE.md  (or ./.github/copilot-instructions.md with --copilot-native)
Scope: essential-rules.md (78 lines)

[Update] Old block: Version from <date>, X lines
[Update] New block: Version from today, Y lines
[Update] Saved project exceptions: Z items

[If both CLAUDE.md and .github/copilot-instructions.md would exist with a block]
⚠ Both CLAUDE.md and .github/copilot-instructions.md contain a Dev Best Practices
  block. Copilot CLI defines no precedence between them — keep both in sync manually
  or pick one.

Changes outside the block: none

Proceed? (yes/no)
```

After writing:
- `✓ Block [inserted / updated]: X rules, Y sections`
- On update: `Project exceptions preserved: Z items`
- Next step: `check-drift` runs automatically for verification

## Step 4 — Standalone Skills Mode (`--target copilot-cli --standalone-skills`)

For projects that don't use Copilot CLI's plugin/marketplace mechanism at all and want
the skill library available via Copilot's standalone skill discovery.

1. **Ask which discovery location** the project should use (Copilot CLI checks all
   three, project-scoped): `.github/skills/`, `.claude/skills/`, or `.agents/skills/`.
   Call this `<location>` below (e.g. `.github/skills/`).
2. **Copy each `../<name>/` skill directory** (all 27 — `SKILL.md` plus any
   `references/`) directly into `<location>/<name>/` (e.g. `.github/skills/design-api/`).
   The relative-path convention from Step 1's fix means this is a plain recursive copy,
   no rewriting needed.
3. **Also copy `../../rules/`** (all four rule files) into the parent of `<location>`,
   under `rules/` (e.g. `.github/skills/` → copy to `.github/rules/`) — `meta-install`
   and `meta-drift` resolve `../../rules/` relative to their own `SKILL.md` inside
   `<location>/<name>/`, so without this the two rules-related skills would be copied
   but broken.
4. **Report** exactly which skill directories and rule files were copied and where.
5. **Note the limitation explicitly:** standalone-copied skills have no autoUpdate —
   future rule/skill changes require re-running this step manually. This is unlike the
   marketplace install path, which stays current automatically.

## Rules
- Only write after confirmation.
- Never touch content outside the markers.
- Always preserve project exceptions — they are deliberate deviations, not errors.
- If the target file does not exist: create it with project placeholder + rules block.
- After every rules-block update call the `check-drift` skill to verify the new block
  was inserted correctly. (Standalone skills mode has no drift-check equivalent — see
  its noted limitation above.)
- Default target is always `claude` unless `--target copilot-cli` is explicitly given —
  never change behavior for existing callers.
