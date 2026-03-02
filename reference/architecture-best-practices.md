# Full-Stack Architecture Best Practices

Referenz für Projekt-Architektur, Schichtenmodelle und Infrastruktur-Patterns (Stand: März 2026).
Sprachunabhängig wo möglich, mit konkreten Beispielen für TypeScript/Node.js und Python.

---

## 1. Projekt-Struktur

### Grundprinzip: Feature-basiert statt technisch

**Schlecht (technisch gruppiert):**

```
src/
  controllers/
    userController.ts
    orderController.ts
    productController.ts
  services/
    userService.ts
    orderService.ts
    productService.ts
  models/
    user.ts
    order.ts
    product.ts
```

Problem: Um ein Feature zu verstehen, muss man zwischen 5+ Ordnern hin- und herspringen.

**Besser (feature-basiert / Colocation):**

```
src/
  features/
    user/
      user.model.ts
      user.service.ts
      user.controller.ts
      user.test.ts
    order/
      order.model.ts
      order.service.ts
      order.controller.ts
      order.test.ts
  shared/
    lib/         # Utilities die überall gebraucht werden
    middleware/   # Auth, Logging, Error Handling
    types/       # Gemeinsame Types/Interfaces
```

Vorteil: Alles was zu einem Feature gehört, ist beisammen. Einfacher zu verstehen, einfacher zu löschen.

### Next.js App Router Struktur

```
src/
  app/                    # Routing (App Router)
    (auth)/               # Route Groups (kein URL-Segment)
      login/page.tsx
      register/page.tsx
    api/                  # API Routes
      monitor/route.ts
      health/route.ts
    layout.tsx
    page.tsx
  components/             # UI-Komponenten
    ui/                   # Generische (Button, Card, Modal)
    features/             # Feature-spezifische Komponenten
  lib/                    # Business Logic, Utilities
    services/             # Externe API-Calls, LLM-Integration
    storage.ts            # Data Access Layer
    schemas.ts            # Zod Schemas
    types.ts              # TypeScript Types
  hooks/                  # Custom React Hooks
```

### Python (FastAPI) Struktur

```
src/
  app/
    main.py               # App-Entry, ASGI Config
    config.py              # Settings (Pydantic BaseSettings)
    dependencies.py        # Dependency Injection
  features/
    user/
      router.py            # API Endpoints
      service.py           # Business Logic
      models.py            # SQLAlchemy/Pydantic Models
      schemas.py           # Request/Response Schemas
    order/
      ...
  shared/
    middleware/            # Auth, CORS, Error Handling
    database.py            # DB Connection, Session
    exceptions.py          # Custom Exceptions
tests/
  features/
    user/
      test_router.py
      test_service.py
```

### Barrel Exports (`index.ts`)

Barrel Exports vereinfachen Imports:

```typescript
// src/lib/index.ts
export { sanitizeUrl, stripCiteTags } from "./types";
export { monitorResponseSchema } from "./schemas";
export { saveData, loadData } from "./storage";

// Nutzung:
import { sanitizeUrl, monitorResponseSchema, saveData } from "@/lib";
```

**Wann Barrel Exports:** Für `lib/`, `components/`, `shared/` – Ordner die von außen importiert werden.
**Wann nicht:** Für Feature-Ordner die nur intern genutzt werden (vermeidet Circular Dependencies).

---

## 2. Schichtenmodell (Layered Architecture)

### Die 4 Schichten

```
┌─────────────────────────────────────┐
│  Presentation Layer                 │  UI, API Routes, Controllers
│  (was der User sieht)              │
├─────────────────────────────────────┤
│  Application Layer                  │  Use Cases, Orchestration
│  (was die App tut)                 │
├─────────────────────────────────────┤
│  Domain Layer                       │  Business Logic, Regeln
│  (was die Geschäftslogik sagt)     │  Keine Abhängigkeiten nach außen!
├─────────────────────────────────────┤
│  Infrastructure Layer               │  DB, APIs, File System, Email
│  (wie es technisch passiert)       │
└─────────────────────────────────────┘
```

### Dependency Rule

**Abhängigkeiten zeigen nur nach innen/unten:**

```
Presentation → Application → Domain ← Infrastructure
                                ↑
                        Domain kennt KEINE
                        konkrete DB/API
```

Die Domain-Schicht definiert Interfaces, die Infrastructure-Schicht implementiert sie (Dependency Inversion).

### Praxis-Beispiel

```typescript
// Domain Layer – kennt keine DB, keine API
interface NewsRepository {
  save(news: NewsItem[]): Promise<void>;
  findRecent(limit: number): Promise<NewsItem[]>;
}

// Application Layer – orchestriert
class RefreshNewsUseCase {
  constructor(
    private newsRepo: NewsRepository,
    private newsProvider: NewsProvider,
  ) {}

  async execute(): Promise<NewsItem[]> {
    const fresh = await this.newsProvider.fetch();
    await this.newsRepo.save(fresh);
    return this.newsRepo.findRecent(100);
  }
}

// Infrastructure Layer – konkrete Implementierung
class FileNewsRepository implements NewsRepository {
  async save(news: NewsItem[]): Promise<void> {
    await fs.writeFile("data/news.json", JSON.stringify(news));
  }
  async findRecent(limit: number): Promise<NewsItem[]> {
    const data = await fs.readFile("data/news.json", "utf-8");
    return JSON.parse(data).slice(0, limit);
  }
}
```

