# App Architecture & Security Best Practices

Reference checklist for web applications (as of March 2026). Language-agnostic where possible, with concrete tool recommendations where necessary.

---

## 1. Security Headers

HTTP response headers that instruct the browser to activate security features.

### Must-Have Headers

| Header | Value | Protects against |
|--------|------|--------------|
| `Content-Security-Policy` | `default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'` | XSS, code injection |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Protocol downgrade, cookie hijacking |
| `X-Content-Type-Options` | `nosniff` | MIME-type sniffing |
| `X-Frame-Options` | `DENY` | Clickjacking |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Information leak via referrer |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=(), payment=()` | Unwanted browser API usage |

### CSP – Theory & Background

**What is CSP?** Content Security Policy is an HTTP response header that tells the browser which resources (scripts, styles, images, fonts, etc.) may be loaded from which sources. Everything not explicitly allowed is blocked.

**The problem without CSP:** Without CSP, an attacker who injects XSS (Cross-Site Scripting) into your page can execute arbitrary JavaScript code — steal data, hijack sessions, install keyloggers. CSP is the last line of defense: even if XSS succeeds, the browser blocks loading external scripts or executing inline code.

**How does it work?**

```text
1. Server sends response with header:
   Content-Security-Policy: script-src 'self'; style-src 'self'

2. Browser parses the HTML page

3. For each resource the browser checks:
   - <script src="https://evil.com/steal.js">  → BLOCKED (not 'self')
   - <script src="/app.js">                    → ALLOWED ('self')
   - <script>alert('xss')</script>             → BLOCKED (no 'unsafe-inline')
   - <img src="https://tracker.com/pixel.gif"> → BLOCKED (if img-src: 'self')

4. Violation is logged in browser console
   (optionally: sent to report-uri)
```

**The three CSP strategies (from weak to strong):**

| Strategy | Security | Practicality | Description |
|-----------|-----------|-----------------|-------------|
| **Allowlist-based** | Medium | High | Explicitly allow domains (`script-src 'self' cdn.example.com`) |
| **Nonce-based** | High | Medium | Random token per request (`script-src 'nonce-abc123'`) |
| **Hash-based** | High | Low | SHA-256 hash of each script (`script-src 'sha256-...'`) |

**Nonce-based is the recommended approach** – Google calls it ["strict CSP"](https://web.dev/articles/strict-csp). It works like this:

1. Server generates a random nonce per request (e.g. `a1b2c3d4`)
2. Server sets the header: `script-src 'nonce-a1b2c3d4' 'strict-dynamic'`
3. Server adds the nonce to every `<script>` tag: `<script nonce="a1b2c3d4">`
4. Browser only executes scripts with the correct nonce
5. `'strict-dynamic'` allows these scripts to dynamically load further scripts

**`'strict-dynamic'` explained:** When a trusted script (with nonce) loads another script via `document.createElement('script')`, the child script is automatically trusted. Without `'strict-dynamic'`, these dynamically loaded scripts would be blocked — which would break most frameworks (React, Vue, etc.).

**Why avoid `'unsafe-inline'`?** `'unsafe-inline'` allows EVERY inline script. An attacker who can inject HTML (`<script>steal()</script>`) has free reign. Nonces solve this: only scripts with the correct (unguessable) nonce are executed.

**The `'unsafe-inline'` dilemma for styles:** Many frameworks (Tailwind, styled-components, Material UI) set inline styles. Here `'unsafe-inline'` for `style-src` is often an acceptable compromise — inline styles are significantly less dangerous than inline scripts (no code execution).

**CSP Levels (versions):**

| Level | Since | Key features |
|-------|------|-------------------|
| CSP 1.0 | 2012 | Basic directives (script-src, style-src, etc.) |
| CSP 2.0 | 2015 | Nonce, hash, `base-uri`, `form-action`, `frame-ancestors` |
| CSP 3.0 | 2018+ | `'strict-dynamic'`, `'report-sample'`, `navigate-to` (draft) |

### CSP Practical Guide

**Minimal CSP:**

```text
default-src 'self';
script-src 'self';
style-src 'self' 'unsafe-inline';
img-src 'self' data: https:;
font-src 'self';
connect-src 'self';
frame-ancestors 'none';
base-uri 'self';
form-action 'self';
```

**CSP directives explained:**

| Directive | Controls | Typical setting |
|-----------|-------------|---------------------|
| `default-src` | Fallback for all resources | `'self'` |
| `script-src` | JavaScript | `'self'` (ideal: with nonce) |
| `style-src` | CSS | `'self' 'unsafe-inline'` (frameworks often need inline) |
| `img-src` | Images | `'self' data: https:` |
| `connect-src` | fetch/XHR/WebSocket | `'self'` + API domains |
| `frame-ancestors` | Who may embed the page | `'none'` (replaces X-Frame-Options) |
| `base-uri` | `<base>` tag | `'self'` |
| `form-action` | Form submissions | `'self'` |

**Nonce-based CSP (gold standard):**

Instead of `'unsafe-inline'` for scripts, generate a random nonce per request:

```text
script-src 'nonce-abc123random' 'strict-dynamic';
```

The server generates a new nonce per request and sets it both in the header and in the `<script nonce="abc123random">` tag.

**Practical tip:** Test CSP in report-only mode first:

```text
Content-Security-Policy-Report-Only: default-src 'self'; report-uri /api/csp-report
```

### Testing

- [securityheaders.com](https://securityheaders.com) – Quick check of all headers
- [Mozilla Observatory](https://observatory.mozilla.org) – More comprehensive scan
- [CSP Evaluator (Google)](https://csp-evaluator.withgoogle.com/) – Checks CSP for weaknesses
- Browser DevTools > Console – shows CSP violations

### CSP Further Reading

- [MDN: Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP) – Official reference, all directives explained
- [web.dev: Strict CSP (Google)](https://web.dev/articles/strict-csp) – Nonce-based CSP step by step
- [CSP Spec (W3C)](https://www.w3.org/TR/CSP3/) – The official specification (Level 3)
- [content-security-policy.com](https://content-security-policy.com/) – Interactive reference with examples
- [CSP Evaluator (Google)](https://csp-evaluator.withgoogle.com/) – Online tool that checks CSP headers for weaknesses
- [Report URI](https://report-uri.com/) – Free CSP reporting (collects violations)

---

## 2. Authentication & Authorization

### Core Principles

1. **Defense in Depth** – Never check at just one place
2. **Fail Closed** – On error: deny access, don't grant it
3. **Least Privilege** – Only the minimum necessary permissions

### Auth Layers

```text
Request
  │
  ├─ Layer 1: Middleware/Gateway (first check)
  │
  ├─ Layer 2: API Route/Controller (authorization)
  │
  └─ Layer 3: Data Access Layer (last check) ← MOST IMPORTANT
