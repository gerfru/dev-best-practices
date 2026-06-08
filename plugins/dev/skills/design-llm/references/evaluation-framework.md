# LLM Evaluation Framework

## Eval-Typen

| Typ | Wann | Wie |
|---|---|---|
| **Offline Eval** | Vor Deployment, bei jeder Änderung | Benchmark-Dataset, automatisch |
| **Online Eval** | In Production | A/B-Test, User-Feedback, Logging |
| **LLM-as-Judge** | Wenn kein Ground-Truth vorhanden | LLM bewertet LLM-Output (mit Skala) |
| **Human Eval** | Kritische Entscheidungen, neue Aufgaben | Labeler-Bewertung (teuer, langsam) |

**Grundregel (CMU 11-667):** Kein Deployment ohne Offline Evals. LLM-as-Judge nur mit menschlich validierter Referenz.

---

## RAG-spezifische Metriken (RAGAS)

| Metrik | Was gemessen wird | Skala |
|---|---|---|
| **Faithfulness** | Antwort durch Retrieved Context belegt? | 0–1 (1 = vollständig belegbar) |
| **Answer Relevancy** | Antwort relevant zur Frage? | 0–1 |
| **Context Precision** | Wie viel des Retrieved Context ist relevant? | 0–1 |
| **Context Recall** | Wird relevantes Wissen tatsächlich retrieved? | 0–1 (braucht Ground-Truth) |

**Tool:** [RAGAS](https://github.com/explodinggradients/ragas) — Open Source, integriert in LangChain/LlamaIndex.

---

## LLM-as-Judge Patterns

| Pattern | Skala | Prompt-Struktur |
|---|---|---|
| **Pairwise Comparison** | A vs. B | "Welche Antwort ist besser: A oder B?" |
| **Likert Scale** | 1–5 | "Bewerte auf einer Skala 1–5: Faithfulness / Relevanz / Vollständigkeit" |
| **Reference-based** | Pass/Fail | "Enthält die Antwort alle Fakten aus der Referenz?" |
| **G-Eval** | 0–1 | Schrittweise Evaluation mit Chain-of-Thought |

**Bias-Risiken:** Positions-Bias (A wird bevorzugt), Längen-Bias (längere Antwort gewinnt), Self-Enhancement (Modell bevorzugt eigene Outputs). Gegenmittel: Positionen tauschen, mehrere Judges, diverse Modelle.

---

## Benchmark-Typen

| Typ | Beispiele | Für |
|---|---|---|
| **Task-spezifisch** | HotpotQA, Natural Questions | RAG / QA-Systeme |
| **Reasoning** | MMLU, HellaSwag, ARC | Allgemeine Reasoning-Fähigkeit |
| **Code** | HumanEval, SWE-bench | Code-Generierung |
| **Safety** | TruthfulQA, MT-Bench | Halluzination, Sicherheit |
| **Domain-spezifisch** | Selbst erstellt | Produktions-Genauigkeit |

**Empfehlung:** Immer einen domänen-spezifischen Benchmark erstellen (50–200 Fragen mit Ground-Truth) — generische Benchmarks korrelieren oft nicht mit Produktions-Performance.

---

## Eval-Pipeline (Minimum für Production)

```text
1. Golden Dataset anlegen (50+ Fragen + Ground-Truth-Antworten)
2. Offline Eval bei jeder Modell-/Prompt-Änderung
   → RAGAS Faithfulness + Answer Relevancy automatisch
3. Regression Gate: neue Version nur deployen wenn Score ≥ Baseline − 3%
4. Online: 10% der Queries per LLM-as-Judge bewerten
5. User-Feedback tracken (👍/👎) → schlechte Queries ins Golden Dataset
```

---

## Referenzen

| Konzept | Quelle |
|---|---|
| LLM-as-Judge / Synthetic Data | CMU 11-667 Lec 13 — "LLMs for evaluation: Synthetic data, simulation, AI-as-judge" |
| Benchmarking | Stanford CS224N Lec (Feb 10) — "Benchmarking and Evaluation" |
| RAGAS | Explodinggradients (2023) — https://github.com/explodinggradients/ragas |
| G-Eval | Liu et al. (2023) — arXiv:2303.16634 |
| Eval in Production | Chip Huyen — "Designing ML Systems" Kap. 6 (Evaluation) |
