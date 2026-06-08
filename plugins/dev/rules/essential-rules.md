# Essential Rules

The most important rules for every project -- compact enough for CLAUDE.md.
More detailed rules: `app-rules.md`, `github-rules.md`, `architecture-rules.md`

---

## Security

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

## API & Database

- Uniform error format: `{ error: { code, message, details } }`
- Rate limiting at middleware/gateway level. Pagination for all lists
- API type: Internal → tRPC. External → REST
- DB: Always use a migration tool (never manual SQL on prod). Prepared statements, least privilege user, TLS to DB server
- ORM choice: Query builder (Drizzle, SQLAlchemy Core) as sweet spot
- Connection pooling required. Serverless → external pooler

## Architecture

- **Feature-based** folder structure (not technical)
- Layering: Routes → Services → Data Access (2-3 layers are enough for solo)
- **Start with a monolith.** Microservices only for a concrete reason
- Monorepo for full-stack (Turborepo / pnpm Workspaces / uv Workspaces)
- 12-Factor: Config in env, stateless processes, logs to stdout, port binding
- Server components as default (React/Next.js). `"use client"` only for interactivity
- Never mix server state (TanStack Query) with client state (useState/Zustand)

## GitHub & CI/CD

- Pre-commit hooks required: gitleaks → ruff (lint+fix incl. S-rules) → format → type check
- TS: ESLint Flat Config + Prettier + Husky. Python: Ruff + mypy + pre-commit
- TS package manager: pnpm. Python: uv. Always commit lockfiles
- CI: Every PR through pipeline (install → lint → type check → build/test → gitleaks)
- Branch protection on main: Require PR, status checks, no force push
- Renovate (not Dependabot). devDeps patch automerge, major manual. Enable Dependabot alerts (security notifications)
- PR size: < 400 LOC, split above that

## Testing

- TS: Vitest + Testing Library + MSW (API mocking) + Playwright (E2E). Python: pytest + Playwright
- Priority: 1) API endpoints 2) data transformations 3) E2E smoke test
- Tests test behavior, not implementation. Mock only at system boundaries
- Coverage: 70-80% lines. Critical paths (auth, payment) ~100%. 100% overall is not the goal

## Docker & Deployment

- Multi-stage build (builder + runner). Pin base images with digest
- Non-root user. HEALTHCHECK. Maintain `.dockerignore`
- Bind ports only to `127.0.0.1`. Named volumes for prod
- Reverse proxy in front of the app (Caddy / Nginx). Automatic HTTPS
- Health checks: `/health` (liveness) + `/ready` (readiness)
- Container scanning: Trivy (CRITICAL, HIGH, exit-code 1)
- Feature flags for zero-downtime: new behavior behind flag → roll out → remove flag. Kill switch for immediate rollback

## Monitoring & Logging

- Structured logging (JSON): TS → Pino, Python → structlog. Timestamps UTC
- Error tracking: Sentry. Uptime: UptimeRobot. Logs: Better Stack / Axiom
- Alert thresholds: error rate > 1%, p95 > 2s, CPU/memory > 80%
- OpenTelemetry as standard. Metrics/traces only when needed

## Accessibility

- Legally required (EU Accessibility Act, BFSG)
- Semantic HTML, heading hierarchy, alt on images, don't remove focus styles
- Testing: axe-core + Lighthouse (automated), keyboard + screen reader (manual)