```

**Why Data Access Layer?** Middleware can be bypassed (CVE-2025-29927 in Next.js showed: a manipulated header could completely bypass middleware). The data access layer is the last line of defense.

### Password Handling

| Rule | Why |
|-------|-------|
| **Never store plaintext** | Always hash |
| **Use bcrypt/scrypt/Argon2** | Intentionally slow, resistant against brute-force |
| **Timing-safe comparisons** | `crypto.timingSafeEqual()` prevents timing attacks |
| **Rate limiting** on login | Brute-force protection (e.g. 5 attempts, then 15 min lockout) |
| **No custom crypto** | Always use established libraries |

### Session Management

| Approach | Advantage | Disadvantage |
|--------|---------|----------|
| **JWT (stateless)** | No server state, scalable | Not revocable (until expiry), token size |
| **Session cookie (stateful)** | Immediately revocable, smaller | Needs session store (Redis/DB) |
| **JWT + refresh token** | Combination of both advantages | More complex |

**Recommendation:** For most web apps: session cookies with httpOnly + secure + sameSite=Lax.

### Cookie Flags

| Flag | Value | Why |
|------|------|-------|
| `httpOnly` | `true` | JavaScript cannot read cookie (XSS protection) |
| `secure` | `true` | HTTPS only |
| `sameSite` | `Lax` or `Strict` | CSRF protection |
| `path` | `/` | Restrict scope |
| `maxAge` | e.g. 86400 | Expiry time |

---

## 3. Input Validation & Output Encoding

### Core Rule

> **Validate input, encode output.** Trust no data coming from outside.

### Input Validation

Validate at the **system boundary** (API entry, form submission, webhook):

| What to validate | How |
|---------------|-----|
| Type | Is it a string/number/boolean? |
| Format | Email, URL, date – regex or library |
| Length | Limit min/max length |
| Value range | Enum, min/max for numbers |
| Business rules | Is the value meaningful in this context? |

**Schema validation (recommended):**

| Language | Tool |
|---------|------|
| TypeScript | **Zod** (runtime validation with type inference) |
| Python | **Pydantic** (v2, Rust-based, fast) |
| Go | **go-playground/validator** |

**Example pattern:**

```text
Client → API Gateway → Schema validation → Business logic → Data access
                            ↑
                    Validate here!
                    Invalid = 400 Bad Request
```

### Output Encoding

| Context | Encoding | Protects against |
|---------|----------|--------------|
| HTML body | HTML entity encoding (`<` → `&lt;`) | XSS |
| HTML attribute | Attribute encoding | XSS |
| JavaScript | JSON.stringify + CSP | XSS |
| URL | URL encoding (`encodeURIComponent`) | Injection |
| SQL | Prepared statements / parameterized queries | SQL injection |
| Shell | No shell calls with user input! | Command injection |

**Frameworks do most of this automatically** – React escapes HTML by default, Django templates likewise. But: `dangerouslySetInnerHTML` (React) or `| safe` (Django) bypass the protection.

### DOM XSS – Modern Protection Layer

Classic output encoding is not enough for DOM-based XSS when JavaScript code writes directly to DOM sinks (`innerHTML`, `document.write`, `src`). Modern defense in two layers:

**Layer 1: Trusted Types (browser enforcement)**

```text
Content-Security-Policy: require-trusted-types-for 'script'
```

Enforces that all assignments to DOM sinks go through a declared policy. Raw strings are blocked by the browser. Google calls this the only measure that structurally eliminates DOM XSS.

**Layer 2: DOMPurify (sanitizer)**

When HTML injection is unavoidable (e.g. rich text), `DOMPurify.sanitize()` before every `innerHTML` assignment:

```javascript
// Unsafe:
element.innerHTML = userContent;

// Safe:
element.innerHTML = DOMPurify.sanitize(userContent);

