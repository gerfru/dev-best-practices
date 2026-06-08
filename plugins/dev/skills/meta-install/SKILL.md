---
name: meta-install
description: Fügt die Dev-Best-Practices-Regeln als strukturierten Block in die CLAUDE.md eines Zielprojekts ein — oder aktualisiert einen bestehenden Block. Use this skill whenever the user wants to add or update best-practice rules in a project CLAUDE.md; triggert bei "Regeln einrichten", "install rules", "rules updaten", "CLAUDE.md setup", "Best Practices aktualisieren", "update rules".
---

# Install Rules

Fügt `essential-rules.md` (oder ausgewählte Sections) als dedizierten Block in die
`CLAUDE.md` eines Zielprojekts ein — oder aktualisiert einen bestehenden Block in-place.
Bestehender Projektkontext und Projekt-Ausnahmen werden nie überschrieben.

## Schritt 0 — Modus erkennen (Install vs. Update)

1. **Ziel-`CLAUDE.md` lokalisieren** (aktuelles Verzeichnis `./CLAUDE.md`)

2. **Modus bestimmen:**

   | Situation | Modus |
   |---|---|
   | Keine `CLAUDE.md` vorhanden | **Neu anlegen** |
   | `CLAUDE.md` ohne `DEV-BEST-PRACTICES:START` Marker | **Erstinstallation** |
   | `CLAUDE.md` mit `DEV-BEST-PRACTICES:START` Marker | **Update** |
   | `--force` Flag | **Update** auch ohne Marker (Block neu erzeugen) |

3. **Umfang bestimmen** (Default: `--essential`):
   - `--essential` → nur `essential-rules.md` (~80 Zeilen, empfohlen)
   - `--full` → alle vier Rule-Files (essential + app + github + architecture)
   - `--section <name>` → einzelne Section, z.B. `--section security`
   - `--update` → gleichen Umfang wie beim letzten Install verwenden (aus Marker lesen)

   Falls keine Angabe und Update-Modus: den im Marker dokumentierten Umfang beibehalten.

## Schritt 1 — Regeln vorbereiten

1. Lese die gewählten Rule-Files aus `${CLAUDE_PLUGIN_ROOT}/rules/`
2. Bei `--section`: die relevante Section extrahieren
3. Prüfe ob Regeln zum erkannten Stack passen:
   - Python-Projekt ohne TypeScript → TypeScript-spezifische Regeln als `[optional]` markieren
   - Kein Frontend → Frontend/CSS-Sections überspringen
   - Solo-Projekt → ASVS L1 als Default vermerken

## Schritt 2a — Erstinstallation

**Block-Format:**
```markdown
<!-- DEV-BEST-PRACTICES:START — via /dev-best-practices:install-rules aktualisieren -->
<!-- Version: essential-rules.md @ <Datum> | Umfang: essential -->

## Dev Best Practices

[Inhalt der Regel-Files]

<!-- DEV-BEST-PRACTICES:END -->
```

**Einfüge-Position:**
- Nach dem projektspezifischen Kontext (Architektur, Commands)
- Vor projekt-spezifischen Ausnahmen falls vorhanden
- Niemals mitten in einen bestehenden Abschnitt

## Schritt 2b — Update (Block bereits vorhanden)

1. **Projekt-Ausnahmen sichern:** Alles innerhalb des Blocks das mit `[Ausnahme:` beginnt
   oder manuell annotiert wurde → zwischenspeichern

2. **Alten Block ersetzen:** Exakt den Text zwischen `DEV-BEST-PRACTICES:START` und
   `DEV-BEST-PRACTICES:END` (inkl. Marker) durch den neuen Block ersetzen

3. **Projekt-Ausnahmen wiederherstellen:** Gesicherte Ausnahmen ans Ende des neuen Blocks
   einfügen (vor `DEV-BEST-PRACTICES:END`), mit Kommentar `<!-- Projekt-Ausnahmen -->`

4. **Version-Marker aktualisieren:**
   ```text
   <!-- Version: essential-rules.md @ <neues Datum> | Umfang: essential | Vorher: <altes Datum> -->
   ```

**Was beim Update nie angefasst wird:**
- Alles außerhalb der Marker-Kommentare
- `[Ausnahme: …]` Blöcke innerhalb des alten Blocks
- Projektbeschreibung, Commands, Architektur-Notizen

## Schritt 3 — Vorschau & Bestätigung

**Vor dem Schreiben zeigen:**

```text
Modus: [Erstinstallation / Update]
Datei: ./CLAUDE.md
Umfang: essential-rules.md (78 Zeilen)

[Update] Alter Block: Version vom <Datum>, X Zeilen
[Update] Neuer Block: Version vom heute, Y Zeilen
[Update] Gesicherte Projekt-Ausnahmen: Z Stück

Änderungen außerhalb des Blocks: keine

Fortfahren? (ja/nein)
```

Nach dem Schreiben:
- `✓ Block [eingefügt / aktualisiert]: X Regeln, Y Sections`
- Bei Update: `Projekt-Ausnahmen erhalten: Z Stück`
- Nächster Schritt: `check-drift` läuft automatisch zur Verifikation

## Regeln
- Nur schreiben nach Bestätigung.
- Niemals Inhalt außerhalb der Marker anfassen.
- Projekt-Ausnahmen immer erhalten — sie sind bewusste Abweichungen, kein Fehler.
- Falls `CLAUDE.md` nicht existiert: Datei mit Projekt-Placeholder + Rules-Block anlegen.
- Nach jedem Update den `check-drift` Skill aufrufen um zu verifizieren dass der neue
  Block korrekt eingefügt wurde.
