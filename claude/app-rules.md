# App Rules

Verbindliche Regeln fuer Web-Applikationen. Keine Theorie -- nur Entscheidungen.
Detaillierte Erklaerungen: `../reference/app-best-practices.md`

---

## Security Headers

Jede App MUSS diese Response-Headers setzen:

- `Strict-Transport-Security`: `max-age=31536000; includeSubDomains`
- `X-Content-Type-Options`: `nosniff`
- `X-Frame-Options`: `DENY` (Defense-in-Depth fuer aeltere Browser; `frame-ancestors 'none'` in CSP hat Vorrang fuer moderne Browser)
- `Referrer-Policy`: `strict-origin-when-cross-origin`
- `Permissions-Policy`: `camera=(), microphone=(), geolocation=(), payment=()`

**CSP-Strategie:** Nonce-basiert mit `'strict-dynamic'` (Gold-Standard):
`Content-Security-Policy: default-src 'self'; script-src 'nonce-{RANDOM}' 'strict-dynamic'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'`

> Einfachere Variante (ohne Nonce, nur fuer Apps ohne dynamisch geladene Scripts):
> `script-src 'self'`

CSP zuerst im `Report-Only` Modus testen.

---

## Authentication & Authorization

- **Defense in Depth:** Auth an 3 Schichten: Middleware → Route/Controller → Data Access Layer (wichtigste!)
- **Fail Closed:** Bei Fehler Zugang verweigern
- **Passwort:** bcrypt (cost ≥ 12) / scrypt / Argon2id, nie Plaintext, Timing-safe Vergleiche, Rate Limiting auf Login
- **Sessions:** Session Cookies mit `httpOnly=true`, `secure=true`, `sameSite=Lax` (Standard-Empfehlung)
- **JWT:** Nur wenn Statelessness wirklich noetig. Bei JWT:
  - Algorithm explizit pinnen (`HS256`/`RS256`), `alg:none` serverseitig ablehnen
  - JWT Secret ≥ 256 bit (ASVS V2.6)
  - Immer mit Refresh Token + Rotation (Invalidierung bei Logout / Token-Diebstahl)
- **MFA:** Empfohlen ab ASVS L2. TOTP (z.B. Google Authenticator) oder WebAuthn/Passkeys
- **Account Lockout:** Nach ≥ 5 Fehlversuchen progressive Verzoegerung oder temporaeres Lock
- **Password-Reset:** zeitlimitierter Einmal-Token (max. 15 min), nach Nutzung sofort invalidieren
- **Kein eigenes Crypto** -- immer etablierte Libraries

---

## Input-Validierung & Output-Encoding

- **Validiere an der System-Grenze** (API-Eingang): Typ, Format, Laenge, Wertebereich
- **Schema-Validierung:** TypeScript → Zod, Python → Pydantic
- **Output-Encoding:** Framework-Defaults nutzen. Kein `dangerouslySetInnerHTML` (React), kein `| safe` (Django)
- **SQL:** Immer Prepared Statements / Parameterized Queries
- **Shell:** Nie User-Input in Shell-Commands
- **DOM XSS:** Kein `innerHTML`/`outerHTML` mit User-Daten. Trusted Types + DOMPurify bei dynamischem HTML-Rendering

---

## API Design

- **Response-Format:** Einheitlich mit `{ error: { code, message, details } }` bei Fehlern
- **Versionierung:** URL Path (`/api/v1/`)
- **Rate Limiting:** Middleware/Gateway-Level (Fixed Window oder Token Bucket)
- **Pagination:** Nie unbegrenzte Listen
- **Idempotenz:** PUT/DELETE muessen wiederholbar sein
- **API-Typ:** Internes API → tRPC. Externes/Public API → REST. Komplexe Datenmodelle → GraphQL

---

## Datenbank

- **Migrationen:** Immer Migration-Tool (nie manuell SQL auf Prod). TS → Drizzle Kit / Prisma Migrate. Python → Alembic
- **Migrations-Regeln:** Immer vorwaerts, idempotent (`IF NOT EXISTS`), kleine Schritte, in Staging testen
- **ORM-Wahl:** Query Builder (Drizzle, SQLAlchemy Core) als Sweet Spot. ORM fuer Prototypen. Raw SQL nur fuer komplexe Queries
- **Connection Pooling:** Pflicht. Serverless → externer Pooler (PgBouncer, Neon Pooler)
- **Sicherheit:** Prepared Statements, Least Privilege DB User, TLS zum DB-Server, Credentials in Env Vars, Backups testen
- **PostgreSQL:** `SCRAM-SHA-256` in `pg_hba.conf` (kein `md5`). pgAudit fuer Audit-Trails

---

## Error Handling & Monitoring

- **Fail Fast:** Fehler sofort melden, nicht verschlucken
- **Keine Secrets in Errors:** Stack Traces, DB-Queries, Pfade nie an Client
- **Retry:** Exponentielles Backoff fuer transiente Fehler
- **Monitoring-Minimum:** Sentry (Error Tracking), Better Stack/UptimeRobot (Uptime), Structured Logging
- **Alert-Schwellen:** Error Rate > 1%, Response Time p95 > 2s, CPU/Memory > 80%

---

## Logging

- **Strukturiert (JSON)**, Correlation ID pro Request, Timestamps in UTC
- **Keine Secrets loggen** (API-Keys, Passwort, Tokens, PII)
- **Tools:** Node.js → Pino, Python → structlog
- **Log Levels:** error (kaputt), warn (unerwartet), info (normaler Betrieb), debug (Entwicklung)
- **Aggregation:** Better Stack (1GB/mo free) oder Axiom (500GB/mo free)

---

## Environment & Secrets

