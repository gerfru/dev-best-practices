# Dev Best Practices

Dieses Repo enthaelt Best-Practice-Regeln fuer Software-Projekte (RAG-Systeme, AI Agents, Data Pipelines, Full-Stack Web Apps) und ein **Claude Code Plugin** mit 24 Skills.

## Repo-Struktur

```text
.claude-plugin/
  marketplace.json          # Macht dieses Repo als Marketplace installierbar

plugins/dev/
  .claude-plugin/
    plugin.json             # Plugin-Metadaten (name: "dev", version: "2.0.0")
  commands/                 # Slash-Command-Definitionen (eine Datei pro Skill)
  skills/                   # Skill-Workflow-Definitionen (auto-triggered)
  rules/                    # Mirror von claude/*.md (wird von Skills als Referenz genutzt)

claude/                     # Kondensierte Regeln fuer Claude Code
  essential-rules.md        # ~80 Zeilen -- in Projekt-CLAUDE.md einfuegen
  app-rules.md              # App-Regeln im Detail
  github-rules.md           # GitHub / CI-Regeln im Detail
  architecture-rules.md     # Architektur-Regeln im Detail

reference/                  # Detaillierte Dokumentation zum Nachschlagen
  app-best-practices.md     # Security, Auth, API, DB, Monitoring, OWASP
  github-best-practices.md  # CI/CD, Linting, Testing, Docker, Code Review
  architecture-best-practices.md  # Schichten, Patterns, Infra, 12-Factor

docs/
  skill-research-basis.md   # Akademische & Industrie-Quellen pro Skill

scripts/
  validate-skills.sh        # Plugin-Struktur-Validator (CI + pre-commit)
```

## Plugin-Skills (24)

```text
DESIGN:  design-app, design-secure, design-api, design-data, design-migration,
         design-ux, design-llm, design-observability, design-cicd, design-iac
REVIEW:  review-app, review-arch, review-secure, review-ux, review-llm
TOOLS:   tool-debug, tool-test, tool-style, tool-a11y, tool-perf
META:    meta-help, meta-install, meta-drift, meta-sync, meta-create-skill
```

Navigationsmenue: `/dev:meta-help`

## Verwendung in Projekten

**Plugin installieren:** `claude plugin install dev@gerald-dev-best-practices`

**Nur Regeln (ohne Plugin):** `claude/essential-rules.md` in Projekt-CLAUDE.md kopieren, oder `/dev:meta-install` verwenden.

**Mehr Detail:** Sections aus `claude/app-rules.md`, `claude/github-rules.md`, `claude/architecture-rules.md` selektiv ergaenzen.

## Pflege

- `reference/` aktualisieren wenn sich Best Practices aendern
- `claude/` synchron halten (nur Regeln, keine Erklaerungen)
- Mirror aktualisieren nach Regel-Aenderungen: `cp claude/*.md plugins/dev/rules/`
- Neuen Skill hinzufuegen: `/dev:meta-create-skill`
- Quellen und akademische Basis: `docs/skill-research-basis.md`

<!-- DEV-BEST-PRACTICES:START — via /dev-best-practices:meta-install aktualisieren -->
<!-- Version: essential-rules.md @ 2026-06-08 | Umfang: essential | Vorher: 2026-06-05 -->

## Dev Best Practices

### Security

- Security Headers setzen: CSP (`default-src 'self'`), HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy
- CSP-Strategie: Nonce-basiert mit `'strict-dynamic'`. `'unsafe-inline'` nur fuer `style-src`
- Auth an 3 Schichten: Middleware → Route → **Data Access Layer** (wichtigste!)
- Passwort: bcrypt (cost ≥ 12) / Argon2id, nie Plaintext. Rate Limiting auf Login
- Sessions: httpOnly, secure, sameSite=Lax
- Input validieren an System-Grenze: TS → Zod, Python → Pydantic
- SQL: Immer Prepared Statements. Shell: Nie User-Input in Commands
- DOM XSS: Kein `innerHTML` mit User-Daten. Trusted Types + DOMPurify bei dynamischem HTML
- Keine Secrets in Error-Responses. Keine Secrets loggen
- `.env` nie committen, `.env.example` committen. Env-Validierung beim App-Start (crasht sofort wenn Variable fehlt)
- Security Assessment: `ruff-S`+`semgrep` (SAST), `pip-audit` (SCA), ASVS 5.0 als Pruefrahmen

