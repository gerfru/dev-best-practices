# Dev Best Practices

Dieses Repo enthaelt Best-Practice-Regeln fuer Software-Projekte -- typischerweise groessere Applikationen (RAG-Systeme, AI Agents, Data Pipelines, etc.) mit Web-Frontend.
Drei Stufen: **Essential** (kompakt, fuer CLAUDE.md), **Thematisch** (ausfuehrlichere Regeln), **Reference** (detailliert, fuer Menschen).

## Repo-Struktur

```text
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
- Nach Regel-Aenderungen Mirror aktualisieren: `cp claude/*.md plugins/dev/rules/`

<!-- DEV-BEST-PRACTICES:START — via /dev-best-practices:meta-install aktualisieren -->
<!-- Version: essential-rules.md @ 2026-06-05 | Umfang: essential -->

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
- Security Assessment: `bandit`+`semgrep` (SAST), `pip-audit` (SCA), ASVS 5.0 als Pruefrahmen

### API & Datenbank

- Einheitliches Error-Format: `{ error: { code, message, details } }`
- Rate Limiting auf Middleware/Gateway-Level. Pagination fuer alle Listen
- API-Typ: Intern → tRPC. Extern → REST
- DB: Immer Migrations-Tool (nie manuell SQL auf Prod). Prepared Statements, Least Privilege User
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

- Pre-commit Hooks Pflicht: gitleaks → bandit → Lint+Fix → Format → Type Check
- TS: ESLint Flat Config + Prettier + Husky. Python: Ruff + mypy + pre-commit
- TS Package Manager: pnpm. Python: uv. Lockfiles immer committen
- CI: Jeder PR durch Pipeline (Install → Lint → Type Check → Build/Test → gitleaks)
- Branch Protection auf main: Require PR, Status Checks, No Force Push
- Renovate (nicht Dependabot). devDeps patch Automerge, Major manuell
- PR-Groesse: < 400 LOC, darueber aufteilen

### Testing

- TS: Vitest + Playwright. Python: pytest + Playwright
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
