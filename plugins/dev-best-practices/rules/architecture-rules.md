# Architecture Rules

Verbindliche Architektur-Entscheidungen. Keine Theorie -- nur Regeln.
Detaillierte Erklaerungen: `../reference/architecture-best-practices.md`

---

## Projekt-Struktur

- **Feature-basiert** (nicht technisch). Alles was zu einem Feature gehoert in einen Ordner
- Tests neben dem Code (`user.test.ts` neben `user.service.ts`)
- `shared/` fuer Utilities, Middleware, Types die ueberall gebraucht werden
- Barrel Exports (`index.ts`) fuer `lib/`, `components/`, `shared/` -- nicht fuer Feature-Ordner

### Next.js App Router
```
src/
  app/            # Routing (App Router)
  components/     # ui/ (generisch) + features/ (spezifisch)
  lib/            # Services, Storage, Schemas, Types
  hooks/          # Custom React Hooks
```

### Python (FastAPI)
```
src/
  app/            # main.py, config.py, dependencies.py
  features/       # Pro Feature: router.py, service.py, models.py, schemas.py
  shared/         # Middleware, database.py, exceptions.py
tests/
  features/       # Spiegelt src/features/
```

---

## Schichtung

- **Kleine Projekte / Prototypen:** 2 Schichten (Routes → Service/Logic)
- **Mittlere Projekte:** 3 Schichten (Routes → Service → Data Access)
- **Grosse Projekte / Teams:** Vollstaendige Layered/Clean Architecture

**Dependency Rule:** Abhaengigkeiten zeigen nur nach innen. Domain-Schicht hat KEINE Abhaengigkeit zu Frameworks, DB, APIs.

**Clean Architecture:** Erst ab Team-Projekt > 10K LOC oder langlebigem Produkt. Fuer Prototypen/Solo: Over-Engineering.

---

## Monolith vs. Microservices

- **Starte IMMER mit Monolith.** Extrahiere Services nur bei konkretem Grund
- **Modularer Monolith** als bester Kompromiss: Klare Modul-Grenzen, eigene Domain-Logik und Data Models pro Modul, Kommunikation nur ueber definierte Interfaces
- Microservices erst wenn: Team waechst, Teile andere Skalierung/Technologie brauchen, Module unabhaengig deployt werden muessen

---

## Monorepo vs. Polyrepo

- **Full-Stack App (Frontend + Backend + Shared):** Monorepo
- **Solo-Projekt:** Monorepo (Turborepo / pnpm Workspaces)
- **Unabhaengige Services, verschiedene Teams:** Polyrepo
- **Monorepo-Tools:** TS → Turborepo. Python → uv Workspaces / Pants

---

## Backend Patterns

- **Standard:** Service Layer Pattern (Controller → Service → Repository)
- Controller: HTTP-Handling. Service: Business-Logik. Repository: Daten-Zugriff
- **CQRS:** Nur wenn Reads >> Writes und verschiedene Optimierungen noetig. Fuer CRUD: Overkill
- **Event-Driven:** Fuer lose Kopplung und asynchrone Verarbeitung. Tools: RabbitMQ, Redis Streams, AWS SQS

---

## Frontend Patterns

- **Component-Hierarchie:** Pages → Feature Components (haben State) → UI Components (Props rein, UI raus) → Hooks → Utils
- **Server Components** (React/Next.js) als Default. `"use client"` nur bei Interaktivitaet
- **State Management:**
  - Lokal: `useState` / `useReducer`
  - 2-3 Komponenten: Props / Composition
  - Viele Komponenten: React Context
  - Komplex: Zustand (leichtgewichtig)
  - **Server State (Daten vom Backend):** TanStack Query / SWR -- nie mit Client State mischen

---

## Data Fetching

- **SSR:** SEO wichtig, initialer Load schnell (Next.js Server Components)
- **SSG:** Inhalt aendert sich selten (`generateStaticParams()`)
- **ISR:** Statisch + periodisch aktualisiert (`revalidate`)
- **CSR:** Hinter Login, Dashboard-Apps (TanStack Query)
- **Deduplizierung:** TanStack Query dedupliziert automatisch
- **Optimistic Updates:** UI sofort updaten, API im Hintergrund, Rollback bei Fehler

---

## Docker Architektur

