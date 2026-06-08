# LLM System Failure Patterns

## Common Architecture Failures

| Pattern | Symptom | Severity | Solution |
|---|---|---|---|
| **Eval-less Deployment** | No metrics; bugs are only reported by users | CRITICAL | Golden dataset + RAGAS before deployment |
| **No Guardrails** | Model responds to out-of-scope queries; PII leak possible | HIGH | Topic guard, input/output filter |
| **Context Stuffing** | Entire document in context → lost-in-the-middle, high cost | HIGH | RAG with chunking + retrieval |
| **Prompting instead of RAG** | Model hallucinates proprietary knowledge | HIGH | RAG for external knowledge sources |
| **Fine-tune instead of RAG** | Knowledge becomes stale; retraining is expensive | MEDIUM | RAG for time-sensitive data |
| **No Semantic Caching** | Identical queries × token costs | MEDIUM | Redis + embedding similarity cache |
| **Monolithic Agent** | One prompt for everything → unreliable, not debuggable | MEDIUM | Specialized sub-agents + supervisor |
| **No LLM Tracing** | Production bugs not reproducible | MEDIUM | Langfuse / Helicone / LangSmith |
| **Magic Chunk Size** | 512 tokens chosen arbitrarily, never evaluated | LOW | Evaluate chunk size via retrieval recall |
| **Single-Model Eval** | LLM-as-judge with own model → self-enhancement bias | LOW | Diverse judges, rotate positions |

---

## RAG-Specific Failure Patterns

| Pattern | Description | Severity |
|---|---|---|
| **Retrieval Failure** | Correct context not retrieved → faithfulness ↓ | HIGH |
| **Chunk Boundary Problem** | Answer lies on a chunk boundary → incomplete context | MEDIUM |
| **Stale Index** | Vector store not updated → outdated answers | MEDIUM |
| **Over-Retrieval** | Top-50 chunks retrieved; context too large → lost-in-the-middle | MEDIUM |
| **Embedding Mismatch** | Indexing with model A, querying with model B | HIGH |

---

## Agent-Specific Failure Patterns

| Pattern | Description | Severity |
|---|---|---|
| **Infinite Loop** | Agent calls tools endlessly; no termination | CRITICAL |
| **Tool Misuse** | Agent uses the wrong tool for the task | HIGH |
| **State Corruption** | Working memory inconsistent after tool failure | HIGH |
| **Hallucinated Tool Call** | Agent "invents" tool parameters | HIGH |
| **Excessive Agency** | Agent executes irreversible actions without confirmation | CRITICAL |

---

## References

| Failure Type | Source |
|---|---|
| LLM Harms in Applications | CMU 11-667 Lec (Mar 10) — "Harms caused by LLM applications" |
| Attacking LLM Applications | CMU 11-667 Lec (Mar 12) — "Attacking LLMs and LLM applications" |
| Agent Safety | Berkeley CS294-196 Lec (Nov 25) — Ben Mann (Anthropic RSP) |
| Safe & Trustworthy Agents | Berkeley CS294-196 Lec (Dec 2) — Dawn Song |
| Excessive Agency | OWASP LLM Top 10 — LLM08 |
