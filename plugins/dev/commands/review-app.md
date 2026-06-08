---
description: Complete app audit against the dev best practices rules (6 axes, parallel subagents).
argument-hint: "[optional path to narrow scope]"
---

Run the app evaluation audit. The standard is the rule files under
`${CLAUDE_PLUGIN_ROOT}/rules/` (essential-rules.md, app-rules.md, github-rules.md,
architecture-rules.md). Follow exactly the workflow definition in
`${CLAUDE_PLUGIN_ROOT}/skills/review-app/SKILL.md`.
Narrow scope to this path if provided: $ARGUMENTS
