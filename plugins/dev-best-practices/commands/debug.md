---
description: Stack-aware Debugging — erkennt automatisch Framework/Stack und liefert einen strukturierten Root-Cause-Plan mit konkreten Fix-Vorschlägen.
argument-hint: "[Fehlermeldung, Stack Trace oder kurze Problembeschreibung]"
---

Analysiere den folgenden Fehler oder das beschriebene Problem. Erkenne zuerst automatisch
den Stack (package.json, pyproject.toml, Dockerfile …), klassifiziere den Fehler-Typ und
liefere einen strukturierten Root-Cause-Report.

Folge exakt der Workflow-Definition in `${CLAUDE_PLUGIN_ROOT}/skills/debug-specialist/SKILL.md`.

Problem: $ARGUMENTS
