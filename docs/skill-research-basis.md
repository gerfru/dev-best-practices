# Academic & Industry Sources — Dev Skills

Kanonische Quellen pro Skill. Massgeblich fuer:
- Verifikation akademischer Verankerung bei neuen Skills
- Nachschlagen von Kurs-Nummern und Literaturangaben
- Orientierung beim Ausbauen bestehender Skills

---

## design-llm + review-llm

| Quelle | Typ | Inhalt |
|---|---|---|
| Stanford CS224N (Winter 2026) | Uni-Kurs | Lectures 7–11: Post-training, PEFT/LoRA, RAG, Agents, Evaluation — Slides oeffentlich |
| CMU 11-667 (Spring 2026) | Uni-Kurs | Prompting, Finetune-Entscheidung, RAG (3 Lectures), Tool-Use, Multi-Agent, Deployment — Slides oeffentlich |
| Berkeley CS294-196 (Fall 2024) | Gastvortraege | Compound AI, Agents for Software Dev, Safety/Guardrails (Anthropic RSP) — Videos oeffentlich |
| MIT 6.5940 (Fall 2024) | Uni-Kurs | Chapter II: Efficient LLM Deployment, Quantization, Long-Context — Slides + Videos oeffentlich |
| Chip Huyen "Designing ML Systems" | Buch | RAG-Design, Monitoring, Production — O'Reilly |
| Raschka "Build an LLM from Scratch" | Buch | Implementation-Tiefe — Manning 2024 |

---

## design-observability

| Quelle | Typ | Inhalt |
|---|---|---|
| Google SRE Book (Beyer et al.) | Buch (frei) | SLO/SLI, Error Budgets, Monitoring, On-Call, Incident Management — sre.google/sre-book |
| The Site Reliability Workbook | Buch (frei) | SLO/Error-Budget-Policy Implementierung — sre.google/workbook |
| Observability Engineering (Majors/Fong-Jones) | Buch | Distributed Tracing, Structured Logging, 3 Pillars — O'Reilly 2022 |
| MIT 6.5840 — Distributed Systems | Uni-Kurs | Fault Tolerance, Consistency, Linearizability — pdos.csail.mit.edu/6.824 |
| CMU 18-749 — Building Reliable Distributed Systems | Uni-Kurs | Replikation, Failure Detection, Incident Case Studies — courses.ece.cmu.edu/18749 |

---

## design-cicd

| Quelle | Typ | Inhalt |
|---|---|---|
| "Accelerate" (Forsgren/Humble/Kim) | Buch | DORA-Metriken empirisch belegt, Trunk-Based Dev, CD als Praediktor — IT Revolution 2018 |
| "Continuous Delivery" (Humble/Farley) | Buch | Deployment-Pipeline-Architektur, Release-Strategien, Environment-Design — Addison-Wesley 2010 |
| DORA State of DevOps Report 2024 | Report (frei) | Aktuelle Metriken, 24 DevOps-Capabilities — dora.dev |
| CMU 17-636 — DevOps: Engineering for Secure Development | Uni-Kurs | Cloud-Infrastruktur, Container, Monitoring — mse.s3d.cmu.edu |

---

## tool-a11y

| Quelle | Typ | Inhalt |
|---|---|---|
| W3C WCAG 2.2 | Standard (frei) | 78 Success Criteria A/AA/AAA, normativ — w3.org/WAI/WCAG22 |
| W3C WAI Digital Accessibility Foundations | Kurs (frei, edX) | WCAG, Disability-Typen, AT, Design-Integration — w3.org/WAI/courses/foundations-course |
| EU EN 301 549 | Norm (frei) | Europaeischer Standard, mappt auf WCAG — relevant fuer EU Accessibility Act (ab Juni 2025) |
| CMU HCII 05-332/632 — Introduction to Accessibility | Uni-Kurs | Disability Studies, Web Accessibility, Assistive Technologies — hcii.cmu.edu |

---

## design-iac

| Quelle | Typ | Inhalt |
|---|---|---|
| Kief Morris "Infrastructure as Code" | Buch | Design-Prinzipien tool-agnostisch: Dynamic Infrastructure, Snowflake Anti-Pattern, Drift, GitOps, Testing — O'Reilly 2nd ed. 2021 |
| Yevgeniy Brikman "Terraform: Up & Running" | Buch | Modul-Design, State Management, Terratest — O'Reilly 3rd ed. 2022 |
| NTNU IIKG3005 — Infrastructure as Code | Uni-Kurs | 7.5 ECTS, IaC-Konzepte, Tool-Auswahl, Versionskontrolle fuer Infra — ntnu.edu/studies/courses/IIKG3005 |

---

## tool-perf

| Quelle | Typ | Inhalt |
|---|---|---|
| Brendan Gregg "Systems Performance" | Buch | USE Method, Flamegraphs, Profiling-Methodik, Linux Perf Tools — Addison-Wesley 2nd ed. 2020 |
| MIT 6.172 — Performance Engineering of Software Systems | Uni-Kurs (frei) | Bentley Rules (Lec 2), Measurement & Timing (Lec 10), Caching (Lec 14) — vollstaendig auf OCW |
| CMU 15-721 — Advanced Database Systems (Spring 2024) | Uni-Kurs (frei) | Query Execution, Vectorized Execution, Optimizer — 15721.courses.cs.cmu.edu |

---

## design-migration

| Quelle | Typ | Inhalt |
|---|---|---|
| Martin Fowler — Patterns (bliki) | Blog/Patterns | Strangler Fig, Branch by Abstraction, Expand-Contract, Blue-Green, Feature Toggles — martinfowler.com |
| Kleppmann "Designing Data-Intensive Applications" | Buch | Kap. 4: Schema Evolution, Forward/Backward Compatibility; Kap. 11: Dual-Write, CDC, Event Log — O'Reilly 2017 |
| MIT 6.5840 — Distributed Systems | Uni-Kurs | Two-Phase Commit, CAP Theorem, Consistency — pdos.csail.mit.edu/6.824 |
| Chris Richardson — Saga Pattern | Pattern-Referenz | Choreography vs. Orchestration Saga — microservices.io/patterns/data/saga |

---

## Bestehende Skills (v1.0.0)

| Skill | Primärquelle |
|---|---|
| design-secure | TU Graz ISEC + Stanford CS255/CS355 + MIT 6.566 |
| design-data | CMU 15-445 (Andy Pavlo) — 15445.courses.cs.cmu.edu |
| design-api | CMU 17-625 + Google API Design Guide |
| design-ux | CMU HCII + Stanford CS247A + HAX/PAIR/CHI 2024 |
| review-arch | CMU 17-633 (David Garlan) |
| review-app | OWASP ASVS 5.0 + DORA |

---

## Recherche-Methodik fuer neue Skills

**Vorgehen:** Universitaeten mit oeffentlichen Syllabi → Lehrveranstaltungsbeschreibungen fetchen → Inhalte auf Kurs-Logik aufbauen → `references/curriculum-mapping.md` mappt jeden Skill-Schritt auf konkrete Quelle.

**Ausnahme:** Wenn Industrie-Buecher besser sind als Uni-Kurse (SRE, CI/CD), werden Buecher als Primaerquelle verwendet.

**Kurs-Verzeichnisse:**
- MIT OCW: ocw.mit.edu (viele Kurse vollstaendig oeffentlich)
- CMU SCS: csd.cmu.edu/course-profiles
- Stanford: explorecourses.stanford.edu
- NTNU: ntnu.edu/studies/courses
- TU Graz: online.tugraz.at