// Combined with Trusted Types:
const policy = trustedTypes.createPolicy('default', {
    createHTML: input => DOMPurify.sanitize(input)
});
element.innerHTML = policy.createHTML(userContent);
```

**Alternative native API (browser support from 2024/2025):** `element.setHTML()` — sanitizes automatically, no external library needed. Not yet universally available.

**Rule of thumb:**
- `.textContent` instead of `.innerHTML` where no HTML is needed
- `DOMPurify` for every case where HTML injection is needed
- Trusted Types as CSP directive for structural enforcement

---

## 4. API Design

### Core Principles

| Principle | Description |
|---------|-------------|
| **Consistent structure** | Uniform response formats, error codes |
| **Versioning** | `/api/v1/` or header-based |
| **Rate limiting** | Protection against abuse and DDoS |
| **Pagination** | Never return unbounded lists |
| **Idempotency** | PUT/DELETE must be repeatable |

### REST vs. tRPC vs. GraphQL

| Criterion | REST | tRPC | GraphQL |
|-----------|------|------|---------|
| Type safety | Manual (OpenAPI) | Automatic (end-to-end) | Schema + codegen |
| Overhead | Low | Minimal | High (resolvers, schema) |
| Learning curve | Low | Low | Medium-high |
| Caching | HTTP caching easy | Custom | Apollo cache, more complex |
| Multiple clients | Good (standard) | TypeScript only | Good (any language) |
| Best for | Public APIs, multi-client | Full-stack TypeScript | Complex data models |

**Rule of thumb:** Internal API → tRPC. External/public API → REST. Complex data queries → GraphQL.

### Error Response Format

Uniform for all endpoints:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "message": "Invalid format" }
    ]
  }
}
```

**HTTP status codes – the most important:**

| Code | Meaning | When |
|------|-----------|------|
| 200 | OK | Successful GET/PUT/PATCH |
| 201 | Created | Successful POST (new object) |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation error (client fault) |
| 401 | Unauthorized | Not authenticated |
| 403 | Forbidden | Authenticated, but no permission |
| 404 | Not Found | Resource does not exist |
| 409 | Conflict | Conflicting change |
| 422 | Unprocessable Entity | Semantically invalid |
| 429 | Too Many Requests | Rate limit reached |
| 500 | Internal Server Error | Server error (never leak details!) |

### Rate Limiting

| Strategy | Description |
|-----------|-------------|
| **Fixed Window** | X requests per minute |
| **Sliding Window** | More precise, but more complex |
| **Token Bucket** | Allows bursts, smooths over time |

Implementation: Middleware/gateway level (not in business logic).

---

## 5. Database

### Migration Tools

Migrations = versioned, repeatable schema changes. **Never run manual SQL on production.**

| Language | Tool | Type |
|---------|------|-----|
| TypeScript | **Drizzle Kit** / **Prisma Migrate** | ORM-integrated |
| Python | **Alembic** (SQLAlchemy) / **Django Migrations** | ORM-integrated |
| Go | **goose** / **golang-migrate** | Standalone |
| Language-agnostic | **Flyway** / **Liquibase** | SQL-based |

### Migration Rules

| Rule | Why |
|-------|-------|
| **Always forward** | Rollback migrations are error-prone. Better a new migration that corrects the error. |
| **Idempotent** | Use `IF NOT EXISTS`, `IF EXISTS` |
| **Small steps** | One change per migration |
| **Separate data migrations** | Schema change ≠ data migration |
| **Test in staging** | Never untested on production |

### ORM vs. Raw SQL vs. Query Builder

| Approach | Advantage | Disadvantage |
|--------|---------|----------|
| **ORM** (Prisma, SQLAlchemy, Django ORM) | Productive, type-safe, migrations | Abstraction can be problematic, N+1 queries |
| **Query builder** (Drizzle, Knex, SQLAlchemy Core) | Close to SQL, type-safe, flexible | More boilerplate than ORM |
| **Raw SQL** | Full control, optimal performance | No type safety, SQL injection risk |

**Recommendation 2026:** Query builder (Drizzle, SQLAlchemy Core) as sweet spot. ORM for rapid prototypes. Raw SQL only for complex queries.

### Connection Pooling

**Why:** Database connections are expensive (TCP handshake, auth, TLS). Pooling keeps connections open and reuses them.

| Environment | Tool |
|----------|------|
| Serverful (Node/Python long-lived) | Built-in pool (Prisma, SQLAlchemy) |
| Serverless (Lambda, Edge) | **PgBouncer** (external), **Neon Pooler**, **Prisma Accelerate** |
| Docker | PgBouncer as sidecar container |

**Serverless problem:** Every cold start opens a new connection → DB limit reached quickly. External pooler is required.

### Security

| Rule | Why |
|-------|-------|
| **Prepared statements / parameterized queries** | Prevent SQL injection |
| **Least privilege DB user** | App user may only do what is needed (no DROP, GRANT) |
| **Encrypted connection** | TLS/SSL to DB server |
| **No DB credentials in code** | Always environment variables |
| **Test backups** | A backup that cannot be restored is not a backup |

### PostgreSQL Hardening (Checklist)

| Measure | Where to configure | Why |
|----------|-----------------|-------|
| `password_encryption = scram-sha-256` | `postgresql.conf` | MD5 is cryptographically broken — SCRAM-SHA-256 is the current standard |
| `hostssl` instead of `host` in all rows | `pg_hba.conf` | Enforces TLS for all connections |
| No `trust` in `pg_hba.conf` | `pg_hba.conf` | `trust` = no password = anyone with network access is in |
| `listen_addresses = 'localhost'` or specific IP | `postgresql.conf` | Don't bind to `*` |
| App user without DDL rights | `GRANT` statements | `CREATE`, `DROP`, `ALTER` only for migrations user |
| Enable pgAudit | Extension + `postgresql.conf` | Logs DDL/privilege changes (`CREATE`, `DROP`, `GRANT`) |
| `log_connections = on` | `postgresql.conf` | Detects unusual connection attempts |

**Minimal pg_hba.conf (production):**
```text
# TYPE  DATABASE  USER       ADDRESS         METHOD
local   all       postgres                   peer
hostssl garmin    garmin_app 172.20.0.0/16   scram-sha-256
```

---

## 6. Error Handling & Monitoring

### Error Handling Principles

