# App Rules

Binding rules for web applications. No theory -- decisions only.
Detailed explanations: `../reference/app-best-practices.md`

---

## Security Headers

Every app MUST set these response headers:

- `Strict-Transport-Security`: `max-age=31536000; includeSubDomains`
- `X-Content-Type-Options`: `nosniff`
- `X-Frame-Options`: `DENY`
- `Referrer-Policy`: `strict-origin-when-cross-origin`
- `Permissions-Policy`: `camera=(), microphone=(), geolocation=(), payment=()`

**CSP strategy:** Nonce-based with `'strict-dynamic'` (gold standard):
`Content-Security-Policy: default-src 'self'; script-src 'nonce-{RANDOM}' 'strict-dynamic'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'`

> Simpler variant (without nonce, only for apps without dynamically loaded scripts):
> `script-src 'self'`

Test CSP in `Report-Only` mode first.

---

## Authentication & Authorization

- **Defense in Depth:** Auth at 3 layers: Middleware → Route/Controller → Data Access Layer (most important!)
- **Fail Closed:** Deny access on error
- **Password:** bcrypt (cost ≥ 12) / scrypt / Argon2id, never plaintext, timing-safe comparisons, rate limiting on login
- **Sessions:** Session cookies with `httpOnly=true`, `secure=true`, `sameSite=Lax` (standard recommendation)
- **JWT:** Only when statelessness is truly needed. Pin algorithm (`HS256`/`RS256`, reject `alg:none`), secret ≥ 256 bit, refresh token + rotation on logout
- **MFA:** TOTP or WebAuthn (ASVS L2). Account lockout after ≥ 5 failed attempts. Password reset: one-time token, max. 15 min
- **No custom crypto** -- always use established libraries

---

## Input Validation & Output Encoding

- **Validate at system boundary** (API entry): type, format, length, value range
- **Schema validation:** TypeScript → Zod, Python → Pydantic
- **Output encoding:** Use framework defaults. No `dangerouslySetInnerHTML` (React), no `| safe` (Django)
- **SQL:** Always prepared statements / parameterized queries
- **Shell:** Never user input in shell commands
- **DOM XSS:** No `innerHTML`/`outerHTML` with user data. Trusted Types + DOMPurify for dynamic HTML rendering

---

## API Design

- **Response format:** Uniform with `{ error: { code, message, details } }` on errors
- **Versioning:** URL path (`/api/v1/`)
- **Rate limiting:** Middleware/gateway level (fixed window or token bucket)
- **Pagination:** Never unbounded lists
- **Idempotency:** PUT/DELETE must be repeatable
- **API type:** Internal API → tRPC. External/public API → REST. Complex data models → GraphQL

---

## Database

- **Migrations:** Always use a migration tool (never manual SQL on prod). TS → Drizzle Kit / Prisma Migrate. Python → Alembic
- **Migration rules:** Always forward, idempotent (`IF NOT EXISTS`), small steps, test in staging
- **ORM choice:** Query builder (Drizzle, SQLAlchemy Core) as sweet spot. ORM for prototypes. Raw SQL only for complex queries
- **Connection pooling:** Required. Serverless → external pooler (PgBouncer, Neon Pooler)
- **Security:** Prepared statements, least privilege DB user, TLS to DB server, credentials in env vars, test backups
- **PostgreSQL:** `SCRAM-SHA-256` in `pg_hba.conf` (not `md5`). pgAudit for audit trails

---

## Error Handling & Monitoring

- **Fail Fast:** Report errors immediately, don't swallow them
- **No secrets in errors:** Never leak stack traces, DB queries, paths to client
- **Retry:** Exponential backoff for transient errors
- **Monitoring minimum:** Sentry (error tracking), Better Stack/UptimeRobot (uptime), structured logging
- **Alert thresholds:** Error rate > 1%, response time p95 > 2s, CPU/memory > 80%

---

## Logging

- **Structured (JSON)**, correlation ID per request, timestamps in UTC
- **Never log secrets** (API keys, passwords, tokens, PII)
- **Tools:** Node.js → Pino, Python → structlog
- **Log levels:** error (broken), warn (unexpected), info (normal operation), debug (development)
- **Aggregation:** Better Stack (1GB/mo free) or Axiom (500GB/mo free)

---

## Environment & Secrets

