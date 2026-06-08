# Security Design Principles

Core principles applied consistently throughout security architecture.
When applying each principle, name it and briefly explain it in context.

---

## Least Privilege

Every component (service, user, process) operates with the minimum
permissions needed. A compromised component then has limited blast radius.
[MIT 6.566 Lec 6](https://css.csail.mit.edu/6.858/2024/)

---

## Defense in Depth

Multiple independent security layers so that failure of one does not
compromise the whole system. No single control is relied upon absolutely.

---

## Fail Secure

When something goes wrong, the system defaults to a safe state (deny, reject)
rather than an insecure one (allow, accept). A failed authentication check
must deny access, not skip the check.

---

## Kerckhoffs's Principle

Security must not depend on the algorithm being secret. Only the key is
secret. Use standard, reviewed algorithms — never custom crypto.
[Stanford CS255 Overview](https://crypto.stanford.edu/~dabo/cs255/)

---

## Separation of Duties

No single entity should have complete control over a critical function.
Requires two people/systems to authorize sensitive operations.

---

## Economy of Mechanism

Simpler designs are easier to verify, audit, and reason about. Security
complexity is a liability — add it only when the threat requires it.

---

## Complete Mediation

Every access to every resource must be checked against the access control
policy. Caching authorization decisions is dangerous if permissions change.
