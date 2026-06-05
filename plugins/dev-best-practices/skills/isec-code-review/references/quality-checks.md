# Code Quality Checks Reference

Security-relevant code quality issues. Poor code quality creates attack surface
even when individual lines appear correct.

---

## 1. Error Handling

### 1.1 Swallowed Exceptions / Silent Failures

**CWE-390, CWE-755**

Check for:

- Empty `except` / `catch` blocks
- Catching generic `Exception` and continuing silently
- Ignoring return values of security-relevant functions (e.g., `write()`, crypto operations)
- Logging error but not propagating it — caller assumes success

**Why it matters:** A failed decryption, a failed signature verification, or a failed permission check that is silently ignored leads to a system that continues operating in an insecure state. An attacker who can trigger the failure condition bypasses the security check. Fail loudly; fail safely.

---

### 1.2 Insufficient Logging of Security Events

**CWE-778**

Check for:

- Failed authentication attempts not logged
- Privilege escalation events not logged
- Admin actions not logged
- Log injection: user-controlled data in log messages without sanitization
- Sensitive data (passwords, tokens, PII) written to logs

**Why it matters (security):** Without logging, a breach may go undetected for months. The average dwell time before detection is 204 days (IBM Cost of a Data Breach 2023). Without logs, forensic investigation after an incident is impossible. With insufficient rate limiting + no logging, brute force attacks proceed undetected.

**Why it matters (compliance):** ISO 27001 A.8.15 requires logging of user activities, exceptions, and security events. GDPR Article 32 requires appropriate technical measures — audit logs are standard evidence of compliance.

---

## 2. Input Validation

### 2.1 Missing or Insufficient Input Validation

**CWE-20**

Check for:

- No validation of user-supplied numeric parameters (negative values, zero, overflow)
- No length limit on text inputs
- No format validation (email, URL, phone) before use
- Validation done client-side only (easily bypassed — always validate server-side)
- Allowlist vs denylist: denylist approaches that block known-bad (easily bypassed with encoding tricks)

**Why it matters:** Input validation is the first line of defense for injection attacks, buffer overflows, and logic flaws. Denylist approaches fail because there are always encoding tricks an attacker can use (URL encoding, Unicode normalization, null bytes) to bypass simple pattern matching. Use allowlists (only accept known-good formats) and validate at the point of use, not just at entry points.

---

### 2.2 Path Traversal

**CWE-22**

Check for:

- File path constructed from user input: `open(base_dir + user_filename)`
- `..` not stripped from path components
- Symlink resolution not performed before path check
- Archive extraction (zip, tar) without checking entry paths — "zip slip" attack

**Why it matters:** `user_filename = "../../etc/passwd"` causes the server to read a system file. Zip slip (2018) affected hundreds of libraries: a zip file with entry path `../../../../etc/cron.d/evil` extracts to the cron directory when the archive is extracted to any directory. Always resolve the canonical path and verify it starts with the expected base directory.

---

## 3. Design Patterns

### 3.1 Security by Obscurity

Check for:

- Security relies on algorithm/key being secret (Kerckhoffs's principle violation)
- Custom encryption "to make it harder" (security through obscurity fails; use standard algorithms)
- Hiding API endpoints instead of authenticating them
- Using non-standard key derivation that "the attacker won't know"

**Why it matters:** Kerckhoffs's principle (1883): a cryptosystem should be secure even if everything about the system, except the key, is public knowledge. Security through obscurity fails because reverse engineering, source code leaks, and insider threats will eventually reveal the algorithm. The only valid secrets are cryptographic keys; algorithms must be assumed public.

---

### 3.2 Privilege Escalation Risk

**CWE-269**

Check for:

- Running as root/administrator when not necessary
- SUID/SGID binaries that invoke user-controlled commands
- Temporary privilege elevation without time limit or scope restriction
- Capability inheritance across `exec()` (Linux capabilities not properly dropped)
- Docker containers running as root

**Why it matters:** Principle of least privilege: every component should operate with the minimum privilege needed to perform its function. A compromised low-privilege process cannot escalate to root if privileges are properly separated. Linux capabilities allow fine-grained privilege grants (e.g., `CAP_NET_BIND_SERVICE` to bind to port 80 without root) — use them instead of running as root.

**Reference:** [MIT 6.566 Lec 6](https://css.csail.mit.edu/6.858/2024/) — Privilege separation

---

### 3.3 Insecure Defaults

Check for:

- Debug mode enabled in production
- Default credentials not changed
- Admin interfaces publicly accessible
- Verbose error messages exposing stack traces to users
- Directory listing enabled on web servers
- CORS configured as `*` (allows any origin to make authenticated requests)

**Why it matters:** Attackers scan for known default configurations systematically. Shodan indexes millions of devices with default credentials. Debug mode in Django, Flask, or Spring Boot exposes interactive debuggers and full stack traces — in some frameworks (Werkzeug), debug mode provides a Python REPL that executes arbitrary code.

---

## 4. Concurrency

### 4.1 Race Conditions (TOCTOU)

**CWE-362, CWE-367**

Check for:

- Check-then-use pattern without atomic operation: check if file exists, then open it
- `access()` + `open()` in C (classic TOCTOU — attacker replaces file between the two calls)
- Non-atomic test-and-set operations on shared state without locks
- Shared mutable state without synchronization in multi-threaded code

**Why it matters:** TOCTOU (Time of Check to Time of Use): between the permission check and the actual operation, the world may have changed. An attacker creates a symlink after the check but before the open, redirecting the operation to a different file. The fix is to use atomic system calls: `openat()` with `O_NOFOLLOW`, or database transactions with proper isolation levels.

---
