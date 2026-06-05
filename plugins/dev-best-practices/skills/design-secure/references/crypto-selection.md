# Cryptography Selection Reference

Decision guide for choosing cryptographic primitives. Always explain the choice.
Never recommend a primitive without explaining why it fits the use case.

Reference: [Stanford CS255](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)

---

## Decision Tree

### Need 1: Encrypt data (confidentiality only is almost always wrong — use AEAD)

**Use: AES-256-GCM** (standard choice, hardware-accelerated on modern CPUs)

- 256-bit key, 96-bit random nonce, 128-bit authentication tag
- Nonce must be unique per (key, message) pair — never reuse
- If nonce exhaustion is a concern at scale: use AES-256-GCM-SIV (nonce-misuse resistant)

**Alternative: ChaCha20-Poly1305** (when hardware AES is unavailable, e.g., IoT, mobile without AES-NI)

- Software-friendly; constant-time implementation easier to achieve
- Used in TLS 1.3, WireGuard, Signal

**Never use:**

- AES-ECB: deterministic, leaks patterns
- AES-CBC without MAC: malleable, padding oracle attacks
- AES-CTR without MAC: malleable
- Any self-designed encryption scheme

**Reference:** [Stanford CS255 Lec 8](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)

---

### Need 2: Protect data integrity without confidentiality

**Use: HMAC-SHA256**

- Keyed MAC; produces 256-bit tag
- Key must be kept secret; different key from encryption key
- Always use `hmac.compare_digest()` or equivalent for constant-time comparison

**Alternative: BLAKE3-MAC** (faster, same security properties)

**Never use:**

- `H(key || message)`: vulnerable to length extension attack (for SHA-1, SHA-256, SHA-512)
- `H(message || key)`: vulnerable to various attacks depending on hash
- Unkeyed hash as integrity check against active adversary (attacker recalculates hash)

---

### Need 3: Hash a password for storage

**Use: Argon2id** (OWASP recommended; PHC winner 2015)

- Parameters: m=64MB memory, t=3 iterations, p=4 parallelism (adjust to ~300ms on your hardware)
- Includes memory-hardness: resists GPU/ASIC attacks

**Alternative: bcrypt** (widely supported; cost factor ≥ 12)

- Limitation: 72-byte password limit; pre-hash with SHA-256 if longer passwords needed
- No memory-hardness — slower than Argon2id at resisting dedicated hardware

**Alternative: scrypt** (if Argon2id unavailable; N=2^20, r=8, p=1)

**Never use:**

- MD5, SHA-1, SHA-256, SHA-512 (fast hashes — GPU cracks billions/second)
- bcrypt with cost < 10
- Any unsalted hash

**Reference:** [Stanford CS255 Lec 15](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)

---

### Need 4: Key exchange (establish a shared secret between two parties)

**Use: X25519** (ECDH on Curve25519)

- 128-bit security level; fast; simple to implement correctly
- Used in TLS 1.3, Signal, WireGuard
- Provides forward secrecy when ephemeral keys are used

**Alternative: ECDH P-256** (required for FIPS compliance)

**Never use:**

- Static DH (no forward secrecy — compromise of long-term key compromises all past sessions)
- RSA key transport (no forward secrecy; larger keys for equivalent security)
- DH with non-standard groups (potential backdoor; small subgroup attacks)

**Reference:** [Stanford CS255 Lec 10](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)

---

### Need 5: Digital signature

**Use: Ed25519** (EdDSA on Curve25519)

- 128-bit security; fast; deterministic (no random nonce in signing — eliminates Sony PS3 failure mode)
- Preferred for new systems

**Alternative: ECDSA P-256** (required for FIPS/interoperability)

- Requires cryptographically random nonce per signature — nonce reuse reveals private key (Sony PS3 attack)
- Always use RFC 6979 deterministic nonce generation

**Alternative: RSA-PSS** (for legacy interoperability; 2048-bit minimum, 4096-bit preferred)

**Never use:**

