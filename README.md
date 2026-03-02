# Dev Best Practices

Persoenliche Best-Practice-Sammlung fuer Software-Projekte -- typischerweise groessere Applikationen (RAG-Systeme, AI Agents, Data Pipelines, etc.) mit Web-Frontend. Drei Detailstufen: ausfuehrliche Referenz-Docs, thematische Regel-Files und ein kompaktes Essential-File fuer CLAUDE.md.

## Repo-Struktur

```
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

## Pflege

- **reference/** aktualisieren wenn sich Best Practices aendern (neue Tools, neue Standards)
- **claude/** synchron halten -- nur Regeln und Entscheidungen, keine Erklaerungen
- **essential-rules.md** ist die Single Source of Truth fuer das Kompaktformat
- Stand-Datum in den Files aktuell halten
