---
name: dev:review-llm
description: >
  LLM system review grounded in CMU 11-667 (Harms + Attacking LLMs),
  Berkeley CS294-196 (Safety/Guardrails), and OWASP LLM Top 10. Use this skill
  whenever the user wants to review an existing LLM-powered system or feature
  for architecture quality, eval coverage, safety, and production readiness.
  Triggers: "review my LLM system", "check my RAG", "is my prompt injection safe",
  "review my agent", "audit my AI feature", "LLM code review", "check my evals",
  "my RAG is not working properly", "review my LLM setup",
  "what is wrong with my agent", "LLM audit". Covers: integration pattern
  assessment, RAG quality, eval coverage, safety/security (OWASP LLM Top 10),
  production readiness (cost, observability, guardrails).
  Always use this skill for LLM system reviews.
---

# LLM System Review Skill

Structured review of existing LLM systems grounded in CMU 11-667, Berkeley CS294-196,
and OWASP LLM Top 10. Identifies architecture gaps, eval blind spots, and safety risks.

---

## Core Philosophy (CMU 11-667)

> "The most dangerous LLM system is one deployed without evals."
> — CMU 11-667 course principle

LLM systems fail silently: hallucinations look like correct answers,
prompt injections look like normal inputs, missing guardrails are invisible
until exploited. Systematic review catches what spot-checks miss.

---

## Step 0 — Clarify Scope

Before the review, establish:

1. **What is being reviewed?** (RAG system / agent / chat feature / prompt chain / fine-tuned model)
2. **What exists?** (code, prompts, eval data, architecture description)
3. **Known problems?** (hallucinations, slow, expensive, poor answers)
4. **Production status?** (prototype / beta / production)

---

## Step 1 — Architecture Review

**Pattern assessment:** Is the chosen pattern (RAG / fine-tune / agent / prompting)
the right one for the problem? Load `references/failure-patterns.md`.

Check:

- [ ] **Integration pattern:** Is there a knowledge bottleneck that requires RAG?
  Is there a behavior bottleneck that requires fine-tuning?
- [ ] **Prompt quality:** Is the system prompt clear, specific, with output format?
  Are roles (system / user / assistant) correctly separated?
- [ ] **Context management:** Is the context window used efficiently?
  No context stuffing (entire documents without retrieval)?

### Additional checks for RAG

- [ ] **Chunking:** Is chunk size evaluated or arbitrary (magic number)?
- [ ] **Retrieval quality:** Dense only? Hybrid search (BM25 + dense) present?
- [ ] **Reranker:** Is there a cross-encoder reranker for top-K?
- [ ] **Embedding consistency:** Indexing and query using the same model?
- [ ] **Index freshness:** When was the last re-index? Is there a stale-data risk?
- [ ] **Similarity threshold:** Are low-confidence chunks filtered out?

### Additional checks for agents

- [ ] **Tool inventory:** Are all tools documented? Are read-only tools clearly separated from write tools?
- [ ] **Max-steps limit:** Is there a limit against infinite loops?
- [ ] **Error handling:** What happens when a tool fails?
- [ ] **Irreversible actions:** Is there a human-in-the-loop for delete/send/pay?

---

## Step 2 — Eval Coverage Review

Load `references/failure-patterns.md` → "Eval-less Deployment".

- [ ] **Do evals exist?** (golden dataset, benchmark, even manual)
- [ ] **Are evals domain-specific?** (generic benchmarks ≠ production quality)
- [ ] **Are RAG metrics measured?** (faithfulness, answer relevancy via RAGAS)
- [ ] **Is there a regression gate?** (no deployment if score < baseline − 3%)
- [ ] **Are evals run on every change?** (prompt change, model update)
- [ ] **LLM-as-judge:** If used — is position/length bias controlled?

**Finding severity:** No evals = CRITICAL (silent failures in production).

---

## Step 3 — Safety & Security Review

Load `references/security-checks.md` — OWASP LLM Top 10 checklist.

Check (depending on system type):

**Prompt Injection (LLM01):**
- [ ] Run a direct injection test
- [ ] Are user input and system prompt clearly separated?
- [ ] Can documents in the RAG index contain instructions? (indirect injection)

**Insecure Output Handling (LLM02):**
- [ ] Is LLM output inserted into HTML/code/shell?
- [ ] Is there output sanitizing/schema validation?

**Sensitive Information Disclosure (LLM06):**
- [ ] Does the RAG index contain PII? Is there tenant isolation?
- [ ] Can the system prompt be extracted?

**Excessive Agency (LLM08) — agents only:**
- [ ] Which irreversible actions are possible?
- [ ] Is there a human-in-the-loop?

---

## Step 4 — Production Readiness Review

- [ ] **Observability:** Are LLM calls logged (prompt, response, latency, tokens)?
  LLM tracing tool present (Langfuse / Helicone / LangSmith)?
- [ ] **Cost monitoring:** Is there a token budget alert?
- [ ] **Latency monitoring:** Is there a p95 latency alert (e.g., > 5s)?
- [ ] **Semantic caching:** Are frequent/similar queries cached?
- [ ] **Fallback strategy:** What happens when the LLM API is unavailable?
- [ ] **Guardrails:** Input filter (PII, topic guard), output check (faithfulness score)?

---

## Standard Finding Format

```text
### [SEVERITY] LLM Finding: [Short Title]
**Category:** Architecture | Eval | Safety | Production

**What:** What the current system does (or does not do).

**Why it is problematic:** One paragraph — what goes wrong in production,
what attack surface is created, what costs arise.

**Recommendation:** Concrete measure with example.

**Reference:** [CMU 11-667 / OWASP LLM / Berkeley CS294-196 / Chip Huyen Ch.]
```

---

## Reference Files

- `references/failure-patterns.md` — Common LLM system failures (architecture, RAG, agent) with severity
- `references/security-checks.md` — OWASP LLM Top 10 checklists (prompt injection, output handling, excessive agency)
- `references/curriculum-mapping.md` — Concept → CMU 11-667 / Berkeley / Stanford / OWASP mapping
