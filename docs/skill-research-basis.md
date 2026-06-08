# Academic & Industry Sources — Dev Skills

Canonical sources per skill. Authoritative for:
- Verifying academic grounding for new skills
- Looking up course numbers and literature references
- Guidance when expanding existing skills

---

## design-llm + review-llm

| Source | Type | Content |
|---|---|---|
| Stanford CS224N (Winter 2026) | University course | Lectures 7–11: Post-training, PEFT/LoRA, RAG, Agents, Evaluation — slides public |
| CMU 11-667 (Spring 2026) | University course | Prompting, fine-tune decisions, RAG (3 lectures), tool use, multi-agent, deployment — slides public |
| Berkeley CS294-196 (Fall 2024) | Guest lectures | Compound AI, agents for software dev, safety/guardrails (Anthropic RSP) — videos public |
| MIT 6.5940 (Fall 2024) | University course | Chapter II: Efficient LLM deployment, quantization, long-context — slides + videos public |
| Chip Huyen "Designing ML Systems" | Book | RAG design, monitoring, production — O'Reilly |
| Raschka "Build an LLM from Scratch" | Book | Implementation depth — Manning 2024 |

---

## design-observability

| Source | Type | Content |
|---|---|---|
| Google SRE Book (Beyer et al.) | Book (free) | SLO/SLI, error budgets, monitoring, on-call, incident management — sre.google/sre-book |
| The Site Reliability Workbook | Book (free) | SLO/error-budget-policy implementation — sre.google/workbook |
| Observability Engineering (Majors/Fong-Jones) | Book | Distributed tracing, structured logging, 3 pillars — O'Reilly 2022 |
| MIT 6.5840 — Distributed Systems | University course | Fault tolerance, consistency, linearizability — pdos.csail.mit.edu/6.824 |
| CMU 18-749 — Building Reliable Distributed Systems | University course | Replication, failure detection, incident case studies — courses.ece.cmu.edu/18749 |

---

## design-cicd

| Source | Type | Content |
|---|---|---|
| "Accelerate" (Forsgren/Humble/Kim) | Book | DORA metrics empirically validated, trunk-based dev, CD as predictor — IT Revolution 2018 |
| "Continuous Delivery" (Humble/Farley) | Book | Deployment pipeline architecture, release strategies, environment design — Addison-Wesley 2010 |
| DORA State of DevOps Report 2024 | Report (free) | Current metrics, 24 DevOps capabilities — dora.dev |
| CMU 17-636 — DevOps: Engineering for Secure Development | University course | Cloud infrastructure, containers, monitoring — mse.s3d.cmu.edu |

---

## tool-a11y

| Source | Type | Content |
|---|---|---|
| W3C WCAG 2.2 | Standard (free) | 78 success criteria A/AA/AAA, normative — w3.org/WAI/WCAG22 |
| W3C WAI Digital Accessibility Foundations | Course (free, edX) | WCAG, disability types, AT, design integration — w3.org/WAI/courses/foundations-course |
| EU EN 301 549 | Standard (free) | European standard, maps to WCAG — relevant for EU Accessibility Act (from June 2025) |
| CMU HCII 05-332/632 — Introduction to Accessibility | University course | Disability studies, web accessibility, assistive technologies — hcii.cmu.edu |

---

## design-iac

| Source | Type | Content |
|---|---|---|
| Kief Morris "Infrastructure as Code" | Book | Tool-agnostic design principles: dynamic infrastructure, snowflake anti-pattern, drift, GitOps, testing — O'Reilly 2nd ed. 2021 |
| Yevgeniy Brikman "Terraform: Up & Running" | Book | Module design, state management, Terratest — O'Reilly 3rd ed. 2022 |
| NTNU IIKG3005 — Infrastructure as Code | University course | 7.5 ECTS, IaC concepts, tool selection, version control for infra — ntnu.edu/studies/courses/IIKG3005 |

---

## tool-perf

| Source | Type | Content |
|---|---|---|
| Brendan Gregg "Systems Performance" | Book | USE method, flamegraphs, profiling methodology, Linux perf tools — Addison-Wesley 2nd ed. 2020 |
| MIT 6.172 — Performance Engineering of Software Systems | University course (free) | Bentley rules (Lec 2), measurement & timing (Lec 10), caching (Lec 14) — fully on OCW |
| CMU 15-721 — Advanced Database Systems (Spring 2024) | University course (free) | Query execution, vectorized execution, optimizer — 15721.courses.cs.cmu.edu |

---

## design-migration

| Source | Type | Content |
|---|---|---|
| Martin Fowler — Patterns (bliki) | Blog/Patterns | Strangler fig, branch by abstraction, expand-contract, blue-green, feature toggles — martinfowler.com |
| Kleppmann "Designing Data-Intensive Applications" | Book | Ch. 4: Schema evolution, forward/backward compatibility; Ch. 11: Dual-write, CDC, event log — O'Reilly 2017 |
| MIT 6.5840 — Distributed Systems | University course | Two-phase commit, CAP theorem, consistency — pdos.csail.mit.edu/6.824 |
| Chris Richardson — Saga Pattern | Pattern reference | Choreography vs. orchestration saga — microservices.io/patterns/data/saga |

---

## Existing Skills (v1.0.0)

| Skill | Primary Source |
|---|---|
| design-secure | TU Graz ISEC + Stanford CS255/CS355 + MIT 6.566 |
| design-data | CMU 15-445 (Andy Pavlo) — 15445.courses.cs.cmu.edu |
| design-api | CMU 17-625 + Google API Design Guide |
| design-ux | CMU HCII + Stanford CS247A + HAX/PAIR/CHI 2024 |
| review-arch | CMU 17-633 (David Garlan) |
| review-app | OWASP ASVS 5.0 + DORA |

---

## Research Methodology for New Skills

**Approach:** Universities with public syllabi → fetch course descriptions → build content on course logic → `references/curriculum-mapping.md` maps each skill step to a concrete source.

**Exception:** When industry books are better than university courses (SRE, CI/CD), books are used as the primary source.

**Course directories:**
- MIT OCW: ocw.mit.edu (many courses fully public)
- CMU SCS: csd.cmu.edu/course-profiles
- Stanford: explorecourses.stanford.edu
- NTNU: ntnu.edu/studies/courses
- TU Graz: online.tugraz.at
