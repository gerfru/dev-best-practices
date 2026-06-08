# LLM Evaluation Framework

## Eval Types

| Type | When | How |
|---|---|---|
| **Offline eval** | Before deployment, on every change | Benchmark dataset, automated |
| **Online eval** | In production | A/B test, user feedback, logging |
| **LLM-as-Judge** | When no ground truth is available | LLM evaluates LLM output (with scale) |
| **Human eval** | Critical decisions, new tasks | Labeler assessment (expensive, slow) |

**Ground rule (CMU 11-667):** No deployment without offline evals. LLM-as-Judge only with human-validated reference.

---

## RAG-Specific Metrics (RAGAS)

| Metric | What is measured | Scale |
|---|---|---|
| **Faithfulness** | Is the answer supported by retrieved context? | 0–1 (1 = fully verifiable) |
| **Answer Relevancy** | Is the answer relevant to the question? | 0–1 |
| **Context Precision** | How much of the retrieved context is relevant? | 0–1 |
| **Context Recall** | Is relevant knowledge actually retrieved? | 0–1 (requires ground truth) |

**Tool:** [RAGAS](https://github.com/explodinggradients/ragas) — open source, integrates with LangChain/LlamaIndex.

---

## LLM-as-Judge Patterns

| Pattern | Scale | Prompt structure |
|---|---|---|
| **Pairwise comparison** | A vs. B | "Which answer is better: A or B?" |
| **Likert scale** | 1–5 | "Rate on a scale of 1–5: faithfulness / relevance / completeness" |
| **Reference-based** | Pass/Fail | "Does the answer contain all facts from the reference?" |
| **G-Eval** | 0–1 | Step-by-step evaluation with chain-of-thought |

**Bias risks:** Position bias (A is preferred), length bias (longer answer wins), self-enhancement (model prefers its own outputs). Countermeasures: swap positions, multiple judges, diverse models.

---

## Benchmark Types

| Type | Examples | For |
|---|---|---|
| **Task-specific** | HotpotQA, Natural Questions | RAG / QA systems |
| **Reasoning** | MMLU, HellaSwag, ARC | General reasoning capability |
| **Code** | HumanEval, SWE-bench | Code generation |
| **Safety** | TruthfulQA, MT-Bench | Hallucination, safety |
| **Domain-specific** | Custom-built | Production accuracy |

**Recommendation:** Always create a domain-specific benchmark (50–200 questions with ground truth) — generic benchmarks often do not correlate with production performance.

---

## Eval Pipeline (Minimum for Production)

```text
1. Create golden dataset (50+ questions + ground-truth answers)
2. Offline eval on every model/prompt change
   → RAGAS Faithfulness + Answer Relevancy automatically
3. Regression gate: only deploy new version if score ≥ baseline − 3%
4. Online: evaluate 10% of queries via LLM-as-Judge
5. Track user feedback (thumbs up/down) → add poor queries to golden dataset
```

---

## References

| Concept | Source |
|---|---|
| LLM-as-Judge / synthetic data | CMU 11-667 Lec 13 — "LLMs for evaluation: Synthetic data, simulation, AI-as-judge" |
| Benchmarking | Stanford CS224N Lec (Feb 10) — "Benchmarking and Evaluation" |
| RAGAS | Explodinggradients (2023) — https://github.com/explodinggradients/ragas |
| G-Eval | Liu et al. (2023) — arXiv:2303.16634 |
| Eval in production | Chip Huyen — "Designing ML Systems" Ch. 6 (Evaluation) |
