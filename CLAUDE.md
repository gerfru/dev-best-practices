# Dev Best Practices

Dieses Repo enthaelt Best-Practice-Regeln fuer Software-Projekte -- typischerweise groessere Applikationen (RAG-Systeme, AI Agents, Data Pipelines, etc.) mit Web-Frontend.
Drei Stufen: **Essential** (kompakt, fuer CLAUDE.md), **Thematisch** (ausfuehrlichere Regeln), **Reference** (detailliert, fuer Menschen).

## Repo-Struktur

```
reference/                          # Detaillierte Dokumentation zum Nachschlagen
  app-best-practices.md             # Security, Auth, API, DB, Monitoring, OWASP
  github-best-practices.md          # CI/CD, Linting, Testing, Docker, Code Review
  architecture-best-practices.md    # Schichten, Patterns, Infra, 12-Factor

claude/                             # Kondensierte Regeln fuer Claude Code / Vibe-Coding
  essential-rules.md                # ~80 Zeilen -- in Projekt-CLAUDE.md einfuegen
  app-rules.md                      # ~170 Zeilen (aus 860)
  github-rules.md                   # ~210 Zeilen (aus 780)
  architecture-rules.md             # ~190 Zeilen (aus 1180)
```

## Verwendung in Projekten

### Standard: essential-rules.md in Projekt-CLAUDE.md kopieren

Reicht fuer die meisten Projekte. ~80 Zeilen, kompakt genug neben projektspezifischem Kontext.

### Mehr Detail noetig?

Einzelne Sections aus den thematischen Files (`app-rules.md`, `github-rules.md`, `architecture-rules.md`) selektiv ergaenzen.

### Global (optional)

Regeln die IMMER gelten in `~/.claude/CLAUDE.md` ablegen:

- Linting/Formatting-Standards
- Git-Workflow
- Security-Grundregeln

## Pflege

- `reference/` aktualisieren wenn sich Best Practices aendern
- `claude/` synchron halten (nur Regeln, keine Erklaerungen)
- `essential-rules.md` ist die Single Source of Truth fuer das Kompaktformat
