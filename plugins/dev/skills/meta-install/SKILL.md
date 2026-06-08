---
name: dev:meta-install
description: Adds the dev best practices rules as a structured block to the CLAUDE.md of a target project — or updates an existing block. Use this skill whenever the user wants to add or update best-practice rules in a project CLAUDE.md; triggers for "set up rules", "install rules", "update rules", "CLAUDE.md setup", "update best practices", "update rules".
---

# Install Rules

Inserts `essential-rules.md` (or selected sections) as a dedicated block into the
`CLAUDE.md` of a target project — or updates an existing block in-place.
Existing project context and project exceptions are never overwritten.

## Step 0 — Detect Mode (Install vs. Update)

1. **Locate target `CLAUDE.md`** (current directory `./CLAUDE.md`)

2. **Determine mode:**

   | Situation | Mode |
   |---|---|
   | No `CLAUDE.md` present | **Create new** |
   | `CLAUDE.md` without `DEV-BEST-PRACTICES:START` marker | **Initial install** |
   | `CLAUDE.md` with `DEV-BEST-PRACTICES:START` marker | **Update** |
   | `--force` flag | **Update** even without marker (regenerate block) |

3. **Determine scope** (default: `--essential`):
   - `--essential` → only `essential-rules.md` (~80 lines, recommended)
   - `--full` → all four rule files (essential + app + github + architecture)
   - `--section <name>` → individual section, e.g. `--section security`
   - `--update` → use same scope as last install (read from marker)

   If no specification and update mode: retain the scope documented in the marker.

## Step 1 — Prepare Rules

1. Read the chosen rule files from `${CLAUDE_PLUGIN_ROOT}/rules/`
2. For `--section`: extract the relevant section
3. Check if rules fit the detected stack:
   - Python project without TypeScript → mark TypeScript-specific rules as `[optional]`
   - No frontend → skip frontend/CSS sections
   - Solo project → note ASVS L1 as default

## Step 2a — Initial Install

**Block format:**
```markdown
<!-- DEV-BEST-PRACTICES:START — update via /dev-best-practices:install-rules -->
<!-- Version: essential-rules.md @ <date> | Scope: essential -->

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
   <!-- Version: essential-rules.md @ <new date> | Scope: essential | Previous: <old date> -->
   ```

**What is never touched during an update:**
- Everything outside the marker comments
- `[Exception: …]` blocks inside the old block
- Project description, commands, architecture notes

## Step 3 — Preview & Confirmation

**Show before writing:**

```text
Mode: [Initial install / Update]
File: ./CLAUDE.md
Scope: essential-rules.md (78 lines)

[Update] Old block: Version from <date>, X lines
[Update] New block: Version from today, Y lines
[Update] Saved project exceptions: Z items

Changes outside the block: none

Proceed? (yes/no)
```

After writing:
- `✓ Block [inserted / updated]: X rules, Y sections`
- On update: `Project exceptions preserved: Z items`
- Next step: `check-drift` runs automatically for verification

## Rules
- Only write after confirmation.
- Never touch content outside the markers.
- Always preserve project exceptions — they are deliberate deviations, not errors.
- If `CLAUDE.md` does not exist: create file with project placeholder + rules block.
- After every update call the `check-drift` skill to verify the new block
  was inserted correctly.
