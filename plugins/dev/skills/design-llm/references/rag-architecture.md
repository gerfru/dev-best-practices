# RAG Architecture — Patterns & Komponenten

## RAG-Varianten

| Variante | Beschreibung | Wann |
|---|---|---|
| **Naive RAG** | Query → Embed → Retrieve → Prompt → Generate | Prototyp, einfache Docs |
| **Advanced RAG** | + Query Rewriting + Reranking + Hybrid Search | Production, qualitätskritisch |
| **Modular RAG** | Austauschbare Komponenten: Indexer, Retriever, Reranker, Generator | Skalierung, A/B-Testing |
| **Agentic RAG** | RAG als Tool in Agent-Loop (iteratives Retrieval) | Multi-Hop Reasoning, Deep Research |

---

## Chunking-Strategie

| Strategie | Chunk-Größe | Wann |
|---|---|---|
| Fixed-Size | 256–512 Tokens + 50–100 Token Overlap | Homogene Dokumente, schnelles Setup |
| Sentence-based | Satz-Grenzen | Natürliche Sprache, Prosa |
| Semantic | Durch Embedding-Ähnlichkeit | Heterogene Inhalte |
| Hierarchical | Small chunks für Retrieval, große für Kontext | Long-form Docs (Bücher, Reports) |
| **Late Chunking** | Chunking nach Embedding (vollständiger Kontext) | State-of-the-Art für lange Dokumente |

**Faustregel:** Chunk-Größe = kürzeste Einheit die eine eigenständige Antwort enthält.

---

## Retrieval-Methoden

| Methode | Wie | Stärke | Schwäche |
|---|---|---|---|
| **Dense Retrieval** | Embedding-Ähnlichkeit (cosine/dot) | Semantisch, sprachunabhängig | Keyword-blind |
| **Sparse Retrieval** | BM25 / TF-IDF | Keyword-exakt, schnell | Kein semantisches Verständnis |
| **Hybrid Search** | Dense + Sparse kombiniert (RRF) | Beste Recall-Werte | Komplexer Stack |
| **Re-ranking** | Cross-Encoder bewertet top-K neu | Präzision ↑ | Latenz ↑ |

**Empfehlung Production:** Hybrid Search (BM25 + Dense) + Reranker (z.B. Cohere Rerank, BGE Reranker).

---

## Embedding-Modelle

| Modell | Dimensionen | Use-Case |
|---|---|---|
| `text-embedding-3-small` (OpenAI) | 1536 | General-Purpose, kostengünstig |
| `text-embedding-3-large` (OpenAI) | 3072 | Höchste Qualität (OpenAI) |
| `all-MiniLM-L6-v2` (sentence-transformers) | 384 | Lokal, schnell, offline |
| `bge-large-en-v1.5` (BAAI) | 1024 | Open-Source, SOTA |
| `multilingual-e5-large` | 1024 | Mehrsprachig (DE/EN) |

---

## Context-Management

| Problem | Lösung |
|---|---|
| Lost-in-the-middle (Infos in der Mitte des Kontexts ignoriert) | Wichtigste Chunks an Anfang + Ende platzieren |
| Context-Overflow | Hierarchisches Retrieval: mehr Chunks, weniger Text pro Chunk |
| Irrelevante Chunks | Similarity-Threshold (nur Chunks > 0.7 Cosine-Similarity) |
| Duplicate Content | Deduplication vor Indexierung; MMR (Maximal Marginal Relevance) |

---

## Referenzen

| Konzept | Quelle |
|---|---|
| RAG Original-Paper | Lewis et al. (2020) — arXiv:2005.11401 |
| RAG Varianten | CMU 11-667 Lec 5–7 — Retrieval 1–3 |
| Modular RAG | CMU 11-667 Lec 8 — "Deep Research" |
| Agentic RAG | Berkeley CS294-196 Lec (Oct 7) — "Compound AI Systems" |
| Late Chunking | CMU 11-667 Lec 5 — "Storing and retrieving knowledge" |
| Context-Window | MIT 6.5940 Lec 15 — "Long Context LLM" |
