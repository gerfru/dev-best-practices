# Monolith to Microservices Reference

Grounded in Martin Fowler's patterns and MIT 6.5840 distributed systems.

---

## The Strangler Fig Pattern (Fowler)

Named after the strangler fig tree that grows around a host tree and eventually replaces it.

**Concept:** Build the new system around the old one. Route traffic incrementally.
When 100% of traffic goes to the new system, decomission the old one.

**Steps:**

1. Put a **façade/proxy** in front of the monolith (API gateway, reverse proxy)
2. Identify the first **seam** to extract — a bounded capability with minimal dependencies
3. Build the new service for that capability
4. **Dark launch**: route traffic to both, compare responses, measure divergence
5. Shift a small % of traffic to the new service (1%, 5%, 10%)
6. Monitor: error rate, latency, data consistency
7. Ramp to 100%; decommission the monolith code for that capability
8. Repeat for the next seam

**What makes a good first seam:**

- Low coupling to the rest of the monolith (few inbound/outbound dependencies)
- Well-defined boundary (clear inputs/outputs)
- High business value (makes the migration worthwhile)
- Non-critical path initially (lower risk for the first attempt)

**Common mistake:** Trying to extract the most complex or most central service first.
Start with the periphery, build confidence, then tackle the core.

---

## Finding Seams

A seam is a place in the codebase where you can pull apart modules with minimal surgery.

**Techniques:**

1. **Dependency analysis**: which modules have the fewest inbound dependencies? Those can be extracted first.
2. **Change frequency**: which modules change together most often? They belong together.
3. **Team ownership**: which parts of the code are "owned" by a specific team? That's a natural service boundary.
4. **DDD Bounded Contexts**: find the subdomain boundaries in the domain model. Each bounded context is a candidate service.
5. **Database table ownership**: which tables does each feature primarily own? Data ownership is often the best boundary indicator.

---

## Data Decoupling (The Hard Part)

Most monolith-to-microservices migrations fail at data decoupling.
When services share a database, they are not truly independent.

**Step 1: Identify table ownership**
For each database table, which service "owns" it (writes to it)?
Other services that read from it are "borrowing" data.

**Step 2: Create read replicas/views for borrowers**
Borrower services get a read-only view or API to the data they need.
This breaks the direct database dependency.

**Step 3: Migrate the data store**
The owning service moves its tables to its own database.
Borrowers now must call the API.

**Step 4: Remove the shared schema**
Delete the old shared tables.

**The dual-write problem:**
During migration, writes may go to both old shared DB and new service DB.
This creates a distributed transaction problem.

Solutions:

- **Event-driven sync**: owner publishes events; consumers update their own read models
- **Change Data Capture (CDC)**: Debezium reads the DB transaction log and publishes events
- **Saga pattern**: replace distributed transactions with compensating transactions

