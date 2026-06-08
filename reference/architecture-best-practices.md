# Full-Stack Architecture Best Practices

Reference for project architecture, layering models, and infrastructure patterns (as of March 2026).
Language-agnostic where possible, with concrete examples for TypeScript/Node.js and Python.

---

## 1. Project Structure

### Core Principle: Feature-Based Instead of Technical

**Bad (technically grouped):**

```text
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

Problem: To understand a feature, you have to jump between 5+ folders.

**Better (feature-based / colocation):**

```text
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
    lib/         # Utilities needed everywhere
    middleware/   # Auth, logging, error handling
    types/       # Common types/interfaces
```

Advantage: Everything belonging to a feature is together. Easier to understand, easier to delete.

### Next.js App Router Structure

```text
src/
  app/                    # Routing (App Router)
    (auth)/               # Route groups (no URL segment)
      login/page.tsx
      register/page.tsx
    api/                  # API routes
      monitor/route.ts
      health/route.ts
    layout.tsx
    page.tsx
  components/             # UI components
    ui/                   # Generic (Button, Card, Modal)
    features/             # Feature-specific components
  lib/                    # Business logic, utilities
    services/             # External API calls, LLM integration
    storage.ts            # Data access layer
    schemas.ts            # Zod schemas
    types.ts              # TypeScript types
  hooks/                  # Custom React hooks
```

### Python (FastAPI) Structure

```text
src/
  app/
    main.py               # App entry, ASGI config
    config.py              # Settings (Pydantic BaseSettings)
    dependencies.py        # Dependency injection
  features/
    user/
      router.py            # API endpoints
      service.py           # Business logic
      models.py            # SQLAlchemy/Pydantic models
      schemas.py           # Request/response schemas
    order/
      ...
  shared/
    middleware/            # Auth, CORS, error handling
    database.py            # DB connection, session
    exceptions.py          # Custom exceptions
tests/
  features/
    user/
      test_router.py
      test_service.py
```

### Barrel Exports (`index.ts`)

Barrel exports simplify imports:

```typescript
// src/lib/index.ts
export { sanitizeUrl, stripCiteTags } from "./types";
export { monitorResponseSchema } from "./schemas";
export { saveData, loadData } from "./storage";

// Usage:
import { sanitizeUrl, monitorResponseSchema, saveData } from "@/lib";
```

**When to use barrel exports:** For `lib/`, `components/`, `shared/` – folders imported from outside.
**When not:** For feature folders used only internally (avoids circular dependencies).

---

## 2. Layering Model (Layered Architecture)

### The 4 Layers

```text
┌─────────────────────────────────────┐
│  Presentation Layer                 │  UI, API routes, controllers
│  (what the user sees)              │
├─────────────────────────────────────┤
│  Application Layer                  │  Use cases, orchestration
│  (what the app does)               │
├─────────────────────────────────────┤
│  Domain Layer                       │  Business logic, rules
│  (what the business logic says)    │  No external dependencies!
├─────────────────────────────────────┤
│  Infrastructure Layer               │  DB, APIs, file system, email
│  (how it happens technically)      │
└─────────────────────────────────────┘
```

### Dependency Rule

**Dependencies point inward/downward only:**

```text
Presentation → Application → Domain ← Infrastructure
                                ↑
                        Domain knows NO
                        concrete DB/API
```

The domain layer defines interfaces, the infrastructure layer implements them (dependency inversion).

### Practical Example

```typescript
// Domain layer – knows no DB, no API
interface NewsRepository {
  save(news: NewsItem[]): Promise<void>;
  findRecent(limit: number): Promise<NewsItem[]>;
}

// Application layer – orchestrates
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

// Infrastructure layer – concrete implementation
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

### When Which Level of Layering?

| Project size | Recommendation |
|-------------|-----------|
| **Small project / prototype** | 2 layers are enough: Routes → Service/Logic |
| **Medium project** | 3 layers: Routes → Service → Data Access |
| **Large project / team** | Full layered/clean architecture |

**Important:** Avoid over-engineering. A solo project doesn't need 4 abstraction layers. Start simple, refactor as it grows.

---

## 3. Clean Architecture / Hexagonal Architecture