- **Single-Container:** Reverse Proxy → App Container (mit Volume fuer Daten)
- **Multi-Container:** docker-compose mit App + DB + Cache, Named Volumes, Health Checks
- Container kommunizieren ueber **Service-Namen** (nicht IPs): `postgres://db:5432/myapp`
- Ports nur auf `127.0.0.1` binden (nicht ans Internet): `"127.0.0.1:3000:3000"`
- Named Volumes fuer Produktion, Bind Mounts fuer Entwicklung
- **Resource Limits** setzen (Memory, CPU)
- **Log-Rotation** konfigurieren (`max-size: "10m"`, `max-file: "3"`)

---

## Reverse Proxy & SSL

- **Immer einen Reverse Proxy** vor der App (SSL, Rate Limiting, Static Files, Compression, Security Headers)
- **Caddy:** Einfachstes Setup, automatisches HTTPS (Let's Encrypt)
- **Nginx:** Performant, Industriestandard
- **Cloudflare Tunnel:** Kein offener Port noetig, DDoS-Schutz

---

## Environments

- **Solo / Kleine Teams:** 2-Tier reicht (Dev + Production)
  - Absicherung ohne Staging: CI mit Tests, Docker-Image lokal testen, Feature Flags, Health Checks + Rollback
- **Staging** erst bei: mehreren Entwicklern, komplexen DB-Migrationen, UAT, Compliance
- Docker Compose Overrides: `docker-compose.yml` (Base/Prod) + `docker-compose.override.yml` (Dev, auto-geladen)

---

## 12-Factor App (Kurzform)

1. Ein Repo, viele Deploys
2. Dependencies explizit deklariert (Lockfile)
3. Config in Environment (nicht im Code)
4. Backing Services als Env Vars (DB-URL, Redis-URL)
5. Build, Release, Run strikt getrennt
6. Stateless Processes (Sessions in Redis, nicht in Memory)
7. Port Binding (`PORT` als Env Var)
8. Skalierung ueber Prozesse (mehrere Container)
9. Disposability (schnell starten, graceful stoppen, SIGTERM Handling)
10. Dev/Prod Parity (Docker macht Dev ≈ Prod)
11. Logs als Stdout/Stderr (nicht in Dateien)
12. Admin Processes als eigene Container/Commands

---

## Testing-Strategie

- **Test-Pyramide als Leitfaden, nicht Gesetz:** Library → viele Unit. API/Backend → viele Integration. UI → mehr E2E
- **Tests testen Verhalten, nicht Implementierung** (Refactoring darf Tests nicht brechen)
- **Arrange → Act → Assert**, ein Konzept pro Test, keine Test-Interdependenz
- **Mocke an Systemgrenzen** (HTTP, DB, Filesystem). Nie eigene Logik mocken. Fakes > Mocks
- **Coverage:** 70-80% Lines, 60-70% Branches. Kritische Pfade (Auth, Payment) ~100%. 100% gesamt ist KEIN Ziel
- **Pragmatisch:** Test-During als Default. TDD fuer Bugs und komplexe Logik. Prototypen: nachholen vor Production

---

## API-Dokumentation

- **Code-First** fuer Solo/Kleine Teams (Doku aus Code generiert)
- **API-First** wenn Frontend/Backend getrennte Teams
- **FastAPI:** Gold-Standard (automatisch aus Type Hints + Pydantic)
- **TS/Node:** Scalar als modernes OpenAPI UI
- Versionierung: URL Path (`/api/v1/`) fuer oeffentliche APIs

---

## Background Jobs

- Nicht jeder Job braucht eine Queue. Einfache Scheduled Tasks: Cron + Script
- **Wenn Queue noetig:** TS → BullMQ (Redis). Python → Celery / ARQ (Redis)
- **Retry:** Exponential Backoff, Max Retries (3-5), Dead Letter Queue
- **Idempotenz:** Jobs muessen mehrfach ausfuehrbar sein ohne Seiteneffekte

---

## Architektur-Checkliste: Neues Projekt

### Vor dem Start
- [ ] Monolith (nicht Microservices)
- [ ] Monorepo fuer Full-Stack
- [ ] SSR Default, CSR fuer Dashboards
- [ ] tRPC intern, REST extern
- [ ] PostgreSQL als Default-DB
- [ ] Server State (TanStack Query) + lokaler State (useState)

### Strukturierung
- [ ] Feature-basierte Ordnerstruktur
- [ ] Klare Schichtung: Routes → Services → Data Access
- [ ] Shared Code in eigene Packages/Module

### Docker / Deployment
- [ ] Multi-Stage Dockerfile
- [ ] docker-compose fuer lokale Entwicklung
- [ ] Named Volumes, Health Checks, Resource Limits, Log-Rotation
- [ ] Reverse Proxy (Caddy / Nginx) mit SSL
