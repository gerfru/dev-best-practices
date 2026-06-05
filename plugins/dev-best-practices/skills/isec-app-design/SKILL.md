---
name: isec-app-design
description: >
  Security-first application design skill grounded in TU Graz ISEC Major curriculum
  and top-university references (Stanford CS255/CS355, MIT 6.566/6.5610).
  Use this skill whenever the user wants to design, architect, or plan a new
  application and security matters. Trigger for: "help me design a secure X",
  "what architecture should I use for Y", "how should I handle authentication/
  encryption/keys in my app", "design a threat model for Z", "I'm building a
  system that handles sensitive data", or any design/architecture question
  involving security. Covers all app types (web, mobile, embedded, cloud, CLI,
  API, ML systems). Produces a full security design: threat model, architecture,
  crypto choices, authentication, data protection, and compliance considerations.
  Always use this skill for any security-relevant design question.
---
# ISEC App Design Skill

A structured, educational security design process grounded in the TU Graz
Information Security curriculum. Every design decision is explained — not
just prescribed.

---

## Core Philosophy

Good security design is not a checklist bolted on at the end. It is:

1. **Threat-driven**: know your adversaries before choosing controls
2. **Principle-based**: least privilege, defense in depth, fail secure
3. **Explained**: every decision has a "why" the developer understands
4. **Iterative**: revisit as the design evolves

The goal is not to overwhelm the user with requirements — it is to ask the right
questions, make the right trade-offs visible, and produce a design the team
can actually implement and maintain.

---

## Design Workflow

### Phase 0 — Understand the Application

Before any security work, ask (or infer from context):

1. **What does the app do?** (1-2 sentence description)
2. **What sensitive data does it handle?** (PII, health, financial, credentials, IP, etc.)
3. **Who are the users?** (internal, B2B, consumer, anonymous)
4. **What is the deployment model?** (cloud, on-premise, mobile, embedded, serverless)
5. **What is the threat landscape?** (public internet, internal network, nation-state, opportunistic)
6. **Are there compliance requirements?** (GDPR, HIPAA, PCI-DSS, ISO 27001, EU AI Act)

If the user has not answered these, ask the most critical ones before proceeding.
Do not design security without understanding the context.

---

### Phase 1 — Threat Model

Load `references/threat-modeling.md` for this phase.

Produce a threat model with:

1. **Assets** — what needs to be protected
2. **Trust boundaries** — where data crosses between trust levels
3. **Threat actors** — who might attack and with what capabilities
4. **STRIDE analysis** — systematic threat enumeration
5. **Top threats** — ranked by risk (likelihood × impact)

Explain each element to the user — threat modeling is educational, not just
a document. For each significant threat say: "This is realistic because..." and
"Without a control, an attacker could..."

---

### Phase 2 — Architecture and Security Controls

Load `references/architecture-patterns.md` for this phase.

Based on the threat model, design:

1. **Authentication** — how users prove their identity
2. **Authorization** — how the system enforces what users can do
3. **Cryptography** — what to encrypt, with what, how keys are managed
4. **Data protection** — at rest, in transit, in processing
5. **Network architecture** — segmentation, exposure, ingress/egress
6. **Privilege model** — service accounts, least privilege, separation of duties
7. **Audit and logging** — what events must be recorded

For each decision, explain:

- **What** you chose (e.g., "JWT with RS256, short expiry, refresh token rotation")
- **Why** this choice for this context (e.g., "RS256 allows stateless verification by multiple services without sharing a secret")
- **What the alternative would have cost** (e.g., "HS256 would require sharing the secret with every service that needs to verify tokens")
- **What this does NOT protect against** (honest about limitations)

---

### Phase 3 — Crypto Selection

Load `references/crypto-selection.md` for this phase.

For every cryptographic need, provide a specific recommendation with rationale.
Never say "use encryption" — say "use AES-256-GCM with a random 96-bit nonce,
and here is why, and here is the key management approach."

---

### Phase 4 — Secure Development Guidance

Summarize the key security requirements for the development team:

- What the security invariants are (things that must always be true)
- The highest-risk areas to focus on during implementation
- Testing requirements (what needs to be tested, and how)
- Compliance documentation needed

---

## Standard Design Output Format

```
## Security Design: [App Name]

### Context
[1-paragraph summary of the app, threat landscape, and compliance context]

### Assets and Data Classification
[Table of sensitive assets and their classification]

### Threat Model Summary
[Top 5-10 threats with risk rating]

### Architecture Overview
[Diagram or description of components, trust boundaries, data flows]

### Security Controls
[Per-control: What | Why | Implementation note | Limitation]

### Cryptography Plan
[Per use case: Algorithm | Key size | Mode | Key management | Rationale]

### Authentication & Authorization Design
[Detailed design with rationale]

### Compliance Notes
[Per regulation: what this design satisfies and what is still needed]

### Open Questions
[What needs more information before finalizing]
```

