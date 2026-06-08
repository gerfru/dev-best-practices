# Akademische Basis — Neue Skills

Stand: 2026-06-08 | Alle Kurs-URLs verifiziert und Inhalte gefetched.

---

## Topic 1: AI / LLM Engineering → `design-llm` + `review-llm`

### Stanford CS224N — Natural Language Processing with Deep Learning (Winter 2026)

**Professoren:** Diyi Yang, Yejin Choi (früher: Christopher Manning)
**URL:** https://web.stanford.edu/class/cs224n/
**Slides:** Öffentlich (PDFs per Lecture auf der Course-Page)

| Datum | Lecture |
|---|---|
| Jan 6 | History of NLP |
| Jan 8 | Word Vectors |
| Jan 13 | Backpropagation and Neural Network Basics |
| Jan 15 | Language Models and RNNs |
| Jan 20 | Transformers |
| Jan 22 | Final Projects: Practical Tips |
| Jan 27 | **Pretraining (Scaling, Systems, Data)** |
| Jan 29 | **Post-training (RLHF, SFT, DPO)** |
| Feb 3 | **Efficient Adaptation (Prompting + PEFT / LoRA)** |
| Feb 5 | **Agents, Tool Use, and RAG** |
| Feb 10 | **Benchmarking and Evaluation** |
| Feb 12 | Reasoning 1 |
| Feb 17 | Reasoning 2 |
| Feb 19 | Guest: Tokenization and Multilinguality (Julie Kallini) |
| Feb 24 | Guest: Interpretability (Been Kim) |
| Feb 26 | Social and Broader Impacts of NLP (Risks) |
| Mar 3 | Guest: Multimodality (Luke Zettlemoyer) |
| Mar 5 | Guest: LoRA and Fine-tuning (John Schulman) |
| Mar 10 | Open Questions in NLP 2026 |

**Für design-llm relevant:** Lectures 7–11 (Post-training, PEFT, RAG, Agents, Evaluation)

---

### CMU 11-667 — Large Language Models: Methods and Applications (Spring 2026)

**URL:** https://cmu-llms.org/schedule/
**Slides:** Öffentlich (Google Cloud Storage PDFs)

| Datum | Lecture |
|---|---|
| Jan 13 | Origins of LLMs |
| Jan 15 | Natural language understanding vs. generation |
| Jan 20 | **The science of prompting** |
| Jan 22 | **Deciding when to finetune and finetuning efficiently** |
| Jan 27 | Learning representations and embeddings |
| Jan 29 | **Retrieval 1: Storing and retrieving knowledge** |
| Feb 3 | **Retrieval 2: RAG and deep research** |
| Feb 5 | **Retrieval 3: RAG and deep research (continued)** |
| Feb 10 | Deep research |
| Feb 12 | Task-Oriented Dialogue |
| Feb 17 | **Tool-use, chitchat, personas, and companionship** |
| Feb 19 | Writing and ideation assistants |
| Feb 24 | **LLMs for evaluation: Synthetic data, simulation, AI-as-judge** |
| Feb 26 | **Multi-agent systems** |
| Mar 10 | **Harms caused by LLM applications** |
| Mar 12 | **Attacking LLMs and LLM applications** |
| Mar 17 | Code-writing assistants (guest: Zora Wang) |
| Apr 7 | Numbers |
| Apr 16 | **Deployment** |

**Für design-llm relevant:** Prompting, Finetune-Entscheidung, RAG (3 Lectures), Tool-Use, Multi-Agent, Deployment, Evaluation

---

### Berkeley CS294/194-196 — Large Language Model Agents (Fall 2024)

**Instructor:** Dawn Song (UC Berkeley) — Gastvortragsformat
**URL:** https://rdi.berkeley.edu/llm-agents/f24
**Slides + Videos:** Öffentlich (PDFs + YouTube per Lecture)