### Core Idea

The business logic (domain) is the core and has **no dependency** on frameworks, databases, or external services. Everything external is replaceable.

```text
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

- **Port** = Interface defined by the domain (e.g. `NewsRepository`)
- **Adapter** = Concrete implementation (e.g. `PostgresNewsRepository`, `FileNewsRepository`)

Advantage: You can change the DB without touching business logic. You can write tests without a real DB.

### When Clean Architecture?

| Situation | Recommendation |
|-----------|-----------|
| Prototype / MVP | No – too much overhead |
| Solo project < 10K LOC | No – simple layering is enough |
| Team project > 10K LOC | Yes – structure pays off |
| Long-lived product | Yes – replaceability important |
| Microservice | Yes – clear boundaries needed |

---

## 4. Monolith vs. Microservices

### Comparison

| Aspect | Monolith | Microservices |
|--------|----------|--------------|
| **Complexity** | Low (one deployment) | High (network, service discovery, etc.) |
| **Deployment** | Simple (one artifact) | Complex (many independent deployments) |
| **Scaling** | Vertical (larger machine) | Horizontal (more instances per service) |
| **Data consistency** | Simple (one DB) | Complex (distributed transactions) |
| **Team autonomy** | Harder with large teams | Services = team boundaries |
| **Debugging** | Stack trace in one process | Distributed tracing needed |
| **Latency** | Function calls (nanoseconds) | Network calls (milliseconds) |

### The Right Choice

```text
                    Start here
                        │
                        ▼
              ┌─────────────────────┐
              │     MONOLITH        │
              │  (well structured)  │
              └──────────┬──────────┘
                         │
              Is the team growing?
              Do parts need different
              scaling/technology?
                         │
                    Yes  │   No
                    ▼    │    ▼
           ┌─────────┐  │  Stay with
           │ Modular  │  │  monolith
           │Monolith  │  │
           └────┬─────┘  │
                │        │
           Individual modules
           need to be deployed
           independently?
                │
           Yes  │
           ▼    │
     ┌──────────┐
     │ Extract   │
     │ individual│
     │ services  │
     └──────────┘
```

**Rule of thumb:** ALWAYS start with a monolith. Extract services only when you have a concrete reason (not preventively).

### The Modular Monolith (Best Compromise)

Monolith with clear module boundaries. Each module has:
- Own domain logic
- Own data model
- Clear API (exports) outward
- Communication through defined interfaces (not direct DB access)

Can later be split into microservices because boundaries are already drawn.

```text
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
│     Communication only through defined APIs  │
└─────────────────────────────────────────────┘
```

---

## 5. Monorepo vs. Polyrepo

### Comparison

| Aspect | Monorepo | Polyrepo |
|--------|----------|----------|
| **Code sharing** | Easy (local imports) | Need to publish packages |
| **Atomic changes** | One commit changes frontend + backend + shared | Multiple PRs across repos |
| **CI/CD** | More complex (what changed?) | Simple (each repo = one build) |
| **Tooling** | Needs special tools (Turborepo, Nx, Pants) | Standard git is enough |
| **Onboarding** | Clone one repo, everything there | Which repos do I need? |
| **Git performance** | Can be slow with millions of files | No problem |

### Monorepo Tools

| Tool | Language | Strength |
|------|---------|--------|
| **Turborepo** | TypeScript/Node | Simple, fast, Vercel-backed |
| **Nx** | TypeScript/Node (+ polyglot) | Feature-rich, dependency graph, plugins |
| **pnpm Workspaces** | Node | Built-in, no extra tool |
| **Pants** | Python (+ polyglot) | Incremental builds, caching |
| **uv Workspaces** | Python | New (2025+), native monorepo support |

### Recommendation

| Situation | Recommendation |
|-----------|-----------|
| Solo project | Monorepo (Turborepo/pnpm Workspaces) |
| Full-stack app (frontend + backend + shared) | Monorepo |
| Independent services, different teams | Polyrepo |
| Mixed languages (TS + Python + Go) | Polyrepo (or Nx/Pants) |

### Monorepo Structure (Turborepo)

```text
my-project/
  apps/
    web/              # Next.js frontend
      package.json
    api/              # Express/Fastify backend
      package.json
  packages/
    shared/           # Shared types, utils
      package.json
    ui/               # Design system / components
      package.json
    config/           # Shared ESLint, TS, Tailwind config
      package.json
  turbo.json          # Build pipeline
  package.json        # Root
  pnpm-workspace.yaml # Workspace definition