### Wann welches Level an Schichtung?

| Projektgröße | Empfehlung |
|-------------|-----------|
| **Kleines Projekt / Prototyp** | 2 Schichten reichen: Routes → Service/Logic |
| **Mittleres Projekt** | 3 Schichten: Routes → Service → Data Access |
| **Großes Projekt / Team** | Vollständige Layered/Clean Architecture |

**Wichtig:** Over-Engineering vermeiden. Ein Solo-Projekt braucht keine 4 Abstraktionsschichten. Starte einfach, refactore wenn es wächst.

---

## 3. Clean Architecture / Hexagonal Architecture

### Grundidee

Die Business-Logik (Domain) ist der Kern und hat **keine Abhängigkeit** zu Frameworks, Datenbanken oder externen Services. Alles Externe ist austauschbar.

```
                    ┌─────────────────┐
                    │   Frameworks    │
                    │   (Express,     │
                    │    Next.js,     │
                    │    FastAPI)     │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   Adapters      │
                    │   (Controller,  │
                    │    Repository   │
                    │    Impl.)      │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   Use Cases     │
                    │   (Application  │
                    │    Logic)       │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   Entities      │
                    │   (Domain       │
                    │    Objects)     │
                    └─────────────────┘
```

### Ports & Adapters (Hexagonal)

- **Port** = Interface das die Domain definiert (z.B. `NewsRepository`)
- **Adapter** = Konkrete Implementierung (z.B. `PostgresNewsRepository`, `FileNewsRepository`)

Vorteil: Du kannst die DB wechseln ohne Business-Logik anzufassen. Du kannst Tests schreiben ohne echte DB.

### Wann Clean Architecture?

| Situation | Empfehlung |
|-----------|-----------|
| Prototyp / MVP | Nein – zu viel Overhead |
| Solo-Projekt < 10K LOC | Nein – einfache Schichtung reicht |
| Team-Projekt > 10K LOC | Ja – Struktur zahlt sich aus |
| Langlebiges Produkt | Ja – Austauschbarkeit wichtig |
| Microservice | Ja – klare Grenzen nötig |

---

## 4. Monolith vs. Microservices

### Vergleich

| Aspekt | Monolith | Microservices |
|--------|----------|--------------|
| **Komplexität** | Niedrig (ein Deployment) | Hoch (Netzwerk, Service Discovery, etc.) |
| **Deployment** | Einfach (ein Artifact) | Komplex (viele unabhängige Deployments) |
| **Skalierung** | Vertikal (größere Maschine) | Horizontal (mehr Instanzen pro Service) |
| **Daten-Konsistenz** | Einfach (eine DB) | Komplex (Distributed Transactions) |
| **Team-Autonomie** | Schwieriger bei großen Teams | Services = Team-Grenzen |
| **Debugging** | Stack Trace in einem Prozess | Distributed Tracing nötig |
| **Latenz** | Funktionsaufrufe (Nanosekunden) | Netzwerk-Calls (Millisekunden) |

### Die richtige Wahl

```
                    Starte hier
                        │
                        ▼
              ┌─────────────────────┐
              │     MONOLITH        │
              │  (gut strukturiert) │
              └──────────┬──────────┘
                         │
              Wächst das Team?
              Brauchen Teile andere
              Skalierung/Technologie?
                         │
                    Ja   │   Nein
                    ▼    │    ▼
           ┌─────────┐  │  Bleib beim
           │ Modular  │  │  Monolith
           │Monolith  │  │
           └────┬─────┘  │
                │        │
           Einzelne Module
           müssen unabhängig
           deployt werden?
                │
           Ja   │
           ▼    │
     ┌──────────┐
     │ Extrahiere│
     │ einzelne  │
     │ Services  │
     └──────────┘
```

**Faustregel:** Starte IMMER mit einem Monolith. Extrahiere Services erst wenn du einen konkreten Grund hast (nicht präventiv).

### Der Modulare Monolith (bester Kompromiss)

Monolith mit klaren Modul-Grenzen. Jedes Modul hat:
- Eigene Domain-Logik
- Eigenes Data Model
- Klare API (Exports) nach außen
- Kommunikation über definierte Interfaces (nicht direkte DB-Zugriffe)

Kann später zu Microservices aufgespalten werden, weil die Grenzen schon gezogen sind.

```
┌─────────────────────────────────────────────┐
│                  Monolith                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │  User     │ │  Order   │ │ Product  │   │
│  │  Module   │ │  Module  │ │ Module   │   │
│  │ ┌──────┐ │ │ ┌──────┐ │ │ ┌──────┐ │   │
│  │ │Domain│ │ │ │Domain│ │ │ │Domain│ │   │
│  │ │  DB  │ │ │ │  DB  │ │ │ │  DB  │ │   │
│  │ └──────┘ │ │ └──────┘ │ │ └──────┘ │   │
│  └──────────┘ └──────────┘ └──────────┘   │
│         ↕              ↕            ↕       │
│     Kommunikation nur über definierte APIs  │
└─────────────────────────────────────────────┘
```

---

## 5. Monorepo vs. Polyrepo

### Vergleich