| Datum | Lecture | Speaker | YouTube |
|---|---|---|---|
| Sep 9 | LLM Reasoning | Denny Zhou (Google DeepMind) | https://youtu.be/QL-FS_Zcmyo |
| Sep 16 | LLM Agents: Brief History and Overview | Shunyu Yao (OpenAI) | https://youtu.be/RM6ZArd2nVc |
| Sep 23 | Agentic AI Frameworks & AutoGen / Multimodal Knowledge Assistant | Chi Wang + Jerry Liu (LlamaIndex) | https://youtu.be/OOdtmCMSOo4 |
| Sep 30 | Enterprise Trends for Generative AI | Burak Gokturk (Google) | https://youtube.com/live/Sy1psHS3w3I |
| Oct 7 | **Compound AI Systems & the DSPy Framework** | Omar Khattab (Databricks) | https://youtube.com/live/JEMYuzrKLUw |
| Oct 14 | **Agents for Software Development** | Graham Neubig (CMU) | https://youtube.com/live/f9L9Fkq-8K4 |
| Oct 21 | AI Agents for Enterprise Workflows | Nicolas Chapados (ServiceNow) | https://youtube.com/live/-yf-e-9FvOc |
| Oct 28 | Neural & Symbolic Decision Making | Yuandong Tian (Meta AI) | https://youtube.com/live/wm9-7VBpdEo |
| Nov 4 | Project GR00T: Generalist Robotics | Jim Fan (NVIDIA) | https://youtube.com/live/Qhxr0uVT2zs |
| Nov 18 | Open-Source and Science in Foundation Models | Percy Liang (Stanford) | https://youtube.com/live/f3KKx9LWntQ |
| Nov 25 | **Measuring Agent Capabilities + Anthropic's RSP** | Ben Mann (Anthropic) | https://youtube.com/live/6y2AnWol7oo |
| Dec 2 | **Safe & Trustworthy AI Agents** | Dawn Song (UC Berkeley) | https://youtube.com/live/QAgR4uQ15rc |

**Für design-llm relevant:** Compound AI Systems, Agents for Software Development, Safety/Guardrails (Anthropic RSP), Evaluation

---

### MIT 6.5940 — TinyML and Efficient Deep Learning Computing (Fall 2024)

**Professor:** Song Han
**URL:** https://hanlab.mit.edu/courses/2024-fall-65940
**Slides + Videos:** Öffentlich (Dropbox + YouTube)

LLM-spezifisches Kapitel (Chapter II):

| # | Datum | Lecture |
|---|---|---|
| 12 | Oct 17 | **Transformer and LLM** |
| 13 | Oct 22 | **Efficient LLM Deployment** |
| 14 | Oct 24 | **LLM Post Training (Quantization etc.)** |
| 15 | Oct 29 | **Long Context LLM** |

**Für design-llm relevant:** Inference-Optimierung, Quantization, Long-Context-Handling, Deployment-Tradeoffs

---

### Kanonische Bücher — AI/LLM Engineering

| Buch | Autor | Verlag | Relevanz |
|---|---|---|---|
| Build a Large Language Model from Scratch | Sebastian Raschka | Manning, 2024 | Implementation-Tiefe |
| Designing Machine Learning Systems | Chip Huyen | O'Reilly | Produktion, RAG-Design, Monitoring |
| Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks | Lewis et al. (2020) | arXiv:2005.11401 | RAG — kanonisches Originalpaper |

---

## Topic 2: Observability / SRE → `design-observability`

**Kernaussage:** Kein Uni-Kurs erreicht die Qualität der Google SRE-Bücher für dieses Thema. Bücher sind hier die primäre Quelle.

### MIT 6.5840 — Distributed Systems (Spring 2026)

**Professoren:** Robert Morris, Frans Kaashoek (Guest: Russ Cox)
**URL:** https://pdos.csail.mit.edu/6.824/schedule.html
**Materials:** Lecture Notes (.txt) + Papers öffentlich

| # | Lecture | Relevanz für Observability |
|---|---|---|
| 1 | Introduction to MapReduce | Grundlage verteilter Systeme |
| 4 | Paxos | Konsistenz-Grundlage |
| 6–7 | Fault Tolerance: Raft (1 & 2) | Fehlertoleranz-Mechanismen |
| 8 | Consistency and Linearizability | Konsistenzmodelle |
| 11 | Distributed Transactions | ACID in verteilten Systemen |
| 15 | Verification of Distributed Systems | Formale Verifikation |
| 16 | Cache Consistency: Memcached at Facebook | Caching in Produktion |
| 17 | AWS Lambda (Marc Brooker, Amazon) | Serverless Reliability |

**Einschränkung:** Kein SLO/SLI/Error-Budget, kein Incident-Response, kein Alerting-Design.

### CMU 18-749 — Building Reliable Distributed Systems

**URL:** https://courses.ece.cmu.edu/18749
**Materials:** Nicht öffentlich (kein Syllabus abrufbar)

**Abgedeckte Themen (Kursbeschreibung):**
- Fault-tolerant Design: Replikation, Group Communication, Datenbanken
- Fault-Recovery: Detection, Logging, Checkpointing, Failure Diagnosis
- Fault-Klassen: Crashes, Communication Errors, Software Upgrades
- Real-world Incident Case Studies (large-scale downtime)
- Cloud-Computing-Platform Reliability
- Projekt: Design + Implementierung + empirische Evaluation eines zuverlässigen Systems

