---
name: design-secure
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

## Output — Design-Datei

Schreibe das Ergebnis nach `./design-secure.md`:

```markdown
# Security Design: [App Name]
Datum: YYYY-MM-DD

## Entscheidungen
| Entscheidung | Wahl | Begründung | Referenz |
|---|---|---|---|

## Threat Model
[Top-Threats mit Risk Rating]

## Architektur & Security Controls
[Per-control: Was | Warum | Implementation | Limitation]

## Krypto-Plan
[Per Use Case: Algorithmus | Modus | Key Management | Begründung]

## Auth & Authorization Design
[Detailliertes Design mit Rationale]

## Compliance Notes
[Per Regulation: was erfüllt, was noch fehlt]

## Annahmen & offene Punkte

---
## ✅ Setup-Todo
- [ ] ...

## 📋 Nächste Schritte (priorisiert)
1. ...
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

Least Privilege, Defense in Depth, Fail Secure, Kerckhoffs, Separation of Duties,
Economy of Mechanism, Complete Mediation: `references/design-principles.md`

## Security Concept → Reference Mapping

Concept → Course Link (Stanford CS255, MIT 6.566, CMU 15-414, ISEC, EU AI Act): `references/curriculum-mapping.md`

---

## Reference Files

Load on demand based on current phase:

- `references/threat-modeling.md` — STRIDE, attack trees, threat actor profiles, risk rating
- `references/architecture-patterns.md` — Auth patterns, network architecture, data protection patterns
- `references/crypto-selection.md` — Decision tree for crypto algorithm selection with rationale
