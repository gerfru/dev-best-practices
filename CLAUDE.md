# Dev Best Practices

This repo contains best-practice rules for software projects (RAG systems, AI agents, data pipelines, full-stack web apps) and a **Claude Code Plugin** with 27 skills that also works as a **GitHub Copilot CLI plugin** (see "Copilot CLI Support" below).

## Repo Structure

```text
.claude-plugin/
  marketplace.json          # Makes this repo installable as a marketplace plugin

plugins/dev/
  .claude-plugin/
    plugin.json             # Plugin metadata (name: "dev", version: "3.0.0") — also read by Copilot CLI (fallback lookup path)
  commands/                 # Slash command definitions (one file per skill) — Claude Code only, Copilot CLI has no equivalent
  skills/                   # Skill workflow definitions (auto-triggered) — shared by Claude Code and Copilot CLI
  rules/                    # Mirror of claude/*.md (used by skills as reference)

claude/                     # Condensed rules for Claude Code
  essential-rules.md        # ~80 lines -- insert into project CLAUDE.md
  app-rules.md              # App rules in detail
  github-rules.md           # GitHub / CI rules in detail
  architecture-rules.md     # Architecture rules in detail

reference/                  # Detailed documentation for reference
  app-best-practices.md     # Security, Auth, API, DB, Monitoring, OWASP
  github-best-practices.md  # CI/CD, Linting, Testing, Docker, Code Review
  architecture-best-practices.md  # Layers, Patterns, Infra, 12-Factor

docs/
  skill-research-basis.md   # Academic & industry sources per skill

scripts/
  validate-skills.sh        # Plugin structure validator (CI + pre-commit)
```

## Plugin Skills (27)

```text
DESIGN:  design-app, design-secure, design-api, design-data, design-migration,
         design-ux, design-llm, design-observability, design-cicd, design-iac,
         design-public
REVIEW:  review-app, review-arch, review-secure, review-ux, review-llm,
         review-public
TOOLS:   tool-debug, tool-test, tool-style, tool-a11y, tool-perf
META:    meta-help, meta-install, meta-drift, meta-sync, meta-create-skill
```

Navigation menu: `/dev:meta-help`

## Usage in Projects

**Install plugin (Claude Code):** `claude plugin install dev@gerald-dev-best-practices`

**Install plugin (GitHub Copilot CLI):** `copilot plugin marketplace add gerfru/dev-best-practices` then `copilot plugin install dev@gerald-dev-best-practices` — see "Copilot CLI Support" below.

**Rules only (without plugin):** Copy `claude/essential-rules.md` into project CLAUDE.md, or use `/dev:meta-install`.

**More detail:** Selectively add sections from `claude/app-rules.md`, `claude/github-rules.md`, `claude/architecture-rules.md`.

## Copilot CLI Support

This plugin is dual-compatible with Claude Code and GitHub Copilot CLI, since both tools
converged on a near-identical plugin architecture:

- **Manifests are reused as-is.** `plugins/dev/.claude-plugin/plugin.json` sits at one of
  Copilot CLI's fallback lookup paths and has no `skills` field — the exact condition both
  tools need (Claude Code rejects a `skills` field; Copilot CLI auto-discovers `skills/`
  only when it's absent). `.claude-plugin/marketplace.json` is also a valid Copilot CLI
  lookup path. No second manifest or generated duplicate tree exists in this repo.
- **`SKILL.md` files use plain relative paths** (`../../rules/...`, `../other-skill/SKILL.md`)
  for all cross-file references, never `${CLAUDE_PLUGIN_ROOT}` — that template variable is
  Claude Code-only and Copilot CLI does not expand it. `${CLAUDE_PLUGIN_ROOT}` remains fine
  inside `plugins/dev/commands/*.md`, which is Claude Code-only (Copilot CLI has no
  slash-command-router concept — skills are natively slash-invocable there via discovery).
- **`meta-install` supports `--target claude|copilot-cli`** — for Copilot CLI it writes into
  the same `CLAUDE.md` by default (Copilot CLI reads it directly as an instructions file),
  or `.github/copilot-instructions.md` with `--copilot-native`. A `--standalone-skills` mode
  copies the skill library into a project's `.github/skills/`, `.claude/skills/`, or
  `.agents/skills/` for Copilot CLI users not using the plugin/marketplace mechanism.
- **Skill `name:` fields use `dev-<skill>` (hyphen, not colon).** Verified live: Copilot CLI
  rejects `:` in skill names ("must contain only ASCII letters, numbers, hyphens,
  underscores"); Claude Code's own `/dev:<skill>` slash-invocation is unaffected since it's
  driven by `commands/<skill>.md` (plugin name + command filename), never by this
  frontmatter field.

## Maintenance

- Update `reference/` when best practices change
- Keep `claude/` in sync (rules only, no explanations)
- Update mirror after rule changes: `cp claude/*.md plugins/dev/rules/`
- Add new skill: `/dev:meta-create-skill`
- Sources and academic basis: `docs/skill-research-basis.md`

<!-- DEV-BEST-PRACTICES:START — update via /dev-best-practices:meta-install -->
<!-- Version: essential-rules.md @ 2026-06-08 | Scope: essential | Previous: 2026-06-05 -->

## Dev Best Practices

### Security

- Set security headers: CSP (`default-src 'self'`), HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy
- CSP strategy: Nonce-based with `'strict-dynamic'`. `'unsafe-inline'` only for `style-src`
- Auth at 3 layers: Middleware → Route → **Data Access Layer** (most important!)
- Password: bcrypt (cost ≥ 12) / Argon2id, never plaintext. Rate limiting on login
- Sessions: httpOnly, secure, sameSite=Lax
- Validate input at system boundary: TS → Zod, Python → Pydantic
- SQL: Always prepared statements. Shell: Never user input in commands
- DOM XSS: No `innerHTML` with user data. Trusted Types + DOMPurify for dynamic HTML
- No secrets in error responses. Never log secrets
- Never commit `.env`, do commit `.env.example`. Validate env vars at app start (crashes immediately if variable is missing)
- Security assessment: `ruff-S`+`semgrep` (SAST), `pip-audit` (SCA), ASVS 5.0 as verification framework

### API & Database

- Uniform error format: `{ error: { code, message, details } }`
- Rate limiting at middleware/gateway level. Pagination for all lists
- API type: Internal → tRPC. External → REST
- DB: Always use a migration tool (never manual SQL on prod). Prepared statements, least privilege user, TLS to DB server
- ORM choice: Query builder (Drizzle, SQLAlchemy Core) as sweet spot
- Connection pooling required. Serverless → external pooler

### Architecture

- **Feature-based** folder structure (not technical)
- Layering: Routes → Services → Data Access (2-3 layers are enough for solo)
- **Start with a monolith.** Microservices only for a concrete reason
- Monorepo for full-stack (Turborepo / pnpm Workspaces / uv Workspaces)
- 12-Factor: Config in env, stateless processes, logs to stdout, port binding
- Server components as default (React/Next.js). `"use client"` only for interactivity
- Never mix server state (TanStack Query) with client state (useState/Zustand)

### GitHub & CI/CD

- Pre-commit hooks required: gitleaks → ruff (lint+fix incl. S-rules) → format → type check
- TS: ESLint Flat Config + Prettier + Husky. Python: Ruff + mypy + pre-commit
- TS package manager: pnpm. Python: uv. Always commit lockfiles
- CI: Every PR through pipeline (install → lint → type check → build/test → gitleaks)
- Branch protection on main: Require PR, status checks, no force push
- Renovate (not Dependabot). devDeps patch automerge, major manual. Enable Dependabot alerts (security notifications)
- PR size: < 400 LOC, split above that

### Testing

- TS: Vitest + Testing Library + MSW (API mocking) + Playwright (E2E). Python: pytest + Playwright
- Priority: 1) API endpoints 2) data transformations 3) E2E smoke test
- Tests test behavior, not implementation. Mock only at system boundaries
- Coverage: 70-80% lines. Critical paths (auth, payment) ~100%. 100% overall is not the goal

### Docker & Deployment

- Multi-stage build (builder + runner). Pin base images with digest
- Non-root user. HEALTHCHECK. Maintain `.dockerignore`
- Bind ports only to `127.0.0.1`. Named volumes for prod
- Reverse proxy in front of the app (Caddy / Nginx). Automatic HTTPS
- Health checks: `/health` (liveness) + `/ready` (readiness)
- Container scanning: Trivy (CRITICAL, HIGH, exit-code 1)
- Feature flags for zero-downtime: new behavior behind flag → roll out → remove flag. Kill switch for immediate rollback

### Monitoring & Logging

- Structured logging (JSON): TS → Pino, Python → structlog. Timestamps UTC
- Error tracking: Sentry. Uptime: UptimeRobot. Logs: Better Stack / Axiom
- Alert thresholds: error rate > 1%, p95 > 2s, CPU/memory > 80%
- OpenTelemetry as standard. Metrics/traces only when needed

### Accessibility

- Legally required (EU Accessibility Act, BFSG)
- Semantic HTML, heading hierarchy, alt on images, don't remove focus styles
- Testing: axe-core + Lighthouse (automated), keyboard + screen reader (manual)

<!-- DEV-BEST-PRACTICES:END -->
