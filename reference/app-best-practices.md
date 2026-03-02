# App Architecture & Security Best Practices

Referenz-Checkliste für Web-Applikationen (Stand: März 2026). Sprachunabhängig wo möglich, mit konkreten Tool-Empfehlungen wo nötig.

---

## 1. Security Headers

HTTP-Response-Headers die den Browser anweisen, Sicherheitsfeatures zu aktivieren.

### Must-Have Headers

| Header | Wert | Schützt gegen |
|--------|------|--------------|
| `Content-Security-Policy` | `default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'` | XSS, Code Injection |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Protocol Downgrade, Cookie Hijacking |
| `X-Content-Type-Options` | `nosniff` | MIME-Type Sniffing |
| `X-Frame-Options` | `DENY` | Clickjacking |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Informationsleck über Referrer |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=(), payment=()` | Ungewollte Browser-API-Nutzung |

### CSP – Theorie & Hintergrund

**Was ist CSP?** Content Security Policy ist ein HTTP-Response-Header der dem Browser sagt, welche Ressourcen (Scripts, Styles, Bilder, Fonts, etc.) von welchen Quellen geladen werden dürfen. Alles was nicht explizit erlaubt ist, wird blockiert.

**Das Problem ohne CSP:** Ohne CSP kann ein Angreifer, der XSS (Cross-Site Scripting) in deine Seite einschleust, beliebigen JavaScript-Code ausführen – Daten stehlen, Sessions übernehmen, Keylogger einbauen. CSP ist die letzte Verteidigungslinie: Selbst wenn XSS gelingt, blockiert der Browser das Nachladen von externen Scripts oder das Ausführen von Inline-Code.

**Wie funktioniert es?**

```
1. Server sendet Response mit Header:
   Content-Security-Policy: script-src 'self'; style-src 'self'

2. Browser parsed die HTML-Seite

3. Für jede Ressource prüft der Browser:
   - <script src="https://evil.com/steal.js">  → BLOCKIERT (nicht 'self')
   - <script src="/app.js">                    → ERLAUBT ('self')
   - <script>alert('xss')</script>             → BLOCKIERT (kein 'unsafe-inline')
   - <img src="https://tracker.com/pixel.gif"> → BLOCKIERT (falls img-src: 'self')

4. Violation wird in Browser Console geloggt
   (optional: an report-uri gesendet)
```

**Die drei CSP-Strategien (von schwach zu stark):**

| Strategie | Sicherheit | Praktikabilität | Beschreibung |
|-----------|-----------|-----------------|-------------|
| **Allowlist-basiert** | Mittel | Hoch | Domains explizit erlauben (`script-src 'self' cdn.example.com`) |
| **Nonce-basiert** | Hoch | Mittel | Zufälliger Token pro Request (`script-src 'nonce-abc123'`) |
| **Hash-basiert** | Hoch | Niedrig | SHA-256 Hash jedes Scripts (`script-src 'sha256-...'`) |

**Nonce-basiert ist der empfohlene Ansatz** – Google nennt es ["strict CSP"](https://web.dev/articles/strict-csp). Es funktioniert so:

1. Server generiert pro Request eine zufällige Nonce (z.B. `a1b2c3d4`)
2. Server setzt den Header: `script-src 'nonce-a1b2c3d4' 'strict-dynamic'`
3. Server fügt die Nonce in jedes `<script>` Tag ein: `<script nonce="a1b2c3d4">`
4. Browser führt nur Scripts mit korrekter Nonce aus
5. `'strict-dynamic'` erlaubt, dass diese Scripts weitere Scripts dynamisch laden dürfen

**`'strict-dynamic'` erklärt:** Wenn ein vertrauenswürdiges Script (mit Nonce) ein weiteres Script per `document.createElement('script')` lädt, wird das Kind-Script automatisch als vertrauenswürdig eingestuft. Ohne `'strict-dynamic'` würden diese dynamisch geladenen Scripts blockiert – was die meisten Frameworks (React, Vue, etc.) kaputt machen würde.

**Warum `'unsafe-inline'` vermeiden?** `'unsafe-inline'` erlaubt JEDES Inline-Script. Ein Angreifer der HTML injecten kann (`<script>steal()</script>`), hat damit freie Bahn. Nonces lösen das: Nur Scripts mit der korrekten (nicht erratbaren) Nonce werden ausgeführt.

**Das `'unsafe-inline'` Dilemma bei Styles:** Viele Frameworks (Tailwind, styled-components, Material UI) setzen Inline-Styles. Hier ist `'unsafe-inline'` für `style-src` oft ein akzeptabler Kompromiss – Inline-Styles sind deutlich weniger gefährlich als Inline-Scripts (kein Code-Execution).

**CSP Levels (Versionen):**

| Level | Seit | Wichtigste Features |
|-------|------|-------------------|
| CSP 1.0 | 2012 | Grundlegende Direktiven (script-src, style-src, etc.) |
| CSP 2.0 | 2015 | Nonce, Hash, `base-uri`, `form-action`, `frame-ancestors` |
| CSP 3.0 | 2018+ | `'strict-dynamic'`, `'report-sample'`, `navigate-to` (Draft) |

### CSP Praxis-Guide

**Minimale CSP:**

```
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