| Principle | Description |
|---------|-------------|
| **Fail Fast** | Report errors immediately, don't swallow them |
| **No secrets in errors** | Never leak stack traces, DB queries, paths to client |
| **Structured errors** | Uniform error format (see API design) |
| **Retry with backoff** | For transient errors (network, rate limits): exponential backoff |
| **Circuit breaker** | On repeated failure: temporarily disable dependency |

### Monitoring Stack

| Layer | What | Tool |
|---------|-----|------|
| **Error tracking** | Exceptions, crashes | **Sentry** (de-facto standard, free tier: 5K events/month) |
| **Uptime monitoring** | Is the app reachable? | **Better Stack** / UptimeRobot / Pingdom |
| **APM (performance)** | Slow requests, bottlenecks | **Sentry Performance** / Datadog / New Relic |
| **Logging** | Structured logs | **Pino** (Node) / **structlog** (Python) + log aggregator |
| **Alerting** | Notifications | Sentry alerts / PagerDuty / Opsgenie |

### What to Monitor (Minimum)

| Metric | Why | Alert threshold |
|--------|-------|---------------|
| **Error rate** | Rises on bugs/outages | > 1% of requests |
| **Response time (p95)** | Performance degradation | > 2s |
| **Uptime** | Availability | < 99.9% |
| **CPU / memory** | Resource exhaustion | > 80% sustained |
| **Disk space** | Logs/data fill disk | > 85% |

---

## 7. Logging

### Core Rules

| Rule | Why |
|-------|-------|
| **Structured (JSON)** | Machine-parseable, searchable |
| **Use log levels** | error, warn, info, debug – use correctly |
| **Correlation ID** | Pull request ID through all services/logs |
| **Never log secrets** | Filter out API keys, passwords, tokens, PII |
| **Timestamps in UTC** | Consistency across time zones |
| **Log rotation** | Prevent disk full |

### Log Levels

| Level | When | Example |
|-------|------|---------|
| **error** | Something is broken, needs attention | DB connection failed, API key invalid |
| **warn** | Unexpected state, but operation continues | Rate limit almost reached, fallback activated |
| **info** | Normal operation, important events | Server started, user logged in, refresh performed |
| **debug** | Detailed info for development | Request/response bodies, query details |

### Tools

| Language | Structured logger | Why |
|---------|------------------|-------|
| Node.js | **Pino** | 5-10x faster than Winston, native JSON |
| Python | **structlog** | Processor pipeline, key-value instead of strings |
| Go | **slog** (stdlib since 1.21) | Built-in, no external dependency needed |

### Log Aggregation (Production)

| Tool | Type | Cost |
|------|-----|--------|
| **Better Stack (Logtail)** | SaaS | Free tier 1GB/month |
| **Axiom** | SaaS | Free tier 500GB/month |
| **Grafana Loki + Grafana** | Self-hosted | Free (but effort) |
| **ELK Stack** | Self-hosted | Free (but much effort) |

---

## 8. Environment & Secrets Management

### Core Rules

| Rule | Why |
|-------|-------|
| **Never commit `.env`** | Always in `.gitignore` |
| **Commit `.env.example`** | Documents which vars are needed (without values) |
| **Runtime validation** | App must check at start whether all vars are set |
| **Different env per stage** | dev / staging / production separated |
| **Rotate secrets** | Renew API keys regularly |

### Env Validation at App Start

The app should **crash immediately** if a required variable is missing – not only when the first request arrives.

**TypeScript (Zod):**

```typescript
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(1),
  NODE_ENV: z.enum(["development", "production", "test"]),
  PORT: z.coerce.number().default(3000),
});

// Crashes immediately if something is missing – with clear error message
export const env = envSchema.parse(process.env);
```

**Python (Pydantic):**

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    api_key: str
    environment: str = "development"
    port: int = 8000

    model_config = {"env_file": ".env"}

# Crashes immediately if something is missing
settings = Settings()
```

### Secret Storage by Environment

| Environment | Where to store secrets |
|----------|---------------------|
| **Local** | `.env` file (never commit) |
| **CI/CD** | GitHub Actions Secrets / GitLab CI Variables |
| **Production (simple)** | Env file on server (`chmod 600`) |
| **Production (better)** | **HashiCorp Vault**, **AWS Secrets Manager**, **Infisical** |
| **Kubernetes** | K8s Secrets + **External Secrets Operator** |

---

## 9. Caching

### Caching Layers

```text
Browser cache → CDN/edge cache → App-level cache → DB query cache → DB
    ↑                ↑                  ↑                ↑
  Fastest       Close to user      In server        Last layer
```

### Cache Strategies

| Strategy | When | How |
|-----------|------|-----|
| **Cache-aside** | Read-heavy apps | App checks cache → miss → DB → write to cache |
| **Write-through** | Consistency important | Write to cache AND DB simultaneously |
| **Write-behind** | Performance important | Write to cache, DB asynchronously |
| **TTL-based** | Simplest approach | Data expires after X seconds |

### HTTP Caching Headers

| Header | Purpose | Example |
|--------|-------|---------|
| `Cache-Control` | Main control | `public, max-age=3600, stale-while-revalidate=60` |
| `ETag` | Versioning | `"abc123"` – server checks if resource has changed |
| `Last-Modified` | Time-based | Browser sends `If-Modified-Since` |
| `Vary` | Cache key variation | `Vary: Accept-Encoding` |

**Practical recommendation:**

```text
# Static assets (JS/CSS/images with hash in filename)
Cache-Control: public, max-age=31536000, immutable

# API responses (dynamic, but cacheable)
Cache-Control: public, max-age=60, stale-while-revalidate=300

