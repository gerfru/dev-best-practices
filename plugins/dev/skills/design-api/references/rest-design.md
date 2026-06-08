# REST API Design Reference

Grounded in CMU 17-625, Google API Design Guide, and Fielding's REST constraints.

---

## REST Constraints (Fielding 2000)

REST is not "JSON over HTTP" — it is a specific architectural style with six constraints.
Violating a constraint means you're not REST; that may be fine, but be explicit about it.

1. **Client-Server**: UI separated from data storage — enables independent evolution
2. **Stateless**: each request contains all information needed — no session state on server
3. **Cacheable**: responses must declare cacheability — enables client and proxy caching
4. **Uniform Interface**: consistent interface (resources, representations, self-descriptive messages, HATEOAS)
5. **Layered System**: client cannot tell if it's connected directly to the server
6. **Code on Demand** (optional): server can send executable code to client

Most "REST" APIs actually implement only constraints 1-3 and part of 4.
That's fine — call it an HTTP API. The important thing is being deliberate.

---

## Resource Modeling

### Core principle: model resources, not operations

**Wrong (RPC-style over HTTP):**

```text
POST /getUser
POST /createUser
POST /deleteUser
POST /updateUserEmail
```

**Right (resource-oriented):**

```text
GET    /users/{id}         → retrieve user
POST   /users              → create user
DELETE /users/{id}         → delete user
PATCH  /users/{id}         → partial update (email, etc.)
PUT    /users/{id}         → full replacement
```

### Resource naming rules

- **Nouns, not verbs**: `/orders`, not `/createOrder` or `/getOrders`
- **Plural nouns for collections**: `/users`, `/products`, `/orders`
- **Lowercase, hyphen-separated**: `/user-profiles`, not `/userProfiles` or `/user_profiles`
- **Hierarchical for ownership**: `/users/{id}/orders` (orders belonging to a user)
- **Avoid deep nesting**: max 2 levels of nesting; use query params for filtering instead
  - ❌ `/users/{userId}/orders/{orderId}/items/{itemId}/reviews`
  - ✅ `/order-items/{itemId}/reviews`

### HTTP method semantics

| Method | Semantics                         | Idempotent      | Safe   |
| ------ | --------------------------------- | --------------- | ------ |
| GET    | Retrieve resource(s)              | ✅ Yes          | ✅ Yes |
| POST   | Create resource or trigger action | ❌ No           | ❌ No  |
| PUT    | Replace resource completely       | ✅ Yes          | ❌ No  |
| PATCH  | Partial update                    | ❌ No (usually) | ❌ No  |
| DELETE | Remove resource                   | ✅ Yes          | ❌ No  |

**Idempotent** means calling it N times has the same effect as calling it once.
PUT must be idempotent — the request body must be the complete new state.
PATCH is typically not idempotent (increment-by-one patches are not idempotent).

---

## HTTP Status Codes

Use the correct status code — clients use these to determine what to do next.

### 2xx — Success

- `200 OK` — successful GET, PATCH, PUT
- `201 Created` — successful POST that created a resource; include `Location` header
- `204 No Content` — successful DELETE or action with no response body
- `206 Partial Content` — paginated or range response

### 3xx — Redirection

- `301 Moved Permanently` — URL has permanently changed; include `Location` header
- `304 Not Modified` — conditional GET; client's cached version is current

### 4xx — Client Error

- `400 Bad Request` — malformed syntax, invalid parameters; include error details
- `401 Unauthorized` — not authenticated (confusingly named — means unauthenticated)
- `403 Forbidden` — authenticated but not authorized
- `404 Not Found` — resource doesn't exist
- `409 Conflict` — state conflict (duplicate create, optimistic lock failure)
- `422 Unprocessable Entity` — well-formed but semantically invalid (use for validation errors)
- `429 Too Many Requests` — rate limited; include `Retry-After` header

### 5xx — Server Error

- `500 Internal Server Error` — unexpected server-side failure; log and investigate
- `502 Bad Gateway` — upstream service failure
- `503 Service Unavailable` — overloaded or in maintenance; include `Retry-After`

---

## Error Response Format

Consistent error format is critical for API usability. Recommended (RFC 9457 Problem Details):

```json
{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "The request body contains invalid data.",
  "instance": "/users",
  "errors": [
    {
      "field": "email",
      "message": "Must be a valid email address",
      "code": "INVALID_FORMAT"
    },
    {
      "field": "age",
      "message": "Must be at least 18",
      "code": "BELOW_MINIMUM"
    }
  ]
}
```

**Never** expose stack traces, internal exception messages, or database error details in API errors.

---

## Pagination

**Cursor-based** (preferred for large/live datasets):

```json
GET /users?limit=20&after=eyJ1c2VyX2lkIjoxMDB9

{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJ1c2VyX2lkIjoxMjB9",
    "has_more": true
  }
}
```

Pros: stable under insertions; O(1) per page; works for infinite scroll.
Cons: can't jump to page N; cursor is opaque to clients.

**Offset-based** (for user-facing paginated tables with page numbers):

```json
GET /users?page=3&per_page=20

{
  "data": [...],
  "pagination": {
    "page": 3,
    "per_page": 20,
    "total": 847,
    "total_pages": 43
  }
}
```

Cons: unstable under concurrent insertions (items shift between pages); slow for large offsets.

---

## Filtering, Sorting, Field Selection

```text
# Filtering — simple equality
GET /orders?status=shipped&customer_id=123

# Filtering — range (prefer explicit params over operators in query string)
GET /orders?created_after=2024-01-01&created_before=2024-12-31

# Sorting
GET /orders?sort=created_at&direction=desc
GET /orders?sort=-created_at  # minus prefix for descending (Google style)

# Field selection (reduce response payload)
GET /users?fields=id,name,email

# Sparse fieldsets (JSON:API style)
GET /users?fields[users]=id,name&fields[orders]=id,total
```

---

## Versioning Anti-Patterns

**URL versioning** (`/v1/users`) — most common, but problematic:

- Clients hardcode version numbers
- Breaking changes require clients to migrate all at once
- Multiple versions must be maintained in parallel

**Header versioning** (`API-Version: 2024-01-01`) — clean but harder to test and debug.

**Query param versioning** (`?version=2`) — least visible; easy to miss.

**Best practice:** Version by date (Google API style) or semantic version in URL.
Commit to a deprecation policy (e.g., 12 months notice before removing a version).
