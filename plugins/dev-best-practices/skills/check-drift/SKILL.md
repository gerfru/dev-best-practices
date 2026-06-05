---
name: check-drift
description: Vergleicht den Dev-Best-Practices-Block in einer Projekt-CLAUDE.md mit dem aktuellen Stand der Rule-Files und zeigt was fehlt, veraltet oder neu hinzugekommen ist. Use this skill whenever the user wants to update their project rules, check if rules are still current, or sync a CLAUDE.md with the latest best practices; triggert bei "Regeln aktualisieren", "sind meine Rules noch aktuell", "drift", "sync CLAUDE.md", "update rules".
---

# Check Drift

Vergleicht was im Zielprojekt steht mit dem was unsere Rule-Files aktuell definieren.
Zeigt den Delta — ohne automatisch zu überschreiben.

## Schritt 0 — Quellen laden

1. **Aktueller Stand (SOLL):** Rule-Files aus `${CLAUDE_PLUGIN_ROOT}/rules/`
   - `essential-rules.md` — immer
   - `app-rules.md`, `github-rules.md`, `architecture-rules.md` — nur wenn im Projekt-Block vorhanden

2. **Projekt-Stand (IST):** `CLAUDE.md` im Ziel-Projekt lesen
   - Block zwischen `DEV-BEST-PRACTICES:START` und `DEV-BEST-PRACTICES:END` extrahieren
   - Falls kein Marker: gesamte `CLAUDE.md` auf Best-Practices-Inhalte prüfen
   - Falls keine `CLAUDE.md`: zu `install-rules` weiterleiten

3. **Version aus Marker lesen** (falls vorhanden):
   ```
   <!-- Version: essential-rules.md @ 2024-01-15 -->
   ```
   → Wie alt ist die installierte Version?

## Schritt 1 — Delta-Analyse

Vergleiche strukturiert auf drei Ebenen:

**Fehlende Sections** (im SOLL, nicht im IST):
- Neue Sections die nach dem letzten Install hinzugekommen sind
- Sections die für diesen Stack relevant wären aber fehlen

**Veraltete Inhalte** (im IST, in SOLL geändert oder entfernt):
- Regeln die sich inhaltlich geändert haben (z.B. Tool-Wechsel: `eslint` → `biome`)
- Regeln die gelöscht wurden weil überholt
- Versions-spezifische Regeln die nicht mehr gelten (z.B. deprecated APIs)

**Projekt-Ausnahmen bewahren** (im IST, nicht im SOLL — absichtlich):
- `[Ausnahme: …]` Blöcke
- Projektspezifische Ergänzungen
- Diese werden nie als "Drift" gewertet

## Schritt 2 — Rule Inventory ausgeben

Übersicht über den Gesamtstand:

```
## Rule Inventory — [Projektname]

| File              | Installiert | Aktuell | Status     |
|-------------------|-------------|---------|------------|
| essential-rules   | 2024-01-15  | heute   | ⚠ veraltet |
| app-rules         | —           | —       | ✗ fehlt    |
| github-rules      | 2024-01-15  | heute   | ✓ aktuell  |
| architecture-rules| —           | —       | ✗ fehlt    |

Projekt-Ausnahmen: 2 (werden nicht angefasst)
```

## Schritt 3 — Delta-Report

```
## Rules Drift Report — [Projektname]

### Fehlende Sections (neu seit letztem Install)
- [Section-Name] in essential-rules.md → [kurze Beschreibung was neu ist]

### Veraltete Regeln
- [Regel] → war: "[alter Wert]" / jetzt: "[neuer Wert]"
  Grund: [warum geändert]

### Empfehlung
[ ] Update durchführen — X Sections betroffen, Aufwand: S/M
[ ] Nur kritische Changes übernehmen (Security, Breaking Changes)
[ ] Manuell prüfen wegen Projekt-Ausnahmen

### Nächster Schritt
`/dev-best-practices:install-rules` mit `--update` um den Block zu aktualisieren.
Projekt-Ausnahmen bleiben erhalten.
```

## Regeln
- Niemals automatisch etwas ändern — nur Report.
- Projekt-spezifische Ausnahmen und Ergänzungen niemals als Drift werten.
- Wenn kein `DEV-BEST-PRACTICES:START` Marker vorhanden: explizit darauf hinweisen
  dass ein Update-Tracking erst nach `install-rules` möglich ist.
- Bei sehr alten Ständen (>6 Monate): Security-relevante Änderungen als `[KRITISCH]` markieren.