```

---

## 6. Backend Architecture Patterns

### MVC (Model-View-Controller)

```text
Request → Controller → Model → Database
              ↓
            View → Response
```

Classic, simple, good for CRUD apps. Gets messy quickly with complex business logic.

### Service Layer Pattern

```text
Request → Controller → Service → Repository → Database
                          ↓
                    Business logic
```

Controller: HTTP handling (request parsing, response formatting).
Service: Business logic (validation, orchestration, rules).
Repository: Data access (queries, CRUD).

**The most important step from MVC:** Extract business logic from controllers into services.

### CQRS (Command Query Responsibility Segregation)

Separate read and write operations:

```text
┌──────────┐     ┌─────────────┐     ┌──────────┐
│  Command  │────▶│ Write Model │────▶│ Write DB │
│  (Write)  │     │ (normalized)│     │          │
└──────────┘     └─────────────┘     └──────────┘

┌──────────┐     ┌─────────────┐     ┌──────────┐
│  Query    │────▶│ Read Model  │────▶│ Read DB  │
│  (Read)   │     │(denormalized│     │(optimized│
└──────────┘     │  for reads) │     │for query)│
                  └─────────────┘     └──────────┘
```

**When CQRS:** Read access >> write access, different optimizations needed.
**When not:** Simple CRUD apps (overkill).

### Event-Driven Architecture

```text
Service A ──publishes──▶ Event Bus ──subscribes──▶ Service B
                              │
                              └──subscribes──▶ Service C
```

**When:** Loose coupling between services, asynchronous processing, audit trails.
**Tools:** RabbitMQ, Apache Kafka, Redis Streams, AWS SQS/SNS.

---

## 7. Frontend Architecture Patterns

### Component Architecture

```text
┌─────────────────────────────────┐
│  Pages / Routes                 │  URL → which page?
├─────────────────────────────────┤
│  Feature Components             │  Business logic components
│  (Dashboard, UserProfile)       │  (fetch data, have state)
├─────────────────────────────────┤
│  UI Components                  │  Pure presentation
│  (Button, Card, Modal)          │  (props in, UI out)
├─────────────────────────────────┤
│  Hooks / State Management       │  Shared logic
│  (useAuth, useMonitorData)      │  (data fetching, state)
├─────────────────────────────────┤
│  Utils / Lib                    │  Pure functions
│  (formatDate, sanitizeUrl)      │  (no state, no UI)
└─────────────────────────────────┘
```

### Server Components vs. Client Components (React/Next.js)

| Type | Renders | Can | Cannot |
|-----|---------|------|-----------|
| **Server component** | On the server | DB access, async/await, read secrets | useState, useEffect, event handlers |
| **Client component** | In browser | Interactivity, browser APIs | Directly access DB/secrets |

**Rule of thumb:** Default is server component. Only add `"use client"` when interactivity is needed.

```text
// Good: Server component fetches data, client component shows interactive part
// page.tsx (Server)
async function DashboardPage() {
  const data = await loadMonitorData();  // Server-only, direct DB access
  return <Dashboard initialData={data} />;
}

// Dashboard.tsx (Client – "use client")
function Dashboard({ initialData }) {
  const [data, setData] = useState(initialData);
  // ... interactivity
}
```

### State Management – Decision Tree

```text
Do you need shared state?
    │
    ├── No → useState / useReducer (local)
    │
    └── Yes → How many consumers?
              │
              ├── 2-3 close components → Props drilling / composition
              │
              ├── Many components → React Context
              │
              └── Complex state with many updates?
                    │
                    ├── Yes → Zustand (lightweight) or Redux Toolkit
                    │
                    └── Server state? → TanStack Query / SWR
