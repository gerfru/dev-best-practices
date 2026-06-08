---
name: meta-create-skill
description: >
  Erstellt einen neuen Skill für dieses Plugin nach der etablierten Methodik:
  Thema → akademische Recherche (Uni-Curricula + kanonische Bücher) → SKILL.md +
  references/. Nutze diesen Skill wenn du einen neuen /dev-Skill erstellen willst.
  Trigger: "create a new skill", "neuen Skill bauen", "Skill für X erstellen",
  "füge einen Skill hinzu", "add skill", "new skill for X".
  Deckt ab: Themen-Klärung, akademische Recherche, Struktur-Entscheidung,
  Schreiben aller Dateien, Housekeeping (commands/, meta-help, plugin.json).
---

# Create Skill

Erstellt einen neuen Skill nach der etablierten Repo-Methodik:
Thema → akademische Recherche → SKILL.md + references/ → commands/ → Housekeeping.

Jeder Skill hat eine akademische Verankerung (Uni-Kurs oder kanonisches Buch).
SKILL.md enthält nur Workflow. Lookup-Material gehört in references/.

---

## Schritt 0 — Thema & Typ klären

**Fragen stellen:**

1. **Thema:** Was soll der Skill können? Ein Satz.
2. **Typ bestimmen:**

   | Typ | Wann | Beispiele |
   |---|---|---|
   | `design-*` | Etwas von Null entwerfen, Entscheidungen treffen | design-api, design-secure, design-ux |
   | `review-*` | Bestehendes analysieren, Findings reporten | review-arch, review-secure, review-ux |
   | `tool-*` | Operativer Workflow, kein Design/Review | tool-debug, tool-test, tool-style |
   | `meta-*` | Repo- oder Plugin-Wartung | meta-install, meta-sync, meta-drift |

3. **Trigger-Keywords:** Mit welchen Sätzen würde ein Nutzer diesen Skill aufrufen? (5–10 Beispiele)
4. **Output:** Was produziert der Skill? (Datei, Report, Analyse, Menü?)

→ Erst wenn Thema, Typ und Output klar sind: weiter zu Schritt 1.

---

## Schritt 1 — Akademische Recherche

Ziel: den Skill auf eine überprüfbare akademische oder kanonische Quelle verankern.
Methodik aus `docs/academic-basis.md` und `docs/gap-analysis.md`.

### 1a — Uni-Curricula suchen

Durchsuche die Kursverzeichnisse dieser Institutionen nach dem Thema:

**DACH + Europa:** TU Graz, TU Wien, ETH Zürich, EPFL, NTNU, LMU München, KIT
**UK:** Cambridge, Oxford, Imperial College, Edinburgh
**USA:** Stanford, MIT, CMU, UC Berkeley, Caltech, Harvard, Princeton, Cornell, UW, UT Austin

Für jeden gefundenen Kurs fetchen:
- Kursnummer + Titel + Professor
- Vollständige Lecture-Liste (Syllabus / Schedule-Page)
- Ob Slides/Videos öffentlich verfügbar sind
- Direkte URL

### 1b — Kanonische Bücher identifizieren

Prüfe: Gibt es ein Industrie-Standardwerk das besser ist als jeder Uni-Kurs?
(Trifft zu bei: SRE → Google SRE Books, CI/CD → Accelerate, Performance → Brendan Gregg)

Wenn ja: Buch als Primärquelle, Uni-Kurs als sekundäre Vertiefung.

### 1c — Primärquelle entscheiden

| Situation | Primärquelle | Skill-Beschreibung sagt |
|---|---|---|
| Starker Uni-Kurs existiert | Kurs | `grounded in CMU 17-633` |
| Industrie-Buch besser | Buch | `grounded in Google SRE Books` |
| Beides gleichwertig | Beides | `grounded in MIT 6.172 and Brendan Gregg` |
| Nur Framework/Standard | Framework | `grounded in WCAG 2.2 / HAX Guidelines` |

### 1d — Recherche-Ergebnis zusammenfassen

Kurz präsentieren:
- Primärquelle (Kurs + Professor + URL oder Buch + Autor)
- Welche konkreten Themen/Kapitel relevant sind
- Was der Kurs/das Buch NICHT abdeckt (Lücken)

→ Nutzer bestätigt die akademische Basis bevor weitergemacht wird.

---

## Schritt 2 — Skill-Struktur planen

### 2a — SKILL.md Inhalt bestimmen

SKILL.md enthält **nur Workflow** — nummerierte Schritte die Claude ausführt.

Was gehört IN SKILL.md:
- Workflow-Schritte (Step 0, Step 1, ...)
- Entscheidungslogik (wenn X dann Y)
- Standard-Finding-Format (bei review-* Skills)
- Output-Format (welche Datei, welche Struktur)
- Verweise auf references/ Dateien