# Personalized data
Cache-Control: private, no-cache

# Never cache (login, mutations)
Cache-Control: no-store
```

### Tools

| Layer | Tool |
|---------|------|
| CDN/Edge | **Cloudflare** / Vercel Edge / AWS CloudFront |
| App-level (key-value) | **Redis** / Valkey / Memcached |
| App-level (in-memory) | `Map()` / `lru-cache` (Node) / `cachetools` (Python) |
| Framework | Next.js `revalidate` / Django Cache Framework |

---

## 10. CORS (Cross-Origin Resource Sharing)

### When Relevant

When frontend and backend run on **different domains** (e.g. `app.example.com` → `api.example.com`).

### Configuration

| Setting | Recommendation | Why |
|---------|-----------|-------|
| `Access-Control-Allow-Origin` | Explicit domain(s) | **Never `*` in production** with credentials |
| `Access-Control-Allow-Methods` | Only needed methods | `GET, POST, PUT, DELETE` |
| `Access-Control-Allow-Headers` | Only needed headers | `Content-Type, Authorization` |
| `Access-Control-Allow-Credentials` | `true` only when needed | For cookie-based auth |
| `Access-Control-Max-Age` | `86400` (24h) | Cache preflight requests |

### Common Mistakes

| Mistake | Problem |
|--------|---------|
| `Access-Control-Allow-Origin: *` + credentials | Browser blocks (by design) |
| CORS only configured in dev server | Production forgotten → API not reachable |
| Preflight (OPTIONS) not handled | PUT/DELETE/custom headers don't work |

---

## 11. File Uploads

### Security Rules

| Rule | Why |
|-------|-------|
| **Limit file size** | DoS protection (e.g. max 10MB) |
| **Validate file type** (magic bytes, not extension) | Catches `.jpg` renamed to `.exe` |
| **Never store in web root** | Prevents direct execution |
| **Generate random filename** | Prevent path traversal (`../../etc/passwd`) |
| **Virus scan** | For user uploads: ClamAV or cloud service |
| **Separate storage** | S3/GCS instead of local filesystem |

---

## 12. Accessibility (a11y)

### Why Required

- **EU Accessibility Act (EAA)** – legally required since June 2025 for digital services in the EU
- **Barrierefreiheitsstärkungsgesetz (BFSG)** – German implementation of the EAA
- Affects: e-commerce, banking, transport, public services

### WCAG 2.2 – The Most Important Points

| Principle | What | Practice |
|---------|-----|--------|
| **Perceivable** | Content must be perceivable | Alt text for images, contrast ≥ 4.5:1, captions for videos |
| **Operable** | UI must be operable | Everything reachable by keyboard, no time limits, skip links |
| **Understandable** | Content must be understandable | Clear language, consistent navigation, error descriptions |
| **Robust** | Content must be robustly interpretable | Semantic HTML, ARIA where needed, valid markup |

### Quick Wins

| Measure | Effort |
|----------|---------|
| Semantic HTML (`<nav>`, `<main>`, `<article>`, `<button>`) | Low |
| Correct heading hierarchy (h1 → h2 → h3, no gaps) | Low |
| `alt` attributes on all `<img>` | Low |
| Don't remove focus styles (`:focus-visible`) | Low |
| Never use color as sole information carrier | Low |
| `aria-label` for icon-only buttons | Low |
| Skip-to-content link | Low |
| Forms: `<label>` with `for` attribute | Low |

### Testing

| Tool | Type | Finds |
|------|-----|--------|
| **axe-core** (browser extension / CLI) | Automatic | ~57% of WCAG problems |
| **Lighthouse** (Chrome DevTools) | Automatic | Accessibility score + tips |
| **Keyboard test** | Manual | Tab order, focus management |
| **Screen reader** (VoiceOver/NVDA) | Manual | Real user experience |

---

## 13. Performance

### Core Web Vitals (Google Ranking Factor)

| Metric | What | Goal |
|--------|-----|------|
| **LCP** (Largest Contentful Paint) | When is the main content visible? | < 2.5s |
| **INP** (Interaction to Next Paint) | How quickly does the UI respond? | < 200ms |
| **CLS** (Cumulative Layout Shift) | Does the layout jump around? | < 0.1 |

### Backend Performance

| Measure | When |
|----------|------|
| **Database indexes** | Slow queries (EXPLAIN ANALYZE) |
| **Avoid N+1 queries** | ORM usage (eager loading / JOIN) |
| **Pagination** | Lists > 50 items |
| **Async I/O** | Parallel external API calls |
| **Connection pooling** | Every DB connection |
| **Response compression** | gzip/brotli for API responses |

### Frontend Performance

| Measure | When |
|----------|------|
| **Code splitting** | Large bundles (> 200KB JS) |
| **Lazy loading** | Images, components below the fold |
| **Image optimization** | WebP/AVIF, responsive sizes |
| **Font optimization** | Self-hosted, `font-display: swap` |
| **Prefetching** | Critical resources, next navigation |
| **Bundle analysis** | Regularly check what lands in the bundle |

---

## 14. Deployment Patterns

### Zero-Downtime Deployment

| Pattern | How | Complexity |
|---------|-----|-------------|
| **Rolling update** | Start new instances, stop old | Low |
| **Blue-green** | Two environments, switch traffic | Medium |
| **Canary** | New version for % of users, then roll out | High |

### Health Checks

Every app needs at least two endpoints:

| Endpoint | Checks | When |
|----------|-------|------|
| `/health` (liveness) | Process is alive | Container orchestration (Docker, K8s) |
| `/ready` (readiness) | App can accept requests (DB ok, etc.) | Load balancer |

### Rollback Strategy

| Method | Speed |
|---------|----------------|
| **Docker tag rollback** | `docker run app:previous-tag` (seconds) |
| **Git revert + redeploy** | Minutes |
| **Blue-green switch** | Seconds (traffic back to old environment) |
| **Feature flags** | Immediately (disable flag) |

---

## 14b. Feature Flags

Feature flags decouple **deployment** (bringing code to production) from **release** (activating feature for users).

### Why Feature Flags

| Without feature flags | With feature flags |
|---|---|
| Deploy = immediate release | Deploy ≠ release |
| Rollback = revert + redeploy (minutes) | Rollback = disable flag (seconds) |
| Big bang releases | Gradual rollout (canary) |
| All users see new features simultaneously | Internal beta → 1% → 10% → 100% |

### Rollout Order

```text
disabled → internal (team) → canary (1%) → partial (10%) → full (100%) → flag_removed
```

### Flag Types

| Type | Purpose | Lifetime |
|---|---|---|
| **Release flag** | Enable/disable new feature | Short (≤ 1 sprint) |
| **Kill switch** | Emergency deactivation without redeploy | Permanent |
| **Experiment flag** | A/B test | Medium (test duration) |
| **Ops flag** | Infrastructure behavior (cache on/off) | Permanent |

### Implementation

**Simple (self-built):**

```typescript
// TypeScript: Env-based flag (sufficient for solo)
const flags = {
  newCheckout: process.env.FLAG_NEW_CHECKOUT === 'true',
  darkMode: process.env.FLAG_DARK_MODE === 'true',
}