**CSP-Direktiven erklärt:**

| Direktive | Kontrolliert | Typische Einstellung |
|-----------|-------------|---------------------|
| `default-src` | Fallback für alle Ressourcen | `'self'` |
| `script-src` | JavaScript | `'self'` (ideal: mit Nonce) |
| `style-src` | CSS | `'self' 'unsafe-inline'` (Frameworks brauchen oft inline) |
| `img-src` | Bilder | `'self' data: https:` |
| `connect-src` | fetch/XHR/WebSocket | `'self'` + API-Domains |
| `frame-ancestors` | Wer darf die Seite einbetten | `'none'` (ersetzt X-Frame-Options) |
| `base-uri` | `<base>` Tag | `'self'` |
| `form-action` | Form-Submissions | `'self'` |

**Nonce-basierte CSP (Gold-Standard):**

Statt `'unsafe-inline'` für Scripts einen zufälligen Nonce pro Request generieren:

```
script-src 'nonce-abc123random' 'strict-dynamic';
```

Der Server generiert pro Request einen neuen Nonce und setzt ihn sowohl im Header als auch im `<script nonce="abc123random">` Tag.

**Praxis-Tipp:** CSP zuerst im Report-Only Modus testen:

```
Content-Security-Policy-Report-Only: default-src 'self'; report-uri /api/csp-report
```

### Testen