Was gehört NICHT in SKILL.md (→ references/):
- Lookup-Tabellen (Concept → Course Link)
- Checklisten (Dark Patterns, Security Checks)
- Framework-Referenzen (HAX Guidelines, WCAG Success Criteria)
- Design-Token-Tabellen, Pattern-Kataloge

### 2b — references/ Dateien planen

Entscheide für jede Lookup-Tabelle:

| Inhalt | Dateiname |
|---|---|
| Concept → Kurs/Buch Mapping | `curriculum-mapping.md` |
| Framework-Kurzreferenz | `frameworks.md` |
| Checkliste mit Severity | `<thema>-checks.md` |
| Design-Prinzipien | `design-principles.md` |
| Pattern-Katalog | `<thema>-patterns.md` |

Faustregel: Wenn der Inhalt länger als ~15 Zeilen ist und nicht zum Workflow-Ablauf gehört → eigene Datei.

### 2c — Plan zeigen und bestätigen

```text
Skill-Name: <name>
Typ: design-* / review-* / tool-* / meta-*
Primärquelle: <Kurs oder Buch>

SKILL.md:
  - Schritt 0: ...
  - Schritt 1: ...
  - Schritt N: ...
  - Output: <Dateiname>

references/:
  - curriculum-mapping.md
  - <weitere Dateien>

commands/<name>.md: ja

Housekeeping:
  - meta-help SKILL.md: Skill eintragen
  - plugin.json: description updaten
```

→ Nutzer bestätigt Struktur bevor geschrieben wird.

---

## Schritt 3 — Dateien schreiben

Reihenfolge: references/ zuerst, dann SKILL.md, dann commands/.

### 3a — references/ Dateien

Format-Vorgabe:
```markdown
# <Titel>

| Concept | Reference |
|---|---|
| ... | ... |
```

Für `curriculum-mapping.md`: Concept + Link zum Kurs/Kapitel.
Für Checklisten: Concept + Test + Severity.
Für Frameworks: Kurzreferenz der wichtigsten Punkte ohne Erklärtext.

### 3b — SKILL.md

Pflicht-Elemente:

```markdown
---
name: <skill-name>
description: >
  <Was der Skill macht>. Grounded in <Primärquelle>.
  Trigger: "<Keyword 1>", "<Keyword 2>", ...
  Deckt ab: <Themen>.
---

# <Titel>

<Ein Satz was dieser Skill tut und warum.>

---

## Core Philosophy (<Primärquelle>)

> "<Zitat aus Kurs/Buch>" — <Quelle>

<2–3 Sätze warum dieser Ansatz.>

---

## Schritt 0 — ...
## Schritt 1 — ...
## Schritt N — ...

---

## Output — <Dateiname>

<Output-Format als Markdown-Codeblock>

## Reference Files

- `references/<datei>.md` — <was drin ist>
```

### 3c — commands/<name>.md

```markdown
---
name: <skill-name>
description: <Kurzbeschreibung für Slash-Command-Discovery, 1 Satz>
---
```

---

## Schritt 4 — Housekeeping

Nach dem Schreiben der Dateien:

### 4a — meta-help aktualisieren

`plugins/dev/skills/meta-help/SKILL.md` — neuen Skill in der richtigen Kategorie eintragen:

```markdown
| `/dev:<name>` | <Kurzbeschreibung> |
```

### 4b — plugin.json updaten

`plugins/dev/.claude-plugin/plugin.json`:
- `description`: Skill-Count und -Liste aktualisieren

### 4c — validate-skills.sh ausführen

```bash
bash scripts/validate-skills.sh
```

Muss grün sein bevor committed wird.

### 4d — Abschlussbericht

```text
✓ Erstellt:
  - plugins/dev/skills/<name>/SKILL.md
  - plugins/dev/skills/<name>/references/<datei>.md  (N Dateien)
  - plugins/dev/commands/<name>.md

✓ Aktualisiert:
  - plugins/dev/skills/meta-help/SKILL.md
  - plugins/dev/.claude-plugin/plugin.json

Nächster Schritt: Branch erstellen, committen, PR öffnen.
```

---

## Regeln

- Schritt 0 nie überspringen — Typ und Output klären bevor recherchiert wird.
- Schritt 1 nie überspringen — kein Skill ohne verifizierte akademische Basis.
- Jede akademische Quelle direkt fetchen und verifizieren (keine Kursnummern aus dem Gedächtnis).
- Nutzer bestätigt Recherche-Ergebnis (Schritt 1d) und Struktur-Plan (Schritt 2c) bevor geschrieben wird.
- SKILL.md enthält nur Workflow — kein Lookup-Material.
- Nur schreiben nach Bestätigung.
- Nach dem Schreiben immer validate-skills.sh ausführen.