if (flags.newCheckout) {
  // new checkout logic
}
```

```python
# Python: Env-based flag
import os

FLAGS = {
    "new_checkout": os.getenv("FLAG_NEW_CHECKOUT", "false") == "true",
}
```

**Scalable (open source):**

| Tool | Hosting | Strength |
|---|---|---|
| **GrowthBook** | Self-hosted / SaaS | A/B testing, analytics integration |
| **Unleash** | Self-hosted / SaaS | Enterprise features, SDKs for 20+ languages |
| **Flagsmith** | Self-hosted / SaaS | Simple, API-first |
| LaunchDarkly | SaaS only | Feature-rich, expensive |

### Flag Hygiene (prevents flag debt)

- **Maximum lifetime:** Release flags active for max. 1 sprint
- **Ticket on creation:** Every flag gets a "cleanup" ticket with deadline
- **Never for permanent config:** Permanent configuration belongs in env vars, not flags
- **Test both paths:** CI must test both states (flag on + off)

### Anti-Patterns

- Flag without cleanup date → never gets removed (flag debt)
- Nested flags (`if (flagA && flagB && !flagC)`) → impossible to understand
- Flags for security-critical decisions (auth, payments) → too risky
- Flag state in DB (not in flag service) → consistency issues with multi-instance

---

## 15. Observability

### The Three Pillars

```text
                    Observability
                   ╱      │      ╲
              Logs     Metrics    Traces
              │          │          │
         What happened?  How much?  Where in system?
```

| Pillar | What | Example | Tool |
|-------|-----|----------|------|
| **Logs** | Discrete events (text lines) | "User login failed for user@example.com" | Pino, structlog |
| **Metrics** | Numerical measurements over time | Request rate: 150/s, error rate: 0.3%, latency p95: 240ms | Prometheus, StatsD |
| **Traces** | Request path through multiple services | Request → API gateway → Auth service → DB → Response (320ms) | Jaeger, Zipkin |

**Logs alone are not enough.** Logs say _what_ happened. Metrics say _how often_ and _how fast_. Traces say _where exactly_ in the system a problem lies.

### OpenTelemetry (OTel) – The Standard

OpenTelemetry is the vendor-independent standard for observability data. Instead of building a separate integration for every provider (Datadog, Sentry, Grafana), you instrument once with OTel and send data to any backend.

```text
App (OTel SDK) → OTel Collector → Backend of your choice
                                    ├── Grafana Cloud
                                    ├── Datadog
                                    ├── Sentry
                                    ├── Jaeger (self-hosted)
                                    └── Axiom / Better Stack
