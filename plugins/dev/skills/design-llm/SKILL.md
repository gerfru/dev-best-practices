---
name: design-llm
description: >
  LLM-System-Design auf Basis von Stanford CS224N (Yang/Choi), CMU 11-667
  (Savelka/Kim) und Chip Huyen "Designing ML Systems". Use this skill whenever
  the user needs to design an LLM-powered feature or system from scratch.
  Triggers: "RAG architecture", "should I fine-tune", "how do I build an agent",
  "prompt engineering strategy", "LLM guardrails", "evaluation strategy for LLM",
  "token budget", "hallucination handling", "inference optimization",
  "wie baue ich einen LLM-Workflow", "LLM in meine App einbauen",
  "welches LLM-Pattern", "RAG oder Fine-tuning". Covers: integration pattern
  selection (Prompting/RAG/Fine-tune/Agent), RAG architecture, evaluation design,
  production concerns (guardrails, cost, latency, observability).
  Always use this skill for LLM architecture decisions.
---

# LLM System Design Skill

Structured LLM system design grounded in Stanford CS224N, CMU 11-667, and
Chip Huyen "Designing ML Systems". Every recommendation explains the trade-off.

---

## Core Philosophy (CMU 11-667)

> "Start with prompting. Reach for RAG when knowledge is the bottleneck.
> Reach for fine-tuning when behavior is the bottleneck.
> Reach for agents when a single LLM call is not enough."
> — CMU 11-667 course principle

LLM architecture decisions are uniquely hard to reverse once data pipelines,
embeddings, and fine-tuning runs are in production.
Understand the bottleneck before choosing the pattern.

---

## Step 0 — System-Kontext klären

Vor dem Design etablieren:

1. **Was wird gebaut?** (Chatbot / Dokumenten-Q&A / Code-Assistent / Agent / Klassifikation)
2. **Wissens-Bottleneck oder Verhaltens-Bottleneck?**
   - Wissen fehlt (aktuelle Docs, proprietäre DB) → RAG
   - Verhalten muss konsistent angepasst sein (Stil, Format, Domänen-Vokabular) → Fine-tune
3. **Latenz-Budget?** (< 1s → kein multi-hop Agent / kein großes Modell ohne Caching)
4. **Kosten-Budget?** (Token-Kosten × erwartete Volume)
5. **Offline-Fähigkeit nötig?** (On-premise, GDPR-kritisch)
6. **Welche Daten existieren?** (Menge, Format, Qualität für RAG-Index oder Fine-tune)

---

## Step 1 — Integration-Pattern entscheiden

Lade `references/integration-patterns.md` — vollständige Entscheidungsmatrix.

**Schnellentscheidung:**

```text
Wissens-Bottleneck?  → RAG
Verhaltens-Bottleneck + >500 Beispiele?  → Fine-tune
Mehrere Schritte / externe Aktionen?  → Agent
Sonst:  → Prompting-only (starte immer hier)
```

Kombinationen sind häufig: RAG + Prompting, Agent + RAG.

---

## Step 2 — Architektur entwerfen

### Bei RAG: Lade `references/rag-architecture.md`

Entscheidungen dokumentieren:
- **Chunking-Strategie:** Größe + Overlap + Methode
- **Embedding-Modell:** Lokal (offline) oder API (Online)
- **Retrieval-Methode:** Dense / Sparse / Hybrid + Reranker
- **Vector Store:** Qdrant / Weaviate / Pinecone / pgvector
- **Context-Budget:** Wieviele Chunks × Chunk-Größe ≤ Context-Window

### Bei Fine-tuning
- **Methode:** Full Fine-tune / LoRA / QLoRA / Prompt-Tuning
  - LoRA: Standard für Production (wenig GPU-Speicher, schnell)
  - Full Fine-tune: nur wenn LoRA nicht ausreicht + Budget vorhanden
- **Daten-Minimum:** ≥ 500 Beispiele (Instruction-Format: prompt + completion)
- **Eval vor Training:** Baseline mit Prompting messen — ist Fine-tuning wirklich nötig?

### Bei Agent
- **Architektur:** ReAct / Plan-and-Execute / Multi-Agent (Supervisor + Specialists)
- **Tools definieren:** Welche externen Aktionen? (Search, Code, API, DB)
- **Loop-Control:** Max-Steps, Abbruchbedingung, Fallback bei Tool-Fehler
- **Zustand:** Wo wird Agent-State gespeichert? (Conversation history, working memory)

