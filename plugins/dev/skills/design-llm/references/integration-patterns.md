# LLM Integration Patterns — Decision Matrix

## When to Use Which Pattern?

| Pattern | Choose when... | Do not choose when... |
|---|---|---|
| **Prompting-only** | Task is solvable with context, no external knowledge needed, rapid prototyping | Knowledge must be current/domain-specific, behavior must be consistently adapted |
| **RAG** | Knowledge bottleneck: model doesn't know the content (docs, DB, current data), no fine-tuning budget | Task needs no external knowledge source, latency-critical without caching |
| **Fine-tuning** | Behavior bottleneck: style/format/tone must be consistently adapted, many examples available, high production volume | Knowledge is missing (→ RAG), small budget, few examples (<500) |
| **Agent / Tool-Use** | Multiple steps, external actions needed (APIs, code execution, search), task not solvable with a single LLM call | Simple Q&A, latency-critical, cost-critical |

**Rule of thumb (CMU 11-667):** Prompt → RAG → Fine-tune → Agent. Always start with the simplest pattern.

---

## Pattern Combinations (common in production)

| Combination | Typical use case |
|---|---|
| RAG + Prompting | Document Q&A, knowledge base chat |
| Fine-tune + RAG | Domain assistant with specific style + current knowledge |
| Agent + RAG | Deep research, code generation with documentation access |
| Agent + Fine-tune | Specialized code agent (e.g. SQL agent) |

---

## Cost / Latency Profile

| Pattern | Latency (p95) | Cost/request | Maintenance effort |
|---|---|---|---|
| Prompting-only | Low (1 LLM call) | Low | Minimal |
| RAG | Medium (+retrieval latency) | Medium (+embedding calls) | Medium (index maintenance) |
| Fine-tune | Low (smaller model possible) | Low (smaller model) | High (retraining) |
| Agent | High (multiple LLM calls) | High (N × token costs) | High (tool integration) |

---

## References

| Decision | Source |
|---|---|
| Prompting vs. fine-tune | CMU 11-667 Lec 4 — "Deciding when to finetune and finetuning efficiently" |
| RAG fundamentals | CMU 11-667 Lec 5–7 — "Retrieval 1–3: Storing, RAG, Deep Research" |
| Multi-agent | CMU 11-667 Lec 14 — "Multi-agent systems" |
| Tool use | CMU 11-667 Lec 11 — "Tool-use, chitchat, personas" |
| Agent frameworks | Berkeley CS294-196 Lec (Oct 7) — "Compound AI Systems & DSPy" (Omar Khattab) |
| Inference optimization | MIT 6.5940 Lec 13 — "Efficient LLM Deployment" |