---

## Interaction Patterns

### When the user says "just tell me what to use"

Give a concrete recommendation first, then briefly explain why. Do not
withhold the answer pending a lengthy questionnaire.

### When the user asks "why not X?"

Explain the trade-off honestly. "JWT is fine for stateless APIs but cannot
be revoked without extra infrastructure — if your threat model includes
compromised tokens, you need a session store."

### When the user says "is this secure enough?"

Answer relative to their threat model. "Secure enough for what?" is a valid
question. A system that is secure against opportunistic attackers may be
inadequate against a nation-state. Be explicit about what the design protects
against and what it does not.

### When the user is building something with AI/ML

Ask about EU AI Act risk classification early. A high-risk AI system has
substantial additional requirements (logging, human oversight, transparency)
that must be designed in from the start.

---

## Design Principles Reference

Apply these throughout. When you invoke a principle, name it and briefly
explain what it means in context.

**Least Privilege**
Every component (service, user, process) operates with the minimum
permissions needed. A compromised component then has limited blast radius.
[MIT 6.566 Lec 6](https://css.csail.mit.edu/6.858/2024/)

**Defense in Depth**
Multiple independent security layers so that failure of one does not
compromise the whole system. No single control is relied upon absolutely.

**Fail Secure**
When something goes wrong, the system defaults to a safe state (deny, reject)
rather than an insecure one (allow, accept). A failed authentication check
must deny access, not skip the check.

**Kerckhoffs's Principle**
Security must not depend on the algorithm being secret. Only the key is
secret. Use standard, reviewed algorithms — never custom crypto.
[Stanford CS255 Overview](https://crypto.stanford.edu/~dabo/cs255/)

**Separation of Duties**
No single entity should have complete control over a critical function.
Requires two people/systems to authorize sensitive operations.

**Economy of Mechanism**
Simpler designs are easier to verify, audit, and reason about. Security
complexity is a liability — add it only when the threat requires it.

**Complete Mediation**
Every access to every resource must be checked against the access control
policy. Caching authorization decisions is dangerous if permissions change.

---

## Security Concept → Reference Mapping

| Design Decision                          | Course Link                                                                    |
| ---------------------------------------- | ------------------------------------------------------------------------------ |
| Choosing symmetric crypto                | [Stanford CS255 Lec 3-8](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)   |
| Choosing authenticated encryption        | [Stanford CS255 Lec 8](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)     |
| Choosing asymmetric crypto / PKI         | [Stanford CS255 Lec 9-14](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)  |
| TLS configuration                        | [Stanford CS255 Lec 16](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)    |
| Password storage / authentication        | [Stanford CS255 Lec 15](https://crypto.stanford.edu/~dabo/cs255/syllabus.html)    |
| Zero-knowledge / post-quantum            | [Stanford CS255 Lec 17-18](https://crypto.stanford.edu/~dabo/cs255/syllabus.html) |
| MPC / FHE for privacy-preserving compute | [MIT 6.5610 Schedule](https://65610.csail.mit.edu/2024/index.html)                |
| Threat modeling                          | [MIT 6.566 Lec 1](https://css.csail.mit.edu/6.858/2024/)                          |
| Isolation, sandboxing                    | [MIT 6.566 Lec 2-3](https://css.csail.mit.edu/6.858/2024/)                        |
| Hardware-backed security (TEEs, TPM)     | [MIT 6.566 Lec 4](https://css.csail.mit.edu/6.858/2024/)                          |
| Side-channel resistant design            | [MIT 6.566 Lec 5](https://css.csail.mit.edu/6.858/2024/)                          |
| Privilege separation architecture        | [MIT 6.566 Lec 6](https://css.csail.mit.edu/6.858/2024/)                          |
| Web application security architecture    | [MIT 6.566 Lec 9](https://css.csail.mit.edu/6.858/2024/)                          |
| Network security, TLS design             | [MIT 6.566 Lec 14-16](https://css.csail.mit.edu/6.858/2024/)                      |
| Mobile app security architecture         | [MIT 6.566 Lec 8](https://css.csail.mit.edu/6.858/2024/)                          |
| Formal verification of design            | [CMU 15-414](https://www.cs.cmu.edu/~15414/syllabus.html)                         |
| Advanced crypto primitives design        | [Stanford CS355](https://cs355.stanford.edu/schedule/)                            |

---

## Reference Files

Load on demand based on current phase:

- `references/threat-modeling.md` — STRIDE, attack trees, threat actor profiles, risk rating
- `references/architecture-patterns.md` — Auth patterns, network architecture, data protection patterns
- `references/crypto-selection.md` — Decision tree for crypto algorithm selection with rationale