- `.env` nie committen, `.env.example` committen
- **Env-Validierung beim App-Start:** App crasht sofort wenn Variable fehlt (Zod / Pydantic)
- **Secrets:** Lokal → `.env`. CI/CD → GitHub Secrets. Production → Vault / Secrets Manager
- Secrets regelmaessig rotieren (alle 90 Tage oder bei Verdacht auf Kompromittierung sofort)

---

## Caching

- **HTTP:** Statische Assets → `Cache-Control: public, max-age=31536000, immutable`. API → `max-age=60, stale-while-revalidate=300`. Personalisiert → `private, no-cache`. Login/Mutations → `no-store`
- **App-Level:** Redis fuer Key-Value. In-Memory (`lru-cache` / `cachetools`) fuer Hot Data
- **Strategie:** Cache-Aside fuer Lese-lastige Apps. TTL-based als einfachster Ansatz

---

## CORS

- `Access-Control-Allow-Origin`: Explizite Domain(s), **nie `*` mit Credentials**
- Preflight (OPTIONS) immer handeln
- `Access-Control-Max-Age: 86400` (Preflight cachen)

---

## File Uploads

- Dateigroesse limitieren (z.B. max 10MB)
- Dateityp via Magic Bytes validieren (nicht Extension)
- Nie im Web-Root speichern, zufaelligen Dateinamen generieren
- Separater Storage (S3/GCS statt lokales Filesystem)

---

## Accessibility

- **Gesetzlich Pflicht** (EU Accessibility Act seit Juni 2025, BFSG)
- Semantisches HTML (`<nav>`, `<main>`, `<button>`), richtige Heading-Hierarchie
- `alt` auf allen `<img>`, `aria-label` fuer Icon-Only Buttons
- Fokus-Styles nicht entfernen (`:focus-visible`), Skip-to-Content Link
- Farbe nie als einziger Informationstraeger
- Testen: axe-core + Lighthouse (automatisch), Tastatur-Test + Screen Reader (manuell)

---

## Performance

- **Core Web Vitals:** LCP < 2.5s, INP < 200ms, CLS < 0.1
- **Backend:** DB-Indizes, N+1 vermeiden, Pagination, Async I/O, Connection Pooling, Response Compression
- **Frontend:** Code Splitting (> 200KB), Lazy Loading, WebP/AVIF, Self-hosted Fonts mit `font-display: swap`

---

## Deployment

- **Health Checks:** `/health` (Liveness) + `/ready` (Readiness)
- **Zero-Downtime:** Rolling Update (minimal), Blue-Green (besser)
- **Rollback:** Docker Tag Rollback oder Blue-Green Switch (Sekunden)

---

## Feature Flags

- **Zweck:** Neues Verhalten hinter Flag verstecken → ausrollen → Flag entfernen. Entkoppelt Deploy von Release
- **Kill Switch:** Jedes neue Feature braucht einen Deaktivierungs-Pfad fuer sofortiges Rollback ohne Redeploy
- **Rollout-Reihenfolge:** `disabled → internal → canary (1%) → partial (10%) → full (100%)`
- **Flag-Lebenszyklus:** Max. 1 Sprint aktiv halten, dann entfernen (verhindert Flag-Schulden)
- **Tools:** GrowthBook (Open Source, Self-hosted), Unleash (Self-hosted), LaunchDarkly (SaaS)
- **Nie fuer:** Dauerhafte Konfiguration oder A/B-Tests ohne Cleanup-Plan

---

## Observability

- **Drei Saeulen:** Logs (was passierte) + Metrics (wie viel) + Traces (wo im System)
- **OpenTelemetry** als herstellerunabhaengiger Standard
- **Vier goldene Signale:** Latency, Traffic, Errors, Saturation
- **Pragmatischer Start:** Sentry + Better Stack/Axiom + UptimeRobot. Metrics/Traces erst bei Bedarf

---

## Security Assessment

- **Pruefrahmen:** OWASP ASVS 5.0 (Mai 2025). Level 1 fuer Solo/kleine Teams (~70 Requirements)
- **SAST:** `ruff-S` (pre-commit, schnell, bandit-Subset) + `semgrep` (CI, cross-file Taint-Analyse). Eigenständiger `bandit` nur wenn tiefere Analyse über Ruff-S hinaus nötig
- **SCA:** `pip-audit` (Python). `pnpm audit` (Node). Nicht Safety (veraltet)
- **SBOM:** `syft` (CycloneDX-Format) bei jedem Release -- Nachweis fuer ISO 27001 / EU CRA
- **Image-Scan:** `trivy` in CI — CRITICAL+HIGH → exit 1
- **Threat Modeling:** STRIDE-GPT fuer neue Systeme/Features (einmalig, nicht pro PR)
- **Rhythmus:** SAST+SCA pro PR → Image-Scan pro Build → STRIDE einmalig pro System

---

## OWASP Top 10 Kurzreferenz

> Vollstaendiger Pruefrahmen: ASVS 5.0 (s.o.)

1. Broken Access Control → Auth am Data Access Layer, Deny by Default
2. Cryptographic Failures → TLS everywhere, Secrets in Env Vars
3. Injection → Prepared Statements, kein Shell-Exec mit User-Input
4. Insecure Design → Threat Modeling, Defense in Depth
5. Security Misconfiguration → Security Headers, keine Default-Credentials
6. Vulnerable Components → Renovate, pip-audit / pnpm audit
7. Auth Failures → MFA, Rate Limiting
8. Data Integrity → CI/CD Security, signierte Artifacts
9. Logging Failures → Structured Logging, Audit Trails
10. SSRF → URL-Allowlists, kein User-Input in Server-Side Requests
