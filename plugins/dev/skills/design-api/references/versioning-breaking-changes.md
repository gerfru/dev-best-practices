# API Versioning & Breaking Change Analysis

Grounded in CMU 17-625, Google AIP-180, and Stripe's API versioning strategy.

---

## The Fundamental Rule

> **Non-breaking changes can be deployed at any time.
> Breaking changes require a new API version.**

A change is breaking if it causes correctly-written existing client code to
fail or behave incorrectly — even if the client code is "wrong" by new standards.

---

## Non-Breaking Changes (Safe to Deploy)

These changes can be made without incrementing the API version:

**Adding:**

- ✅ New optional request fields (with sensible defaults)
- ✅ New response fields (clients should ignore unknown fields — tolerant reader pattern)
- ✅ New endpoints / resources
- ✅ New enum values in responses (clients must handle unknown enum values gracefully)
- ✅ New optional query parameters
- ✅ New HTTP methods on existing resources
- ✅ New error codes (clients should handle unknown error codes gracefully)

**Relaxing:**

- ✅ Making a required field optional
- ✅ Expanding accepted value ranges (e.g., max length from 100 to 200)
- ✅ Adding new accepted formats for existing fields

---

## Breaking Changes (Require New API Version)

These changes will break existing clients:

**Removing:**

- ❌ Removing a field from a response
- ❌ Removing an endpoint
- ❌ Removing an enum value from a request field
- ❌ Removing a query parameter

**Renaming:**

- ❌ Renaming a field (even with a deprecation notice — the old name breaks)
- ❌ Renaming a resource or endpoint URL
- ❌ Renaming enum values

**Changing semantics:**

- ❌ Changing the meaning of an existing field
- ❌ Changing the type of a field (string → integer, even if values are compatible)
- ❌ Changing the structure of a response (flat → nested, array → object)
- ❌ Changing authentication requirements
- ❌ Making an optional field required
- ❌ Narrowing accepted value ranges
- ❌ Changing HTTP status codes for existing scenarios
- ❌ Changing pagination behavior that clients rely on

---

## Versioning Strategies Compared

### URL Path Versioning (`/v1/`, `/v2/`)

```
GET /v1/users/123
GET /v2/users/123
```

**Pros:** Explicit; easy to test; browsers can cache per-version.
**Cons:** URI is supposed to identify a resource, not a version; multiple codepaths to maintain.
**Best for:** Public APIs with long support windows (Stripe, Twilio model).

### Date-Based Versioning (Google Cloud style)

```
GET /users/123
API-Version: 2024-01-15
```

Or in URL: `/2024-01-15/users/123`
**Pros:** Forces explicit version pinning per client; incremental migration.
**Cons:** Hard to test in browser; requires header support.
**Best for:** APIs that evolve frequently and have sophisticated clients.

### Semantic Versioning Header

```
GET /users/123
Accept: application/vnd.myapi.v2+json
```

**Pros:** Clean resource URLs; standard HTTP content negotiation.
**Cons:** Hard to discover; awkward to test; not widely understood.
**Best for:** Internal APIs with sophisticated consumers.

### Stripe's Approach (recommended for external APIs)

- Every API change gets a date-stamped version (`2024-01-15`)
- New accounts get the latest version by default
- Existing accounts stay on their version until they explicitly upgrade
- Old versions maintained for 2+ years
- Dashboard shows which version each API key uses

---

## Deprecation Strategy

A deprecation is a promise: "this will be removed on [date]."

**Announce deprecation with:**

- `Deprecation: true` response header
- `Sunset: Sat, 31 Dec 2025 23:59:59 GMT` header (RFC 8594)
- Documentation marking (`@deprecated`)
- Email/changelog notification to affected clients

**Deprecation timeline (minimum):**

- Internal APIs: 1-3 months
- Partner/B2B APIs: 6-12 months
- Public consumer APIs: 12-24 months

---

## GraphQL-Specific Breaking Changes

GraphQL has different rules from REST:

**Non-breaking:**

- ✅ Adding a new type, field, or argument
- ✅ Adding a new query or mutation
- ✅ Making an argument optional

**Breaking:**

- ❌ Removing a field (even if `@deprecated` — it's still breaking for clients using it)
- ❌ Changing a field's type (even to a compatible type like `String` → `ID`)
- ❌ Making a nullable field non-nullable
- ❌ Removing a query or mutation
- ❌ Making an optional argument required

**GraphQL versioning approaches:**

- Field deprecation (`@deprecated(reason: "Use newField instead")`)
- Schema stitching / federation for incremental migration
- No URL versioning — GraphQL's type system is the contract

---

## gRPC / Protobuf-Specific Breaking Changes

Protobuf has its own compatibility model based on field numbers:

**Non-breaking:**

- ✅ Adding a new field (with a new field number)
- ✅ Adding a new service method
- ✅ Renaming a field (field number is what matters in the wire format, not the name)
- ✅ Changing a field from `required` to `optional` (proto2)

**Breaking:**

- ❌ Removing or renumbering a field
- ❌ Changing a field's type (incompatible wire types will cause parse errors)
- ❌ Removing a service method
- ❌ Changing semantics (even if the wire format is compatible)

**Golden rule:** Never reuse a field number. Mark removed fields as `reserved`.

```protobuf
message User {
  reserved 2, 15;           // field numbers no longer in use
  reserved "old_name";      // field names no longer in use
  string id = 1;
  string email = 3;
}
```
