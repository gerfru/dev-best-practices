---
name: dev:design-llm
description: >
  LLM system design grounded in Stanford CS224N (Yang/Choi), CMU 11-667
  (Savelka/Kim) and Chip Huyen "Designing ML Systems". Use this skill whenever
  the user needs to design an LLM-powered feature or system from scratch.
  Triggers: "RAG architecture", "should I fine-tune", "how do I build an agent",
  "prompt engineering strategy", "LLM guardrails", "evaluation strategy for LLM",
  "token budget", "hallucination handling", "inference optimization",
  "how do I build an LLM workflow", "integrate LLM into my app",
  "which LLM pattern", "RAG or fine-tuning". Covers: integration pattern
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

## Step 0 — Clarify System Context

Establish before designing:

1. **What is being built?** (Chatbot / Document Q&A / Code assistant / Agent / Classification)
2. **Knowledge bottleneck or behavior bottleneck?**
   - Knowledge missing (current docs, proprietary DB) → RAG
   - Behavior must be consistently adapted (style, format, domain vocabulary) → Fine-tune
3. **Latency budget?** (< 1s → no multi-hop agent / no large model without caching)
4. **Cost budget?** (token costs × expected volume)
5. **Offline capability needed?** (on-premise, GDPR-critical)
6. **What data exists?** (quantity, format, quality for RAG index or fine-tune)

---

## Step 1 — Decide Integration Pattern

Load `references/integration-patterns.md` — complete decision matrix.

**Quick decision:**

```text
Knowledge bottleneck?  → RAG
Behavior bottleneck + >500 examples?  → Fine-tune
Multiple steps / external actions?  → Agent
Otherwise:  → Prompting-only (always start here)
```

Combinations are common: RAG + Prompting, Agent + RAG.

---

## Step 2 — Design Architecture

### For RAG: Load `references/rag-architecture.md`

Document decisions:
- **Chunking strategy:** Size + overlap + method
- **Embedding model:** Local (offline) or API (online)
- **Retrieval method:** Dense / Sparse / Hybrid + reranker
- **Vector store:** Qdrant / Weaviate / Pinecone / pgvector
- **Context budget:** How many chunks × chunk size ≤ context window

### For Fine-tuning
- **Method:** Full fine-tune / LoRA / QLoRA / Prompt-Tuning
  - LoRA: Standard for production (low GPU memory, fast)
  - Full fine-tune: only if LoRA is insufficient + budget available
- **Data minimum:** ≥ 500 examples (instruction format: prompt + completion)
- **Eval before training:** Measure baseline with prompting — is fine-tuning really needed?

### For Agent
- **Architecture:** ReAct / Plan-and-Execute / Multi-Agent (Supervisor + Specialists)
- **Define tools:** Which external actions? (Search, Code, API, DB)
- **Loop control:** Max steps, termination condition, fallback on tool failure
- **State:** Where is agent state stored? (Conversation history, working memory)

### Model Selection (all patterns)

| Requirement | Recommendation |
|---|---|
| Highest quality, API | Claude Sonnet 4+ / GPT-4o |
| Cost-optimized, API | Claude Haiku / GPT-4o-mini |
| Offline / on-premise | Llama 3.1 8B–70B / Mistral 7B |
| Embedding (offline) | bge-large-en-v1.5 / multilingual-e5-large |

---

## Step 3 — Plan Evaluation Strategy

Load `references/evaluation-framework.md` — RAGAS, LLM-as-Judge, benchmark types.

**Minimum before deployment:**

1. **Create golden dataset** (50+ questions + ground truth — domain-specific!)
2. **RAG:** Measure RAGAS Faithfulness + Answer Relevancy automatically
3. **Regression gate:** Only deploy new version if score ≥ baseline − 3%
4. **LLM-as-Judge** for subjective quality (watch for bias: position bias and length bias)

*No deployment without offline evals.* — CMU 11-667

---

## Step 4 — Production Decisions

### Guardrails
- **Input:** Prompt injection detection, PII filtering (presidio / AWS Comprehend)
- **Output:** Hallucination check (faithfulness score < threshold → fallback response)
- **Topic guard:** Detect and reject out-of-scope queries (classifier or LLM prompt)

### Cost & Latency
- **Prompt caching:** Cache reusable system prompts (Anthropic / OpenAI support)
- **Semantic caching:** Similar queries → same answer (Redis + embedding similarity)
- **Streaming:** Token-by-token for better perceived latency
- **Model routing:** Simple queries → small model, complex → large model

### Observability
- Log every LLM call: prompt, response, latency, token count, model
- **LLM tracing:** LangSmith / Helicone / Langfuse (open-source)
- Alert on: error rate > 2%, latency p95 > 5s, token cost/day > budget

---

## Output — Design File

Write the result to `./design-llm.md`:

```markdown
# LLM System Design: [Context/Feature Name]
Pattern: RAG / Fine-tune / Agent / Prompting | Date: YYYY-MM-DD

## Decisions
| Decision | Choice | Rationale | Reference |
|---|---|---|---|

## Architecture Overview
[Data flow: Input → Retrieval/Tool → Context → LLM → Output]

## Evaluation Strategy
- Golden dataset: X questions, source: ...
- Metrics: Faithfulness ≥ 0.8, Relevancy ≥ 0.75
- Regression gate: ≥ baseline − 3%

## Guardrails
[Input filter, output check, topic guard]

## Cost & Latency Budget
- Expected volume: X requests/day
- Token budget: ~X tokens/request × cost/1M = X EUR/month

## Assumptions & Open Questions

---
## Setup Todo
- [ ] Choose embedding model + local setup or API
- [ ] Set up vector store
- [ ] Create golden dataset (min. 50 questions)
- [ ] Set up RAGAS eval pipeline
- [ ] Set up LLM tracing (Langfuse / Helicone)
- [ ] Implement guardrails

## Next Steps (prioritized)
1. ...
```

---

## Reference Files

- `references/integration-patterns.md` — RAG vs Fine-tune vs Prompting vs Agent decision matrix
- `references/rag-architecture.md` — RAG variants, chunking, retrieval, reranking, embedding models
- `references/evaluation-framework.md` — RAGAS, LLM-as-Judge, benchmark types, eval pipeline
- `references/curriculum-mapping.md` — Concept → Stanford CS224N / CMU 11-667 / Berkeley / MIT lecture links
