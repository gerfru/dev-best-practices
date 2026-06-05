# Threat Modeling Reference

---

## STRIDE Framework

Apply STRIDE to each component and data flow in the system.
For each threat category, generate concrete threats for the specific application.

| Letter      | Threat                 | Violated Property | Example                                                |
| ----------- | ---------------------- | ----------------- | ------------------------------------------------------ |
| **S** | Spoofing               | Authentication    | Attacker impersonates a legitimate user or service     |
| **T** | Tampering              | Integrity         | Attacker modifies data in transit or at rest           |
| **R** | Repudiation            | Non-repudiation   | User denies having performed an action; no audit trail |
| **I** | Information Disclosure | Confidentiality   | Sensitive data exposed to unauthorized parties         |
| **D** | Denial of Service      | Availability      | Service made unavailable to legitimate users           |
| **E** | Elevation of Privilege | Authorization     | Attacker gains capabilities beyond what was granted    |

### How to Apply STRIDE

For each component or data flow:

1. List all applicable STRIDE threats
2. Assess: Is there already a control? Is the threat realistic for this context?
3. If no control and realistic: add to the risk register

---

## Threat Actor Profiles

Choose the relevant profile(s) for the application's threat landscape.

### Script Kiddie / Opportunistic Attacker

- **Motivation**: opportunistic, notoriety, small financial gain
- **Capability**: runs public tools and exploit kits; no novel vulnerability research
- **Approach**: automated scanning, known CVEs, default credentials
- **Mitigated by**: basic hygiene — patched dependencies, no default creds, basic hardening

### Financially Motivated Cybercriminal

- **Motivation**: ransomware, data theft for sale, fraud
- **Capability**: uses commercial attack toolkits (Cobalt Strike, Metasploit); can buy 0-days; persistent
- **Approach**: phishing, credential stuffing, supply chain; maintains long-term access
- **Mitigated by**: defense in depth, EDR, MFA, incident response, backups

### Insider Threat

- **Motivation**: financial gain, grievance, coercion
- **Capability**: legitimate access; knows system internals; can bypass perimeter
- **Approach**: data exfiltration, sabotage, privilege abuse
- **Mitigated by**: least privilege, separation of duties, audit logging, anomaly detection

### Nation-State / Advanced Persistent Threat (APT)

- **Motivation**: espionage, critical infrastructure disruption, IP theft
- **Capability**: 0-day exploits, supply chain attacks, long dwell time (months/years), massive resources
- **Approach**: spear phishing, watering hole, supply chain compromise, hardware implants
- **Mitigated by**: air-gapping critical systems, formal verification, hardware security, zero-trust

### Competing Business / Industrial Espionage

- **Motivation**: IP theft, competitive advantage
- **Capability**: similar to APT but more targeted; legal means (FOIA, employee poaching) combined with cyber
- **Approach**: targeting developers/employees, vendor compromise

---

## Trust Boundary Identification

A trust boundary is a line across which data or control passes between entities
with different trust levels. Every trust boundary is a potential attack surface.

Common trust boundaries:

- Internet ↔ DMZ / Load Balancer
- DMZ ↔ Internal network / Application server
- Application server ↔ Database
- User browser ↔ Web application (Same-Origin boundary)
- Mobile app ↔ Backend API
- Admin interface ↔ Regular user interface
- CI/CD pipeline ↔ Production environment
- Third-party service ↔ Internal system

For each trust boundary, ask:

1. What data crosses this boundary?
2. Is it authenticated (proven source identity)?
3. Is it authorized (permitted by policy)?
4. Is it integrity-protected (cannot be tampered)?
5. Is it confidential (cannot be read by intermediaries)?

---

## Risk Rating

Rate each threat using a simple matrix: **Risk = Likelihood × Impact**

**Likelihood:**

- 1 — Unlikely (requires nation-state capability or very specific conditions)
- 2 — Possible (requires skill and motivation but feasible)
- 3 — Likely (exploitable with public tools; attacker has clear motivation)

**Impact:**

- 1 — Low (minor disruption; limited data; reversible)
- 2 — Medium (significant data breach; service disruption; reputational damage)
- 3 — High (critical data loss; regulatory breach; irreversible damage; safety impact)

| Risk Score | Priority                                |
| ---------- | --------------------------------------- |
| 7-9        | 🔴 CRITICAL — Mitigate before launch   |
| 4-6        | 🟠 HIGH — Mitigate in current sprint   |
| 2-3        | 🟡 MEDIUM — Mitigate within release    |
| 1          | 🔵 LOW — Accept or mitigate in backlog |

---

## Attack Tree Example (Authentication)

For complex threats, use an attack tree to decompose the attack goal into
sub-goals. This reveals which controls are most effective.

```
Goal: Authenticate as a legitimate user without valid credentials
├── Steal valid credentials
│   ├── Phishing attack → Mitigated by: MFA
│   ├── Credential stuffing (from other breached DB) → Mitigated by: MFA, rate limiting
│   ├── Keylogger on user's device → Mitigated by: device trust, passkeys
│   └── Intercept credentials in transit → Mitigated by: TLS
├── Bypass authentication
│   ├── SQL injection in login query → Mitigated by: parameterized queries
│   ├── JWT forgery (alg:none or key confusion) → Mitigated by: strict alg allowlist
│   └── Session fixation → Mitigated by: regenerate session ID after auth
└── Exploit account recovery
    ├── Weak security questions → Mitigated by: remove security questions
    └── Email account takeover → Mitigated by: MFA on email account
```

---

## Threat Model Output Template

```markdown
## Threat Model: [Application Name]

### Assets
| Asset | Classification | Owner | Impact if compromised |
|---|---|---|---|
| User PII | Confidential | Product team | GDPR breach, reputational damage |
| Auth tokens | Secret | Platform team | Account takeover |
| Encryption keys | Secret | Security team | Full data compromise |

### Trust Boundaries
[List boundaries with what crosses them]

### Threat Actors
[Select from profiles above; customize for context]

### STRIDE Analysis
[Table: Component × STRIDE category × Threat description × Existing control × Residual risk]

### Top Risks (ranked)
1. [Risk] — Score X — Mitigation: [control]
2. ...

### Accepted Risks
[Risks explicitly accepted with justification]
```