- RSA-PKCS#1v1.5 signatures (new systems): theoretical attacks exist; use PSS
- DSA: parameter generation is complex; nonce reuse catastrophic; deprecated

**Reference:** [Stanford CS255 Lec 13](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)

---

### Need 6: Derive keys from a password or shared secret

**Use: HKDF-SHA256** (HMAC-based Key Derivation Function, RFC 5869)

- Structure: Extract step (compress input into a pseudorandom key) + Expand step (derive multiple keys)
- Use a unique salt per derivation; use context string in expand to separate key uses
- Example: `HKDF(secret, salt, info="auth-key v1")` → authentication key
  `HKDF(secret, salt, info="enc-key v1")` → encryption key

**For password-to-key:** Use Argon2id (see Need 3) — HKDF is not memory-hard

**Never use:**

- `H(password)` as key (no stretching, susceptible to dictionary attacks)
- Truncated hash as key (unsafe key derivation)
- The same key for multiple purposes (encryption + signing)

---

### Need 7: Generate random values (nonces, tokens, IDs)

**Use: OS CSPRNG**

- Python: `secrets.token_bytes(32)`
- Node.js: `crypto.randomBytes(32)`
- Go: `crypto/rand.Read()`
- Rust: `rand::rngs::OsRng`
- Java: `SecureRandom`
- C: `getrandom()` syscall or `/dev/urandom`

**Never use:**

- `random()`, `rand()`, `Math.random()` — not cryptographically secure; predictable state
- Time-based seeds for PRNG
- UUIDs as security tokens (UUID v4 uses PRNG; quality varies by implementation)

---

### Need 8: Post-quantum cryptography

**Context:** Classical computers cannot break AES-256 or SHA-256. Quantum computers
(Shor's algorithm) break RSA, ECC, and DH. If your data must remain secret for

> 10 years, or if you need to defend against future quantum adversaries, use PQC.

**For key encapsulation (replacing ECDH):**
Use: **CRYSTALS-Kyber** (NIST selected 2022; now ML-KEM, FIPS 203)

- Based on Module-LWE; 128-bit post-quantum security at Kyber-768

**For digital signatures (replacing ECDSA/Ed25519):**
Use: **CRYSTALS-Dilithium** (NIST selected 2022; now ML-DSA, FIPS 204)
Alternative: **SPHINCS+** (hash-based; conservative security; larger signatures)

**Hybrid approach (recommended during transition):**
Combine classical and post-quantum: X25519 + Kyber-768 for key exchange.
If either is broken, the other maintains security.

**Reference:** [Stanford CS255 Lec 17](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)
              [MIT 6.5610 Lec 4](https://65610.csail.mit.edu/2024/index.html)

---

## Key Management Principles

Key management is where most real-world crypto failures occur. The algorithm is
usually correct; the key handling is not.

**Key generation**

- Keys must be generated from a CSPRNG (see Need 7)
- Never derive a key from a predictable value (hostname, timestamp, version number)

**Key storage**

- Never store keys in source code, config files committed to git, or environment variable files in the repo
- Use a dedicated secrets manager: HashiCorp Vault, AWS KMS, Azure Key Vault, GCP Cloud KMS
- For local/embedded: use the OS keychain (macOS Keychain, Windows DPAPI, Linux secret service)
- For hardware-backed: TPM 2.0, Hardware Security Module (HSM), Secure Enclave (iOS), StrongBox (Android)

**Key separation**

- Use different keys for different purposes: one for encryption, one for signing, one for MAC
- Use HKDF to derive purpose-specific keys from a single master key

**Key rotation**

- Plan for rotation from day one; it is much harder to add later
- Envelope encryption: encrypt data with a Data Encryption Key (DEK); encrypt DEK with a Key Encryption Key (KEK); rotate KEK without re-encrypting all data

**Key destruction**

- Overwrite key material with zeros before freeing memory (secure_memzero, memset_s)
- Standard `free()` does not clear memory; the key remains accessible to an attacker with memory read access

**Reference:** [Stanford CS255 Lec 16](https://crypto.stanford.edu/~dabo/cs255/syllabus.html) — Key exchange and management