| Aspekt | Monorepo | Polyrepo |
|--------|----------|----------|
| **Code Sharing** | Einfach (lokale Imports) | Packages publishen nötig |
| **Atomic Changes** | Ein Commit ändert Frontend + Backend + Shared | Mehrere PRs über Repos |
| **CI/CD** | Komplexer (was hat sich geändert?) | Einfach (jedes Repo = ein Build) |
| **Tooling** | Braucht spezielle Tools (Turborepo, Nx, Pants) | Standard Git reicht |
| **Onboarding** | Ein Repo klonen, alles da | Welche Repos brauche ich? |
| **Git Performance** | Kann bei Millionen Files langsam werden | Kein Problem |

### Monorepo Tools

| Tool | Sprache | Stärke |
|------|---------|--------|
| **Turborepo** | TypeScript/Node | Einfach, schnell, Vercel-backed |
| **Nx** | TypeScript/Node (+ polyglot) | Feature-reich, Dependency Graph, Plugins |
| **pnpm Workspaces** | Node | Built-in, kein Extra-Tool |
| **Pants** | Python (+ polyglot) | Inkrementelle Builds, Caching |
| **uv Workspaces** | Python | Neu (2025+), natives Monorepo-Support |

### Empfehlung

| Situation | Empfehlung |
|-----------|-----------|
| Solo-Projekt | Monorepo (Turborepo/pnpm Workspaces) |
| Full-Stack App (Frontend + Backend + Shared) | Monorepo |
| Unabhängige Services, verschiedene Teams | Polyrepo |
| Mixed Languages (TS + Python + Go) | Polyrepo (oder Nx/Pants) |

### Monorepo Struktur (Turborepo)

```
my-project/
  apps/
    web/              # Next.js Frontend
      package.json
    api/              # Express/Fastify Backend
      package.json
  packages/
    shared/           # Geteilte Types, Utils
      package.json
    ui/               # Design System / Komponenten
      package.json
    config/           # Shared ESLint, TS, Tailwind Config
      package.json
  turbo.json          # Build Pipeline
  package.json        # Root
  pnpm-workspace.yaml # Workspace Definition
```

---

## 6. Backend-Architektur Patterns

### MVC (Model-View-Controller)

```
Request → Controller → Model → Database
              ↓
            View → Response
```

Klassisch, einfach, gut für CRUD-Apps. Wird schnell unübersichtlich bei komplexer Business-Logik.

### Service Layer Pattern

```
Request → Controller → Service → Repository → Database
                          ↓
                    Business Logic
```

Controller: HTTP-Handling (Request parsing, Response formatting).
Service: Business-Logik (Validierung, Orchestration, Regeln).
Repository: Daten-Zugriff (Queries, CRUD).

**Der wichtigste Schritt von MVC:** Business-Logik aus dem Controller in Services extrahieren.

### CQRS (Command Query Responsibility Segregation)

Lese- und Schreib-Operationen trennen:

```
┌──────────┐     ┌─────────────┐     ┌──────────┐
│  Command  │────▶│ Write Model │────▶│ Write DB │
│  (Write)  │     │ (normalized)│     │          │
└──────────┘     └─────────────┘     └──────────┘

┌──────────┐     ┌─────────────┐     ┌──────────┐
│  Query    │────▶│ Read Model  │────▶│ Read DB  │
│  (Read)   │     │(denormalized│     │(optimiert│
└──────────┘     │  für Reads) │     │für Query)│
                  └─────────────┘     └──────────┘
```

**Wann CQRS:** Lese-Zugriffe >> Schreib-Zugriffe, verschiedene Optimierungen nötig.
**Wann nicht:** Einfache CRUD-Apps (Overkill).

### Event-Driven Architecture

```
Service A ──publishes──▶ Event Bus ──subscribes──▶ Service B
                              │
                              └──subscribes──▶ Service C
```

**Wann:** Lose Kopplung zwischen Services, asynchrone Verarbeitung, Audit Trails.
**Tools:** RabbitMQ, Apache Kafka, Redis Streams, AWS SQS/SNS.

---

## 7. Frontend-Architektur Patterns

### Component Architecture

```
┌─────────────────────────────────┐
│  Pages / Routes                 │  URL → welche Seite?
├─────────────────────────────────┤
│  Feature Components             │  Geschäftslogik-Komponenten
│  (Dashboard, UserProfile)       │  (fetchen Daten, haben State)
├─────────────────────────────────┤
│  UI Components                  │  Reine Darstellung
│  (Button, Card, Modal)          │  (Props rein, UI raus)
├─────────────────────────────────┤
│  Hooks / State Management       │  Shared Logic
│  (useAuth, useMonitorData)      │  (Daten-Fetching, State)
├─────────────────────────────────┤
│  Utils / Lib                    │  Pure Functions
│  (formatDate, sanitizeUrl)      │  (kein State, kein UI)
└─────────────────────────────────┘
```

### Server Components vs. Client Components (React/Next.js)

| Typ | Rendert | Kann | Kann nicht |
|-----|---------|------|-----------|
| **Server Component** | Auf dem Server | DB-Zugriff, async/await, Secrets lesen | useState, useEffect, Event Handlers |
| **Client Component** | Im Browser | Interaktivität, Browser APIs | Direkt auf DB/Secrets zugreifen |

**Faustregel:** Default ist Server Component. Nur `"use client"` hinzufügen wenn Interaktivität nötig ist.

