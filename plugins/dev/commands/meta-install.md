---
description: Installiert oder aktualisiert Dev-Best-Practices-Regeln in der CLAUDE.md. Erkennt automatisch ob Erstinstallation oder Update noetig ist. Flags: --essential (default), --full, --update, --section <name>.
argument-hint: "[--essential | --full | --update | --section <security|cicd|architecture>]"
---

Füge die Dev-Best-Practices-Regeln in die CLAUDE.md dieses Projekts ein.
Bestehender Projektkontext wird nicht überschrieben.

Folge exakt der Workflow-Definition in `${CLAUDE_PLUGIN_ROOT}/skills/meta-install/SKILL.md`.

Optionen: $ARGUMENTS
