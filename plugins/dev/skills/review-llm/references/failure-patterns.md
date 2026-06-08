# LLM System Failure Patterns

## Häufige Architektur-Fehler

| Pattern | Symptom | Severity | Lösung |
|---|---|---|---|
| **Eval-less Deployment** | Keine Metriken, Bugs werden erst von Usern gemeldet | CRITICAL | Golden Dataset + RAGAS vor Deployment |
| **No Guardrails** | Modell antwortet auf Out-of-scope Queries, PII-Leak möglich | HIGH | Topik-Guard, Input/Output-Filter |
| **Context Stuffing** | Gesamtes Dokument in Kontext → Lost-in-the-middle, hohe Kosten | HIGH | RAG mit Chunking + Retrieval |
| **Prompting statt RAG** | Modell halluziniert proprietäres Wissen | HIGH | RAG für externe Wissensquellen |
| **Fine-tune statt RAG** | Wissen veraltet, Retraining teuer | MEDIUM | RAG für zeitkritische Daten |
| **Kein Semantic Caching** | Identische Queries × Token-Kosten | MEDIUM | Redis + Embedding-Similarity Cache |
| **Monolithischer Agent** | Ein Prompt für alles → unzuverlässig, nicht debugbar | MEDIUM | Spezialisierte Sub-Agents + Supervisor |
| **Kein LLM-Tracing** | Production-Bugs nicht reproduzierbar | MEDIUM | Langfuse / Helicone / LangSmith |
| **Magic Chunk Size** | 512 Tokens willkürlich gewählt, nie evaluiert | LOW | Chunk-Größe per Retrieval-Recall evaluieren |
| **Single-Model Eval** | LLM-as-Judge mit eigenem Modell → Self-Enhancement Bias | LOW | Diverse Judges, Positionen rotieren |

---

## RAG-spezifische Failure-Patterns

| Pattern | Beschreibung | Severity |
|---|---|---|
| **Retrieval Failure** | Richtiger Kontext nicht retrieved → Faithfulness ↓ | HIGH |
| **Chunk Boundary Problem** | Antwort liegt auf Chunk-Grenze → unvollständiger Kontext | MEDIUM |
| **Stale Index** | Vector Store nicht aktualisiert → veraltete Antworten | MEDIUM |
| **Over-Retrieval** | Top-50 Chunks retrieved, Kontext zu groß → Lost-in-the-middle | MEDIUM |
| **Embedding Mismatch** | Indexierung mit Modell A, Query mit Modell B | HIGH |

---

## Agent-spezifische Failure-Patterns

| Pattern | Beschreibung | Severity |
|---|---|---|
| **Infinite Loop** | Agent ruft Tools endlos auf, kein Abbruch | CRITICAL |
| **Tool Misuse** | Agent nutzt falsches Tool für Aufgabe | HIGH |
| **State Corruption** | Working Memory inkonsistent nach Tool-Fehler | HIGH |
| **Halluzinierter Tool-Call** | Agent "erfindet" Tool-Parameter | HIGH |
| **Excessive Agency** | Agent führt irreversible Aktionen ohne Bestätigung aus | CRITICAL |

---

## Referenzen

| Failure-Typ | Quelle |
|---|---|
| LLM Harms in Applications | CMU 11-667 Lec (Mar 10) — "Harms caused by LLM applications" |
| Attacking LLM Applications | CMU 11-667 Lec (Mar 12) — "Attacking LLMs and LLM applications" |
| Agent Safety | Berkeley CS294-196 Lec (Nov 25) — Ben Mann (Anthropic RSP) |
| Safe & Trustworthy Agents | Berkeley CS294-196 Lec (Dec 2) — Dawn Song |
| Excessive Agency | OWASP LLM Top 10 — LLM08 |