```
// Gut: Server Component holt Daten, Client Component zeigt interaktiven Teil
// page.tsx (Server)
async function DashboardPage() {
  const data = await loadMonitorData();  // Server-only, direkt DB-Zugriff
  return <Dashboard initialData={data} />;
}

// Dashboard.tsx (Client – "use client")
function Dashboard({ initialData }) {
  const [data, setData] = useState(initialData);
  // ... Interaktivität
}
```

### State Management – Entscheidungsbaum

```
Brauchst du geteilten State?
    │
    ├── Nein → useState / useReducer (lokal)
    │
    └── Ja → Wie viele Konsumenten?
              │
              ├── 2-3 nahe Komponenten → Props drilling / Composition
              │
              ├── Viele Komponenten → React Context
              │
              └── Komplexer State mit vielen Updates?
                    │
                    ├── Ja → Zustand (leichtgewichtig) oder Redux Toolkit
                    │
                    └── Server State? → TanStack Query / SWR
```

**Server State** (Daten vom Backend) ≠ **Client State** (UI-Zustand). Mische sie nicht:
- **Server State:** TanStack Query, SWR, oder Next.js Server Components
- **Client State:** useState, Zustand, Redux Toolkit

---

## 8. Data Fetching Patterns

### Server-Side vs. Client-Side

| Pattern | Wann | Tool |
|---------|------|------|
| **SSR (Server-Side Rendering)** | SEO wichtig, initialer Load schnell | Next.js Server Components |
| **SSG (Static Site Generation)** | Inhalt ändert sich selten | Next.js `generateStaticParams()` |
| **ISR (Incremental Static Regen.)** | Statisch + periodisch aktualisiert | Next.js `revalidate` |
| **CSR (Client-Side Rendering)** | Hinter Login, Dashboard-Apps | TanStack Query, SWR |
| **Streaming** | Lange Queries, Progressive Loading | React Suspense + Streaming SSR |

### API-Call Patterns

**Deduplizierung:** Mehrere Komponenten fetchen die gleichen Daten → nur ein Request.

```typescript
// TanStack Query dedupliziert automatisch:
// Beide Hooks machen nur EINEN API-Call
function ComponentA() {
  const { data } = useQuery({ queryKey: ["monitor"], queryFn: fetchMonitor });
}
function ComponentB() {
  const { data } = useQuery({ queryKey: ["monitor"], queryFn: fetchMonitor });
}
```

**Optimistic Updates:** UI sofort updaten, API-Call im Hintergrund.

```typescript
// User klickt "Löschen" → Item verschwindet sofort
// API-Call läuft parallel
// Bei Fehler: Rollback auf vorherigen Zustand
```

**Stale-While-Revalidate:** Gecachte Daten sofort anzeigen, im Hintergrund frische holen.

---

## 9. Docker Architektur

### Single-Container App

Für einfache Apps (wie der News Monitor):

```
┌─────────────────────┐
│    Cloudflare        │
│    Tunnel / Nginx    │
│    (Reverse Proxy)   │
└──────────┬──────────┘
           │ :3000
┌──────────▼──────────┐
│    App Container     │
│    (Next.js /        │
│     FastAPI)         │
│    ┌───────────────┐ │
│    │ /app/data     │ │ ← Docker Volume
│    └───────────────┘ │
└─────────────────────┘
```

### Multi-Container App (docker-compose)

Für Apps mit DB, Cache, Background Workers:

```
┌──────────────────────────────────────────┐
│              docker-compose              │
│                                          │
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │  App     │  │  Postgres│  │ Redis  ││
│  │  :3000   │──│  :5432   │  │ :6379  ││
│  └──────────┘  └──────────┘  └────────┘│
│       │              │            │      │
│  ┌────▼───┐    ┌─────▼────┐ ┌────▼───┐ │
│  │ Volume │    │  Volume  │ │ Volume │ │
│  │app-data│    │ pg-data  │ │redis-  │ │
│  │        │    │          │ │data    │ │
│  └────────┘    └──────────┘ └────────┘ │
└──────────────────────────────────────────┘
```

**`docker-compose.yml` (Referenz):**

```yaml
services:
  app:
    build: .
    ports:
      - "127.0.0.1:3000:3000"  # Nur localhost!
    env_file: .env
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  db:
    image: postgres:17-alpine
    volumes:
      - pg-data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myapp
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  pg-data:
  redis-data:
```

### Docker Networking Basics

```
┌─────────────────────────────────────────────┐
│          Docker Network (bridge)            │
│                                             │
│  app ──────── db        Intern: Hostname    │
│    │          │         (app kann "db:5432" │
│    └──────── redis       erreichen)         │
│                                             │
│  Extern: Nur app:3000 via Port-Mapping      │
└─────────────────────────────────────────────┘
```

- Container kommunizieren über **Service-Namen** (nicht IPs): `postgres://db:5432/myapp`
- Nur explizit gemappte Ports sind von außen erreichbar
- `127.0.0.1:3000:3000` bindet nur an localhost (nicht ans Internet)
- Default: Alle Services im gleichen `docker-compose.yml` teilen ein Netzwerk

### Docker Volumes: Bind Mount vs. Named Volume

| Typ | Syntax | Wann |
|-----|--------|------|
| **Named Volume** | `volumes: [pg-data:/var/lib/...]` | Produktion (Docker verwaltet) |
| **Bind Mount** | `volumes: [./data:/app/data]` | Entwicklung (Live-Reload, einfacher Zugriff) |
| **tmpfs** | `tmpfs: /tmp` | Temporäre Daten (verschwindet bei Neustart) |

