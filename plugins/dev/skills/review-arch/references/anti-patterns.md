# Architectural Anti-Patterns & Coupling Reference

Grounded in CMU 17-633 (Bass/Clements/Kazman) and Martin Fowler's patterns.

---

## Coupling Analysis

### Coupling Types (CMU 17-633 Module Structure)

**Afferent coupling (Ca)** — how many modules depend ON this module

- High Ca = this module is heavily used → changes here break many things
- "Stability" metric: stable modules should have high Ca

**Efferent coupling (Ce)** — how many modules this module depends ON

- High Ce = this module depends on many things → hard to reuse; breaks when dependencies change
- "Instability" metric: I = Ce / (Ca + Ce), range 0 (stable) to 1 (unstable)

**The Stable Dependencies Principle (SDP):** depend in the direction of stability.
A volatile module (I=1) should not be depended on by a stable module (I=0).
Violation: a core domain model depending on an infrastructure detail.

**The Stable Abstractions Principle (SAP):** stable modules should be abstract;
instable modules should be concrete. Stable + concrete = "zone of pain".
Instable + abstract = "zone of uselessness".

### Coupling Patterns to Flag

**Tight temporal coupling**
Two services must be available simultaneously for an operation to succeed.
Synchronous REST calls between services create tight temporal coupling.
Fix: async messaging (queues, events) decouples availability.

**Shared database coupling**
Multiple services access the same database schema.
Schema changes require coordinating all services simultaneously.
Fix: each service owns its data; share via API or events. [Fowler: SharedDatabase](https://martinfowler.com/bliki/IntegrationDatabase.html)

**Implicit interface coupling**
Services depend on undocumented internal details of other services
(internal data structures, specific error codes, execution order).
Fix: explicit contracts (OpenAPI, Protobuf, AsyncAPI).

**Deployment coupling**
Multiple services must be deployed together.
Often a sign that service boundaries are wrong.
Fix: decouple release cycles; one team, one deployment pipeline.

---

## Architectural Anti-Patterns

### Big Ball of Mud

**What:** No discernible architecture; code grows by accretion; everything depends on everything.
**Symptoms:** Any change requires touching many files; nobody can explain the structure;
"just follow the pattern you see nearby" is the onboarding guide.
**Why it happens:** Pressure to ship; no architectural governance; successful system that
outlived its original design.
**CMU reference:** Foote & Yoder 1997 — "Big Ball of Mud" (canonical paper).
**Fix:** Identify seams (natural boundaries where coupling is lower); apply Strangler Fig
pattern to incrementally extract modules. [Fowler: StranglerFigApplication](https://martinfowler.com/bliki/StranglerFigApplication.html)

---

### God Service / God Object

**What:** One service or class does too much — it knows about, or is called by, everything.
**Symptoms:** The service has 50+ endpoints; it's involved in every user flow;
it's the most frequently merged file in the repository.
**Why it matters:** High afferent coupling → changes are high-risk; single team bottleneck;
violates Single Responsibility Principle at the service level.
**Fix:** Identify bounded contexts (DDD); split along domain capability lines, not technical layers.
[Fowler: BoundedContext](https://martinfowler.com/bliki/BoundedContext.html)

---

### Distributed Monolith

**What:** Services are separately deployed but so tightly coupled they must be changed and
deployed together. The worst of both worlds: distributed system complexity + monolith rigidity.
**Symptoms:** "We need to coordinate with 5 teams to deploy this feature";
services share a database; services call each other synchronously in request chains > 3 hops.
**Why it matters:** Defeats the purpose of microservices; adds network latency and failure
modes without adding team autonomy or independent deployability.
**Fix:** Identify which services are always changed together → they should be one service.
Apply the "two-pizza team" test: one team should own one deployable unit.

---

### Chatty API / Over-fetching / Under-fetching

**What:** API design forces clients to make many calls to accomplish one logical operation
(chatty), or returns far more data than needed (over-fetching), or forces multiple
round-trips to assemble data (under-fetching).
**Symptoms:** Frontend makes 15 API calls to render one screen;
API returns 50 fields when 3 are needed; clients maintain their own aggregation logic.
**Why it matters:** Performance degrades at scale; API is hard to evolve; client logic
duplicates server-side concerns.
**CMU 17-625 reference:** API usability and the principle of "design APIs that are easy to
use and difficult to misuse."
**Fix:** Design experience-first APIs (BFF — Backend For Frontend pattern);
consider GraphQL for flexible querying; use composite endpoints for common patterns.
[Fowler: BFF](https://samnewman.io/patterns/architectural/bff/)

---

### Layering Violation / Layer Skipping

**What:** A higher layer directly depends on a lower layer that it should not access,
bypassing the intermediate layer. E.g., UI layer directly queries the database.
**Why it matters (CMU 17-633):** Layered architecture provides modifiability by
constraining allowed-to-use relations. When a layer is bypassed, that modifiability
guarantee is lost — the bypassing layer now depends on both the skipped layer's
interface AND its implementation details.
**Fix:** Enforce layer boundaries via package visibility rules, module system, or
architecture fitness functions (ArchUnit, Dependency Cruiser).

---

### Anemic Domain Model

**What:** Domain objects are pure data containers (getters/setters only); all business
logic lives in service classes. The domain model has no behavior.
**Why it matters:** Business rules scatter across service classes; same rule gets
duplicated; invariants are enforced inconsistently; the model doesn't protect its own integrity.
**CMU reference:** Relates to the "Repository style" (L9) where data and behavior separation
is a deliberate architectural choice — but the anti-pattern is doing it without deliberate choice.
**Fix:** Move behavior into domain objects; use DDD aggregates to enforce invariants at the boundary.
[Fowler: AnemicDomainModel](https://martinfowler.com/bliki/AnemicDomainModel.html)

---

### Shared Kernel / Inappropriate Intimacy

**What:** Two modules or services share a common code library that both depend on and
that both teams can change. The "shared kernel" in DDD is a deliberate, maintained contract;
inappropriate intimacy is when it grows unchecked.
**Symptoms:** A "commons" or "shared" library that contains domain logic, not just utilities;
changes to it require coordinating multiple teams; the library has 200+ classes.
**Fix:** Distinguish infrastructure utilities (ok to share) from domain logic (should not be shared);
publish a versioned library with an explicit contract; or duplicate deliberately.

---

### Resume-Driven Development (Technology Mismatch)

**What:** Technology choices driven by novelty or team interest rather than system requirements.
**Symptoms:** Kubernetes for a system with 3 users; event sourcing for a simple CRUD app;
microservices for a 2-person team.
**CMU 17-633 framing:** Architecture must be driven by quality attribute requirements and
business constraints, not technology preferences. The cost of the wrong abstraction is paid
for years.
**Fix:** Document the quality attribute scenario the technology is intended to address.
If you cannot write it, reconsider the choice.
