---
description: Stack-aware debugging - erkennt automatisch Framework/Stack und liefert einen Root-Cause-Plan mit konkreten Fix-Vorschlaegen.
argument-hint: "[Fehlermeldung, Stack Trace oder Problembeschreibung]"
---

Analysiere den folgenden Fehler oder das beschriebene Problem. Erkenne zuerst automatisch
den Stack (package.json, pyproject.toml, Dockerfile …), klassifiziere den Fehler-Typ und
liefere einen strukturierten Root-Cause-Report.

Folge exakt der Workflow-Definition in `${CLAUDE_PLUGIN_ROOT}/skills/tool-debug/SKILL.md`.

Problem: $ARGUMENTS