**Wichtig:** Named Volumes überleben `docker compose down`. Nur `docker compose down -v` löscht sie.

---

## 10. Reverse Proxy & SSL

### Warum ein Reverse Proxy?

```
Internet                   Server
   │
   │    ┌──────────────┐
   ├───▶│ Reverse Proxy│    - SSL Termination
   │    │ (Nginx /     │    - Rate Limiting
   │    │  Caddy /     │    - Static File Serving
   │    │  Cloudflare) │    - Compression
   │    └──────┬───────┘    - Caching
   │           │             - Security Headers
   │    ┌──────▼───────┐
   │    │  App (:3000) │    - Nur Business Logic
   │    └──────────────┘
```

### Optionen

| Tool | Stärke | Best für |
|------|--------|---------|
| **Caddy** | Automatisches HTTPS (Let's Encrypt), einfachste Config | Kleine/mittlere Apps |
| **Nginx** | Performant, flexibel, Industriestandard | Alles |
| **Traefik** | Docker-native, automatische Service-Discovery | Docker/K8s Umgebungen |
| **Cloudflare Tunnel** | Kein offener Port nötig, DDoS-Schutz | Wenn kein Public IP gewünscht |

### Caddy (einfachstes Setup)

```
# Caddyfile – das ist ALLES was du brauchst
myapp.example.com {
    reverse_proxy app:3000
}
# HTTPS wird automatisch konfiguriert (Let's Encrypt)
```

### Nginx (Referenz-Config)

```nginx
server {
    listen 443 ssl http2;
    server_name myapp.example.com;

    ssl_certificate /etc/letsencrypt/live/myapp/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/myapp/privkey.pem;

    # Security Headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Proxy
    location / {
        proxy_pass http://app:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static Files (optional, wenn App eigene Static Files hat)
    location /_next/static/ {
        proxy_pass http://app:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# HTTP → HTTPS Redirect
server {
    listen 80;
    server_name myapp.example.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 11. Environment-Strategien

### Minimum: Dev + Production (2-Tier)

Für Solo-Projekte und kleine Teams reicht oft ein 2-Tier-Setup:

| Aspekt | Development | Production |
|--------|------------|------------|
| **Datenbank** | Lokal (Docker) oder SQLite | Echte Daten |
| **External APIs** | Mocks / Sandbox | Live |
| **Debug Mode** | An | **Aus** |
| **Logging Level** | debug | info/warn |
| **SSL** | Optional (localhost) | Ja |
| **Secrets** | `.env` lokal | CI/CD Secrets / Vault |
| **Error Detail** | Stack Traces | Generische Meldung |

**Das reicht wenn:**
- Solo-Entwickler oder kleines Team (1-3 Personen)
- Kein Kunden-facing SLA (interne Tools, Side Projects)
- Deployments sind schnell revertbar (Docker, Vercel, etc.)
- Gute Test-Coverage als Sicherheitsnetz

**Empfohlene Absicherung ohne Staging:**
- CI Pipeline mit Tests + Linting (ersetzt manuelles Staging-Testing)
- Docker-Image lokal testen bevor man deployed (`docker compose up` mit Prod-Config)
- Feature Flags für riskante Changes (schrittweise aktivieren)
- Health Checks + Rollback-Strategie im Deployment

### Level Up: Dev + Staging + Production (3-Tier)

Staging wird sinnvoll wenn:
- **Mehrere Entwickler** gleichzeitig deployen
- **Externe Abhängigkeiten** (Payment APIs, Third-Party Webhooks) getestet werden müssen
- **Datenbank-Migrationen** komplex sind und vor Prod validiert werden sollten
- **Kunden/Stakeholder** vor Release testen wollen (UAT)
- **Compliance-Anforderungen** eine Pre-Production-Validierung verlangen

| Aspekt | Development | Staging | Production |
|--------|------------|---------|------------|
| **Datenbank** | Lokal (Docker) oder SQLite | Kopie von Prod (anonymisiert!) | Echte Daten |
| **External APIs** | Mocks / Sandbox | Sandbox / eingeschränkt | Live |
| **Debug Mode** | An | An | **Aus** |
| **Logging Level** | debug | info | info/warn |
| **SSL** | Optional (localhost) | Ja | Ja |
| **Secrets** | `.env` lokal | CI/CD Secrets | Vault / Secret Manager |
| **Error Detail** | Stack Traces | Stack Traces | Generische Meldung |

### Docker Compose Overrides

```
docker-compose.yml           # Base Config (Production-ready)
docker-compose.override.yml  # Dev Overrides (auto-geladen)
docker-compose.prod.yml      # Production Overrides
```

```yaml
# docker-compose.override.yml (Entwicklung)
services:
  app:
    build:
      target: builder    # Dev Stage statt Production Stage
    volumes:
      - .:/app           # Live-Reload via Bind Mount
      - /app/node_modules # Node Modules nicht überschreiben
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"      # Direkt erreichbar (kein localhost-only)
```

```bash
# Entwicklung (lädt automatisch docker-compose.override.yml)
docker compose up

# Production (ignoriert override, lädt prod)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## 12. API Gateway Pattern

### Wann brauche ich ein API Gateway?

```
Ohne Gateway:                    Mit Gateway:
Client → Service A               Client → Gateway → Service A
Client → Service B                                → Service B
Client → Service C                                → Service C
(Client kennt alle Services)     (Client kennt nur Gateway)
```

### Was ein Gateway macht

| Feature | Beschreibung |
|---------|-------------|
| **Routing** | `/api/users` → User Service, `/api/orders` → Order Service |
| **Auth** | Token-Validierung einmal zentral |
| **Rate Limiting** | Pro Client/API-Key |
| **Request Transform** | Headers hinzufügen, Bodys transformieren |
| **Response Aggregation** | Mehrere Service-Calls zu einer Response kombinieren |
| **Circuit Breaking** | Failing Service temporär deaktivieren |

### Tools

| Tool | Typ | Best für |
|------|-----|---------|
| **Nginx / Caddy** | Reverse Proxy mit Routing | Einfache Cases |
| **Kong** | Full API Gateway | Enterprise |
| **Traefik** | Docker-native Gateway | Container-Umgebungen |
| **Next.js API Routes** | Built-in | Full-Stack Next.js Apps |
| **tRPC** | Type-safe Gateway | TypeScript Monorepos |

---

## 13. Twelve-Factor App

Die [12 Faktoren](https://12factor.net/) – Grundprinzipien für moderne Apps:

| # | Faktor | Regel | Praxis |
|---|--------|-------|--------|
| 1 | **Codebase** | Ein Repo, viele Deploys | Git + Branch pro Env |
| 2 | **Dependencies** | Explizit deklariert | `package.json` / `pyproject.toml` + Lockfile |
| 3 | **Config** | In Environment, nicht im Code | `.env` + Env Vars |
| 4 | **Backing Services** | Als angehängte Ressourcen | DB-URL als Env Var, nicht hardcoded |
| 5 | **Build, Release, Run** | Strikt getrennt | CI baut → Image releast → Container läuft |
| 6 | **Processes** | Stateless, Share-Nothing | Kein lokaler State (Session in Redis, nicht in Memory) |
| 7 | **Port Binding** | App bindet eigenen Port | `PORT=3000` als Env Var |
| 8 | **Concurrency** | Skalierung über Prozesse | Mehrere Container, nicht Threads |
| 9 | **Disposability** | Schnell starten, graceful stoppen | SIGTERM Handling, Health Checks |
| 10 | **Dev/Prod Parity** | Environments angleichen | Docker macht Dev ≈ Prod |
| 11 | **Logs** | Als Event-Streams | Stdout/Stderr, nicht in Dateien |
| 12 | **Admin Processes** | Einmalige Tasks als eigene Prozesse | Migrations als eigener Container/Command |

---

## 14. Testing-Strategie

### Die Test-Pyramide

```
         ╱  E2E  ╲          Wenige, langsam, teuer
        ╱─────────╲         Testen: ganze User Flows
       ╱Integration╲        Mittelviele, mittelschnell
      ╱─────────────╲       Testen: Zusammenspiel mehrerer Module
     ╱     Unit      ╲      Viele, schnell, günstig
    ╱─────────────────╲     Testen: einzelne Funktionen/Klassen
```

**Die Pyramide ist ein Leitfaden, kein Gesetz.** Das Verhältnis hängt vom Projekttyp ab:

| Projekttyp | Schwerpunkt | Warum |
|------------|------------|-------|
| **Library / Utility** | Viele Unit-Tests | Klar definierte Ein-/Ausgaben |
| **API / Backend** | Viele Integration-Tests | Zusammenspiel von Routes, DB, Auth |
| **UI-lastige App** | Mehr E2E, weniger Unit | User-Interaktion ist das Entscheidende |
| **CRUD App** | Wenig Unit, viel Integration/E2E | Wenig Logik, viel Zusammenspiel |

### Was auf welcher Ebene testen

| Ebene | Was testen | Was NICHT testen |
|-------|-----------|-----------------|
| **Unit** | Pure Functions, Berechnungen, Validierung, Transformer, Utilities | Framework-Code, DB-Queries, HTTP-Calls |
| **Integration** | API Routes end-to-end, DB-Operationen, Service-Zusammenspiel, Auth-Flows | UI-Rendering, Browser-Verhalten |
| **E2E** | Kritische User Journeys (Signup, Checkout, Core-Feature), Cross-Browser | Alles was Unit/Integration abdeckt |

### Testing-Regeln

| Regel | Warum |
|-------|-------|
| **Tests testen Verhalten, nicht Implementierung** | Refactoring darf Tests nicht brechen |
| **Arrange → Act → Assert** (AAA) | Klare Struktur, lesbarer Test |
| **Ein Konzept pro Test** | Test-Name beschreibt was getestet wird |
| **Keine Test-Interdependenz** | Tests müssen in beliebiger Reihenfolge laufen |
| **Test-Daten im Test definieren** | Kein Hidden State aus anderen Dateien |
| **Keine Logik im Test** | Kein if/else, Loops, oder Berechnungen in Tests |

### Mocking-Strategie

| Regel | Erklärung |
|-------|-----------|
| **Mocke an Systemgrenzen** | HTTP-Calls, DB, Filesystem, externe APIs |
| **Mocke nicht die eigene Logik** | Interne Funktionen nicht mocken → sonst testet man nichts |
| **Bevorzuge Fakes über Mocks** | In-Memory-DB statt DB-Mock, MSW statt fetch-Mock |
| **Mock so wenig wie möglich** | Je mehr Mocks, desto weniger Aussagekraft |

**Tools für Mocking:**

| Sprache | HTTP Mocking | DB | Allgemein |
|---------|-------------|-----|-----------|
| TypeScript | **MSW** (Mock Service Worker) | In-Memory SQLite / Testcontainers | `vi.mock()` (Vitest) |
| Python | **respx** / httpx MockTransport | SQLite in-memory / Testcontainers | `unittest.mock` / `pytest-mock` |

### Test-Daten

| Ansatz | Wann |
|--------|------|
| **Fixtures im Test** | Einfache Daten, direkt im Test-File |
| **Factory Functions** | Wiederkehrende Objekte (`createUser({ name: "Test" })`) |
| **Builder Pattern** | Komplexe Objekte mit vielen Optionen |
| **Seeding Scripts** | E2E-Tests die echte DB brauchen |

### Coverage

| Metrik | Zielwert | Kommentar |
|--------|----------|-----------|
| **Line Coverage** | 70-80% | Mehr ist nice-to-have, nicht Pflicht |
| **Branch Coverage** | 60-70% | Wichtiger als Line Coverage |
| **Kritische Pfade** | ~100% | Auth, Payment, Datenverlust-Szenarien |

**100% Coverage ist kein Ziel.** Es führt zu Test-Bloat und falscher Sicherheit. Besser: kritische Pfade gut testen, Triviales weglassen.

### Wann Tests schreiben

| Ansatz | Wann sinnvoll |
|--------|--------------|
| **Test-First (TDD)** | Bug-Fixing (reproduziere Bug als Test, dann fixen), komplexe Logik |
| **Test-After** | UI-Code, Prototypen, explorative Phase |
| **Test-During** | Guter Kompromiss: Feature + Test in derselben PR |

**Pragmatischer Ansatz:** Test-During als Default. TDD für Bugs und komplexe Logik. Bei Prototypen: gar nicht, aber nachholen vor Production.

---

## 15. API-Dokumentation

### API-First vs. Code-First

| Ansatz | Workflow | Vorteil | Nachteil |
|--------|----------|---------|----------|
| **API-First** | Schema schreiben → Code generieren | Frontend/Backend parallel, klarer Contract | Mehr Upfront-Aufwand |
| **Code-First** | Code schreiben → Doku generieren | Schneller Start, immer aktuell | Doku ist Nebenprodukt, oft unvollständig |

**Empfehlung:** Code-First für Solo/Kleine Teams. API-First wenn Frontend/Backend getrennte Teams sind.

### OpenAPI / Swagger

Der de-facto Standard für REST-API-Dokumentation. Maschinenlesbares JSON/YAML-Schema das automatisch generiert werden kann.

**[TS/Node] Automatische Generierung:**

| Tool | Ansatz | Best für |
|------|--------|---------|
| **next-swagger-doc** | Decorators in API Routes | Next.js API Routes |
| **tsoa** | Controller mit Decorators → OpenAPI | Express / Koa |
| **Hono OpenAPI** | Schema-basiert (Zod) | Hono Framework |
| **tRPC Panel** | Auto-generierte UI aus tRPC Router | tRPC APIs (kein OpenAPI nötig) |
| **Scalar** | Modernes UI für OpenAPI Specs | Ersatz für Swagger UI |

**[Python] Automatische Generierung:**

| Tool | Ansatz | Best für |
|------|--------|---------|
| **FastAPI** | Automatisch aus Type Hints + Pydantic | FastAPI (built-in unter `/docs`) |
| **drf-spectacular** | Automatisch aus Serializers | Django REST Framework |
| **Connexion** | API-First: OpenAPI Spec → Code | Flask / ASGI |

**FastAPI ist hier der Gold-Standard** – Doku wird automatisch aus dem Code generiert und ist immer aktuell.

### Was dokumentieren

| Element | Pflicht | Beispiel |
|---------|---------|---------|
| **Endpoint URL + Methode** | Ja | `POST /api/v1/users` |
| **Request Body Schema** | Ja | JSON-Schema mit Typen und Validierung |
| **Response Schema** (pro Status Code) | Ja | 200, 400, 401, 404, 500 |
| **Auth-Anforderungen** | Ja | `Bearer Token`, `API Key`, `Cookie` |
| **Rate Limits** | Ja (wenn vorhanden) | `100 req/min` |
| **Beispiel Request/Response** | Empfohlen | Konkretes JSON-Beispiel |
| **Changelog / Breaking Changes** | Empfohlen | Versionshistorie |

### Versionierung

| Strategie | Wie | Pro | Contra |
|-----------|-----|-----|--------|
| **URL Path** | `/api/v1/users` | Einfach, explizit | URL-Änderung |
| **Header** | `Accept: application/vnd.api+json;version=2` | URL bleibt gleich | Weniger sichtbar |
| **Query Param** | `/api/users?version=2` | Einfach | Unüblich, Cache-Probleme |

**Empfehlung:** URL Path (`/api/v1/`) für öffentliche APIs. Interne APIs: oft keine Versionierung nötig.

### Tools für API-Testing und Doku

| Tool | Typ | Kosten |
|------|-----|--------|
| **Scalar** | Moderne API-Doku UI (OpenAPI) | Open Source |
| **Bruno** | API Client (Git-friendly, kein Account) | Open Source |
| **Hoppscotch** | API Client (Web-basiert) | Open Source |
| **Postman** | API Client + Doku | Free Tier |

---

## 16. Background Jobs & Task Queues

### Wann brauche ich Background Jobs?

| Szenario | Warum nicht im Request? |
|----------|----------------------|
| **E-Mail versenden** | Langsam, darf Request nicht blockieren |
| **PDF/Report generieren** | CPU-intensiv, dauert Sekunden bis Minuten |
| **Externe API aufrufen** | Retry bei Failure, Rate Limits |
| **Daten importieren/exportieren** | Große Datenmengen, lange Laufzeit |
| **Scheduled Tasks** (Cron) | Regelmäßige Cleanup-, Sync-, Report-Jobs |

### Architektur

```
User Request → API → Queue (Redis/DB) → Worker → Job erledigt
                 ↑                          │
                 └── Response: "Job queued"  └── Optional: Webhook/Notification
```

**Grundprinzip:** Request nimmt Job entgegen und antwortet sofort. Worker verarbeitet asynchron.

### Tools

| Sprache | Tool | Backend | Best für |
|---------|------|---------|---------|
| TypeScript | **BullMQ** | Redis | Standard-Wahl für Node.js |
| TypeScript | **Trigger.dev** | Cloud/Self-hosted | Serverless Background Jobs |
| Python | **Celery** | Redis / RabbitMQ | Standard-Wahl für Python |
| Python | **Dramatiq** | Redis / RabbitMQ | Einfachere Alternative zu Celery |
| Python | **ARQ** | Redis | Async-native, lightweight |
| Sprachunabhängig | **Temporal** | Self-hosted | Komplexe Workflows, Orchestration |

### Einfachste Lösung: Cron + Script

Nicht jeder Job braucht eine Queue. Für einfache Scheduled Tasks reicht oft:

```yaml
# docker-compose.yml
services:
  app:
    image: myapp

  # Einfacher Cron-Job als eigener Container
  cron:
    image: myapp
    command: >
      sh -c "while true; do
        sleep 3600;
        node scripts/cleanup.js;
      done"
```

Oder systemd Timer, GitHub Actions Scheduled Workflows, oder ein einfacher `setInterval()` im Prozess.

### Retry & Error Handling

| Pattern | Beschreibung |
|---------|-------------|
| **Exponential Backoff** | 1s → 2s → 4s → 8s → ... (verhindert Thundering Herd) |
| **Max Retries** | Nach N Fehlversuchen aufgeben (z.B. 3-5) |
| **Dead Letter Queue** | Fehlgeschlagene Jobs separat speichern zur Analyse |
| **Idempotenz** | Job muss mehrfach ausführbar sein ohne Seiteneffekte |

---

## Checkliste: Architektur-Entscheidungen

### Vor dem Start

- [ ] Monolith oder Microservices? → **Starte mit Monolith**
- [ ] Monorepo oder Polyrepo? → **Monorepo für Full-Stack**
- [ ] Rendering: SSR / SSG / CSR? → **SSR Default, CSR für Dashboards**
- [ ] API: REST / tRPC / GraphQL? → **tRPC intern, REST extern**
- [ ] DB: SQL / NoSQL / File-based? → **PostgreSQL als sichere Wahl**
- [ ] State Management? → **Server State (TanStack Query) + lokaler State (useState)**

### Strukturierung

- [ ] Feature-basierte Ordnerstruktur (nicht technisch)
- [ ] Klare Schichtung: Routes → Services → Data Access
- [ ] Domain-Logik frei von Framework-Abhängigkeiten
- [ ] Shared Code in eigene Packages/Module
- [ ] Barrel Exports für saubere Import-Pfade

### Docker / Deployment

- [ ] Multi-Stage Dockerfile (Builder + Runner)
- [ ] docker-compose für lokale Entwicklung
- [ ] Named Volumes für persistente Daten
- [ ] Health Checks für alle Services
- [ ] Resource Limits (Memory, CPU)
- [ ] Log-Rotation konfiguriert
- [ ] Reverse Proxy vor der App (Caddy / Nginx / Cloudflare)
- [ ] SSL/TLS konfiguriert

### Skalierbarkeit (wenn nötig)

- [ ] Stateless Design (kein In-Memory State)
- [ ] Sessions in Redis/DB (nicht im Prozess)
- [ ] Connection Pooling für DB
- [ ] Cache-Layer (Redis) für häufige Queries
- [ ] Background Jobs in eigene Worker extrahieren

---

## Referenzen

- [12-Factor App](https://12factor.net/) – Die Grundprinzipien
- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Patterns of Enterprise Application Architecture (Fowler)](https://martinfowler.com/eaaCatalog/)
- [Turborepo Docs](https://turbo.build/repo/docs)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Caddy Server Docs](https://caddyserver.com/docs/)
- [Nginx Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [Next.js App Router Architecture](https://nextjs.org/docs/app)
- [FastAPI Project Structure](https://fastapi.tiangolo.com/tutorial/)
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html) – Der API-Doku Standard
- [Scalar API Reference](https://github.com/scalar/scalar) – Modernes OpenAPI UI
- [BullMQ Docs](https://docs.bullmq.io/) – Node.js Task Queue
- [Celery Docs](https://docs.celeryq.dev/) – Python Task Queue
- [Temporal Docs](https://docs.temporal.io/) – Workflow Orchestration
