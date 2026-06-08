# RAG Architecture — Patterns & Components

## RAG Variants

| Variant | Description | When |
|---|---|---|
| **Naive RAG** | Query → Embed → Retrieve → Prompt → Generate | Prototype, simple docs |
| **Advanced RAG** | + query rewriting + reranking + hybrid search | Production, quality-critical |
| **Modular RAG** | Exchangeable components: indexer, retriever, reranker, generator | Scaling, A/B testing |
| **Agentic RAG** | RAG as tool in agent loop (iterative retrieval) | Multi-hop reasoning, deep research |

---

## Chunking Strategy

| Strategy | Chunk size | When |
|---|---|---|
| Fixed-size | 256–512 tokens + 50–100 token overlap | Homogeneous documents, quick setup |
| Sentence-based | Sentence boundaries | Natural language, prose |
| Semantic | Via embedding similarity | Heterogeneous content |
| Hierarchical | Small chunks for retrieval, large for context | Long-form docs (books, reports) |
| **Late Chunking** | Chunking after embedding (full context) | State-of-the-art for long documents |

**Rule of thumb:** Chunk size = shortest unit that contains a self-contained answer.

---

## Retrieval Methods

| Method | How | Strength | Weakness |
|---|---|---|---|
| **Dense Retrieval** | Embedding similarity (cosine/dot) | Semantic, language-agnostic | Keyword-blind |
| **Sparse Retrieval** | BM25 / TF-IDF | Exact keyword match, fast | No semantic understanding |
| **Hybrid Search** | Dense + sparse combined (RRF) | Best recall values | More complex stack |
| **Re-ranking** | Cross-encoder re-scores top-K | Precision ↑ | Latency ↑ |

**Production recommendation:** Hybrid search (BM25 + Dense) + reranker (e.g. Cohere Rerank, BGE Reranker).

---

## Embedding Models

| Model | Dimensions | Use case |
|---|---|---|
| `text-embedding-3-small` (OpenAI) | 1536 | General-purpose, cost-efficient |
| `text-embedding-3-large` (OpenAI) | 3072 | Highest quality (OpenAI) |
| `all-MiniLM-L6-v2` (sentence-transformers) | 384 | Local, fast, offline |
| `bge-large-en-v1.5` (BAAI) | 1024 | Open-source, SOTA |
| `multilingual-e5-large` | 1024 | Multilingual (DE/EN) |

---

## Context Management

| Problem | Solution |
|---|---|
| Lost-in-the-middle (info in the middle of context ignored) | Place most important chunks at start + end |
| Context overflow | Hierarchical retrieval: more chunks, less text per chunk |
| Irrelevant chunks | Similarity threshold (only chunks > 0.7 cosine similarity) |
| Duplicate content | Deduplication before indexing; MMR (Maximal Marginal Relevance) |

---

## References

| Concept | Source |
|---|---|
| RAG original paper | Lewis et al. (2020) — arXiv:2005.11401 |
| RAG variants | CMU 11-667 Lec 5–7 — Retrieval 1–3 |
| Modular RAG | CMU 11-667 Lec 8 — "Deep Research" |
| Agentic RAG | Berkeley CS294-196 Lec (Oct 7) — "Compound AI Systems" |
| Late chunking | CMU 11-667 Lec 5 — "Storing and retrieving knowledge" |
| Context window | MIT 6.5940 Lec 15 — "Long Context LLM" |