- Never commit `.env`, do commit `.env.example`
- **Validate env vars at app start:** App crashes immediately if variable is missing (Zod / Pydantic)
- **Secrets:** Local → `.env`. CI/CD → GitHub Secrets. Production → Vault / Secrets Manager
- Rotate secrets regularly (every 90 days or immediately upon suspected compromise)

---

## Caching

- **HTTP:** Static assets → `Cache-Control: public, max-age=31536000, immutable`. API → `max-age=60, stale-while-revalidate=300`. Personalized → `private, no-cache`. Login/mutations → `no-store`
- **App-level:** Redis for key-value. In-memory (`lru-cache` / `cachetools`) for hot data
- **Strategy:** Cache-aside for read-heavy apps. TTL-based as simplest approach

---

## CORS

- `Access-Control-Allow-Origin`: Explicit domain(s), **never `*` with credentials**
- Always handle preflight (OPTIONS)
- `Access-Control-Max-Age: 86400` (cache preflight)

---

## File Uploads

- Limit file size (e.g. max 10MB)
- Validate file type via magic bytes (not extension)
- Never store in web root, generate random filename
- Separate storage (S3/GCS instead of local filesystem)

---

## Accessibility

- **Legally required** (EU Accessibility Act since June 2025, BFSG)
- Semantic HTML (`<nav>`, `<main>`, `<button>`), correct heading hierarchy
- `alt` on all `<img>`, `aria-label` for icon-only buttons
- Don't remove focus styles (`:focus-visible`), skip-to-content link
- Never use color as the sole information carrier
- Testing: axe-core + Lighthouse (automated), keyboard test + screen reader (manual)

---

## Performance

- **Core Web Vitals:** LCP < 2.5s, INP < 200ms, CLS < 0.1
- **Backend:** DB indexes, avoid N+1, pagination, async I/O, connection pooling, response compression
- **Frontend:** Code splitting (> 200KB), lazy loading, WebP/AVIF, self-hosted fonts with `font-display: swap`

---

## Deployment

- **Health checks:** `/health` (liveness) + `/ready` (readiness)
- **Zero-downtime:** Rolling update (minimal), blue-green (better)
- **Rollback:** Docker tag rollback or blue-green switch (seconds)

---

## Feature Flags

- **Purpose:** Hide new behavior behind a flag → roll out → remove flag. Decouples deploy from release
- **Kill switch:** Every new feature needs a deactivation path for immediate rollback without redeploy
- **Rollout order:** `disabled → internal → canary (1%) → partial (10%) → full (100%)`
- **Flag lifecycle:** Keep active for max. 1 sprint, then remove (prevents flag debt)
- **Tools:** GrowthBook (open source, self-hosted), Unleash (self-hosted), LaunchDarkly (SaaS)
- **Never for:** Permanent configuration or A/B tests without a cleanup plan

---

## Observability

- **Three pillars:** Logs (what happened) + metrics (how much) + traces (where in the system)
- **OpenTelemetry** as vendor-independent standard
- **Four golden signals:** Latency, traffic, errors, saturation
- **Pragmatic start:** Sentry + Better Stack/Axiom + UptimeRobot. Metrics/traces only when needed

---

## Security Assessment

- **Framework:** OWASP ASVS 5.0 (May 2025). Level 1 for solo/small teams (~70 requirements)
- **SAST:** `ruff-S` (pre-commit) + `semgrep` (CI, cross-file taint analysis)
- **SCA:** `pip-audit` (Python). `pnpm audit` (Node). Not Safety (outdated)
- **SBOM:** `syft` (CycloneDX) on release build -- ISO 27001 / EU CRA
- **Image scan:** `trivy` in CI — CRITICAL+HIGH → exit 1
- **Threat modeling:** STRIDE-GPT for new systems/features (once, not per PR)
- **Cadence:** SAST+SCA per PR → image scan per build → STRIDE once per system

---

## OWASP Top 10 Quick Reference

> Full verification framework: ASVS 5.0 (see above)

1. Broken Access Control → Auth at data access layer, deny by default
2. Cryptographic Failures → TLS everywhere, secrets in env vars
3. Injection → Prepared statements, no shell exec with user input
4. Insecure Design → Threat modeling, defense in depth
5. Security Misconfiguration → Security headers, no default credentials
6. Vulnerable Components → Renovate, pip-audit / pnpm audit
7. Auth Failures → MFA, rate limiting
8. Data Integrity → CI/CD security, signed artifacts
9. Logging Failures → Structured logging, audit trails
10. SSRF → URL allowlists, no user input in server-side requests
