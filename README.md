# Dev Best Practices

Persoenliche Best-Practice-Sammlung fuer Software-Projekte -- typischerweise groessere Applikationen (RAG-Systeme, AI Agents, Data Pipelines, etc.) mit Web-Frontend. Drei Detailstufen: ausfuehrliche Referenz-Docs, thematische Regel-Files und ein kompaktes Essential-File fuer CLAUDE.md.

Das Repo ist ausserdem ein **Claude-Code-Plugin-Marketplace**: einmal installiert, stehen die Befehle `/dev-best-practices:app-design` und `/dev-best-practices:app-eval` in jedem Projekt zur Verfuegung (siehe [Als Claude Code Plugin](#als-claude-code-plugin-app-design--app-eval)).

## Repo-Struktur

```
.claude-plugin/
  marketplace.json                  Marketplace-Katalog (macht das Repo installierbar)
plugins/
  dev-best-practices/
    .claude-plugin/plugin.json      Plugin-Metadaten
    commands/                       Slash-Commands (app-design, app-eval)
    skills/                         Skills (app-design, app-eval) -- auto-trigger
    rules/                          Kopie der claude/*.md (Pruefmassstab fuer die Skills)

reference/                          Detaillierte Dokumentation (fuer Menschen)
  app-best-practices.md             Security, Auth, API, DB, Monitoring, OWASP
  github-best-practices.md          CI/CD, Linting, Testing, Docker, Code Review
  architecture-best-practices.md    Schichten, Patterns, Infra, 12-Factor

claude/                             Kondensierte Regeln (fuer Claude Code)
  essential-rules.md                Alles Wichtige in ~80 Zeilen → in CLAUDE.md einfuegen
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

## Benutzung

### 1. Neues Projekt: Essential Rules in CLAUDE.md

Das `essential-rules.md` in die Projekt-CLAUDE.md kopieren -- passt immer, egal welcher Projekttyp:

```markdown
# CLAUDE.md (im neuen Projekt)

## Projekt
...projektspezifische Infos...

## Best Practices
<!-- Inhalt aus claude/essential-rules.md hier einfuegen -->
```

### 2. Mehr Detail noetig? Thematische Files selektiv ergaenzen

Wenn ein Thema mehr Tiefe braucht (z.B. ausfuehrlichere Security-Regeln), einzelne Sections aus den thematischen Files ergaenzen:

| Projekttyp | Essential + ergaenzen mit |
| --- | --- |
| RAG / AI App mit Web-UI | Nach Bedarf aus allen drei |
| AI Agent / Pipeline Backend | app-rules + github-rules |
| Full-Stack Web App | Nach Bedarf aus allen drei |
| API-only Service | app-rules |
| Quick Prototype | Essential reicht |

### 3. Globale Regeln (optional)

Regeln die fuer ALLE Projekte gelten sollen in `~/.claude/CLAUDE.md` ablegen. Gute Kandidaten:

- Linting/Formatting-Standards (Ruff, ESLint, Prettier)
- Pre-commit Hook Setup
- Git-Workflow (Branch Protection, PR-Template)
- Security-Grundregeln (Secrets, Input-Validierung)

### 4. Nachschlagen

Die `reference/`-Files enthalten die ausfuehrlichen Erklaerungen mit Theorie, Hintergruenden, Vergleichstabellen und Links. Gut fuer:

- Warum eine bestimmte Entscheidung getroffen wurde
- Tool-Vergleiche wenn Alternativen evaluiert werden
- Onboarding / Wissen auffrischen
- Checklisten vor einem Deploy

## Als Claude Code Plugin (app-design / app-eval)

Das Repo stellt als Plugin zwei Befehle bereit:

- `/dev-best-practices:app-design` -- von der App-Idee zu Architektur-/Stack-Entscheidungen, auf Basis der Regeln in diesem Repo
- `/dev-best-practices:app-eval` -- vollstaendiges App-Audit gegen dieselben Regeln (6 Achsen, parallele Subagenten)

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

# Plugin installieren  (Schema: <plugin>@<marketplace-name>)
claude plugin install dev-best-practices@gerald-dev-best-practices

# pruefen
claude plugin marketplace list
```

Danach `claude` starten und z.B. aufrufen:

```
/dev-best-practices:app-eval
```

> Hinweis: Hinter dem `@` steht der **Marketplace-Name** aus `marketplace.json`
> (`gerald-dev-best-practices`), nicht der GitHub-Pfad. Der GitHub-Pfad
> (`gerfru/dev-best-practices`) wird nur beim `add` verwendet.

### Aktualisieren

Regeln/Skills geaendert? Aenderungen pushen, dann auf dem jeweiligen Rechner die aktuelle Version ziehen:

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
- **claude/** synchron halten -- nur Regeln und Entscheidungen, keine Erklaerungen
- **essential-rules.md** ist die Single Source of Truth fuer das Kompaktformat
- Stand-Datum in den Files aktuell halten
- **Nach Regel-Aenderungen** die Regeln ins Plugin spiegeln, damit die Skills den aktuellen Stand pruefen:
  ```bash
  cp claude/*.md plugins/dev-best-practices/rules/
  ```
  (z.B. als `make sync`, damit `claude/` Single Source of Truth bleibt)
- **JSON-Dateien ohne BOM** speichern (`marketplace.json`, `plugin.json`), sonst schlaegt das Hinzufuegen des Marketplace fehl