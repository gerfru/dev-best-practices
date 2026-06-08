---
description: Installs or updates dev best practices rules in CLAUDE.md. Automatically detects whether initial installation or update is needed. Flags: --essential (default), --full, --update, --section <name>.
argument-hint: "[--essential | --full | --update | --section <security|cicd|architecture>]"
---

Add the dev best practices rules to this project's CLAUDE.md.
Existing project context will not be overwritten.

Follow exactly the workflow definition in `${CLAUDE_PLUGIN_ROOT}/skills/meta-install/SKILL.md`.

Options: $ARGUMENTS
