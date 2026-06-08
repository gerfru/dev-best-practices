# Schema Evolution — Reference

Source: Kleppmann "Designing Data-Intensive Applications" (O'Reilly 2017), Ch. 4 + Ch. 11.

## Forward vs. Backward Compatibility (Kleppmann Ch. 4)

| Term | Definition | Concretely |
|---|---|---|
| **Backward Compatibility** | New code can read old data | Code v2 reads data written with v1 |
| **Forward Compatibility** | Old code can read new data | Code v1 reads data written with v2 |

**Goal for rolling deployments:** Both — new and old code versions run simultaneously.

### Rules for Schema Changes

| Change | Backward compat. | Forward compat. | Safe? |
|---|---|---|---|
| Add new optional field | ✅ (default value) | ✅ (ignored) | ✅ Safe |
| Add required field | ❌ Old code has no field | ✅ | ❌ Dangerous |
| Remove field | ✅ | ❌ Old code expects field | ❌ Expand-Contract needed |
| Change type (int → string) | ❌ | ❌ | ❌ Breaking change |
| Rename field | ❌ | ❌ | ❌ Breaking change |
| Add enum value | ✅ | ❌ Old code doesn't know value | ⚠️ Check all consumers |

**Expand-Contract Pattern for field removal:**

```text
Phase 1 — Expand:   Add new field, write both fields in parallel
Phase 2 — Migrate:  Migrate old data to new field, only read from old field
Phase 3 — Contract: Remove old field (no code reads it anymore)
```

---

## Dual-Write Problem (Kleppmann Ch. 11)

When two stores are written to simultaneously (e.g. DB + search index):

**Problem:** No atomic commit across both systems possible.

| Scenario | Risk |
|---|---|
| Write A successful, Write B failed | Stores diverge |
| Write B visible first (ordering) | Inconsistent state |
| Failure after Write A, before Write B | Partial state |

**Solutions per Kleppmann:**

1. **Change Data Capture (CDC):** Write only to DB; CDC reads transaction log and
   updates secondary stores. Causally correct ordering via log basis.

2. **Outbox Pattern:** Write event + data in a single DB transaction to outbox table.
   Separate processor reads outbox and publishes events.

3. **Event Log as Source of Truth:** All write operations as events in ordered log
   (Kafka). All stores are read models that consume the log.

---

## Change Data Capture (CDC) (Kleppmann Ch. 11)

CDC reads the transaction log of the database (binlog for MySQL, WAL for PostgreSQL).

```text
Application → DB (write) → Transaction Log → CDC Connector → Event Stream → Consumer
```

**Advantages over Dual-Write:**
- Causally correct ordering (log ordering)
- No missed changes
- Low latency (near real-time)
- No application code changes needed

**CDC Tools:**
- **Debezium** (open source, Kafka Connect) — PostgreSQL, MySQL, MongoDB, SQL Server
- **AWS DMS** — managed CDC for AWS targets
- **Google Datastream** — managed CDC for GCP

**Migration via CDC (zero-downtime DB migration):**

```text
1. Enable CDC on source DB (reads WAL/binlog from checkpoint)
2. Load initial snapshot into target DB
3. CDC streams all delta changes into target DB (catching up)
4. Enable reads from target DB (shadow read)
5. Divergence check (source vs. target)
6. Switch writes to target (dual-write phase eliminated)
7. Shut down source after confidence period
```

---

## Avro Schema Registry (Kleppmann Ch. 4)

For event-driven architectures: send schema version with each event.

**Avro Schema Evolution Rules:**
- Add field: provide default value → backward + forward compat
- Remove field: provide default value in old schema → backward + forward compat
- No default: breaking change

**Confluent Schema Registry Pattern:**
- Schema ID in message header (`magic byte + schema ID`)
- Reader reads schema ID, fetches schema from registry, converts
- Old and new schemas can coexist in parallel

---

## Decision Tree: Which Migration Technique?

```text
Must the old system keep running while the new one is deployed?
├─ No → Maintenance window, big bang (only for small/non-critical systems)
└─ Yes →
   Is it a schema change in the DB?
   ├─ Yes → Expand-Contract Pattern (phases: expand → migrate → contract)
   └─ No (new system / new store) →
      Is data consistency between stores critical?
      ├─ Yes → CDC (Debezium) + divergence check
      └─ No / OK with eventual consistency → Dual-Write + timeout-based migration
```