### Kanonische Bücher — Observability / SRE

Diese Bücher sind definitiv besser als jeder Uni-Kurs für dieses Thema:

| Buch | Autor | Verlag | Relevanz | Frei? |
|---|---|---|---|---|
| Site Reliability Engineering | Beyer, Jones, Petoff, Murphy | O'Reilly, 2016 | SLO/SLI, Error Budgets, Monitoring, On-Call, Incident Management | ✅ sre.google/sre-book |
| The Site Reliability Workbook | Beyer et al. | O'Reilly, 2018 | Implementierung von SLO/Error-Budget-Policies | ✅ sre.google/workbook |
| Building Secure & Reliable Systems | Google | O'Reilly, 2020 | Reliability als Design-Eigenschaft | ✅ sre.google/books |
| Observability Engineering | Charity Majors, Liz Fong-Jones, George Miranda | O'Reilly, 2022 | Distributed Tracing, Structured Logging, 3 Pillars in Praxis | ❌ Kauf |

---

## Topic 3: CI/CD Pipeline Design → `design-cicd`

**Kernaussage:** Wie bei SRE — Industrie-Bücher (insbes. "Accelerate") sind besser als jeder Uni-Kurs.

### CMU 17-636 — DevOps: Engineering for Secure Development and Deployment

**URL:** https://mse.s3d.cmu.edu/applicants/course-offerings.html (Suche: 17-636)
**Materials:** Nicht öffentlich

**Abgedeckte Themen:**
- Cloud-Infrastruktur und Container-Management (Docker, Kubernetes)
- Virtual Machines, Container, Netzwerke
- Internet Security Mechanisms, Credential Management
- Produktions-Monitoring durch Log Collection und Analyse
- Case Studies: MLOps und regulierte Umgebungen

**Einschränkung:** Kein DORA-Metrics-Framework, kein Trunk-Based-Development, kein Deployment-Strategy-Design (Blue-Green, Canary, Feature Flags) als explizite Themen.

### UC Berkeley / Jez Humble — LAPM (Lean/Agile Product Management)

**Status:** Domain `lapm.continuousdelivery.com` zum Zeitpunkt der Recherche nicht erreichbar (refused connection). Kurs möglicherweise eingestellt.

**Inhalt bekannt aus:** Jez Humble's Bücher (unten), die das gleiche Material abdecken.

### Kanonische Bücher — CI/CD

| Buch | Autor | Verlag | Relevanz | Frei? |
|---|---|---|---|---|
| Continuous Delivery | Jez Humble, David Farley | Addison-Wesley, 2010 | Deployment-Pipeline-Architektur, Release-Strategien, Environment-Design | ❌ |
| Accelerate | Forsgren, Humble, Kim | IT Revolution, 2018 | DORA-Metriken (empirisch belegt), Trunk-Based-Dev, CD als Prädiktor | ❌ |
| The DevOps Handbook | Kim, Humble, Debois, Willis | IT Revolution, 2016 | Three Ways, praktische Implementierung | ❌ |
| DORA State of DevOps Report 2024 | DORA Research Team | Google | Aktuelle Metriken, 24 DevOps-Capabilities | ✅ dora.dev |

---

## Topic 4: Accessibility → `tool-a11y`

### CMU HCII 05-332 / 05-632 — Introduction to Accessibility and Assistive Technology

**Professor:** Patrick Carrington
**URL:** https://hcii.cmu.edu/course/introduction-accessibility-and-assistive-technology
**Materials:** Nicht öffentlich (12 Units, Herbstsemester)

**Abgedeckte Themen:**
- Accessibility-Theorie, Geschichte, Policy und Praxis in Computing
- Disability Studies und HCI-Perspektive
- Web Accessibility (insbes. Blind/Low-Vision)
- Designing für Hearing Loss, Motor Impairments, kognitive Einschränkungen, Neurodiversität
- Permanent / situational / temporary disabilities — universelles Design-Prinzip
- Assistive Technologies: TTS, Speech Recognition, OCR, Predictive Typing, Tactile Displays
- Wie Behinderung Mainstream-Technologien geprägt hat (Speech Recognition als AT-Ursprung)

### W3C WAI — Digital Accessibility Foundations (edX, gratis)

**URL:** https://www.w3.org/WAI/courses/foundations-course/
**Dauer:** 16–20 Stunden, selbst-getaktet. Verfügbar bis mindestens November 2026.
**Materials:** Öffentlich auf edX (kostenloser Audit)

