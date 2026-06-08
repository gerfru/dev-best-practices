---
name: dev:tool-debug
description: Stack-aware debugging assistant. Analyzes an error or unexpected behavior, automatically detects the stack/framework, and delivers a structured root-cause plan with concrete fix suggestions. Use this skill whenever the user reports a bug, error message, unexpected behavior, or asks "why does X not work"; triggers for "error", "bug", "not working", "debug", "why does X happen", stack traces, or unexpected output.
---

# Debug (stack-aware)

Analyzes an error with context awareness: first detects the stack, then the error type,
then the most likely cause. No generic checklists — only what is relevant for this
stack and this error.

## Step 0 — Detect Context & Stack

Scan the project automatically (never guess, never assume):

**Language & Runtime:**
- `package.json` → Node.js/TypeScript, framework (Next.js, Express, Fastify, NestJS …)
- `pyproject.toml` / `requirements.txt` → Python, framework (FastAPI, Django, Flask …)
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pom.xml` / `build.gradle` → Java/Kotlin

**Deployment & Infrastructure:**
- `Dockerfile` / `docker-compose.yml` → container context, network aliases, volumes
- `.github/workflows/` → CI pipeline, build steps
- Project `CLAUDE.md` → documented exceptions, known issues

**Gather error context from the user:**
- Error message / stack trace (if not provided: ask once)
- When does it occur (startup / runtime / build / test)?
- Reproducible or intermittent?
- What changed recently?

## Step 1 — Classify the Error

Assign the error to a category and adapt the analysis:

| Category | Typical causes | Where to look |
|---|---|---|
| **Import / Dependency** | Wrong version, missing peer dep, circular import | package.json / lock file, import order |
| **Configuration** | Missing env var, wrong path, type mismatch in config | .env, config files, startup logs |
| **Network / API** | Wrong port, CORS, missing auth header, timeout | Docker network, proxy config, request headers |
| **Database** | Migration not run, connection pool exhausted, query error | Migration history, connection string, query logs |
| **Async / Concurrency** | Race condition, unhandled promise, deadlock | Event loop, async/await chain, locking |
| **Type / Schema** | Null pointer, schema mismatch, wrong format | Types, validation (Zod/Pydantic), serialization |
| **Build / Compile** | Transpile error, missing types, tree-shaking | tsconfig, bundler config, import paths |
| **Environment difference** | "works locally" → container/CI differs | Env vars, Node/Python version, path separators |

## Step 2 — Root Cause Analysis

1. **Read the relevant files** (not all — only those matching the error category)
2. **Trace the error path** from the error message backward through the call chain
3. **Check the most common causes** for this stack + this category
4. **Formulate 1–3 hypotheses** with confidence (high/medium/low) and rationale

Stack-specific checks (only when relevant):

**Next.js / React:**
- Server vs. client component boundary violated?
- `use client` / `use server` directive correct?
- Hydration mismatch (server/client render different)?
- `.env.local` vs. `.env.production` — variable exposed?

**FastAPI / Python:**
- Pydantic schema mismatch (v1 vs. v2 API)?
- Async error: missing `await`, sync function in async context?
- Dependency injection failed (`Depends()`)?
- CORS middleware order wrong?

**Docker / Container:**
- Service name in Compose network incorrectly referenced?
- Volume mount overwrites compiled artifacts?
- Health check blocking startup order?
- Port 0.0.0.0 vs. 127.0.0.1 (only reachable inside container)?

**Database (Postgres/SQLite/…):**
- Check migration status (which migrations have run?)
- Connection string different in container vs. local?
- N+1 query or missing index on timeout?

## Step 3 — Output

Structured report:

```text
## Error Analysis: [short title]

**Stack:** [detected stack]
**Category:** [error type]
**Confidence:** [high/medium/low]

### Root Cause (most likely cause)
[1–3 sentences: what is going wrong and why]

### Affected Files
- [file:line] — [what is wrong there]

### Fix
[concrete fix with code snippet where possible]

### Verification
[How to confirm the fix worked]

### If the fix doesn't help
[Next hypothesis + what to check then]
```

## Rules
- No checklist-based approach. Only what is relevant for this error.
- Do not offer multiple fix variants when one clearly dominates — recommend directly.
- If the error cannot be clearly localized: suggest two targeted diagnostic steps,
  do not enumerate all possible causes.
- Auto-fix only when the user explicitly requests it.
