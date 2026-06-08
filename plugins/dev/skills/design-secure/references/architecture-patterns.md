# Architecture Patterns Reference

Security architecture patterns for common design problems.
Each pattern includes: what it solves, when to use it, how it works, and limitations.

---

## Authentication Patterns

### Pattern 1: JWT with RS256 + Short Expiry + Refresh Tokens

**Problem:** Stateless authentication for APIs serving multiple services.

**Design:**

- Access token: JWT signed with RS256 private key; expiry 5-15 minutes
- Refresh token: opaque random token (32 bytes from CSPRNG); stored server-side; expiry 7-30 days
- Refresh endpoint: validates refresh token, issues new access + refresh token pair, invalidates old refresh token (rotation)

**Why RS256 over HS256:**
RS256 uses asymmetric keys. Services that need to verify tokens only need the public key — they never see the signing key. HS256 requires sharing the secret with every verifying service, creating more attack surface.

**Why short expiry:**
JWTs cannot be revoked (they are self-contained). Short expiry limits the window an attacker has with a stolen token. Refresh token rotation means a stolen refresh token is detected when the attacker uses it (the legitimate user's next refresh will find the token already used).

**Limitations:** Not suitable if you need instant token revocation (e.g., "logout all devices immediately"). For that, add a token blocklist or use opaque tokens with a session store.

**Reference:** [Stanford CS255 Lec 13](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)

---

### Pattern 2: Passkeys / WebAuthn (Passwordless)

**Problem:** Password authentication is phishable; users reuse passwords; credential databases get breached.

**Design:**

- User registers: browser generates a key pair; public key stored on server; private key in device's secure enclave
- User authenticates: server sends challenge; device signs with private key; server verifies with stored public key
- The private key never leaves the device; the server never sees a password

**Why this is phishing-resistant:**
The WebAuthn credential is scoped to an origin (domain + scheme + port). A phishing site at `bank-login.evil.com` cannot use the credential for `bank.com` — the browser checks the origin before signing.

**Implementation considerations:**

- Discoverable credentials (passkeys): stored in platform authenticator (phone, computer), synced via iCloud/Google Password Manager
- Security keys (YubiKey): physical token; highest security; no sync
- Fallback for account recovery: essential — what happens if the device is lost?

**Reference:** [MIT 6.566 Lec 17](https://css.csail.mit.edu/6.858/2024/) — User authentication

---

### Pattern 3: OAuth 2.0 / OpenID Connect for Third-Party Auth

**Problem:** Users want to authenticate via an existing identity provider (Google, Microsoft, GitHub).

**Design (Authorization Code Flow + PKCE):**

1. App generates `code_verifier` (random, 32 bytes) and `code_challenge = SHA256(code_verifier)`
2. Redirect user to IdP with `code_challenge`, `state` (CSRF token), `scope=openid profile email`
3. IdP authenticates user, redirects back with `code`
4. App exchanges `code` + `code_verifier` for `id_token` + `access_token`
5. Validate `id_token` (verify signature, issuer, audience, expiry, nonce)

**Why PKCE:** Prevents authorization code interception attacks. Even if an attacker intercepts the code, they cannot exchange it without the `code_verifier` which never leaves the app.

**Never use:** Implicit flow (tokens in URL fragment, logged by servers); password grant (defeats the purpose); client credentials without rate limiting.

**Reference:** [Stanford CS255 Lec 16](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)

---

## Authorization Patterns

### Pattern 4: Role-Based Access Control (RBAC)

**Problem:** Different users should have different permissions.

**Design:**

- Permissions are assigned to roles, not directly to users
- Users are assigned to roles
- Code checks: "does the user's role have permission X?" not "is the user admin?"
- Store role assignments in a central, auditable place

**Common mistake:** Checking role names in business logic (`if user.role == "admin"`) rather than checking specific permissions (`if user.can("delete_user")`). The latter is more granular and easier to audit.

---

### Pattern 5: Attribute-Based Access Control (ABAC)

**Problem:** RBAC is too coarse — you need fine-grained policies based on context.

**Design:**

- Access decision based on attributes of: subject (user), resource (data), action, environment (time, IP, device)
- Policy: `allow if user.department == resource.department AND action == "read" AND time.hour in [9,17]`
- Implement with a policy engine: OPA (Open Policy Agent), Cedar (AWS)

**When to use:** Multi-tenant systems; healthcare (access based on patient-provider relationship); financial (access based on account ownership + regulatory context).

---

## Network Architecture Patterns

### Pattern 6: Defense-in-Depth Network Architecture

```text
Internet
    │
    ▼
[WAF / CDN / DDoS protection]
    │
    ▼
[Load Balancer] ──── TLS termination here
    │
    ▼
[DMZ / Public subnet]
[Web servers / API gateway]
    │ (internal traffic only, no internet access)
    ▼
[Private subnet]
[Application servers] ──── encrypted inter-service communication (mTLS)
    │
    ▼
[Data subnet]
[Database / secrets store / cache] ──── no direct public access
```

**Trust principles:**

- Each layer trusts only the layer directly above it; never skips
- Inbound: whitelist only necessary ports and source IPs at each boundary
- Outbound: restrict egress to known destinations (limits C2 callback if compromised)
- Database: never directly accessible from internet; only from app servers; limited to specific queries

---

### Pattern 7: Zero Trust Architecture

**Problem:** Traditional perimeter security fails when attackers are already inside the network.

**Principles:**

- Never trust, always verify — authenticate and authorize every request regardless of network location
- Assume breach — design as if attackers are already inside
- Verify explicitly — use all available data points (identity, location, device health, service)

**Implementation:**

- mTLS (mutual TLS) for all inter-service communication — every service authenticates to every other service
- Service mesh (Istio, Linkerd) for automatic mTLS and policy enforcement
- Identity-aware proxy (BeyondCorp, Google IAP) — users authenticated at the proxy, not per-application
- Micro-segmentation — fine-grained network policies between services

**Reference:** [MIT 6.566 Lec 7](https://css.csail.mit.edu/6.858/2024/) — Data center infrastructure

---

## Data Protection Patterns

### Pattern 8: Envelope Encryption

**Problem:** Encrypting large amounts of data with a key that needs to be rotatable.

**Design:**

- Generate a random Data Encryption Key (DEK) for each record/file (AES-256-GCM key)
- Encrypt the data with the DEK
- Encrypt the DEK with a Key Encryption Key (KEK) managed by a KMS (AWS KMS, Cloud KMS)
- Store: ciphertext + encrypted_DEK alongside the data

**Key rotation:** Rotate the KEK; re-encrypt all DEKs (not all data). Much cheaper than re-encrypting all data.

**Why per-record DEKs:** If one DEK is compromised, only that record is exposed. If you encrypt everything with one DEK, one compromise exposes everything.

---

### Pattern 9: Pseudonymization

**Problem:** Need to work with data (analytics, testing, ML training) without exposing personal identifiers.

**Design:**

- Replace direct identifiers (name, email, SSN) with a pseudonym (a random token or HMAC of the identifier + secret key)
- Store the mapping between real identifier and pseudonym separately, with strict access control
- Use the pseudonym in analytics systems

**HMAC-based pseudonymization:**
`pseudonym = HMAC-SHA256(secret_key, real_identifier)`

- Consistent: same identifier always produces the same pseudonym (enables joining datasets)
- Non-reversible without the key: protects against database breach of the analytics system
- Key rotation invalidates all pseudonyms: plan accordingly

**Difference from anonymization:** Pseudonymization is reversible (with the key). True anonymization is irreversible but rarely achievable in practice — re-identification attacks are powerful.

---

## Logging and Audit Patterns

### Pattern 10: Secure Audit Log

**Problem:** Audit logs must be tamper-evident — an attacker who compromises the system should not be able to erase their tracks.

**Design:**

- Log every security-relevant event: authentication success/failure, authorization decisions, data access, admin actions, configuration changes
- Each log entry: timestamp, actor (user/service ID), action, resource, result, source IP
- Forward logs to an immutable log store immediately (separate system the attacker cannot reach)
- Hash chaining: each log entry includes hash of previous entry — any deletion or modification is detectable
- Consider: AWS CloudTrail (tamper-evident), Azure Monitor, or a dedicated SIEM

**What to log:**

```text
{
  "timestamp": "2025-01-15T14:23:01.234Z",  // ISO 8601, UTC
  "event_type": "auth.login.success",
  "actor": {"id": "user-uuid", "type": "user"},
  "resource": {"type": "session", "id": "session-uuid"},
  "outcome": "success",
  "context": {"ip": "1.2.3.4", "user_agent": "Mozilla/5.0...", "mfa_used": true}
}
```

**What NOT to log:** Passwords (even hashed), full credit card numbers, session tokens, encryption keys, full personal data (log pseudonymized identifiers instead).

**Reference:** ISO 27001 A.8.15; GDPR Art. 32