| Modul | Sektionen | Inhalt |
|---|---|---|
| 1: What is Web Accessibility | 2 | Definitionen, Missverständnisse |
| 2: People and Digital Technology | 5 | Disability-Typen, Interaktion mit Assistive Technology, Videos: Low Vision, Text Wrapping |
| 3: Business Case and Benefits | 2 | Marktreichweite, rechtliches Risiko, Innovation |
| 4: Principles, Standards, and Checks | 5 | **WCAG-Anforderungen bis AAA**, Barrieren evaluieren, non-technische + technische Guidance, Headings/Motion-Videos |
| 5: Getting Started with Accessibility | 2 | Integration in Design-Prozess, Integration in Entwicklungsprozess |

### Normative Standards + Kanonische Quellen

| Quelle | Typ | Relevanz | Frei? |
|---|---|---|---|
| W3C WCAG 2.2 | Standard | Die normative Quelle — 78 Success Criteria in 3 Levels (A/AA/AAA) | ✅ w3.org/WAI/WCAG22 |
| W3C WAI Curricula on Web Accessibility | Framework | Modul-Struktur für Developer, Designer, Content Authors | ✅ w3.org/WAI/curricula/ |
| Deque University | Training | WCAG 2.2 spezifisch + Screen-Reader-Testing (NVDA, JAWS, VoiceOver) + Audit-Methodik | ❌ |
| EU EN 301 549 | Norm | Europäischer Standard, mappt auf WCAG — direkt relevant für EU Accessibility Act (ab Juni 2025) | ✅ |

---

## Topic 5: Infrastructure as Code → `design-iac`

### NTNU IIKG3005 — Infrastructure as Code

**URL:** https://www.ntnu.edu/studies/courses/IIKG3005
**Credits:** 7.5 ECTS | Sprache: Norwegisch
**Nächster Start:** Herbst 2026
**Materials:** Nicht öffentlich (Pflichtübungen + 3h Klausur)

**Learning Outcomes:**

*Wissen:*
- Infrastruktur-Management mit Software-Development-Prinzipien
- IaC-Konzepte und Tools
- Große Public-Cloud-Plattformen

*Fähigkeiten:*
- IT-Infrastruktur per Code provisionieren und verwalten
- Versionskontrolle für Infrastruktur
- Informierte Tool-Auswahl treffen
- Änderungen in Produktion über versionierte Repositories einbringen

*Kompetenzen:*
- DevOps-Philosophie und -Kultur
- IaC-Implementierungen troubleshooten

**Hinweis:** Einziger dedizierter akademischer Kurs zu IaC weltweit (ETH Zürich Cloud Computing deckt kein IaC ab).

### Kanonische Bücher — Infrastructure as Code

| Buch | Autor | Verlag | Relevanz | Frei? |
|---|---|---|---|---|
| Infrastructure as Code | Kief Morris | O'Reilly, 2nd ed. 2021 | Design-Prinzipien (tool-agnostisch): Dynamic Infrastructure, Drift, GitOps, Testing | ❌ |
| Terraform: Up & Running | Yevgeniy Brikman | O'Reilly, 3rd ed. 2022 | Terraform-spezifisch: Modul-Design, State Management, Terratest | ❌ |
| GitOps and Kubernetes | Yuen, Miell et al. | Manning, 2021 | GitOps als Operational Pattern über IaC | ❌ |

---

## Topic 6: Performance Engineering → `tool-perf`

### MIT 6.172 — Performance Engineering of Software Systems (Fall 2018)

**Professoren:** Charles Leiserson, Julian Shun
**URL:** https://ocw.mit.edu/courses/6-172-performance-engineering-of-software-systems-fall-2018/
**Materials:** Vollständig öffentlich auf MIT OCW — alle 23 Lectures, Slides (PDFs), Videos

| # | Lecture |
|---|---|
| 1 | Introduction and Matrix Multiplication |
| 2 | **Bentley Rules for Optimizing Work** |
| 3 | Bit Hacks |
| 4 | Assembly Language and Computer Architecture |
| 5 | C to Assembly |
| 6 | Multicore Programming |
| 7 | Races and Parallelism |
| 8 | Analysis of Multithreaded Algorithms |
| 9 | What Compilers Can and Cannot Do |
| 10 | **Measurement and Timing** |
| 11 | Storage Allocation |
| 12 | Parallel Storage Allocation |
| 13 | The Cilk Runtime System |
| 14 | **Caching and Cache-Efficient Algorithms** |
| 15 | Cache-Oblivious Algorithms |
| 16 | Nondeterministic Parallel Programming |
| 17 | Synchronization Without Locks |
| 18 | Domain Specific Languages and Autotuning |
| 19 | Leiserchess Codewalk |
| 20 | Speculative Parallelism & Leiserchess |
| 21 | Tuning a TSP Algorithm |
| 22 | Graph Optimization |
| 23 | High Performance in Dynamic Languages |