[MIT 6.5840: Distributed Transactions](https://pdos.csail.mit.edu/6.824/)

---

## Zero-Downtime Database Migration

Grounded in the Expand-Contract (Parallel Change) pattern.

## The Problem

You cannot change a database column that production code is using without a brief
inconsistency window — unless you use the Expand-Contract pattern.

## Expand-Contract Pattern (Fowler: ParallelChange)

Named after the three phases: Expand → Migrate → Contract.

**Example: Renaming `user_name` to `full_name`**

### Phase 1: Expand

Add the new column without removing the old one.
The application now writes to BOTH columns.
The application reads from the OLD column (to not break existing code).

```sql
ALTER TABLE users ADD COLUMN full_name VARCHAR(255);
```

Application write logic:

```python
user.user_name = value  # old column (keep writing)
user.full_name = value  # new column (start writing)
```

**Deploy this.** Old code still works (reads `user_name`). New column exists and is being populated.

### Phase 2: Migrate

Backfill the new column for existing rows.

```sql
UPDATE users SET full_name = user_name WHERE full_name IS NULL;
```

Run in batches to avoid locking the table:

```sql
UPDATE users SET full_name = user_name
WHERE id BETWEEN 1 AND 1000 AND full_name IS NULL;
```

Verify: `SELECT COUNT(*) FROM users WHERE full_name IS NULL;` → should be 0.

### Phase 3: Contract (Switch Reads)

Update the application to READ from the new column.

```python
user.full_name = value      # write to new column only now
# value = user.full_name    # read from new column
```

**Deploy this.** Monitor for errors. If successful, proceed.

### Phase 4: Contract (Remove Old Column)

```sql
ALTER TABLE users DROP COLUMN user_name;
```

**Critical:** This phase can only happen after all application code that references
`user_name` is deployed. Check all services, all code paths, all ETL jobs.

## Adding NOT NULL Columns (Without Downtime)

Never add a `NOT NULL` column without a default to a populated table.
It requires a full table rewrite, which locks the table.

**Safe approach:**

1. Add column as nullable: `ALTER TABLE orders ADD COLUMN region VARCHAR(50);`
2. Backfill: `UPDATE orders SET region = 'EU' WHERE created_at < '2024-01-01';`
3. Add NOT NULL constraint: `ALTER TABLE orders ALTER COLUMN region SET NOT NULL;`
   (On PostgreSQL, this validates against existing data — set a default first)

## Index Creation Without Downtime (PostgreSQL)

```sql
-- This locks the table:
CREATE INDEX idx_users_email ON users(email);

-- This does NOT lock the table (takes longer but safe in production):
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

`CREATE INDEX CONCURRENTLY` takes longer but doesn't block reads or writes.

---

## Distributed Systems Concepts for Migration

Grounded in MIT 6.5840 (Distributed Systems).

## CAP Theorem (Brewer 2000)

In a distributed system, you can have at most two of:

- **C**onsistency: every read sees the most recent write
- **A**vailability: every request receives a response
- **P**artition tolerance: the system continues to work despite network partitions

Since network partitions are a physical reality, you must choose between **CP** and **AP**.

**CP systems** (consistent under partition): ZooKeeper, etcd, HBase

- During a partition, some nodes become unavailable rather than serve stale data
- Right for: coordination, distributed locks, financial systems

**AP systems** (available under partition): DynamoDB, Cassandra, CouchDB

- During a partition, nodes serve potentially stale data
- Right for: shopping carts, user preferences, social feeds

**Implication for migrations:** When migrating from one system to another, you may
temporarily reduce your consistency guarantees. Make this explicit in the migration plan.

## Consistency Models (MIT 6.5840)

**Linearizability (strongest):** Operations appear instantaneous; all clients see
the same order. As if the system is a single server. Expensive — requires coordination.

**Sequential consistency:** All operations occur in some sequential order; each
client sees operations in the order they performed them, but clients may disagree
on the global order.

**Eventual consistency (weakest):** Given no new updates, all replicas will eventually
converge to the same value. No guarantee on when. Cheap — no coordination needed.
DynamoDB, Cassandra default.

**Read-your-writes consistency:** A client always sees their own writes. Minimum
useful guarantee for user-facing systems.

## Two-Phase Commit (2PC) — MIT 6.5840

The classic distributed transaction protocol. Used when you need atomic operations
across multiple databases/services.

**Phase 1 (Prepare):** Coordinator asks all participants "can you commit?"
All participants lock their resources and respond Yes or No.

**Phase 2 (Commit/Abort):** If all said Yes → coordinator sends Commit.
If any said No → coordinator sends Abort.

**The problem:** The coordinator can fail between Phase 1 and Phase 2,
leaving participants locked indefinitely. This is the "blocking" failure mode of 2PC.

**For migrations:** Avoid 2PC if possible. Use the Saga pattern instead.

## Saga Pattern

Replace distributed transactions with a sequence of local transactions,
each publishing an event that triggers the next step.
If a step fails, trigger compensating transactions to undo previous steps.

**Choreography-based saga (no central coordinator):**
Each service listens for events and reacts. Decentralized but hard to track.

**Orchestration-based saga (central coordinator):**
A saga orchestrator sends commands to each service and handles failures.
Easier to monitor and debug.

**Migration example: Monolith order processing → microservices**
Old: `BEGIN; INSERT order; UPDATE inventory; COMMIT;`
New saga:

1. Order Service: create order → publish `OrderCreated`
2. Inventory Service: reserve stock → publish `InventoryReserved` or `InventoryFailed`
3. If `InventoryFailed`: Order Service compensates → cancel order, publish `OrderCancelled`
