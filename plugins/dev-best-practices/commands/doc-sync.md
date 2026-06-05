---
description: Repo-Wartung - prueft ob claude/*.md noch die Essenz von reference/*.md widerspiegelt und findet Drift zwischen Master- und Derived-Files.
argument-hint: "[optional: app | github | architecture | essential]"
---

Prüfe ob die kompakten Rule-Files unter claude/ noch mit den detaillierten reference/-Files
übereinstimmen. Finde neue Sections, veraltete Regeln und Kondensierungs-Probleme.

Folge exakt der Workflow-Definition in `${CLAUDE_PLUGIN_ROOT}/skills/doc-sync/SKILL.md`.

Fokus: $ARGUMENTS