```

**Why OTel instead of vendor SDK?**
- Avoid vendor lock-in: switch backend without code changes
- One SDK for logs + metrics + traces
- Large community, many auto-instrumentations

### Metrics – What to Measure

| Metric type | What | Example |
|------------|-----|---------|
| **Counter** | Counts events (only upward) | Total requests, errors, logins |
| **Gauge** | Current value (up and down) | Active connections, queue length, memory |
| **Histogram** | Distribution of values | Request latency (p50, p95, p99) |

**The four golden signals (Google SRE):**

| Signal | What | Alert when |
|--------|-----|-----------|
| **Latency** | How long do requests take? | p95 > 2s |
| **Traffic** | How many requests are coming in? | Unusual increase/decrease |
| **Errors** | How many requests fail? | Error rate > 1% |
| **Saturation** | How full are resources? | CPU > 80%, memory > 85%, disk > 90% |

### Distributed Tracing

Relevant as soon as a request passes through multiple services (or: API → external API → DB).

```text
Trace: "POST /api/order"
├── Span: API Gateway (12ms)
├── Span: Auth Service (45ms)
│   └── Span: DB Query - validate token (8ms)
├── Span: Order Service (180ms)
│   ├── Span: DB Query - create order (25ms)
│   └── Span: Payment API Call (140ms)  ← Bottleneck!
└── Span: Email Service (async, 0ms wait)
Total: 237ms
```

**Trace** = entire request path. **Span** = individual step in the trace. Each span has start/end and metadata.

### Observability Stack by Budget

| Budget | Logs | Metrics | Traces | Dashboards |
|--------|------|---------|--------|------------|
| **Free** | Better Stack (1GB/mo) or Axiom (500GB/mo) | Prometheus + Grafana (self-hosted) | Jaeger (self-hosted) | Grafana |
| **Low-budget** | Better Stack / Axiom | Grafana Cloud (free tier) | Grafana Tempo (free tier) | Grafana Cloud |
| **Enterprise** | Datadog / Splunk | Datadog | Datadog APM | Datadog |

**Pragmatic start (solo/small project):**
1. **Sentry** for error tracking + performance (free tier: 5K events/mo)
2. **Better Stack** or **Axiom** for logs (generous free tiers)
3. **UptimeRobot** for uptime monitoring (free, 50 monitors)
4. Metrics + traces → only when need arises (multiple services, performance problems)

---

## 16. Security Assessment & ASVS

### OWASP ASVS 5.0 — The Right Framework

OWASP ASVS (Application Security Verification Standard) 5.0 (May 2025) is the most widely used verifiable checklist format for web app security. Three levels:

| Level | For | Requirements |
|-------|-----|---------------|
| **L1** | All software — absolute minimum | ~70 requirements |
| **L2** | Most production apps | ~200 requirements |
| **L3** | Critical systems (banking, healthcare) | ~350 requirements |

**Recommendation for solo/small teams: L1 in phases.** Not all at once — start with the three chapters that cause most breaches:

1. Chapter 2 — Authentication & Session
2. Chapter 4 — Access Control (especially data access layer)
3. Chapter 5 — Input Validation

Then: Chapter 7 (error handling), Chapter 9 (communication/TLS).

**ASVS vs. OWASP Top 10:** Top 10 is a risk awareness list, not a process. ASVS is a verifiable checklist format — every requirement can be rated yes/no.

[ASVS Project](https://owasp.org/www-project-application-security-verification-standard/) · [ASVS × Cheat Sheet Index](https://cheatsheetseries.owasp.org/IndexASVS.html)

### Security Tooling Stack (Python/Docker/Postgres)

**Three layers, all necessary:**

| Layer | Tool | Purpose | When |
|-------|------|-------|------|
| **SAST fast** | `bandit` | Python-specific checks (pickle, shell injection, hardcoded secrets) | pre-commit |
| **SAST deep** | `semgrep` (community rules) | Cross-file taint tracking — finds SQL injection through call chains | CI |
| **SCA** | `pip-audit` | Check dependencies against OSV/PyPI advisory DB | pre-commit + CI |
| **Image scan** | `trivy` | OS packages + dependencies + misconfigs + secrets in Docker image | CI |
| **Host audit** | `docker-bench-security` | CIS benchmark against Docker host | Once + per release |

**Bandit vs. Semgrep:** Bandit is fast and configuration-free — ideal as pre-commit gate. Semgrep with `p/python` + `p/owasp-top-ten` rules goes deeper (cross-file dataflow). Use both together.

**Safety vs. pip-audit:** Safety heavily restricted its free tier in 2023/2024. pip-audit is maintained by PyPA itself, uses the Google OSV database, requires no account. pip-audit is the community standard.

**Ruff as Bandit replacement:** From Ruff 0.4+, Bandit rules are integrated as prefix `S` in Ruff (`ruff --select S`). Can potentially replace Bandit for teams already using Ruff.

### CI/CD Pipeline Integration

```text
pre-commit (seconds, blocks commit):
  gitleaks → ruff --select S → bandit → pip-audit

CI: every PR (< 5 min):
  pip-audit  --fail-on CRITICAL,HIGH
  semgrep    --config=p/python --config=p/owasp-top-ten
  trivy image --exit-code 1 --severity CRITICAL,HIGH
  docker build --check

Result routing:
  CRITICAL/HIGH → merge blocked
  MEDIUM/LOW    → GitHub Security tab via --sarif (async triage)
