# Gap Analysis — dev-best-practices

Stand: 2026-06-08 | Zuletzt aktualisiert: 2026-06-08

## Strukturelle Bugs (Quick Fixes)

| Problem | Impact | Status |
|---|---|---|
| `commands/design-ux.md` fehlt | Slash-Command-Discovery findet `/dev:design-ux` nicht | ✅ Behoben |
| `commands/review-ux.md` fehlt | Slash-Command-Discovery findet `/dev:review-ux` nicht | ✅ Behoben |
| Skill-Count-Drift: README/plugin.json = "17", commands/ = 15 | Inkonsistente Kommunikation nach außen | ✅ Behoben (plugin.json = 19, commands/ = 20 inkl. meta-help) |

## Trigger-Qualität (Skill Discovery)

| Problem | Betroffene Skills | Status |
|---|---|---|
| Overlap-Dreieck ohne Abgrenzung | `review-app`, `review-arch`, `review-secure` | ✅ Behoben — review-app erklärt Abgrenzung explizit |
| Fehlende deutsche Trigger | `review-arch`, `review-secure` | ✅ Behoben — deutsche Trigger-Zeilen ergänzt |
| Meta-Skill ohne Scope-Guard | `meta-sync` | ✅ Behoben — "nur für dev-best-practices Repo" ergänzt |

---

## Inhaltliche Lücken + Akademische Verankerung

| Bereich | Skill | Prio | Status | Akademische Basis (verifiziert) | Kanonische Bücher |
|---|---|---|---|---|---|
| **AI/LLM Engineering** | `design-llm` + `review-llm` | Hoch | ✅ Erledigt (#14) | Stanford CS224N; CMU 11-667; Berkeley CS294-196; MIT 6.5940 | Chip Huyen "Designing ML Systems"; Raschka "Build an LLM from Scratch" |
| **Observability / SRE** | `design-observability` | Mittel | ✅ Erledigt | CMU 18-749; MIT 6.5840 | Google SRE Book (free); Site Reliability Workbook (free); "Observability Engineering" (Majors/Fong-Jones) |
| **CI/CD Pipeline Design** | `design-cicd` | Mittel | ✅ Erledigt | CMU 17-636; Jez Humble (Berkeley) | "Continuous Delivery" (Humble/Farley); "Accelerate" (Forsgren/Humble/Kim); DORA Report 2024 (free) |
| **Accessibility** | `tool-a11y` | Mittel | ✅ Erledigt | CMU HCII 05-332/632; W3C WAI Digital Foundations (edX) | WCAG 2.2 (normativ, free); EU EN 301 549 |
| **Infrastructure as Code** | `design-iac` | Niedrig | 🔲 Offen | NTNU IIKG3005 (einziger dedizierter Kurs weltweit) | "Infrastructure as Code" (Kief Morris); "Terraform: Up & Running" (Brikman) |
| **Performance Engineering** | `tool-perf` | Niedrig | 🔲 Offen | MIT 6.172 (vollständig auf OCW); CMU 15-721; UT Austin CS395T | "Systems Performance" (Brendan Gregg) — USE Method + Flamegraphs |
| **design-migration vertiefen** | `design-migration` | Niedrig | 🔲 Offen | Bereits: Fowler + MIT 6.5840 | Kleppmann "Designing Data-Intensive Applications" |

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
- ETH Zürich — [Course Catalogue](https://www.vvz.ethz.ch)
- EPFL Lausanne
- NTNU Trondheim (stark in IaC/DevOps)
- LMU München, KIT Karlsruhe, Universität Wien

**UK:**
- University of Cambridge — Computer Science Tripos
- University of Oxford — CS Department
- Imperial College London
- University of Edinburgh

**USA (Top-Tier):**
- Stanford — [CS Courses](https://explorecourses.stanford.edu)
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
