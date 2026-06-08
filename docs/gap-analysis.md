# Gap Analysis — dev-best-practices

Stand: 2026-06-08

## Strukturelle Bugs (Quick Fixes)

| Problem | Impact |
|---|---|
| `commands/design-ux.md` fehlt | Slash-Command-Discovery findet `/dev:design-ux` nicht |
| `commands/review-ux.md` fehlt | Slash-Command-Discovery findet `/dev:review-ux` nicht |
| Skill-Count-Drift: README/plugin.json = "17", commands/ = 15 | Inkonsistente Kommunikation nach außen |

---

## Inhaltliche Lücken + Akademische Verankerung

| Bereich | Prio | Inhalt | Akademische Basis (verifiziert) | Kanonische Bücher / Besser als jeder Kurs |
|---|---|---|---|---|
| **AI/LLM Engineering** | Hoch | Prompt Engineering, RAG-Design, Evals, Guardrails, Tool-Use/Agents, Token-Budget, Halluzinations-Handling, Fine-Tuning-Entscheidung, Inference-Optimierung | Stanford CS224N (RAG, Agents, Evals, PEFT/LoRA, RLHF/DPO — Yang/Choi); CMU 11-667 (Methods & Applications — Savelka/Kim); Berkeley CS294-196 (LLM Agents — Song/Chen, inkl. Anthropic/OpenAI Guest Lectures); MIT 6.5940 (Efficient LLM Deployment / Inference — Song Han) | Sebastian Raschka "Build an LLM from Scratch" (Manning 2024); Chip Huyen "Designing ML Systems" (O'Reilly); Lewis et al. (2020) RAG Paper (kanonisch) |
| **design-observability** | Mittel | Observability-Architektur: SLO/SLI/Error-Budget, Distributed Tracing, Metriken-Design, Alert-Strategie, Incident Response, On-Call-Design | CMU 18-749 (Building Reliable Distributed Systems — Narasimhan); MIT 6.5840 (Distributed Systems — Morris/Kaashoek) | **Google SRE Book** (Beyer et al., free: sre.google); **The Site Reliability Workbook** (Beyer et al., free); **"Observability Engineering"** (Majors/Fong-Jones, O'Reilly 2022) — Bücher sind hier definitiv besser als jeder Uni-Kurs |
| **design-cicd** | Mittel | Pipeline-Architektur, Deployment-Strategien (Blue-Green, Canary, Feature Flags), Environment-Design, DORA-Metriken, Trunk-Based Development | CMU 17-636 DevSecOps (S3D); UC Berkeley Info 290M (Jez Humble — co-Autor "Accelerate") | **"Continuous Delivery"** (Humble/Farley, Addison-Wesley 2010); **"Accelerate"** (Forsgren/Humble/Kim, IT Revolution 2018); DORA State of DevOps Report 2024 (free: dora.dev) — Industrie-Bücher sind definitiv besser |
| **tool-a11y** | Mittel | WCAG 2.2 Audit-Workflow, axe-core Integration, Screen-Reader-Testing (NVDA, JAWS, VoiceOver), Keyboard-Navigation, EU Accessibility Act / EN 301 549 | CMU HCII 05-332/632 (Intro to Accessibility & Assistive Technology — Carrington); W3C WAI Digital Accessibility Foundations (edX, 16-20h, gratis) | W3C WAI Curricula Framework (w3.org/WAI/curricula/); Deque University (WCAG 2.2 + Audit-Methodik); EU EN 301 549 (Normativ für EU Accessibility Act) |
| **Infrastructure as Code** | Niedrig | IaC Design-Prinzipien, Modul-Design, State-Management, Drift-Detection, Terratest, GitOps | NTNU IIKG3005 (einziger dedizierter akademischer Kurs weltweit — Skjerven/Melling/Lin); ETH Zürich Cloud Computing (Klimovic) deckt IaC nicht ab | **"Infrastructure as Code"** (Kief Morris, O'Reilly 2021, nicht tool-spezifisch); **"Terraform: Up & Running"** (Brikman, O'Reilly 3rd ed. 2022) |
| **Performance / Load Testing** | Niedrig | Performance-Testing-Methodik, Profiling-Strategie, Bottleneck-Analyse, Queuing-Theorie, Flamegraphs, Kapazitätsplanung | MIT 6.172 (Performance Engineering — Leiserson/Shun, **vollständig auf OCW**); CMU 15-721 (Advanced DB Systems — Andy Pavlo, **alle Videos public**); UT Austin CS395T (Performance Analysis of Networked Systems — Venkat Arun) | **"Systems Performance"** (Brendan Gregg, 2nd ed. 2020, Addison-Wesley) — Gregg's USE Method + Flamegraphs sind der Industriestandard |
| **design-migration vertiefen** | Niedrig | Schema-Migration-Safety, Dual-Write, Event-Replay, Rollback | Bereits: Fowler + MIT 6.5840. Ergänzen: Kleppmann "Designing Data-Intensive Applications" | Martin Kleppmann "Designing Data-Intensive Applications" (O'Reilly) |

### Korrekturen gegenüber erster Einschätzung

- `MIT 6.S965` ist **nicht** ein LLM-Kurs — das ist TinyML/Efficient DL (Song Han). Korrekte Nummer: `MIT 6.5940`
- `CMU 17-814` als SRE-Kurs existiert nicht im aktuellen CMU-Katalog → ersetzt durch `CMU 18-749`
- Für **SRE/Observability** und **CI/CD**: kein Uni-Kurs ist so gut wie die kanonischen Industrie-Bücher (Google SRE trilogy, Accelerate) — das ist für diese zwei Themen der Normalfall, nicht die Ausnahme

---

## Recherche-Methodik

So entstehen die akademischen Grundlagen für neue Skills — analog zu den bestehenden (CMU 17-625 → design-api, CMU 15-445 → design-data, TU Graz ISEC → design-secure):

### Schritt 1 — Universitäten mit starken Curricula identifizieren

**DACH + Europa:**
- TU Graz — [TUGRAZonline](https://online.tugraz.at)
- TU Wien — [TISS](https://tiss.tuwien.ac.at)
- ETH Zürich — [Course Catalogue](https://www.vorlesungsverzeichnis.ethz.ch)
- EPFL Lausanne
- NTNU Trondheim (stark in IaC/DevOps)
- LMU München, KIT Karlsruhe, Universität Wien

**UK:**
- University of Cambridge — Computer Science Tripos
- University of Oxford — CS Department
- Imperial College London
- University of Edinburgh

**USA (Top-Tier):**
- Stanford — [CS Courses](https://cs.stanford.edu/academics/courses)
- MIT — [OCW](https://ocw.mit.edu) + [Course Catalog](https://student.mit.edu/catalog)
- CMU — [SCS Course Listings](https://csd.cmu.edu/course-profiles)
- UC Berkeley — [CS Courses](https://www2.eecs.berkeley.edu/Courses/CS/)
- Caltech, Harvard, Princeton, Cornell, UW Paul G. Allen School, UT Austin

### Schritt 2 — Lehrveranstaltungsbeschreibungen fetchen

1. Kursverzeichnis öffnen, relevante Kursnummern identifizieren
2. Kursbeschreibung + Syllabus fetchen: Lernziele, Themenübersicht, Literaturliste
3. Öffentlich zugängliche Materialien prüfen: MIT OCW, Stanford Engineering Everywhere, CMU-öffentliche Slides/Videos
4. Prüfen: Deckt der Kurs die benötigte Tiefe ab? Korrektheit der Kursnummer verifizieren (MIT/CMU renumbern regelmäßig)

### Schritt 3 — Inhalte aufbauen

Analog zu den bestehenden Skills:
- Skill-Beschreibung verankert explizit den Kurs (`grounded in CMU 17-625`)
- Workflow-Schritte folgen der Kurs-Logik
- `references/curriculum-mapping.md` mappt jeden Inhaltspunkt auf konkrete Lehrveranstaltung oder Buch-Kapitel
- Externe Links zeigen auf öffentliche Kurs-URLs (Slides, OCW, Syllabus)
- **Ausnahme:** Wenn Industrie-Bücher besser sind als Uni-Kurse (SRE, CI/CD), werden Bücher als primäre Quelle verwendet — mit Angabe von Kapitel und Seite

### Qualitätsanker — bestehende Verankerungen als Maßstab

| Skill | Primäre Quelle | Typ |
|---|---|---|
| design-secure | TU Graz ISEC + Stanford CS255/CS355 + MIT 6.566 | Uni-Kurse |
| design-data | CMU 15-445 (Andy Pavlo) | Uni-Kurs |
| design-ux | CMU HCII + Stanford CS247A + HAX/PAIR/CHI2024 | Uni + Frameworks |
| review-arch | CMU 17-633 (David Garlan) | Uni-Kurs |
| review-secure | TU Graz ISEC + Stanford CS255/CS355 + CMU 15-414 | Uni-Kurse |
| review-app | OWASP ASVS 5.0 + DORA | Industrie-Standards |

---

## Stärken (zur Orientierung)

- Security (ASVS 5.0, STRIDE, Crypto) — sehr gut
- Architektur (CMU 17-633, Fowler) — gut
- API Design (CMU 17-625, Google API Guide) — gut
- Human-AI Interaction (HAX/PAIR/CHI/NNG) — einzigartig
- Drei-Schichten-Struktur (reference → rules → skills) — besser als alle Community-Alternativen
- Mirror-Sync + Drift-Detection (meta-sync/meta-drift) — gibt's sonst nirgends