```

**Server state** (data from backend) ≠ **client state** (UI state). Don't mix them:
- **Server state:** TanStack Query, SWR, or Next.js server components
- **Client state:** useState, Zustand, Redux Toolkit

---

## 8. Data Fetching Patterns

### Server-Side vs. Client-Side

| Pattern | When | Tool |
|---------|------|------|
| **SSR (Server-Side Rendering)** | SEO important, fast initial load | Next.js server components |
| **SSG (Static Site Generation)** | Content changes rarely | Next.js `generateStaticParams()` |
| **ISR (Incremental Static Regen.)** | Static + periodically updated | Next.js `revalidate` |
| **CSR (Client-Side Rendering)** | Behind login, dashboard apps | TanStack Query, SWR |
| **Streaming** | Long queries, progressive loading | React Suspense + streaming SSR |

### API Call Patterns

**Deduplication:** Multiple components fetching the same data → only one request.

```typescript
// TanStack Query deduplicates automatically:
// Both hooks make only ONE API call
function ComponentA() {
  const { data } = useQuery({ queryKey: ["monitor"], queryFn: fetchMonitor });
}
function ComponentB() {
  const { data } = useQuery({ queryKey: ["monitor"], queryFn: fetchMonitor });
}
```

**Optimistic updates:** Update UI immediately, API call in background.

```typescript
// User clicks "Delete" → item disappears immediately
// API call runs in parallel
// On error: rollback to previous state
```

**Stale-While-Revalidate:** Show cached data immediately, fetch fresh in background.

---

## 9. Docker Architecture

### Single-Container App

For simple apps (like the news monitor):

```text
┌─────────────────────┐
│    Cloudflare        │
│    Tunnel / Nginx    │
│    (Reverse proxy)   │
└──────────┬──────────┘
           │ :3000
┌──────────▼──────────┐
│    App container     │
│    (Next.js /        │
│     FastAPI)         │
│    ┌───────────────┐ │
│    │ /app/data     │ │ ← Docker volume
│    └───────────────┘ │
└─────────────────────┘
```

### Multi-Container App (docker-compose)

For apps with DB, cache, background workers:

```text
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

**`docker-compose.yml` (reference):**

```yaml
services:
  app:
    build: .
    ports:
      - "127.0.0.1:3000:3000"  # Localhost only!
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

```text
┌─────────────────────────────────────────────┐
│          Docker network (bridge)            │
│                                             │
│  app ──────── db        Internal: hostname  │
│    │          │         (app can reach      │
│    └──────── redis       "db:5432")         │
│                                             │
│  External: Only app:3000 via port mapping   │
└─────────────────────────────────────────────┘
```

- Containers communicate via **service names** (not IPs): `postgres://db:5432/myapp`
- Only explicitly mapped ports are reachable from outside
- `127.0.0.1:3000:3000` binds only to localhost (not to the internet)
- Default: All services in the same `docker-compose.yml` share a network

### Docker Volumes: Bind Mount vs. Named Volume

| Type | Syntax | When |
|-----|--------|------|
| **Named volume** | `volumes: [pg-data:/var/lib/...]` | Production (Docker manages) |
| **Bind mount** | `volumes: [./data:/app/data]` | Development (live reload, easy access) |
| **tmpfs** | `tmpfs: /tmp` | Temporary data (disappears on restart) |

**Important:** Named volumes survive `docker compose down`. Only `docker compose down -v` deletes them.

---

## 10. Reverse Proxy & SSL

### Why a Reverse Proxy?

```text
Internet                   Server
   │
   │    ┌──────────────┐
   ├───▶│ Reverse proxy│    - SSL termination
   │    │ (Nginx /     │    - Rate limiting
   │    │  Caddy /     │    - Static file serving
   │    │  Cloudflare) │    - Compression
   │    └──────┬───────┘    - Caching
   │           │             - Security headers
   │    ┌──────▼───────┐
   │    │  App (:3000) │    - Business logic only
   │    └──────────────┘
```

### Options

