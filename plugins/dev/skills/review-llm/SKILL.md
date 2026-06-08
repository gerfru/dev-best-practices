---
name: review-llm
description: >
  LLM-System-Review auf Basis von CMU 11-667 (Harms + Attacking LLMs),
  Berkeley CS294-196 (Safety/Guardrails) und OWASP LLM Top 10. Use this skill
  whenever the user wants to review an existing LLM-powered system or feature
  for architecture quality, eval coverage, safety, and production readiness.
  Triggers: "review my LLM system", "check my RAG", "is my prompt injection safe",
  "review my agent", "audit my AI feature", "LLM code review", "check my evals",
  "mein RAG funktioniert nicht richtig", "review mein LLM-Setup",
  "was ist falsch an meinem Agent", "LLM-Audit". Covers: integration pattern
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

## Step 0 — Scope klären

Vor dem Review etablieren:

1. **Was wird reviewed?** (RAG-System / Agent / Chat-Feature / Prompt-Chain / Fine-tuned Model)
2. **Was existiert?** (Code, Prompts, Eval-Daten, Architektur-Beschreibung)
3. **Bekannte Probleme?** (Halluzinationen, langsam, teuer, schlechte Antworten)
4. **Production-Status?** (Prototyp / Beta / Production)

---

## Step 1 — Architektur-Review

**Pattern-Assessment:** Ist das gewählte Pattern (RAG / Fine-tune / Agent / Prompting)
das richtige für das Problem? Lade `references/failure-patterns.md`.

Prüfen:

- [ ] **Integration-Pattern:** Gibt es einen Wissens-Bottleneck der RAG erfordert?
  Gibt es einen Verhaltens-Bottleneck der Fine-tuning erfordert?
- [ ] **Prompt-Qualität:** Ist der System-Prompt klar, spezifisch, mit Output-Format?
  Sind Rollen (System / User / Assistant) korrekt getrennt?
- [ ] **Context-Management:** Wird Context-Window effizient genutzt?
  Kein Context Stuffing (gesamte Dokumente ohne Retrieval)?

### Bei RAG zusätzlich prüfen

- [ ] **Chunking:** Ist Chunk-Größe evaluiert oder willkürlich (Magic Number)?
- [ ] **Retrieval-Qualität:** Dense only? Hybrid Search (BM25 + Dense) vorhanden?
- [ ] **Reranker:** Gibt es einen Cross-Encoder-Reranker für Top-K?
- [ ] **Embedding-Konsistenz:** Indexierung und Query mit demselben Modell?
- [ ] **Index-Aktualität:** Wann wurde zuletzt re-indexed? Gibt es Stale-Data-Risiko?
- [ ] **Similarity-Threshold:** Werden Low-Confidence Chunks herausgefiltert?

### Bei Agent zusätzlich prüfen

- [ ] **Tool-Inventar:** Sind alle Tools dokumentiert? Sind Read-Only Tools klar von Write-Tools getrennt?
- [ ] **Max-Steps-Limit:** Gibt es ein Limit gegen Infinite Loops?
- [ ] **Fehlerbehandlung:** Was passiert wenn ein Tool fehlschlägt?
- [ ] **Irreversible Aktionen:** Gibt es Human-in-the-Loop für Delete/Send/Pay?

---

## Step 2 — Eval-Coverage-Review

Lade `references/failure-patterns.md` → "Eval-less Deployment".

- [ ] **Existieren Evals?** (Golden Dataset, Benchmark, auch manuell)
- [ ] **Sind Evals domänen-spezifisch?** (Generische Benchmarks ≠ Produktions-Qualität)
- [ ] **Werden RAG-Metriken gemessen?** (Faithfulness, Answer Relevancy via RAGAS)
- [ ] **Gibt es einen Regression Gate?** (Kein Deployment wenn Score < Baseline − 3%)
- [ ] **Werden Evals bei jeder Änderung ausgeführt?** (Prompt-Änderung, Model-Update)
- [ ] **LLM-as-Judge:** Falls verwendet — wird Positions-/Längen-Bias kontrolliert?

**Finding-Severity:** Kein Eval = CRITICAL (silent failures in production).

---

## Step 3 — Safety & Security Review

Lade `references/security-checks.md` — OWASP LLM Top 10 Checkliste.

Prüfen (je nach System-Typ):

**Prompt Injection (LLM01):**
- [ ] Direkter Injection-Test durchführen
- [ ] Sind User-Input und System-Prompt klar getrennt?
- [ ] Können Dokumente im RAG-Index Instruktionen enthalten? (Indirekte Injection)

**Insecure Output Handling (LLM02):**
- [ ] Wird LLM-Output in HTML/Code/Shell eingesetzt?
- [ ] Gibt es Output-Sanitizing/Schema-Validation?

**Sensitive Information Disclosure (LLM06):**
- [ ] Enthält der RAG-Index PII? Gibt es Tenant-Isolation?
- [ ] Kann der System-Prompt extrahiert werden?

**Excessive Agency (LLM08) — nur bei Agents:**
- [ ] Welche irreversiblen Aktionen sind möglich?
- [ ] Gibt es Human-in-the-Loop?

---

## Step 4 — Production-Readiness-Review

- [ ] **Observability:** Werden LLM-Calls geloggt (Prompt, Response, Latenz, Tokens)?
  LLM-Tracing-Tool vorhanden (Langfuse / Helicone / LangSmith)?
- [ ] **Cost-Monitoring:** Gibt es ein Token-Budget-Alert?
- [ ] **Latenz-Monitoring:** Gibt es p95-Latenz-Alert (z.B. > 5s)?
- [ ] **Semantic Caching:** Werden häufige/ähnliche Queries gecacht?
- [ ] **Fallback-Strategie:** Was passiert wenn LLM-API nicht erreichbar ist?
- [ ] **Guardrails:** Input-Filter (PII, Topik-Guard), Output-Check (Faithfulness-Score)?

---

## Standard-Finding-Format

```text
### [SEVERITY] LLM Finding: [Kurztitel]
**Kategorie:** Architektur | Eval | Safety | Production

**Was:** Was das aktuelle System tut (oder nicht tut).

**Warum es problematisch ist:** Ein Absatz — was in Production schiefgeht,
welche Angriffsfläche entsteht, welche Kosten entstehen.

**Empfehlung:** Konkrete Maßnahme mit Beispiel.

**Referenz:** [CMU 11-667 / OWASP LLM / Berkeley CS294-196 / Chip Huyen Kap.]
```

---

## Reference Files

- `references/failure-patterns.md` — Häufige LLM-System-Fehler (Architektur, RAG, Agent) mit Severity
- `references/security-checks.md` — OWASP LLM Top 10 Checklisten (Prompt Injection, Output Handling, Excessive Agency)
- `references/curriculum-mapping.md` — Concept → CMU 11-667 / Berkeley / Stanford / OWASP Mapping
