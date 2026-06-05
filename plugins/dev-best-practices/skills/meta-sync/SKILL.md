---
name: meta-sync
description: Prüft ob die kompakten claude/*.md Rule-Files noch die Essenz der detaillierten reference/*.md widerspiegeln — findet Sections die in reference/ neu/geändert sind aber noch nicht in claude/ übertragen wurden. Use this skill for maintaining this dev-best-practices repo itself; triggert bei "Regeln synchronisieren", "reference aktualisieren", "claude/ sync", "sind die Rules noch aktuell", Repo-Wartung.
---

# Doc Sync (Repo-intern)

Dieser Skill ist für die Wartung des dev-best-practices Repos selbst.
Maßstab: `reference/*.md` sind die detaillierte Quelle (Master).
`claude/*.md` sind die kondensierte Ableitung (Derived).

## Schritt 0 — Dateipaar-Mapping laden

| Reference (Master) | Claude (Derived) |
|---|---|
| `reference/app-best-practices.md` | `claude/app-rules.md` |
| `reference/github-best-practices.md` | `claude/github-rules.md` |
| `reference/architecture-best-practices.md` | `claude/architecture-rules.md` |

`claude/essential-rules.md` ist eigenständig — es destilliert aus allen drei.
Es wird separat geprüft: Enthält es die wichtigsten Punkte aus allen drei Derived-Files?

## Schritt 1 — Paarweise Analyse

Für jedes Dateipaar (parallel lesbar):

**Was suchen:**

1. **Neue Sections in Reference die in Claude fehlen:**
   - Heading in `reference/` der kein Pendant in `claude/` hat
   - Neue Tools / Frameworks die erwähnt werden (z.B. Biome, Bun, uv, Ruff)
   - Neue Compliance-Anforderungen (ASVS 5.0 Änderungen, neue OWASP-Items)

2. **Veraltete Regeln in Claude:**
   - Empfehlungen in `claude/` die in `reference/` zurückgezogen oder geändert wurden
   - Deprecated Tools die noch in `claude/` stehen
   - Versionsnummern die nicht mehr stimmen

3. **Qualität der Kondensierung:**
   - Ist die Essenz korrekt erfasst oder fehlt ein wichtiger Nuancen?
   - Ist eine Section in `claude/` zu lang geworden (>20% der Reference-Section)?
   - Enthält `claude/` noch Erklärungen die nur in `reference/` gehören?

## Schritt 2 — Essential-Rules Cross-Check

`essential-rules.md` extra prüfen:

1. Enthält es mindestens einen Punkt aus jeder Haupt-Section der drei `claude/`-Files?
2. Gibt es neue Security/Architecture-Regeln in `claude/` die in `essential-rules.md` fehlen aber hingehören?
3. Ist `essential-rules.md` noch unter ~100 Zeilen? (Ziel: kompakt genug für CLAUDE.md)

## Schritt 3 — Sync-Report

```
## Doc Sync Report

### app-rules.md
✓ Aktuell: [X Sections]
⚠ Neu in Reference, fehlt in Claude:
  - [Section] — [was hinzugekommen ist, 1 Satz]
⚠ Veraltet in Claude:
  - [Regel/Tool] — [was sich geändert hat]

### github-rules.md
[analog]

### architecture-rules.md
[analog]

### essential-rules.md Cross-Check
✓ Deckt alle Kern-Sections ab
⚠ Fehlt: [neue kritische Regel die aufgenommen werden sollte]
ℹ Größe: [aktuelle Zeilenzahl] / Ziel: <100 Zeilen

---
### Empfohlene Änderungen (priorisiert)
1. [KRITISCH] [Datei] — [was und warum kritisch]
2. [NORMAL] [Datei] — [was]
3. [MINOR] [Datei] — [was]

Gesamtaufwand: S/M/L
```

## Schritt 4 — Änderungen umsetzen (nur auf Anfrage)

Falls der Nutzer die Änderungen durchführen will:
1. Zeige für jede Änderung: aktueller Text → vorgeschlagener neuer Text
2. Nutzer bestätigt pro Änderung oder für alle
3. Schreibe nur bestätigte Änderungen

## Regeln
- Keine automatischen Änderungen ohne Bestätigung.
- `reference/` wird nie verändert — nur `claude/` und `essential-rules.md`.
- Kondensierung bewahren: `claude/`-Files sollen knapp bleiben. Keine langen Erklärungen rüberkopieren.
- Inhaltliche Korrektheit vor Vollständigkeit: lieber eine Regel weglassen als eine falsch kondensieren.
