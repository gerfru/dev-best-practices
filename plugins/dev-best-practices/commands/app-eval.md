---
description: Vollstaendiges App-Audit gegen die Dev-Best-Practices-Regeln (6 Achsen, parallele Subagenten).
argument-hint: "[optionaler Pfad zum Eingrenzen]"
---

Fuehre das App-Evaluierungs-Audit aus. Maszstab sind die Regel-Files unter
`${CLAUDE_PLUGIN_ROOT}/rules/` (essential-rules.md, app-rules.md, github-rules.md,
architecture-rules.md). Folge exakt der Workflow-Definition in
`${CLAUDE_PLUGIN_ROOT}/skills/app-eval/SKILL.md`.
Scope auf diesen Pfad eingrenzen, falls angegeben: $ARGUMENTS