```

Semgrep and pip-audit support `--sarif` — the output uploads directly to the GitHub Security tab.

### Docker Security Hardening

**5 non-negotiable controls (CIS Benchmark):**

| Control | Why | How |
|-----------|-------|-----|
| **Non-root user** | Root escape → host compromise | `USER appuser` in every Dockerfile |
| **Pin base image with digest** | Tags are mutable — a tag can be a different image tomorrow | `FROM python:3.12-slim@sha256:...` |
| **Multi-stage build** | Build tools not in runner image | `FROM python:3.12-slim AS builder` → `FROM python:3.12-slim AS runner` |
| **`docker build --check`** | Dockerfile linting (non-root, HEALTHCHECK, etc.) | Built into Docker 24+ |
| **docker-bench-security** | CIS benchmark against Docker host | `docker run --rm docker/docker-bench-security` |

### Threat Modeling for Solo/Small Teams

**STRIDE** is the right choice — lowest entry barrier, well documented, LLM-compatible.

**Alternatives:**
- PASTA: Requires formal business risk process → not for solo
- LINDDUN: Privacy-specific → only when GDPR-critical

**Lightweight STRIDE process (1-2 hours, once per project):**

1. Simple data flow diagram: boxes = processes, arrows = data flows, cylinders = stores
2. For each trust boundary: 6 STRIDE questions (Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation)
3. Findings as GitHub issues — no separate document
4. **[STRIDE-GPT](https://github.com/mrwadams/stride-gpt)** (open source) generates a STRIDE model from a text description — most pragmatic entry point for solo devs

**OWASP 4-question format** (even leaner):
> What are we building? What can go wrong? What do we do about it? Was it enough?

### OWASP Cheat Sheets — The Most Important for This Stack

| Priority | Cheat sheet | Why |
|-----------|-------------|-------|
| 1 | [SQL Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html) | Prepared statements correctly |
| 1 | [Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) | Login, rate limiting, lockout |
| 1 | [Session Management](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) | Cookie flags, invalidation |
| 2 | [Content Security Policy](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html) | Nonce-based CSP |
| 2 | [Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html) | Non-root, capabilities, read-only |
| 3 | [Logging](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html) | What to log, what never to log |
| 3 | [Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) | .env handling, vault options |

---

## 17. OWASP Top 10 (2021) – Quick Reference

The most common security risks in web apps:

| # | Risk | Countermeasure |
|---|--------|---------------|
| A01 | **Broken Access Control** | Auth at data access layer, RBAC, deny by default |
| A02 | **Cryptographic Failures** | TLS everywhere, no custom crypto, secrets in env vars |
| A03 | **Injection** | Prepared statements, input validation, no shell exec with user input |
| A04 | **Insecure Design** | Threat modeling, security reviews, defense in depth |
| A05 | **Security Misconfiguration** | Hardened defaults, security headers, no default credentials |
| A06 | **Vulnerable Components** | Renovate/Dependabot, npm audit / pip-audit, Trivy |
| A07 | **Auth Failures** | MFA, rate limiting, secure session management |
| A08 | **Data Integrity Failures** | CI/CD pipeline security, signed artifacts, SRI for CDN scripts |
| A09 | **Logging & Monitoring Failures** | Structured logging, Sentry, audit trails |
| A10 | **SSRF** | URL allowlists, no user input in server-side requests |

---

## Checklist: Securing a New App

### Setup (once, before first commit)

- [ ] `gitleaks` + `bandit` + `pip-audit` in pre-commit
- [ ] `semgrep` + `trivy image` in CI pipeline
- [ ] `.env.example` committed, `.env` in `.gitignore`
- [ ] STRIDE threat model created (or OWASP 4-question format)
- [ ] ASVS L1 chapters 2, 4, 5 worked through

### Before First Deploy

- [ ] Configure security headers (CSP, HSTS, X-Frame-Options, etc.)
- [ ] Input validation at all API entry points (Zod / Pydantic)
- [ ] Output encoding — framework defaults, no `dangerouslySetInnerHTML` / no `innerHTML` with uncontrolled data
- [ ] Auth at data access layer, not only middleware
- [ ] Secrets in environment variables, `.env` in `.gitignore`
- [ ] Env validation at app start (Zod / Pydantic)
- [ ] Enforce HTTPS (HSTS header)
- [ ] Error responses without internal details (stack traces, paths, queries)
- [ ] Docker: `USER appuser` in Dockerfile, base image pinned with `@sha256`, multi-stage build
- [ ] `docker build --check` green

### Before Production

- [ ] Rate limiting on login + register + all write endpoints
- [ ] CORS correctly configured (no wildcards with credentials)
- [ ] Cookie flags (httpOnly, secure, sameSite=Lax)
- [ ] Health check endpoint (`/health`)
- [ ] Error monitoring (Sentry)
- [ ] Uptime monitoring (Better Stack / UptimeRobot)
- [ ] Structured logging (Pino / structlog)
- [ ] PostgreSQL: SCRAM-SHA-256 active, app user without DDL rights, no `trust` in pg_hba.conf
- [ ] Database: prepared statements, backups configured and tested
- [ ] File uploads: size limit, type validation, separate storage
- [ ] Accessibility: semantic HTML, keyboard navigation, contrast

### Regularly

- [ ] Update dependencies (Renovate)
- [ ] Keep `pip-audit` / `npm audit` green in CI
- [ ] Test security headers (securityheaders.com)
- [ ] Lighthouse audit (performance + accessibility)
- [ ] Test backup restore
- [ ] Rotate secrets
- [ ] `docker-bench-security` per release

---

## References

- [OWASP ASVS 5.0](https://owasp.org/www-project-application-security-verification-standard/) – Verifiable security standard (May 2025)
- [ASVS × Cheat Sheet Index](https://cheatsheetseries.owasp.org/IndexASVS.html) – ASVS requirements cross-referenced with cheat sheets
- [OWASP Top 10 (2021)](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [OWASP Threat Modeling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html)
- [STRIDE-GPT (GitHub)](https://github.com/mrwadams/stride-gpt) – Generate STRIDE model from text description
- [Semgrep Community Rules](https://semgrep.dev/r) – Python/FastAPI/OWASP rule sets
- [pip-audit (PyPA)](https://github.com/pypa/pip-audit) – SCA for Python
- [Trivy (Aqua Security)](https://trivy.dev/) – Image + dependency + misconfiguration scanner
- [docker-bench-security](https://github.com/docker/docker-bench-security) – CIS benchmark for Docker
- [Trusted Types (web.dev)](https://web.dev/articles/trusted-types) – Structurally eliminate DOM XSS
- [DOMPurify](https://github.com/cure53/DOMPurify) – HTML sanitizer library
- [Mozilla Observatory](https://observatory.mozilla.org)
- [SecurityHeaders.com](https://securityheaders.com)
- [CSP Evaluator (Google)](https://csp-evaluator.withgoogle.com/)
- [Web Content Accessibility Guidelines (WCAG 2.2)](https://www.w3.org/TR/WCAG22/)
- [web.dev Core Web Vitals](https://web.dev/vitals/)
- [Sentry Docs](https://docs.sentry.io/)
- [12-Factor App](https://12factor.net/)
- [OpenTelemetry Docs](https://opentelemetry.io/docs/)
- [Google SRE Book – Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)
- [Grafana Cloud](https://grafana.com/products/cloud/)
- [Axiom](https://axiom.co/)
