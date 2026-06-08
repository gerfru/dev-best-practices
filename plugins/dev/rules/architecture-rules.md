# Architecture Rules

Binding architecture decisions. No theory -- rules only.
Detailed explanations: `../reference/architecture-best-practices.md`

---

## Project Structure

- **Feature-based** (not technical). Everything belonging to a feature goes in one folder
- Tests next to the code (`user.test.ts` next to `user.service.ts`)
- `shared/` for utilities, middleware, types needed everywhere
- Barrel exports (`index.ts`) for `lib/`, `components/`, `shared/` -- not for feature folders

### Next.js App Router

```text
src/
  app/            # Routing (App Router)
  components/     # ui/ (generic) + features/ (specific)
  lib/            # Services, storage, schemas, types
  hooks/          # Custom React hooks
```

### Python (FastAPI)

```text
src/
  app/            # main.py, config.py, dependencies.py
  features/       # Per feature: router.py, service.py, models.py, schemas.py
  shared/         # Middleware, database.py, exceptions.py
tests/
  features/       # Mirrors src/features/
```

---

## Layering

- **Small projects / prototypes:** 2 layers (routes → service/logic)
- **Medium projects:** 3 layers (routes → service → data access)
- **Large projects / teams:** Full layered/clean architecture

**Dependency rule:** Dependencies point inward only. Domain layer has NO dependency on frameworks, DB, or APIs.

**Clean architecture:** Only for team projects > 10K LOC or long-lived products. For prototypes/solo: over-engineering.

---

## Monolith vs. Microservices

- **ALWAYS start with a monolith.** Extract services only for a concrete reason
- **Modular monolith** as the best compromise: clear module boundaries, own domain logic and data models per module, communication only through defined interfaces
- Microservices only when: team grows, parts need different scaling/technology, modules need to be deployed independently

---

## Monorepo vs. Polyrepo

- **Full-stack app (frontend + backend + shared):** Monorepo
- **Solo project:** Monorepo (Turborepo / pnpm Workspaces)
- **Independent services, different teams:** Polyrepo
- **Monorepo tools:** TS → Turborepo. Python → uv Workspaces / Pants

---

## Backend Patterns

- **Standard:** Service layer pattern (controller → service → repository)
- Controller: HTTP handling. Service: business logic. Repository: data access
- **CQRS:** Only when reads >> writes and different optimizations are needed. For CRUD: overkill
- **Event-driven:** For loose coupling and asynchronous processing. Tools: RabbitMQ, Redis Streams, AWS SQS

---

## Frontend Patterns

- **Component hierarchy:** Pages → feature components (have state) → UI components (props in, UI out) → hooks → utils
- **Server components** (React/Next.js) as default. `"use client"` only for interactivity
- **State management:**
  - Local: `useState` / `useReducer`
  - 2-3 components: props / composition
  - Many components: React Context
  - Complex: Zustand (lightweight)
  - **Server state (data from backend):** TanStack Query / SWR -- never mix with client state

---

## Data Fetching

- **SSR:** SEO important, fast initial load (Next.js server components)
- **SSG:** Content changes rarely (`generateStaticParams()`)
- **ISR:** Static + periodically updated (`revalidate`)
- **CSR:** Behind login, dashboard apps (TanStack Query)
- **Deduplication:** TanStack Query deduplicates automatically
- **Optimistic updates:** Update UI immediately, API in background, rollback on error

---

## Docker Architecture

- **Single container:** Reverse proxy → app container (with volume for data)
- **Multi-container:** docker-compose with app + DB + cache, named volumes, health checks
- Containers communicate via **service names** (not IPs): `postgres://db:5432/myapp`
- Bind ports only to `127.0.0.1` (not to the internet): `"127.0.0.1:3000:3000"`
- Named volumes for production, bind mounts for development
- Set **resource limits** (memory, CPU)
- Configure **log rotation** (`max-size: "10m"`, `max-file: "3"`)

---

## Reverse Proxy & SSL

- **Always a reverse proxy** in front of the app (SSL, rate limiting, static files, compression, security headers)
- **Caddy:** Simplest setup, automatic HTTPS (Let's Encrypt)
- **Nginx:** Performant, industry standard
- **Cloudflare Tunnel:** No open port needed, DDoS protection

---

## Environments

- **Solo / small teams:** 2-tier is enough (dev + production)
  - Protection without staging: CI with tests, test Docker image locally, feature flags, health checks + rollback
- **Staging** only when: multiple developers, complex DB migrations, UAT, compliance
- Docker Compose overrides: `docker-compose.yml` (base/prod) + `docker-compose.override.yml` (dev, auto-loaded)

---

## 12-Factor App (Short form)

1. One repo, many deploys
2. Dependencies explicitly declared (lockfile)
3. Config in environment (not in code)
4. Backing services as env vars (DB URL, Redis URL)
5. Build, release, run strictly separated
6. Stateless processes (sessions in Redis, not in memory)
7. Port binding (`PORT` as env var)
8. Scale via processes (multiple containers)
9. Disposability (fast start, graceful stop, SIGTERM handling)
10. Dev/prod parity (Docker makes dev ≈ prod)
11. Logs as stdout/stderr (not in files)
12. Admin processes as separate containers/commands

---

## Testing Strategy

- **Test pyramid as a guide, not a law:** Library → many unit. API/backend → many integration. UI → more E2E
- **Tests test behavior, not implementation** (refactoring must not break tests)
- **Arrange → Act → Assert**, one concept per test, no test interdependence
- **Mock at system boundaries** (HTTP, DB, filesystem). Never mock own logic. Fakes > mocks
- **Coverage:** 70-80% lines, 60-70% branches. Critical paths (auth, payment) ~100%. 100% overall is NOT the goal
- **Pragmatic:** Test-during as default. TDD for bugs and complex logic. Prototypes: catch up before production

---

## API Documentation

- **Code-first** for solo/small teams (docs generated from code)
- **API-first** when frontend/backend are separate teams
- **FastAPI:** Gold standard (automatic from type hints + Pydantic)
- **TS/Node:** Scalar as modern OpenAPI UI
- Versioning: URL path (`/api/v1/`) for public APIs

---

## Background Jobs

- Not every job needs a queue. Simple scheduled tasks: cron + script
- **When queue is needed:** TS → BullMQ (Redis). Python → Celery / ARQ (Redis)
- **Retry:** Exponential backoff, max retries (3-5), dead letter queue
- **Idempotency:** Jobs must be executable multiple times without side effects

---

## Architecture Checklist: New Project

### Before Starting
- [ ] Monolith (not microservices)
- [ ] Monorepo for full-stack
- [ ] SSR default, CSR for dashboards
- [ ] tRPC internal, REST external
- [ ] PostgreSQL as default DB
- [ ] Server state (TanStack Query) + local state (useState)

### Structuring
- [ ] Feature-based folder structure
- [ ] Clear layering: routes → services → data access
- [ ] Shared code in separate packages/modules

### Docker / Deployment
- [ ] Multi-stage Dockerfile
- [ ] docker-compose for local development
- [ ] Named volumes, health checks, resource limits, log rotation
- [ ] Reverse proxy (Caddy / Nginx) with SSL