**Einschränkung:** Low-Level Perf (CPU, Cache, Parallelism). Kein Web-Scale Load Testing, kein Queuing-Theory, kein Capacity Planning.

---

### CMU 15-721 — Advanced Database Systems (Spring 2024)

**Professor:** Andy Pavlo
**URL:** https://15721.courses.cs.cmu.edu/spring2024/schedule.html
**Materials:** Alle Slides (PDFs) + Videos öffentlich

| # | Datum | Lecture |
|---|---|---|
| 01 | Jan 22 | Modern Analytical Database Systems |
| 02–03 | Jan 24–29 | **Data Formats & Encoding (I & II)** |
| 04–05 | Feb 5–7 | **Query Execution & Processing (I & II)** |
| 06 | Feb 12 | **Vectorized Query Execution** |
| 07 | Feb 14 | **Code Generation & Compilation** |
| 08 | Feb 19 | Scheduling & Coordination |
| 09 | Feb 21 | **Hash Join Algorithms** |
| 10 | Feb 26 | Multi-Way Join Algorithms |
| 11 | Mar 11 | Server-side Logic Execution |
| 12 | Mar 13 | Networking Protocols |
| 13–15 | Mar 18–25 | **Optimizer Implementation (I–III)** |
| 16 | Apr 1 | **Cost Models** |
| 17 | Apr 8 | System Analysis: Google Dremel/BigQuery |
| 18 | Apr 10 | System Analysis: Databricks/Spark |
| 19 | Apr 15 | System Analysis: Snowflake |
| 20 | Apr 17 | System Analysis: DuckDB |
| 21 | Apr 22 | System Analysis: Yellowbrick |
| 22 | Apr 24 | System Analysis: Amazon Redshift |

---

### UT Austin CS395T — Performance Analysis of Networked Systems (Spring 2024)

**Professor:** Venkat Arun
**URL:** https://www.cs.utexas.edu/~venkatar/performance_analysis_of_networked_systems.html
**Materials:** Canvas (nicht öffentlich)

| Lectures | Thema | Methoden |
|---|---|---|
| 1–3 | Switch Load Balancing | PIM, iSLIP, Valiant Load Balancing |
| 4–5 | Application Load Balancing | Power of Two Choices, Breakwater |
| 6–7 | Process Scheduling | Work Stealing, Linux Scheduler Analysis |
| 8–10 | Fairness | Alpha Fairness, Multi-Resource Fairness |
| 11–12 | Caching Policies | LRU Analysis |
| 13–15 | ML in Systems | Competitive Caching, Statistische Ansätze |
| 16–18 | Computational Complexity in Systems | Traffic Engineering, Optimization |
| 19–21 | **Congestion Control** | AIMD, Vegas, RCP, DCTCP |
| 22–26 | **Performance Verification & Abstractions** | fPerf, PIFO, Network Slicing |

### Kanonische Bücher — Performance Engineering

| Buch | Autor | Verlag | Relevanz | Frei? |
|---|---|---|---|---|
| Systems Performance: Enterprise and the Cloud | Brendan Gregg | Addison-Wesley, 2nd ed. 2020 | **USE Method, Flamegraphs, Profiling-Methodik, Linux Perf Tools** — besser als MIT 6.172 für applied performance | ❌ |
| The Art of Capacity Planning | John Allspaw | O'Reilly, 2008 | Capacity Planning Methodik | ❌ |

---

## Übersicht: Primärquellen pro Skill

| Skill | Primäre akademische Quelle | Kanonisches Buch |
|---|---|---|
| `design-llm` | Stanford CS224N + CMU 11-667 + Berkeley CS294-196 | Chip Huyen "Designing ML Systems" |
| `design-observability` | Google SRE Books (Industrie > Uni) | "Observability Engineering" (Majors/Fong-Jones) |
| `design-cicd` | "Accelerate" + DORA Research (Industrie > Uni) | "Continuous Delivery" (Humble/Farley) |
| `tool-a11y` | CMU HCII 05-332 + W3C WAI Digital Foundations | WCAG 2.2 (W3C, normativ) |
| `design-iac` | NTNU IIKG3005 | "Infrastructure as Code" (Kief Morris) |
| `tool-perf` | MIT 6.172 (vollständig auf OCW) | "Systems Performance" (Brendan Gregg) |
