# Normalization & Indexing Reference

Grounded in CMU 15-445 (Pavlo) and Stanford CS245.

---

## Normalization

### Why Normalize?

Normalization eliminates **update anomalies** — situations where the same fact
is stored in multiple places, and an update to one place leaves the others stale.

**Insertion anomaly:** Cannot record information without unrelated information
(e.g., cannot add a department without having at least one employee in it).

**Deletion anomaly:** Deleting one record accidentally deletes other information
(e.g., deleting the last employee in a department also deletes the department).

**Update anomaly:** Changing one fact requires updating multiple rows
(e.g., a department name change requires updating every employee row).

---

### Normal Forms

**1NF (First Normal Form):**

- Every column contains atomic values (no arrays, no comma-separated lists, no JSON blobs masquerading as columns)
- No repeating column groups (`phone1`, `phone2`, `phone3`)
- Each row is uniquely identifiable (has a primary key)

**Violation example:**

```sql
-- Wrong: comma-separated tags is not atomic
CREATE TABLE articles (
  id INT PRIMARY KEY,
  title VARCHAR(255),
  tags VARCHAR(500)  -- "python,django,web" -- violates 1NF
);

-- Right: separate table
CREATE TABLE article_tags (
  article_id INT REFERENCES articles(id),
  tag VARCHAR(100),
  PRIMARY KEY (article_id, tag)
);
```

---

**2NF (Second Normal Form):**

- Is in 1NF
- Every non-key attribute is fully functionally dependent on the entire primary key
  (no partial dependency — only relevant for composite primary keys)

**Violation example:**

```sql
-- Wrong: order_date depends only on order_id, not on (order_id, product_id)
CREATE TABLE order_items (
  order_id INT,
  product_id INT,
  order_date DATE,        -- depends only on order_id → partial dependency
  product_name VARCHAR,   -- depends only on product_id → partial dependency
  quantity INT,
  PRIMARY KEY (order_id, product_id)
);

-- Right:
CREATE TABLE orders (order_id INT PRIMARY KEY, order_date DATE);
CREATE TABLE products (product_id INT PRIMARY KEY, product_name VARCHAR);
CREATE TABLE order_items (
  order_id INT REFERENCES orders(id),
  product_id INT REFERENCES products(id),
  quantity INT,
  PRIMARY KEY (order_id, product_id)
);
```

---

**3NF (Third Normal Form):**

- Is in 2NF
- No transitive dependency: non-key attribute A → non-key attribute B → non-key attribute C
  is a violation (B should be in its own table)

**Violation example:**

```sql
-- Wrong: zip_code → city, state (transitive dependency)
CREATE TABLE customers (
  id INT PRIMARY KEY,
  name VARCHAR,
  zip_code VARCHAR(10),
  city VARCHAR(100),     -- determined by zip_code, not by id
  state VARCHAR(2)       -- determined by zip_code, not by id
);

-- Right:
CREATE TABLE zip_codes (zip_code VARCHAR(10) PRIMARY KEY, city VARCHAR, state VARCHAR);
CREATE TABLE customers (
  id INT PRIMARY KEY,
  name VARCHAR,
  zip_code VARCHAR(10) REFERENCES zip_codes(zip_code)
);
```

---

**BCNF (Boyce-Codd Normal Form):**
Stronger than 3NF. For every functional dependency X → Y, X must be a superkey.
Eliminates all anomalies based on functional dependencies.

Most practical schemas should target 3NF or BCNF for transactional data.

---

### When to Denormalize

Denormalization trades write complexity and anomaly risk for read performance.
Always measure before denormalizing — premature denormalization is technical debt.

**Legitimate reasons to denormalize:**

1. **Aggregate performance**: computing SUM/COUNT at query time is too slow at scale
   → store pre-computed aggregates, updated by triggers or application logic
2. **Join elimination**: a hot query joins many tables → store derived data together
3. **Reporting/OLAP**: analytical queries need different access patterns than OLTP
   → separate read model (CQRS) rather than denormalizing the write model
4. **Document storage**: entity has complex nested structure that's always accessed as a whole
   → store as JSON column (PostgreSQL JSONB) rather than normalized tables

