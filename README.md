# Dev Best Practices

Persoenliche Best-Practice-Sammlung fuer Software-Projekte -- typischerweise groessere Applikationen (RAG-Systeme, AI Agents, Data Pipelines, etc.) mit Web-Frontend. Drei Detailstufen: ausfuehrliche Referenz-Docs, thematische Regel-Files und ein kompaktes Essential-File fuer CLAUDE.md.

Das Repo ist ausserdem ein **Claude-Code-Plugin-Marketplace**: einmal installiert, stehen alle Befehle in jedem Projekt zur Verfuegung (siehe [Als Claude Code Plugin](#als-claude-code-plugin)).

## Repo-Struktur

```
.claude-plugin/
  marketplace.json                  Marketplace-Katalog (macht das Repo installierbar)
plugins/
  dev-best-practices/
    .claude-plugin/plugin.json      Plugin-Metadaten
    commands/                       Slash-Commands (alle unten gelisteten Befehle)
    skills/                         Skills mit Workflow-Definitionen -- auto-trigger
    rules/                          Kopie der claude/*.md (Pruefmassstab fuer die Skills)

reference/                          Detaillierte Dokumentation (fuer Menschen)
  app-best-practices.md             Security, Auth, API, DB, Monitoring, OWASP
  github-best-practices.md          CI/CD, Linting, Testing, Docker, Code Review
  architecture-best-practices.md    Schichten, Patterns, Infra, 12-Factor

claude/                             Kondensierte Regeln (fuer Claude Code)
  essential-rules.md                Alles Wichtige in ~80 Zeilen
  app-rules.md                      App-Regeln ausfuehrlicher (~170 Zeilen)
  github-rules.md                   GitHub/CI-Regeln ausfuehrlicher (~210 Zeilen)
  architecture-rules.md             Architektur-Regeln ausfuehrlicher (~190 Zeilen)
```

## Die drei Stufen

| Stufe | Files | Zeilen | Zweck |
| --- | --- | --- | --- |
| **Essential** | `claude/essential-rules.md` | ~80 | In CLAUDE.md einfuegen. Kompakt genug fuer jedes Projekt |
| **Thematisch** | `claude/app-rules.md` etc. | ~570 | Vertiefte Regeln pro Thema. Selektiv nachschlagen oder einfuegen |
| **Reference** | `reference/*.md` | ~2800 | Ausfuehrliche Docs mit Theorie, Vergleichen, Links. Fuer Menschen |

## Als Claude Code Plugin

Das Repo stellt als Plugin acht Befehle bereit -- aufgeteilt in drei Gruppen:

### Analyse & Planung

| Befehl | Was er tut |
| --- | --- |
| `/dev-best-practices:app-design` | App-Idee → Architektur-/Stack-Entscheidungen auf Basis der Regeln |
| `/dev-best-practices:app-eval` | Vollstaendiges App-Audit (6 Achsen, parallele Subagenten); erkennt Stack automatisch |

### Entwicklungs-Assistenten (stack-aware)

Alle drei erkennen automatisch Sprache, Framework und vorhandenes Setup -- keine manuelle Konfiguration noetig.

| Befehl | Was er tut |
| --- | --- |
| `/dev-best-practices:debug [Fehlermeldung]` | Root-Cause-Analyse: klassifiziert den Fehler-Typ, prueft stack-spezifische Ursachen (Next.js, FastAPI, Docker, DB …), liefert konkreten Fix |
| `/dev-best-practices:test [Fokus]` | Erkennt Test-Framework + Coverage-Stand, schreibt fehlende Tests oder entwirft Test-Strategie gemaess Testpyramide |
| `/dev-best-practices:styling [Aufgabe]` | Erkennt CSS-System (Tailwind, CSS Modules, SCSS, CSS-in-JS) + Komponenten-Library, liefert Loesung im Stil des vorhandenen Systems |

### Regel-Management

| Befehl | Was er tut |
| --- | --- |
| `/dev-best-practices:install-rules [--essential\|--full\|--section X]` | Fuegt `essential-rules.md` automatisch in die `CLAUDE.md` des aktuellen Projekts ein. Erkennt ob Erstinstallation oder Update noetig ist. Projekt-Ausnahmen bleiben erhalten. |
| `/dev-best-practices:check-drift` | Vergleicht den installierten Rules-Block mit dem aktuellen Stand -- zeigt fehlende Sections, veraltete Regeln, empfiehlt Update |
| `/dev-best-practices:doc-sync` | Repo-intern: prueft ob `claude/*.md` noch die Essenz von `reference/*.md` widerspiegelt |

### Typischer Workflow

**Neues Projekt einrichten:**
```
/dev-best-practices:install-rules
```
Fuegt `essential-rules.md` mit Versions-Markern in `CLAUDE.md` ein. Einmalig, kein Copy-Paste.

**Bestehende Installation aktualisieren:**
```
/dev-best-practices:check-drift     # Was hat sich geaendert?
/dev-best-practices:install-rules   # Update durchfuehren (Marker erkannt → in-place Update)
```

**Laufende Entwicklung:**
```
/dev-best-practices:debug [Fehler]     # Fehler analysieren
/dev-best-practices:test               # Fehlende Tests schreiben
/dev-best-practices:styling [Problem]  # CSS-Frage klaeren
/dev-best-practices:app-eval           # Gesamtaudit vor Release
```

## Benutzung ohne Plugin (manuell)

### Neues Projekt: Essential Rules in CLAUDE.md

Das `essential-rules.md` manuell in die Projekt-CLAUDE.md kopieren -- oder `/dev-best-practices:install-rules` verwenden (automatisch, empfohlen).

| Projekttyp | Essential + ergaenzen mit |
| --- | --- |
| RAG / AI App mit Web-UI | Nach Bedarf aus allen drei |
| AI Agent / Pipeline Backend | app-rules + github-rules |
| Full-Stack Web App | Nach Bedarf aus allen drei |
| API-only Service | app-rules |
| Quick Prototype | Essential reicht |

### Globale Regeln (optional)

Regeln die fuer ALLE Projekte gelten sollen in `~/.claude/CLAUDE.md` ablegen:

- Linting/Formatting-Standards (Ruff, ESLint, Prettier)
- Pre-commit Hook Setup
- Git-Workflow (Branch Protection, PR-Template)
- Security-Grundregeln (Secrets, Input-Validierung)

### Nachschlagen

Die `reference/`-Files enthalten ausfuehrliche Erklaerungen mit Theorie, Hintergruenden, Vergleichstabellen und Links. Gut fuer Tool-Vergleiche, Onboarding und Pre-Deploy-Checklisten.

## Plugin installieren

Voraussetzung: Claude Code ist installiert. Einmal pro Rechner einrichten, danach in jedem Projekt verfuegbar.

### Windows -- ueber Claude Code in VS Code

1. In VS Code links auf das **Claude-Icon** (Spark) klicken → der Claude-Code-Chat oeffnet sich.
2. Ins Eingabefeld tippen: `/plugin` → der Dialog **Manage Plugins** oeffnet sich.
3. Tab **Marketplaces** → Feld ausfuellen mit `gerfru/dev-best-practices` → **Add**.
4. Tab **Plugins** → `dev-best-practices` auswaehlen → **Install**.
5. Testen: `/dev-best-practices:app-design eine kleine Habit-Tracker-App`

### Mac / Linux -- ueber bash (CLI)

```bash
# Marketplace hinzufuegen (GitHub-Pfad)
claude plugin marketplace add gerfru/dev-best-practices

# Plugin installieren (Schema: <plugin>@<marketplace-name>)
claude plugin install dev-best-practices@gerald-dev-best-practices

# pruefen
claude plugin marketplace list
```

> Hinweis: Hinter dem `@` steht der **Marketplace-Name** aus `marketplace.json`
> (`gerald-dev-best-practices`), nicht der GitHub-Pfad.

### Plugin aktualisieren

Regeln/Skills geaendert? Aenderungen pushen, dann auf dem jeweiligen Rechner:

```bash
# Mac/Linux
claude plugin marketplace update gerald-dev-best-practices
```

Windows (im Claude-Code-Chat): `/plugin` → Tab **Marketplaces** → beim Eintrag `gerald-dev-best-practices` auf **Refresh** klicken.

In einer laufenden Session danach `/reload-plugins`, damit Aenderungen ohne Neustart greifen.

### Troubleshooting

- **„Failed to parse marketplace file ... Unrecognized token"**: Eine JSON-Datei
  (`marketplace.json` / `plugin.json`) hat ein BOM. Unter Windows entfernen:
  ```powershell
  Get-ChildItem -Recurse -File -Path .claude-plugin,plugins | ForEach-Object {
    $c = Get-Content -Raw -LiteralPath $_.FullName
    [System.IO.File]::WriteAllText($_.FullName, $c, (New-Object System.Text.UTF8Encoding($false)))
  }
  ```
  Dann pushen und den Marketplace auf den Clients neu holen (entfernen + neu hinzufuegen).
- **Befehle erscheinen nicht** nach der Installation: `/reload-plugins` ausfuehren.
- **`claude plugin marketplace ...` „unknown command"** (aeltere Version): stattdessen
  `claude` starten und dieselben Befehle als Slash-Kommandos nutzen
  (`/plugin marketplace add ...`, `/plugin install ...`).

## Pflege

- **reference/** aktualisieren wenn sich Best Practices aendern (neue Tools, neue Standards)
- **claude/** synchron halten -- nur Regeln, keine Erklaerungen; `/dev-best-practices:doc-sync` zeigt Drift
- **essential-rules.md** ist die Single Source of Truth fuer das Kompaktformat
- **Nach Regel-Aenderungen** die Regeln ins Plugin spiegeln:
  ```bash
  cp claude/*.md plugins/dev-best-practices/rules/
  ```
- **JSON-Dateien ohne BOM** speichern (`marketplace.json`, `plugin.json`), sonst schlaegt das Hinzufuegen des Marketplace fehl