- [securityheaders.com](https://securityheaders.com) – Schnellcheck aller Headers
- [Mozilla Observatory](https://observatory.mozilla.org) – Umfassenderer Scan
- [CSP Evaluator (Google)](https://csp-evaluator.withgoogle.com/) – Prüft CSP auf Schwächen
- Browser DevTools > Console – zeigt CSP-Verletzungen

### CSP Weiterführende Links

- [MDN: Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP) – Offizielle Referenz, alle Direktiven erklärt
- [web.dev: Strict CSP (Google)](https://web.dev/articles/strict-csp) – Nonce-basierte CSP Schritt für Schritt
- [CSP Spec (W3C)](https://www.w3.org/TR/CSP3/) – Die offizielle Spezifikation (Level 3)
- [content-security-policy.com](https://content-security-policy.com/) – Interaktive Referenz mit Beispielen
- [CSP Evaluator (Google)](https://csp-evaluator.withgoogle.com/) – Online-Tool das CSP-Header auf Schwächen prüft
- [Report URI](https://report-uri.com/) – Kostenloses CSP-Reporting (sammelt Violations)

---

## 2. Authentication & Authorization

### Grundprinzipien

1. **Defense in Depth** – Nie nur an einer Stelle prüfen
2. **Fail Closed** – Bei Fehler: Zugang verweigern, nicht gewähren
3. **Least Privilege** – Nur die minimal nötigen Rechte

### Auth-Schichten

```
Request
  │
  ├─ Schicht 1: Middleware/Gateway (erste Prüfung)
  │
  ├─ Schicht 2: API Route/Controller (Autorisierung)
  │
  └─ Schicht 3: Data Access Layer (letzte Prüfung) ← WICHTIGSTE
```

**Warum Data Access Layer?** Middleware kann umgangen werden (CVE-2025-29927 in Next.js zeigte: ein manipulierter Header konnte die Middleware komplett bypassen). Die Data-Access-Schicht ist die letzte Verteidigungslinie.

### Passwort-Handling

| Regel | Warum |
|-------|-------|
| **Nie Plaintext speichern** | Immer hashen |
| **bcrypt/scrypt/Argon2** verwenden | Absichtlich langsam, resistant gegen Brute-Force |
| **Timing-safe Vergleiche** | `crypto.timingSafeEqual()` verhindert Timing-Attacks |
| **Rate Limiting** auf Login | Brute-Force-Schutz (z.B. 5 Versuche, dann 15 Min Sperre) |
| **Kein eigenes Crypto** | Immer etablierte Libraries verwenden |

### Session Management

| Ansatz | Vorteil | Nachteil |
|--------|---------|----------|
| **JWT (stateless)** | Kein Server-State, skalierbar | Nicht widerrufbar (bis Ablauf), Token-Größe |
| **Session Cookie (stateful)** | Sofort widerrufbar, kleiner | Braucht Session-Store (Redis/DB) |
| **JWT + Refresh Token** | Kombination beider Vorteile | Komplexer |

**Empfehlung:** Für die meisten Web-Apps: Session Cookies mit httpOnly + secure + sameSite=Lax.

### Cookie-Flags

| Flag | Wert | Warum |
|------|------|-------|
| `httpOnly` | `true` | JavaScript kann Cookie nicht lesen (XSS-Schutz) |
| `secure` | `true` | Nur über HTTPS |
| `sameSite` | `Lax` oder `Strict` | CSRF-Schutz |
| `path` | `/` | Scope einschränken |
| `maxAge` | z.B. 86400 | Ablaufzeit |

---

## 3. Input-Validierung & Output-Encoding

### Grundregel

> **Validiere Input, encode Output.** Vertraue keinen Daten die von außen kommen.

### Input-Validierung

Validiere an der **System-Grenze** (API-Eingang, Form-Submission, Webhook):

| Was validieren | Wie |
|---------------|-----|
| Typ | Ist es ein String/Number/Boolean? |
| Format | E-Mail, URL, Datum – Regex oder Library |
| Länge | Min/Max-Länge begrenzen |
| Wertebereich | Enum, Min/Max für Zahlen |
| Business Rules | Ist der Wert in diesem Kontext sinnvoll? |

**Schema-Validierung (empfohlen):**

| Sprache | Tool |
|---------|------|
| TypeScript | **Zod** (Runtime-Validierung mit Type-Inference) |
| Python | **Pydantic** (v2, Rust-basiert, schnell) |
| Go | **go-playground/validator** |

**Beispiel-Pattern:**

```
Client → API Gateway → Schema-Validierung → Business Logic → Data Access
                            ↑
                    Hier validieren!
                    Ungültig = 400 Bad Request
```

### Output-Encoding

| Kontext | Encoding | Schützt gegen |
|---------|----------|--------------|
| HTML Body | HTML-Entity-Encoding (`<` → `&lt;`) | XSS |
| HTML Attribute | Attribute-Encoding | XSS |
| JavaScript | JSON.stringify + CSP | XSS |
| URL | URL-Encoding (`encodeURIComponent`) | Injection |
| SQL | Prepared Statements / Parameterized Queries | SQL Injection |
| Shell | Keine Shell-Aufrufe mit User-Input! | Command Injection |

**Frameworks machen das meiste automatisch** – React escaped HTML by default, Django Templates ebenso. Aber: `dangerouslySetInnerHTML` (React) oder `| safe` (Django) umgehen den Schutz.

---

## 4. API Design

### Grundprinzipien

| Prinzip | Beschreibung |
|---------|-------------|
| **Konsistente Struktur** | Einheitliche Response-Formate, Error-Codes |
| **Versionierung** | `/api/v1/` oder Header-basiert |
| **Rate Limiting** | Schutz vor Abuse und DDoS |
| **Pagination** | Nie unbegrenzte Listen zurückgeben |
| **Idempotenz** | PUT/DELETE sollen wiederholbar sein |

### REST vs. tRPC vs. GraphQL

| Kriterium | REST | tRPC | GraphQL |
|-----------|------|------|---------|
| Type Safety | Manuell (OpenAPI) | Automatisch (end-to-end) | Schema + Codegen |
| Overhead | Gering | Minimal | Hoch (Resolver, Schema) |
| Lernkurve | Niedrig | Niedrig | Mittel-Hoch |
| Caching | HTTP-Caching einfach | Custom | Apollo Cache, komplexer |
| Mehrere Clients | Gut (Standard) | Nur TypeScript | Gut (jede Sprache) |
| Best für | Public APIs, Multi-Client | Full-Stack TypeScript | Komplexe Datenmodelle |

**Faustregel:** Internes API → tRPC. Externes/Public API → REST. Komplexe Datenabfragen → GraphQL.

### Error-Response Format

Einheitlich für alle Endpoints:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Menschenlesbare Beschreibung",
    "details": [
      { "field": "email", "message": "Ungültiges Format" }
    ]
  }
}
```

**HTTP Status Codes – die wichtigsten:**

| Code | Bedeutung | Wann |
|------|-----------|------|
| 200 | OK | Erfolgreiche GET/PUT/PATCH |
| 201 | Created | Erfolgreiche POST (neues Objekt) |
| 204 | No Content | Erfolgreiche DELETE |
| 400 | Bad Request | Validierungsfehler (Client-Schuld) |
| 401 | Unauthorized | Nicht authentifiziert |
| 403 | Forbidden | Authentifiziert, aber keine Rechte |
| 404 | Not Found | Ressource existiert nicht |
| 409 | Conflict | Konfliktierende Änderung |
| 422 | Unprocessable Entity | Semantisch ungültig |
| 429 | Too Many Requests | Rate Limit erreicht |
| 500 | Internal Server Error | Server-Fehler (nie Details leaken!) |

### Rate Limiting

| Strategie | Beschreibung |
|-----------|-------------|
| **Fixed Window** | X Requests pro Minute |
| **Sliding Window** | Genauer, aber aufwändiger |
| **Token Bucket** | Erlaubt Bursts, glättet über Zeit |

Implementierung: Middleware/Gateway-Level (nicht in Business Logic).

---

## 5. Datenbank

### Migration Tools

Migrationen = versionierte, wiederholbare Schema-Änderungen. **Nie manuell SQL auf Produktion ausführen.**

| Sprache | Tool | Typ |
|---------|------|-----|
| TypeScript | **Drizzle Kit** / **Prisma Migrate** | ORM-integriert |
| Python | **Alembic** (SQLAlchemy) / **Django Migrations** | ORM-integriert |
| Go | **goose** / **golang-migrate** | Standalone |
| Sprachunabhängig | **Flyway** / **Liquibase** | SQL-basiert |

### Migrations-Regeln

| Regel | Warum |
|-------|-------|
| **Immer vorwärts** | Rollback-Migrations sind fehleranfällig. Lieber neue Migration die den Fehler korrigiert. |
| **Idempotent** | `IF NOT EXISTS`, `IF EXISTS` verwenden |
| **Kleine Schritte** | Eine Änderung pro Migration |
| **Daten-Migration separat** | Schema-Änderung ≠ Daten-Migration |
| **Testen in Staging** | Nie ungetestet auf Produktion |

### ORM vs. Raw SQL vs. Query Builder

| Ansatz | Vorteil | Nachteil |
|--------|---------|----------|
| **ORM** (Prisma, SQLAlchemy, Django ORM) | Produktiv, Type-Safe, Migrations | Abstraktion kann problematisch werden, N+1 Queries |
| **Query Builder** (Drizzle, Knex, SQLAlchemy Core) | SQL-nah, Type-Safe, flexibel | Mehr Schreibarbeit als ORM |
| **Raw SQL** | Volle Kontrolle, optimale Performance | Kein Type-Safety, SQL-Injection-Risiko |

**Empfehlung 2026:** Query Builder (Drizzle, SQLAlchemy Core) als Sweet Spot. ORM für schnelle Prototypen. Raw SQL nur für komplexe Queries.

### Connection Pooling

**Warum:** Datenbankverbindungen sind teuer (TCP Handshake, Auth, TLS). Pooling hält Verbindungen offen und wiederverwendet sie.

| Umgebung | Tool |
|----------|------|
| Serverful (Node/Python langlebig) | Built-in Pool (Prisma, SQLAlchemy) |
| Serverless (Lambda, Edge) | **PgBouncer** (extern), **Neon Pooler**, **Prisma Accelerate** |
| Docker | PgBouncer als Sidecar-Container |

**Serverless-Problem:** Jeder Cold Start öffnet neue Verbindung → DB-Limit schnell erreicht. Externer Pooler ist Pflicht.

### Sicherheit

| Regel | Warum |
|-------|-------|
| **Prepared Statements / Parameterized Queries** | SQL Injection verhindern |
| **Least Privilege DB User** | App-User darf nur was nötig ist (kein DROP, GRANT) |
| **Verschlüsselte Verbindung** | TLS/SSL zum DB-Server |
| **Keine DB-Credentials im Code** | Immer Environment Variables |
| **Backups testen** | Ein Backup das nicht restorebar ist, ist kein Backup |

---

## 6. Error Handling & Monitoring

### Error-Handling Prinzipien

| Prinzip | Beschreibung |
|---------|-------------|
| **Fail Fast** | Fehler sofort melden, nicht verschlucken |
| **Keine Secrets in Errors** | Stack Traces, DB-Queries, Pfade nie an Client leaken |
| **Strukturierte Fehler** | Einheitliches Error-Format (siehe API Design) |
| **Retry mit Backoff** | Für transiente Fehler (Netzwerk, Rate Limits): exponentielles Backoff |
| **Circuit Breaker** | Bei wiederholtem Failure: Dependency temporär abschalten |

### Monitoring Stack

| Schicht | Was | Tool |
|---------|-----|------|
| **Error Tracking** | Exceptions, Crashes | **Sentry** (de-facto Standard, Free Tier: 5K Events/Monat) |
| **Uptime Monitoring** | Ist die App erreichbar? | **Better Stack** / UptimeRobot / Pingdom |
| **APM (Performance)** | Slow Requests, Bottlenecks | **Sentry Performance** / Datadog / New Relic |
| **Logging** | Strukturierte Logs | **Pino** (Node) / **structlog** (Python) + Log-Aggregator |
| **Alerting** | Benachrichtigungen | Sentry Alerts / PagerDuty / Opsgenie |

### Was monitoren (Minimum)

| Metrik | Warum | Alert-Schwelle |
|--------|-------|---------------|
| **Error Rate** | Steigt bei Bugs/Ausfällen | > 1% der Requests |
| **Response Time (p95)** | Performance-Degradierung | > 2s |
| **Uptime** | Verfügbarkeit | < 99.9% |
| **CPU / Memory** | Resource-Erschöpfung | > 80% sustained |
| **Disk Space** | Logs/Daten füllen Disk | > 85% |

---

## 7. Logging

### Grundregeln

| Regel | Warum |
|-------|-------|
| **Strukturiert (JSON)** | Maschinen-parsebar, durchsuchbar |
| **Log Levels nutzen** | error, warn, info, debug – richtig einsetzen |
| **Correlation ID** | Request-ID durch alle Services/Logs ziehen |
| **Keine Secrets loggen** | API-Keys, Passwörter, Tokens, PII rausfiltern |
| **Timestamps in UTC** | Konsistenz über Zeitzonen |
| **Log-Rotation** | Disk-Full verhindern |

### Log Levels

| Level | Wann | Beispiel |
|-------|------|---------|
| **error** | Etwas ist kaputt, braucht Aufmerksamkeit | DB-Verbindung fehlgeschlagen, API-Key ungültig |
| **warn** | Unerwarteter Zustand, aber Betrieb läuft | Rate Limit fast erreicht, Fallback aktiviert |
| **info** | Normaler Betrieb, wichtige Events | Server gestartet, User eingeloggt, Refresh durchgeführt |
| **debug** | Detaillierte Infos für Entwicklung | Request/Response Bodies, Query-Details |

### Tools

| Sprache | Structured Logger | Warum |
|---------|------------------|-------|
| Node.js | **Pino** | 5-10x schneller als Winston, natives JSON |
| Python | **structlog** | Processor-Pipeline, Key-Value statt Strings |
| Go | **slog** (stdlib seit 1.21) | Built-in, kein External Dependency nötig |

### Log-Aggregation (Production)

| Tool | Typ | Kosten |
|------|-----|--------|
| **Better Stack (Logtail)** | SaaS | Free Tier 1GB/Monat |
| **Axiom** | SaaS | Free Tier 500GB/Monat |
| **Grafana Loki + Grafana** | Self-hosted | Kostenlos (aber Aufwand) |
| **ELK Stack** | Self-hosted | Kostenlos (aber viel Aufwand) |

---

## 8. Environment & Secrets Management

### Grundregeln

| Regel | Warum |
|-------|-------|
| **`.env` nie committen** | Immer in `.gitignore` |
| **`.env.example` committen** | Dokumentiert welche Vars nötig sind (ohne Werte) |
| **Runtime-Validierung** | App muss beim Start prüfen ob alle Vars gesetzt sind |
| **Unterschiedliche Env pro Stage** | dev / staging / production getrennt |
| **Secrets rotieren** | API-Keys regelmäßig erneuern |

### Env-Validierung beim App-Start

Die App sollte **sofort crashen** wenn eine nötige Variable fehlt – nicht erst wenn der erste Request kommt.

**TypeScript (Zod):**

```typescript
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(1),
  NODE_ENV: z.enum(["development", "production", "test"]),
  PORT: z.coerce.number().default(3000),
});

// Crasht sofort wenn was fehlt – mit klarer Fehlermeldung
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

# Crasht sofort wenn was fehlt
settings = Settings()
```

### Secret-Speicherung nach Umgebung

| Umgebung | Wo Secrets speichern |
|----------|---------------------|
| **Lokal** | `.env` Datei (nie committen) |
| **CI/CD** | GitHub Actions Secrets / GitLab CI Variables |
| **Production (einfach)** | Env-File auf Server (`chmod 600`) |
| **Production (besser)** | **HashiCorp Vault**, **AWS Secrets Manager**, **Infisical** |
| **Kubernetes** | K8s Secrets + **External Secrets Operator** |

---

## 9. Caching

### Caching-Schichten

```
Browser Cache → CDN/Edge Cache → App-Level Cache → DB Query Cache → DB
    ↑                ↑                  ↑                ↑
  Schnellste     Nah am User      Im Server        Letzte Schicht
```

### Cache-Strategien

| Strategie | Wann | Wie |
|-----------|------|-----|
| **Cache-Aside** | Lese-lastige Apps | App prüft Cache → Miss → DB → in Cache schreiben |
| **Write-Through** | Konsistenz wichtig | Schreibe in Cache UND DB gleichzeitig |
| **Write-Behind** | Performance wichtig | Schreibe in Cache, DB asynchron |
| **TTL-based** | Einfachster Ansatz | Daten ablaufen nach X Sekunden |

### HTTP Caching Headers

| Header | Zweck | Beispiel |
|--------|-------|---------|
| `Cache-Control` | Hauptsteuerung | `public, max-age=3600, stale-while-revalidate=60` |
| `ETag` | Versionierung | `"abc123"` – Server prüft ob sich Ressource geändert hat |
| `Last-Modified` | Zeitbasiert | Browser sendet `If-Modified-Since` |
| `Vary` | Cache-Key Variation | `Vary: Accept-Encoding` |

**Praxis-Empfehlung:**

```
# Statische Assets (JS/CSS/Bilder mit Hash im Dateinamen)
Cache-Control: public, max-age=31536000, immutable

# API-Responses (dynamisch, aber cachebar)
Cache-Control: public, max-age=60, stale-while-revalidate=300

# Personalisierte Daten
Cache-Control: private, no-cache

# Nie cachen (Login, Mutations)
Cache-Control: no-store
```

### Tools

| Schicht | Tool |
|---------|------|
| CDN/Edge | **Cloudflare** / Vercel Edge / AWS CloudFront |
| App-Level (Key-Value) | **Redis** / Valkey / Memcached |
| App-Level (In-Memory) | `Map()` / `lru-cache` (Node) / `cachetools` (Python) |
| Framework | Next.js `revalidate` / Django Cache Framework |

---

## 10. CORS (Cross-Origin Resource Sharing)

### Wann relevant

Wenn Frontend und Backend auf **unterschiedlichen Domains** laufen (z.B. `app.example.com` → `api.example.com`).

### Konfiguration

| Setting | Empfehlung | Warum |
|---------|-----------|-------|
| `Access-Control-Allow-Origin` | Explizite Domain(s) | **Nie `*` in Produktion** mit Credentials |
| `Access-Control-Allow-Methods` | Nur nötige Methoden | `GET, POST, PUT, DELETE` |
| `Access-Control-Allow-Headers` | Nur nötige Headers | `Content-Type, Authorization` |
| `Access-Control-Allow-Credentials` | `true` nur wenn nötig | Für Cookie-basierte Auth |
| `Access-Control-Max-Age` | `86400` (24h) | Preflight-Requests cachen |

### Häufige Fehler

| Fehler | Problem |
|--------|---------|
| `Access-Control-Allow-Origin: *` + Credentials | Browser blockiert (by design) |
| CORS nur im Dev-Server konfiguriert | Production vergessen → API nicht erreichbar |
| Preflight (OPTIONS) nicht gehandelt | PUT/DELETE/Custom-Headers funktionieren nicht |

---

## 11. File Uploads

### Sicherheitsregeln

| Regel | Warum |
|-------|-------|
| **Dateigröße limitieren** | DoS-Schutz (z.B. max 10MB) |
| **Dateityp validieren** (Magic Bytes, nicht Extension) | `.jpg` umbenannt in `.exe` fangen |
| **Nie im Web-Root speichern** | Verhindert direktes Ausführen |
| **Zufälligen Dateinamen generieren** | Path Traversal verhindern (`../../etc/passwd`) |
| **Virus-Scan** | Bei User-Uploads: ClamAV oder Cloud-Service |
| **Separater Storage** | S3/GCS statt lokales Filesystem |

---

## 12. Accessibility (a11y)

### Warum Pflicht

- **EU Accessibility Act (EAA)** – seit Juni 2025 gesetzlich vorgeschrieben für digitale Dienste in der EU
- **Barrierefreiheitsstärkungsgesetz (BFSG)** – deutsche Umsetzung des EAA
- Betrifft: E-Commerce, Banking, Transport, öffentliche Dienste

### WCAG 2.2 – Die wichtigsten Punkte

| Prinzip | Was | Praxis |
|---------|-----|--------|
| **Perceivable** | Inhalte müssen wahrnehmbar sein | Alt-Text für Bilder, Kontrast ≥ 4.5:1, Untertitel für Videos |
| **Operable** | UI muss bedienbar sein | Alles per Tastatur erreichbar, keine Zeitlimits, Skip-Links |
| **Understandable** | Inhalte müssen verständlich sein | Klare Sprache, konsistente Navigation, Error-Beschreibungen |
| **Robust** | Inhalte müssen robust interpretierbar sein | Semantisches HTML, ARIA wo nötig, valides Markup |

### Quick Wins

| Maßnahme | Aufwand |
|----------|---------|
| Semantisches HTML (`<nav>`, `<main>`, `<article>`, `<button>`) | Niedrig |
| Richtige Heading-Hierarchie (h1 → h2 → h3, keine Lücken) | Niedrig |
| `alt` Attribute auf allen `<img>` | Niedrig |
| Fokus-Styles nicht entfernen (`:focus-visible`) | Niedrig |
| Farbe nie als einziger Informationsträger | Niedrig |
| `aria-label` für Icon-Only Buttons | Niedrig |
| Skip-to-Content Link | Niedrig |
| Formulare: `<label>` mit `for` Attribut | Niedrig |

### Testing

| Tool | Typ | Findet |
|------|-----|--------|
| **axe-core** (Browser Extension / CLI) | Automatisch | ~57% der WCAG-Probleme |
| **Lighthouse** (Chrome DevTools) | Automatisch | Accessibility Score + Tipps |
| **Tastatur-Test** | Manuell | Tab-Reihenfolge, Fokus-Management |
| **Screen Reader** (VoiceOver/NVDA) | Manuell | Echte User-Experience |

---

## 13. Performance

### Core Web Vitals (Google Ranking-Faktor)

| Metrik | Was | Ziel |
|--------|-----|------|
| **LCP** (Largest Contentful Paint) | Wann ist der Hauptinhalt sichtbar? | < 2.5s |
| **INP** (Interaction to Next Paint) | Wie schnell reagiert die UI? | < 200ms |
| **CLS** (Cumulative Layout Shift) | Springt das Layout herum? | < 0.1 |

### Backend Performance

| Maßnahme | Wann |
|----------|------|
| **Datenbankindizes** | Langsame Queries (EXPLAIN ANALYZE) |
| **N+1 Query vermeiden** | ORM-Nutzung (Eager Loading / JOIN) |
| **Pagination** | Listen > 50 Items |
| **Async I/O** | Parallele externe API-Calls |
| **Connection Pooling** | Jede DB-Verbindung |
| **Response Compression** | gzip/brotli für API-Responses |

### Frontend Performance

| Maßnahme | Wann |
|----------|------|
| **Code Splitting** | Große Bundles (> 200KB JS) |
| **Lazy Loading** | Bilder, Komponenten below the fold |
| **Image Optimization** | WebP/AVIF, responsive Sizes |
| **Font Optimization** | Self-hosted, `font-display: swap` |
| **Prefetching** | Kritische Ressourcen, nächste Navigation |
| **Bundle Analysis** | Regelmäßig prüfen was im Bundle landet |

---

## 14. Deployment Patterns

### Zero-Downtime Deployment

| Pattern | Wie | Komplexität |
|---------|-----|-------------|
| **Rolling Update** | Neue Instanzen starten, alte stoppen | Niedrig |
| **Blue-Green** | Zwei Umgebungen, Traffic umschalten | Mittel |
| **Canary** | Neue Version für % der User, dann ausrollen | Hoch |

### Health Checks

Jede App braucht mindestens zwei Endpoints:

| Endpoint | Prüft | Wann |
|----------|-------|------|
| `/health` (Liveness) | Prozess lebt | Container-Orchestration (Docker, K8s) |
| `/ready` (Readiness) | App kann Requests annehmen (DB ok, etc.) | Load Balancer |

### Rollback-Strategie

| Methode | Geschwindigkeit |
|---------|----------------|
| **Docker Tag Rollback** | `docker run app:previous-tag` (Sekunden) |
| **Git Revert + Redeploy** | Minuten |
| **Blue-Green Switch** | Sekunden (Traffic zurück auf alte Umgebung) |
| **Feature Flags** | Sofort (Flag deaktivieren) |

---

## 15. Observability

### Die drei Säulen

```
                    Observability
                   ╱      │      ╲
              Logs     Metrics    Traces
              │          │          │
         Was passierte?  Wie viel?  Wo im System?
```

| Säule | Was | Beispiel | Tool |
|-------|-----|----------|------|
| **Logs** | Diskrete Events (Textzeilen) | "User login failed for user@example.com" | Pino, structlog |
| **Metrics** | Numerische Messwerte über Zeit | Request-Rate: 150/s, Error-Rate: 0.3%, Latency p95: 240ms | Prometheus, StatsD |
| **Traces** | Request-Pfad durch mehrere Services | Request → API Gateway → Auth Service → DB → Response (320ms) | Jaeger, Zipkin |

**Logs alleine reichen nicht.** Logs sagen _was_ passiert ist. Metrics sagen _wie oft_ und _wie schnell_. Traces sagen _wo genau_ im System ein Problem liegt.

### OpenTelemetry (OTel) – Der Standard

OpenTelemetry ist der herstellerunabhängige Standard für Observability-Daten. Statt für jeden Anbieter (Datadog, Sentry, Grafana) eine eigene Integration zu bauen, instrumentiert man einmal mit OTel und schickt die Daten an ein beliebiges Backend.

```
App (OTel SDK) → OTel Collector → Backend deiner Wahl
                                    ├── Grafana Cloud
                                    ├── Datadog
                                    ├── Sentry
                                    ├── Jaeger (Self-hosted)
                                    └── Axiom / Better Stack
```

**Warum OTel statt Vendor-SDK?**
- Vendor Lock-in vermeiden: Backend wechseln ohne Code-Änderung
- Ein SDK für Logs + Metrics + Traces
- Breite Community, viele Auto-Instrumentierungen

### Metrics – Was messen

| Metrik-Typ | Was | Beispiel |
|------------|-----|---------|
| **Counter** | Zählt Events (nur aufwärts) | Total Requests, Errors, Logins |
| **Gauge** | Aktueller Wert (auf und ab) | Aktive Connections, Queue-Länge, Memory |
| **Histogram** | Verteilung von Werten | Request-Latenz (p50, p95, p99) |

**Die vier goldenen Signale (Google SRE):**

| Signal | Was | Alert wenn |
|--------|-----|-----------|
| **Latency** | Wie lange dauern Requests? | p95 > 2s |
| **Traffic** | Wie viele Requests kommen rein? | Ungewöhnlicher Anstieg/Abfall |
| **Errors** | Wie viele Requests schlagen fehl? | Error Rate > 1% |
| **Saturation** | Wie voll sind Ressourcen? | CPU > 80%, Memory > 85%, Disk > 90% |

### Distributed Tracing

Relevant sobald ein Request mehrere Services durchläuft (oder auch: API → externe API → DB).

```
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

**Trace** = gesamter Request-Pfad. **Span** = einzelner Schritt im Trace. Jeder Span hat Start/Ende und Metadaten.

### Observability-Stack nach Budget

| Budget | Logs | Metrics | Traces | Dashboards |
|--------|------|---------|--------|------------|
| **Kostenlos** | Better Stack (1GB/mo) oder Axiom (500GB/mo) | Prometheus + Grafana (self-hosted) | Jaeger (self-hosted) | Grafana |
| **Low-Budget** | Better Stack / Axiom | Grafana Cloud (Free Tier) | Grafana Tempo (Free Tier) | Grafana Cloud |
| **Enterprise** | Datadog / Splunk | Datadog | Datadog APM | Datadog |

**Pragmatischer Start (Solo/Kleinprojekt):**
1. **Sentry** für Error Tracking + Performance (Free Tier: 5K events/mo)
2. **Better Stack** oder **Axiom** für Logs (großzügige Free Tiers)
3. **UptimeRobot** für Uptime Monitoring (kostenlos, 50 Monitors)
4. Metrics + Traces → erst wenn Bedarf entsteht (mehrere Services, Performance-Probleme)

---

## 16. OWASP Top 10 (2021) – Schnellreferenz

Die häufigsten Sicherheitsrisiken in Web-Apps:

| # | Risiko | Gegenmaßnahme |
|---|--------|---------------|
| A01 | **Broken Access Control** | Auth am Data Access Layer, RBAC, Deny by Default |
| A02 | **Cryptographic Failures** | TLS everywhere, keine eigene Crypto, Secrets in Env Vars |
| A03 | **Injection** | Prepared Statements, Input-Validierung, kein Shell-Exec mit User-Input |
| A04 | **Insecure Design** | Threat Modeling, Security Reviews, Defense in Depth |
| A05 | **Security Misconfiguration** | Hardened Defaults, Security Headers, keine Default-Credentials |
| A06 | **Vulnerable Components** | Renovate/Dependabot, npm audit / pip-audit, Trivy |
| A07 | **Auth Failures** | MFA, Rate Limiting, sichere Session-Management |
| A08 | **Data Integrity Failures** | CI/CD Pipeline Security, signierte Artifacts, SRI für CDN-Scripts |
| A09 | **Logging & Monitoring Failures** | Structured Logging, Sentry, Audit Trails |
| A10 | **SSRF** | URL-Allowlists, kein User-Input in Server-Side Requests |

---

## Checkliste: Neue App absichern

### Vor dem ersten Deploy

- [ ] Security Headers konfigurieren (CSP, HSTS, X-Frame-Options, etc.)
- [ ] Input-Validierung an allen API-Eingängen (Zod / Pydantic)
- [ ] Output-Encoding (Framework-Defaults nutzen, kein `dangerouslySetInnerHTML`)
- [ ] Auth am Data Access Layer, nicht nur Middleware
- [ ] Secrets in Environment Variables, `.env` in `.gitignore`
- [ ] Env-Validierung beim App-Start (Zod / Pydantic)
- [ ] HTTPS erzwingen (HSTS Header)
- [ ] Error Responses ohne interne Details (Stack Traces, Pfade, Queries)

### Vor Production

- [ ] Rate Limiting auf API-Endpoints
- [ ] CORS korrekt konfiguriert (keine Wildcards mit Credentials)
- [ ] Cookie-Flags (httpOnly, secure, sameSite)
- [ ] Health Check Endpoint (`/health`)
- [ ] Error Monitoring (Sentry)
- [ ] Uptime Monitoring (Better Stack / UptimeRobot)
- [ ] Structured Logging (Pino / structlog)
- [ ] Datenbank: Prepared Statements, Least Privilege User, Backups
- [ ] File Uploads: Größenlimit, Typ-Validierung, separater Storage
- [ ] Accessibility: Semantisches HTML, Tastatur-Navigation, Kontrast

### Regelmäßig

- [ ] Dependencies updaten (Renovate)
- [ ] Security Headers testen (securityheaders.com)
- [ ] Lighthouse Audit (Performance + Accessibility)
- [ ] Dependency Audit (`npm audit` / `pip-audit`)
- [ ] Backup-Restore testen
- [ ] Secrets rotieren

---

## Referenzen

- [OWASP Top 10 (2021)](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [Mozilla Observatory](https://observatory.mozilla.org)
- [SecurityHeaders.com](https://securityheaders.com)
- [Web Content Accessibility Guidelines (WCAG 2.2)](https://www.w3.org/TR/WCAG22/)
- [web.dev Core Web Vitals](https://web.dev/vitals/)
- [Sentry Docs](https://docs.sentry.io/)
- [12-Factor App](https://12factor.net/)
- [OpenTelemetry Docs](https://opentelemetry.io/docs/) – Herstellerunabhängiger Observability-Standard
- [Google SRE Book – Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/) – Die vier goldenen Signale
- [Grafana Cloud](https://grafana.com/products/cloud/) – Logs, Metrics, Traces Free Tier
- [Axiom](https://axiom.co/) – Log-Aggregation mit großzügigem Free Tier