### API & Datenbank

- Einheitliches Error-Format: `{ error: { code, message, details } }`
- Rate Limiting auf Middleware/Gateway-Level. Pagination fuer alle Listen
- API-Typ: Intern → tRPC. Extern → REST
- DB: Immer Migrations-Tool (nie manuell SQL auf Prod). Prepared Statements, Least Privilege User, TLS zum DB-Server
- ORM-Wahl: Query Builder (Drizzle, SQLAlchemy Core) als Sweet Spot
- Connection Pooling Pflicht. Serverless → externer Pooler

### Architecture

- **Feature-basierte** Ordnerstruktur (nicht technisch)
- Schichtung: Routes → Services → Data Access (2-3 Schichten reichen fuer Solo)
- **Starte mit Monolith.** Microservices nur bei konkretem Grund
- Monorepo fuer Full-Stack (Turborepo / pnpm Workspaces / uv Workspaces)
- 12-Factor: Config in Env, Stateless Processes, Logs auf Stdout, Port Binding
- Server Components als Default (React/Next.js). `"use client"` nur bei Interaktivitaet
- Server State (TanStack Query) und Client State (useState/Zustand) nie mischen

### GitHub & CI/CD

- Pre-commit Hooks Pflicht: gitleaks → ruff (Lint+Fix inkl. S-Regeln) → Format → Type Check
- TS: ESLint Flat Config + Prettier + Husky. Python: Ruff + mypy + pre-commit
- TS Package Manager: pnpm. Python: uv. Lockfiles immer committen
- CI: Jeder PR durch Pipeline (Install → Lint → Type Check → Build/Test → gitleaks)
- Branch Protection auf main: Require PR, Status Checks, No Force Push
- Renovate (nicht Dependabot). devDeps patch Automerge, Major manuell. Dependabot Alerts aktivieren (Security-Meldungen)
- PR-Groesse: < 400 LOC, darueber aufteilen

### Testing

- TS: Vitest + Testing Library + MSW (API-Mocking) + Playwright (E2E). Python: pytest + Playwright
- Prioritaet: 1) API Endpoints 2) Data Transformationen 3) E2E Smoke Test
- Tests testen Verhalten, nicht Implementierung. Mocke nur an Systemgrenzen
- Coverage: 70-80% Lines. Kritische Pfade (Auth, Payment) ~100%. 100% gesamt ist kein Ziel

### Docker & Deployment

- Multi-Stage Build (Builder + Runner). Base Images mit Digest pinnen
- Non-root User. HEALTHCHECK. `.dockerignore` pflegen
- Ports nur auf `127.0.0.1` binden. Named Volumes fuer Prod
- Reverse Proxy vor der App (Caddy / Nginx). Automatisches HTTPS
- Health Checks: `/health` (Liveness) + `/ready` (Readiness)
- Container-Scanning: Trivy (CRITICAL, HIGH, exit-code 1)
- Feature Flags fuer Zero-Downtime: neues Verhalten hinter Flag → ausrollen → Flag entfernen. Kill Switch fuer sofortiges Rollback

### Monitoring & Logging

- Structured Logging (JSON): TS → Pino, Python → structlog. Timestamps UTC
- Error Tracking: Sentry. Uptime: UptimeRobot. Logs: Better Stack / Axiom
- Alert-Schwellen: Error Rate > 1%, p95 > 2s, CPU/Memory > 80%
- OpenTelemetry als Standard. Metrics/Traces erst bei Bedarf

### Accessibility

- Gesetzlich Pflicht (EU Accessibility Act, BFSG)
- Semantisches HTML, Heading-Hierarchie, alt auf Bildern, Fokus-Styles nicht entfernen
- Testen: axe-core + Lighthouse (automatisch), Tastatur + Screen Reader (manuell)

<!-- DEV-BEST-PRACTICES:END -->
