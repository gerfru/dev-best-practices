# Event Sourcing & CQRS Reference

Grounded in Martin Fowler's patterns and Greg Young's CQRS/ES work.

---

## CQRS — Command Query Responsibility Segregation

[Fowler: CQRS](https://martinfowler.com/bliki/CQRS.html)

### What It Is

Separate the model used for writes (**commands**) from the model used for reads (**queries**).
Most systems use the same model for both. CQRS splits them, allowing each to be
optimized independently.

```text
Client
  │
  ├── Command → Command Handler → Write Model (normalized, consistent, ACID)
  │                                       │
  │                               [publishes events]
  │                                       │
  └── Query  → Query Handler  → Read Model (denormalized, optimized for display)
                                       ↑
                               [updated by events from write model]
```

### When CQRS Helps

- Read and write workloads have **very different scale requirements** (reads >> writes)
- The **query model** would be a very awkward fit for the write model (complex aggregations, joins)
- You need **multiple read representations** of the same data for different clients
- The domain has **complex business logic** that benefits from a clean command model

### When CQRS Hurts

- Simple CRUD applications (CQRS adds complexity without benefit)
- Small teams without the bandwidth to maintain two models
- Strong consistency requirements between reads and writes (CQRS typically introduces eventual consistency)
- The domain doesn't have meaningfully different read/write patterns

### The Consistency Trade-Off

With CQRS, the read model is updated asynchronously from the write model.
Between a command completing and the read model updating, reads may return stale data.

This is **acceptable for most user-facing scenarios** (the user doesn't notice 200ms lag).
It is **not acceptable** for:

- Financial totals that must be immediately consistent
- Inventory counts where double-selling must be prevented
- Authentication/authorization data

---

## Event Sourcing

[Fowler: EventSourcing](https://martinfowler.com/eaaDev/EventSourcing.html)

### What It Is

Instead of storing the **current state** of an entity, store the **sequence of events**
that led to that state. The current state is derived by replaying events.

**Traditional (state-based):**

```text
users table:
| id | name    | email         | subscription | updated_at |
|----|---------|---------------|--------------|------------|
| 1  | Alice   | alice@ex.com  | premium      | 2024-06-01 |
```

**Event-sourced:**

```text
events table:
| id | aggregate_id | type                    | data                          | timestamp  |
|----|-------------|-------------------------|-------------------------------|------------|
| 1  | user-1      | UserRegistered          | {name: Alice, email: ...}     | 2024-01-01 |
| 2  | user-1      | EmailChanged            | {email: newemail@...}         | 2024-03-15 |
| 3  | user-1      | SubscriptionUpgraded    | {plan: premium}               | 2024-06-01 |
```

Current state = apply all events in order.

### What Event Sourcing Gives You

**Complete audit log by design:** every change is recorded with who did it and when.
No need to build audit tables separately.

**Temporal queries:** "What did Alice's account look like on March 1st?"
Replay events up to that date.

**Debugging:** replay the sequence of events that led to a bug.

**Event-driven integration:** events are the natural integration point for other services.

**Business insight:** the event log captures business processes, not just state transitions.

### What Event Sourcing Costs You

**Complexity:** deriving current state requires replaying events.
Use snapshots to avoid replaying 10,000 events for every query.

**Query complexity:** you cannot simply `SELECT * FROM users WHERE subscription = 'premium'`.
You need a read model (CQRS) that projects the current state.

**Schema evolution:** event schemas must be versioned. Events from 3 years ago may
have a different structure than today's events. Requires careful upcasting.

**Eventual consistency:** read models lag behind the event stream.

**Operational complexity:** event store management, snapshot strategy, projection rebuilding.

### When to Use Event Sourcing

✅ Use when:

- Audit trail is a core business requirement (financial, healthcare, compliance)
- You need temporal queries ("what did this look like at time T?")
- Complex business processes with multiple state transitions
- Event-driven integration between bounded contexts is the primary integration pattern
- The business itself thinks in terms of events ("order placed", "payment failed")

❌ Don't use when:

- Simple CRUD with no audit requirements
- Small team without ES operational experience
- You just want an audit log (use a simple audit table instead)
- Strong consistency between events and read model is required
- The team hasn't used ES before (start with a small, non-critical aggregate first)

---

## Event Store Design

```sql
CREATE TABLE events (
  id            BIGSERIAL PRIMARY KEY,
  aggregate_id  UUID NOT NULL,
  aggregate_type VARCHAR(100) NOT NULL,
  event_type    VARCHAR(100) NOT NULL,
  event_version INTEGER NOT NULL DEFAULT 1,
  sequence_num  INTEGER NOT NULL,           -- per-aggregate sequence number
  data          JSONB NOT NULL,             -- event payload
  metadata      JSONB,                      -- causation_id, correlation_id, user_id
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE (aggregate_id, sequence_num)       -- optimistic concurrency control
);

CREATE INDEX idx_events_aggregate ON events (aggregate_id, sequence_num);
CREATE INDEX idx_events_type_time ON events (event_type, created_at);
```

**Optimistic concurrency:** when appending event N+1, verify that the last event
for this aggregate has sequence_num = N. If not, another writer raced you — retry.

---

## Snapshot Strategy

Replaying 10,000 events to get current state is expensive.
Use snapshots: periodically save the current aggregate state alongside the event stream.

```sql
CREATE TABLE snapshots (
  aggregate_id  UUID PRIMARY KEY,
  aggregate_type VARCHAR(100) NOT NULL,
  sequence_num  INTEGER NOT NULL,   -- the event sequence this snapshot represents
  state         JSONB NOT NULL,     -- serialized aggregate state
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Rebuild strategy:**

1. Load the most recent snapshot for the aggregate
2. Replay events with sequence_num > snapshot.sequence_num
3. Apply to the snapshotted state

Snapshot frequency: every 50-100 events is a common heuristic. Profile your actual replay times.
