---
name: install-rules
description: Fügt die Dev-Best-Practices-Regeln als strukturierten Block in die CLAUDE.md eines Zielprojekts ein — ohne bestehenden Projektkontext zu überschreiben. Use this skill whenever the user wants to add best-practice rules to a project, set up a new project with rules, or copy essential-rules into a CLAUDE.md; triggert bei "Regeln einrichten", "install rules", "CLAUDE.md setup", "Best Practices in Projekt einbinden".
---

# Install Rules

Fügt `essential-rules.md` (oder ausgewählte Sections) als dedizierten Block in die
`CLAUDE.md` eines Zielprojekts ein. Bestehender Projektkontext wird nie überschrieben.

## Schritt 0 — Ziel-Projekt & Umfang klären

1. **Ziel-`CLAUDE.md` lokalisieren:**
   - Im aktuellen Verzeichnis (`./CLAUDE.md`)
   - Falls nicht vorhanden: anbieten, eine neue anzulegen

2. **Bestehenden Inhalt lesen:**
   - Ist bereits ein Dev-Best-Practices-Block vorhanden? → zu `check-rules-drift` weiterleiten
   - Welche Sections gibt es schon? (Projektkontext, Commands, Architektur-Notizen)

3. **Umfang bestimmen** (Default: `--essential`):
   - `--essential` → nur `essential-rules.md` (~80 Zeilen, empfohlen für die meisten Projekte)
   - `--full` → alle vier Rule-Files (essential + app + github + architecture, ~670 Zeilen)
   - `--section <name>` → einzelne Section, z.B. `--section security` oder `--section cicd`

   Falls keine Angabe: `--essential` verwenden und kurz erklären warum.

## Schritt 1 — Regeln vorbereiten

1. Lese die gewählten Rule-Files aus `${CLAUDE_PLUGIN_ROOT}/rules/`
2. Bei `--section`: die relevante Section extrahieren
3. Prüfe ob Regeln zum erkannten Stack passen:
   - Python-Projekt ohne TypeScript → TypeScript-spezifische Regeln als `[optional]` markieren
   - Kein Frontend → Frontend/CSS-Sections überspringen
   - Solo-Projekt → ASVS L1 als Default vermerken

## Schritt 2 — In CLAUDE.md einfügen

**Einfüge-Format:**

```markdown
<!-- DEV-BEST-PRACTICES:START — nicht manuell bearbeiten, via /dev-best-practices:install-rules aktualisieren -->
<!-- Version: essential-rules.md @ <Datum> -->

## Dev Best Practices

[Inhalt der Regel-Files]

<!-- DEV-BEST-PRACTICES:END -->
```

**Einfüge-Position:**
- Nach dem projektspezifischen Kontext (Architektur-Beschreibung, Commands)
- Vor projekt-spezifischen Ausnahmen falls vorhanden
- Niemals mitten in einen bestehenden Abschnitt

**Niemals überschreiben:**
- Projektbeschreibung und Kontext
- Bestehende Commands und Workflows
- Dokumentierte Ausnahmen (`[Ausnahme: …]` Blöcke)

## Schritt 3 — Ausgabe & Bestätigung

Zeige dem Nutzer vor dem Schreiben:
1. Welche Rules eingefügt werden (Liste der Sections)
2. Wo in der `CLAUDE.md` der Block eingefügt wird
3. Ob bestehende Inhalte berührt werden (nein → direkt, ja → erst bestätigen lassen)

Nach dem Schreiben:
- Kurze Zusammenfassung: X Regeln aus Y Sections eingefügt
- Hinweis: `check-rules-drift` kann später prüfen ob die Regeln noch aktuell sind

## Regeln
- Nur schreiben wenn der Nutzer es bestätigt hat.
- Bestehenden Projektkontext niemals löschen oder überschreiben.
- Kommentar-Marker (`DEV-BEST-PRACTICES:START/END`) immer setzen — ermöglicht späteres Update durch `check-rules-drift`.
- Falls `CLAUDE.md` nicht existiert: Datei anlegen mit Projekt-Placeholder + Rules-Block, nicht nur die Rules ohne Kontext.