### Modell-Wahl (alle Patterns)

| Anforderung | Empfehlung |
|---|---|
| Höchste Qualität, API | Claude Sonnet 4+ / GPT-4o |
| Kosten-optimiert, API | Claude Haiku / GPT-4o-mini |
| Offline / On-premise | Llama 3.1 8B–70B / Mistral 7B |
| Embedding (Offline) | bge-large-en-v1.5 / multilingual-e5-large |

---

## Step 3 — Evaluation-Strategie planen

Lade `references/evaluation-framework.md` — RAGAS, LLM-as-Judge, Benchmark-Typen.

**Minimum vor Deployment:**

1. **Golden Dataset anlegen** (50+ Fragen + Ground-Truth — domänen-spezifisch!)
2. **RAG:** RAGAS Faithfulness + Answer Relevancy automatisch messen
3. **Regression Gate:** neue Version nur deployen wenn Score ≥ Baseline − 3%
4. **LLM-as-Judge** für subjektive Qualität (Bias beachten: positions- und längen-bias)

*Kein Deployment ohne Offline Evals.* — CMU 11-667

---

## Step 4 — Production-Entscheidungen

### Guardrails
- **Input:** Prompt-Injection-Detection, PII-Filtering (presidio / AWS Comprehend)
- **Output:** Halluzinations-Check (Faithfulness-Score < Threshold → Fallback-Response)
- **Topik-Guard:** Out-of-scope Queries erkennen und ablehnen (Classifier oder LLM-Prompt)

### Cost & Latency
- **Prompt-Caching:** Wiederverwendbare System-Prompts cachen (Anthropic / OpenAI support)
- **Semantic Caching:** Ähnliche Queries → gleiche Antwort (Redis + Embedding-Similarity)
- **Streaming:** Token-by-Token für bessere perceived latency
- **Model Routing:** Einfache Queries → kleines Modell, komplexe → großes Modell

### Observability
- Jeden LLM-Call loggen: Prompt, Response, Latenz, Token-Count, Model
- **LLM-Tracing:** LangSmith / Helicone / Langfuse (open-source)
- Alert bei: Error Rate > 2%, Latenz p95 > 5s, Token-Cost/Day > Budget

---

## Output — Design-Datei

Schreibe das Ergebnis nach `./design-llm.md`:

```markdown
# LLM System Design: [Kontext/Feature-Name]
Pattern: RAG / Fine-tune / Agent / Prompting | Datum: YYYY-MM-DD

## Entscheidungen
| Entscheidung | Wahl | Begründung | Referenz |
|---|---|---|---|

## Architektur-Überblick
[Datenfluss: Input → Retrieval/Tool → Context → LLM → Output]

## Evaluation-Strategie
- Golden Dataset: X Fragen, Quelle: ...
- Metriken: Faithfulness ≥ 0.8, Relevancy ≥ 0.75
- Regression Gate: ≥ Baseline − 3%

## Guardrails
[Input-Filter, Output-Check, Topik-Guard]

## Cost- & Latency-Budget
- Erwartete Volume: X Requests/Tag
- Token-Budget: ~X Tokens/Request × Kosten/1M = X EUR/Monat

## Annahmen & offene Punkte

---
## ✅ Setup-Todo
- [ ] Embedding-Modell wählen + lokales Setup oder API
- [ ] Vector Store aufsetzen
- [ ] Golden Dataset anlegen (min. 50 Fragen)
- [ ] RAGAS Eval-Pipeline einrichten
- [ ] LLM-Tracing (Langfuse / Helicone) einrichten
- [ ] Guardrails implementieren

## 📋 Nächste Schritte (priorisiert)
1. ...
```

---

## Reference Files

- `references/integration-patterns.md` — RAG vs Fine-tune vs Prompting vs Agent Entscheidungsmatrix
- `references/rag-architecture.md` — RAG-Varianten, Chunking, Retrieval, Reranking, Embedding-Modelle
- `references/evaluation-framework.md` — RAGAS, LLM-as-Judge, Benchmark-Typen, Eval-Pipeline
- `references/curriculum-mapping.md` — Concept → Stanford CS224N / CMU 11-667 / Berkeley / MIT Lecture-Links