| Tool | Strength | Best for |
|------|--------|---------|
| **Caddy** | Automatic HTTPS (Let's Encrypt), simplest config | Small/medium apps |
| **Nginx** | Performant, flexible, industry standard | Everything |
| **Traefik** | Docker-native, automatic service discovery | Docker/K8s environments |
| **Cloudflare Tunnel** | No open port needed, DDoS protection | When no public IP desired |

### Caddy (Simplest Setup)

```text
# Caddyfile – this is ALL you need
myapp.example.com {
    reverse_proxy app:3000
}
# HTTPS is automatically configured (Let's Encrypt)
```

### Nginx (Reference Config)

```nginx
server {
    listen 443 ssl http2;
    server_name myapp.example.com;

    ssl_certificate /etc/letsencrypt/live/myapp/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/myapp/privkey.pem;

    # Security headers
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

    # Static files (optional, if app has own static files)
    location /_next/static/ {
        proxy_pass http://app:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# HTTP → HTTPS redirect
server {
    listen 80;
    server_name myapp.example.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 11. Environment Strategies

### Minimum: Dev + Production (2-Tier)

For solo projects and small teams, a 2-tier setup is often enough:

| Aspect | Development | Production |
|--------|------------|------------|
| **Database** | Local (Docker) or SQLite | Real data |
| **External APIs** | Mocks / sandbox | Live |
| **Debug mode** | On | **Off** |
| **Logging level** | debug | info/warn |
| **SSL** | Optional (localhost) | Yes |
| **Secrets** | `.env` local | CI/CD secrets / Vault |
| **Error detail** | Stack traces | Generic message |

**This is enough when:**
- Solo developer or small team (1-3 people)
- No customer-facing SLA (internal tools, side projects)
- Deployments are quickly revertable (Docker, Vercel, etc.)
- Good test coverage as safety net

**Recommended protection without staging:**
- CI pipeline with tests + linting (replaces manual staging testing)
- Test Docker image locally before deploying (`docker compose up` with prod config)
- Feature flags for risky changes (gradual activation)
- Health checks + rollback strategy in deployment

### Level Up: Dev + Staging + Production (3-Tier)

Staging becomes useful when:
- **Multiple developers** deploy simultaneously
- **External dependencies** (payment APIs, third-party webhooks) need to be tested
- **Database migrations** are complex and should be validated before prod
- **Customers/stakeholders** want to test before release (UAT)
- **Compliance requirements** demand pre-production validation

| Aspect | Development | Staging | Production |
|--------|------------|---------|------------|
| **Database** | Local (Docker) or SQLite | Copy of prod (anonymized!) | Real data |
| **External APIs** | Mocks / sandbox | Sandbox / restricted | Live |
| **Debug mode** | On | On | **Off** |
| **Logging level** | debug | info | info/warn |
| **SSL** | Optional (localhost) | Yes | Yes |
| **Secrets** | `.env` local | CI/CD secrets | Vault / Secret Manager |
| **Error detail** | Stack traces | Stack traces | Generic message |

### Docker Compose Overrides

```text
docker-compose.yml           # Base config (production-ready)
docker-compose.override.yml  # Dev overrides (auto-loaded)
docker-compose.prod.yml      # Production overrides
```

```yaml
# docker-compose.override.yml (development)
services:
  app:
    build:
      target: builder    # Dev stage instead of production stage
    volumes:
      - .:/app           # Live reload via bind mount
      - /app/node_modules # Don't override node modules
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"      # Directly reachable (no localhost-only)
```

```bash
# Development (automatically loads docker-compose.override.yml)
docker compose up

# Production (ignores override, loads prod)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## 12. API Gateway Pattern

### When Do I Need an API Gateway?

```text
Without gateway:                 With gateway:
Client → Service A               Client → Gateway → Service A
Client → Service B                                → Service B
Client → Service C                                → Service C
(Client knows all services)     (Client knows only gateway)
```

### What a Gateway Does

| Feature | Description |
|---------|-------------|
| **Routing** | `/api/users` → User Service, `/api/orders` → Order Service |
| **Auth** | Token validation centrally once |
| **Rate limiting** | Per client/API key |
| **Request transform** | Add headers, transform bodies |
| **Response aggregation** | Combine multiple service calls into one response |
| **Circuit breaking** | Temporarily disable failing service |

### Tools

| Tool | Type | Best for |
|------|-----|---------|
| **Nginx / Caddy** | Reverse proxy with routing | Simple cases |
| **Kong** | Full API gateway | Enterprise |
| **Traefik** | Docker-native gateway | Container environments |
| **Next.js API Routes** | Built-in | Full-stack Next.js apps |
| **tRPC** | Type-safe gateway | TypeScript monorepos |

---

## 13. Twelve-Factor App

The [12 factors](https://12factor.net/) – core principles for modern apps:

| # | Factor | Rule | Practice |
|---|--------|-------|--------|
| 1 | **Codebase** | One repo, many deploys | Git + branch per env |
| 2 | **Dependencies** | Explicitly declared | `package.json` / `pyproject.toml` + lockfile |
| 3 | **Config** | In environment, not in code | `.env` + env vars |
| 4 | **Backing services** | As attached resources | DB URL as env var, not hardcoded |
| 5 | **Build, release, run** | Strictly separated | CI builds → image released → container runs |
| 6 | **Processes** | Stateless, share-nothing | No local state (sessions in Redis, not in memory) |
| 7 | **Port binding** | App binds own port | `PORT=3000` as env var |
| 8 | **Concurrency** | Scale via processes | Multiple containers, not threads |
| 9 | **Disposability** | Fast start, graceful stop | SIGTERM handling, health checks |
| 10 | **Dev/prod parity** | Align environments | Docker makes dev ≈ prod |
| 11 | **Logs** | As event streams | Stdout/stderr, not in files |
| 12 | **Admin processes** | One-time tasks as separate processes | Migrations as separate container/command |

---

## 14. Testing Strategy

### The Test Pyramid

```text
         ╱  E2E  ╲          Few, slow, expensive
        ╱─────────╲         Test: entire user flows
       ╱Integration╲        Medium, medium speed
      ╱─────────────╲       Test: interaction of multiple modules
     ╱     Unit      ╲      Many, fast, cheap
    ╱─────────────────╲     Test: individual functions/classes
```

**The pyramid is a guide, not a law.** The ratio depends on project type:

| Project type | Focus | Why |
|------------|------------|-------|
| **Library / utility** | Many unit tests | Clearly defined inputs/outputs |
| **API / backend** | Many integration tests | Interplay of routes, DB, auth |
| **UI-heavy app** | More E2E, fewer unit | User interaction is what matters |
| **CRUD app** | Few unit, lots of integration/E2E | Little logic, lots of interplay |

### What to Test at Each Level

| Level | What to test | What NOT to test |
|-------|-----------|-----------------|
| **Unit** | Pure functions, calculations, validation, transformers, utilities | Framework code, DB queries, HTTP calls |
| **Integration** | API routes end-to-end, DB operations, service interplay, auth flows | UI rendering, browser behavior |
| **E2E** | Critical user journeys (signup, checkout, core feature), cross-browser | Everything unit/integration covers |

### Testing Rules

| Rule | Why |
|-------|-------|
| **Tests test behavior, not implementation** | Refactoring must not break tests |
| **Arrange → Act → Assert** (AAA) | Clear structure, readable test |
| **One concept per test** | Test name describes what is being tested |
| **No test interdependence** | Tests must run in any order |
| **Define test data in the test** | No hidden state from other files |
| **No logic in test** | No if/else, loops, or calculations in tests |

### Mocking Strategy

| Rule | Explanation |
|-------|-----------|
| **Mock at system boundaries** | HTTP calls, DB, filesystem, external APIs |
| **Don't mock your own logic** | Internal functions not mocked → otherwise you test nothing |
| **Prefer fakes over mocks** | In-memory DB instead of DB mock, MSW instead of fetch mock |
| **Mock as little as possible** | More mocks = less meaningful |

**Mocking tools:**

| Language | HTTP mocking | DB | General |
|---------|-------------|-----|-----------|
| TypeScript | **MSW** (Mock Service Worker) | In-memory SQLite / Testcontainers | `vi.mock()` (Vitest) |
| Python | **respx** / httpx MockTransport | SQLite in-memory / Testcontainers | `unittest.mock` / `pytest-mock` |

### Test Data

| Approach | When |
|--------|------|
| **Fixtures in test** | Simple data, directly in test file |
| **Factory functions** | Recurring objects (`createUser({ name: "Test" })`) |
| **Builder pattern** | Complex objects with many options |
| **Seeding scripts** | E2E tests that need a real DB |

### Coverage

| Metric | Target | Comment |
|--------|----------|-----------|
| **Line coverage** | 70-80% | More is nice-to-have, not required |
| **Branch coverage** | 60-70% | More important than line coverage |
| **Critical paths** | ~100% | Auth, payment, data loss scenarios |

**100% coverage is not the goal.** It leads to test bloat and false confidence. Better: test critical paths thoroughly, skip trivial code.

### When to Write Tests

| Approach | When useful |
|--------|--------------|
| **Test-First (TDD)** | Bug fixing (reproduce bug as test, then fix), complex logic |
| **Test-After** | UI code, prototypes, exploratory phase |
| **Test-During** | Good compromise: feature + test in the same PR |

**Pragmatic approach:** Test-during as default. TDD for bugs and complex logic. For prototypes: skip, but catch up before production.

---

## 15. API Documentation

### API-First vs. Code-First

| Approach | Workflow | Advantage | Disadvantage |
|--------|----------|---------|----------|
| **API-First** | Write schema → generate code | Frontend/backend in parallel, clear contract | More upfront effort |
| **Code-First** | Write code → generate docs | Faster start, always current | Docs are a byproduct, often incomplete |

**Recommendation:** Code-first for solo/small teams. API-first when frontend/backend are separate teams.

### OpenAPI / Swagger

The de-facto standard for REST API documentation. Machine-readable JSON/YAML schema that can be automatically generated.

**[TS/Node] Automatic generation:**

| Tool | Approach | Best for |
|------|--------|---------|
| **next-swagger-doc** | Decorators in API routes | Next.js API routes |
| **tsoa** | Controllers with decorators → OpenAPI | Express / Koa |
| **Hono OpenAPI** | Schema-based (Zod) | Hono framework |
| **tRPC Panel** | Auto-generated UI from tRPC router | tRPC APIs (no OpenAPI needed) |
| **Scalar** | Modern UI for OpenAPI specs | Replacement for Swagger UI |

**[Python] Automatic generation:**

| Tool | Approach | Best for |
|------|--------|---------|
| **FastAPI** | Automatic from type hints + Pydantic | FastAPI (built-in at `/docs`) |
| **drf-spectacular** | Automatic from serializers | Django REST Framework |
| **Connexion** | API-first: OpenAPI spec → code | Flask / ASGI |

**FastAPI is the gold standard here** – docs are automatically generated from code and always current.

### What to Document

| Element | Required | Example |
|---------|---------|---------|
| **Endpoint URL + method** | Yes | `POST /api/v1/users` |
| **Request body schema** | Yes | JSON schema with types and validation |
| **Response schema** (per status code) | Yes | 200, 400, 401, 404, 500 |
| **Auth requirements** | Yes | `Bearer Token`, `API Key`, `Cookie` |
| **Rate limits** | Yes (if present) | `100 req/min` |
| **Example request/response** | Recommended | Concrete JSON example |
| **Changelog / breaking changes** | Recommended | Version history |

### Versioning

| Strategy | How | Pro | Con |
|-----------|-----|-----|--------|
| **URL path** | `/api/v1/users` | Simple, explicit | URL change |
| **Header** | `Accept: application/vnd.api+json;version=2` | URL stays the same | Less visible |
| **Query param** | `/api/users?version=2` | Simple | Uncommon, cache issues |

**Recommendation:** URL path (`/api/v1/`) for public APIs. Internal APIs: often no versioning needed.

### Tools for API Testing and Docs

| Tool | Type | Cost |
|------|-----|--------|
| **Scalar** | Modern API docs UI (OpenAPI) | Open source |
| **Bruno** | API client (Git-friendly, no account) | Open source |
| **Hoppscotch** | API client (web-based) | Open source |
| **Postman** | API client + docs | Free tier |

---

## 16. Background Jobs & Task Queues

### When Do I Need Background Jobs?

| Scenario | Why not in request? |
|----------|----------------------|
| **Send email** | Slow, must not block request |
| **Generate PDF/report** | CPU-intensive, takes seconds to minutes |
| **Call external API** | Retry on failure, rate limits |
| **Import/export data** | Large data volumes, long runtime |
| **Scheduled tasks** (cron) | Regular cleanup, sync, report jobs |

### Architecture

```text
User request → API → Queue (Redis/DB) → Worker → Job done
                 ↑                          │
                 └── Response: "Job queued"  └── Optional: Webhook/notification
```

**Core principle:** Request accepts job and responds immediately. Worker processes asynchronously.

### Tools

| Language | Tool | Backend | Best for |
|---------|------|---------|---------|
| TypeScript | **BullMQ** | Redis | Standard choice for Node.js |
| TypeScript | **Trigger.dev** | Cloud/self-hosted | Serverless background jobs |
| Python | **Celery** | Redis / RabbitMQ | Standard choice for Python |
| Python | **Dramatiq** | Redis / RabbitMQ | Simpler alternative to Celery |
| Python | **ARQ** | Redis | Async-native, lightweight |
| Language-agnostic | **Temporal** | Self-hosted | Complex workflows, orchestration |

### Simplest Solution: Cron + Script

Not every job needs a queue. For simple scheduled tasks this is often enough:

```yaml
# docker-compose.yml
services:
  app:
    image: myapp

  # Simple cron job as separate container
  cron:
    image: myapp
    command: >
      sh -c "while true; do
        sleep 3600;
        node scripts/cleanup.js;
      done"
```

Or systemd timer, GitHub Actions scheduled workflows, or a simple `setInterval()` in the process.

### Retry & Error Handling

| Pattern | Description |
|---------|-------------|
| **Exponential backoff** | 1s → 2s → 4s → 8s → ... (prevents thundering herd) |
| **Max retries** | Give up after N failed attempts (e.g. 3-5) |
| **Dead letter queue** | Store failed jobs separately for analysis |
| **Idempotency** | Job must be executable multiple times without side effects |

---

## Checklist: Architecture Decisions

### Before Starting

- [ ] Monolith or microservices? → **Start with monolith**
- [ ] Monorepo or polyrepo? → **Monorepo for full-stack**
- [ ] Rendering: SSR / SSG / CSR? → **SSR default, CSR for dashboards**
- [ ] API: REST / tRPC / GraphQL? → **tRPC internal, REST external**
- [ ] DB: SQL / NoSQL / file-based? → **PostgreSQL as safe default**
- [ ] State management? → **Server state (TanStack Query) + local state (useState)**

### Structuring

- [ ] Feature-based folder structure (not technical)
- [ ] Clear layering: routes → services → data access
- [ ] Domain logic free of framework dependencies
- [ ] Shared code in separate packages/modules
- [ ] Barrel exports for clean import paths

### Docker / Deployment

- [ ] Multi-stage Dockerfile (builder + runner)
- [ ] docker-compose for local development
- [ ] Named volumes for persistent data
- [ ] Health checks for all services
- [ ] Resource limits (memory, CPU)
- [ ] Log rotation configured
- [ ] Reverse proxy in front of app (Caddy / Nginx / Cloudflare)
- [ ] SSL/TLS configured

### Scalability (when needed)

- [ ] Stateless design (no in-memory state)
- [ ] Sessions in Redis/DB (not in process)
- [ ] Connection pooling for DB
- [ ] Cache layer (Redis) for frequent queries
- [ ] Background jobs extracted to separate workers

---

## References

- [12-Factor App](https://12factor.net/) – The core principles
- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Patterns of Enterprise Application Architecture (Fowler)](https://martinfowler.com/eaaCatalog/)
- [Turborepo Docs](https://turbo.build/repo/docs)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Caddy Server Docs](https://caddyserver.com/docs/)
- [Nginx Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [Next.js App Router Architecture](https://nextjs.org/docs/app)
- [FastAPI Project Structure](https://fastapi.tiangolo.com/tutorial/)
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html) – The API docs standard
- [Scalar API Reference](https://github.com/scalar/scalar) – Modern OpenAPI UI
- [BullMQ Docs](https://docs.bullmq.io/) – Node.js task queue
- [Celery Docs](https://docs.celeryq.dev/) – Python task queue
- [Temporal Docs](https://docs.temporal.io/) – Workflow orchestration