**Document the denormalization decision:**

```sql
-- denormalized: order_total is also computable via SUM(order_items.price * quantity)
-- reason: displayed on every order list page; computing at query time is O(n*items) per page load
-- invariant: order_total must be updated whenever an order_item is added/removed/updated
-- maintained by: application layer (not database trigger, for visibility)
```

---

## Indexing Reference (CMU 15-445 Lec 08-09)

### B-Tree Index (the default)

A balanced tree where every leaf is at the same depth. Supports:

- Equality: `WHERE email = 'user@example.com'`
- Range: `WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31'`
- Prefix: `WHERE name LIKE 'Smith%'` (but NOT `LIKE '%Smith'`)
- Sorting: `ORDER BY created_at DESC` (can use the index)

**When to create a B-Tree index:**

- Foreign key columns (critical — prevents table locks on parent delete in some databases)
- Columns used in WHERE clauses with selective conditions (< 5-10% of rows)
- Columns used in JOIN conditions
- Columns used in ORDER BY / GROUP BY (avoids filesort)

**When NOT to create an index:**

- Low-cardinality columns (`status` with 3 values — index is often slower than full scan)
- Columns never used in WHERE/JOIN/ORDER BY
- Very small tables (full scan is faster; index has overhead)
- Heavily written tables (every write must update all indexes — diminishing returns)

---

### Hash Index

O(1) lookup for exact equality. Does NOT support range queries or sorting.
Used internally by most databases for hash joins.

PostgreSQL explicit hash index:

```sql
CREATE INDEX idx_users_email_hash ON users USING HASH (email);
```

Use only when you need fast equality lookup and will never range-scan.

---

### Composite Index (Multi-Column)

```sql
CREATE INDEX idx_orders_customer_date ON orders (customer_id, created_at DESC);
```

**Column order matters critically:**

- A composite index on `(A, B, C)` can be used for queries on: A, (A,B), (A,B,C)
- It CANNOT be used for queries on just B or just C (without A)
- **Rule**: put the most selective column first; put columns used in equality before range columns

**Example:**

```sql
-- Index: (customer_id, status, created_at)

-- ✅ Uses index (equality on customer_id and status, then range on created_at):
WHERE customer_id = 123 AND status = 'shipped' AND created_at > '2024-01-01'

-- ✅ Uses index (equality on customer_id):
WHERE customer_id = 123

-- ❌ Cannot use index (status is not the leading column):
WHERE status = 'shipped'
```

---

### Covering Index (Index-Only Scan)

An index that contains all columns a query needs — the database never reads the table.

```sql
-- Query:
SELECT id, email, created_at FROM users WHERE status = 'active';

-- Covering index includes all queried columns:
CREATE INDEX idx_users_covering ON users (status) INCLUDE (id, email, created_at);
-- PostgreSQL syntax: INCLUDE for non-key columns
```

An index-only scan is dramatically faster than an index scan + table heap fetch,
especially for wide tables with many columns.

---

### Partial Index

Index only the rows matching a condition. Smaller, faster, more targeted.

```sql
-- Only index active users (not deleted/suspended):
CREATE INDEX idx_users_active_email ON users (email) WHERE status = 'active';

-- Only index unfulfilled orders:
CREATE INDEX idx_orders_pending ON orders (created_at) WHERE status IN ('pending', 'processing');
```

---

### Index Anti-Patterns

**Too many indexes on a write-heavy table:**
Every INSERT, UPDATE, DELETE must update all indexes. A table with 20 indexes
on an order-processing system will have dramatically slower writes.

**Index on a low-cardinality column alone:**
`CREATE INDEX idx_users_status ON users (status)` where status has 3 values.
The query planner often prefers a full scan over an index scan when >5-10% of rows match.

**Unused indexes:**
PostgreSQL: `SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;`
Unused indexes waste space and slow down writes.

**Index that can't be used due to function wrapping:**

```sql
-- ❌ Index on email is not used:
WHERE LOWER(email) = 'user@example.com'

-- ✅ Fix: create a functional index:
CREATE INDEX idx_users_lower_email ON users (LOWER(email));
-- Or: store email already lowercased
```
