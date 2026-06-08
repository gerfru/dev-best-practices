---
name: dev:tool-test
description: Stack-aware test assistant. Automatically detects language, framework, and existing test setup, then designs or generates appropriate tests (unit, integration, E2E) according to the test pyramid. Use this skill whenever the user wants to write, improve, or review tests; triggers for "write tests", "test strategy", "increase coverage", "how do I test X", "missing tests", "flaky tests".
---

# Test (stack-aware)

First analyzes what is present (stack, test framework, coverage), then decides
what is missing and why — no generic templates, but tests that fit this project.

## Step 0 — Detect Stack & Test Setup

Scan automatically:

**Detect test framework:**
- `package.json` → `jest`, `vitest`, `playwright`, `cypress`, `testing-library`
- `pyproject.toml` / `pytest.ini` → `pytest`, `unittest`, `hypothesis`
- `*.test.ts` / `*.spec.ts` / `test_*.py` → existing test conventions

**Evaluate existing setup:**
- How much coverage already exists? (`coverage/`, `.coverage`, `jest.config`)
- What test types exist? (Unit / Integration / E2E / Snapshot)
- Are there fixtures, mocks, test utils?
- Does the test suite run in CI? (`.github/workflows/`)

**Project context:**
- What is the core of the app? (Auth, payment, API, data processing …)
- Which paths are critical and still untested?
- Check project `CLAUDE.md` for known test exceptions

If unclear what should be tested: ask once concretely.

## Step 1 — Derive Test Strategy (Pyramid)

Evaluate the current state against the test pyramid and identify the biggest gaps:

```text
        [E2E]          few, slow, high value for critical flows
       [Integr.]       service boundaries, DB, external APIs
      [Unit Tests]     functions, classes, pure logic — fast, many
```

**Critical paths that ALWAYS need tests:**
- Authentication & authorization (login, token validation, permission checks)
- Data mutations (create/update/delete with validation)
- External integrations (API calls, webhooks, payment)
- Error handling (what happens when X fails?)

**Stack-specific test recommendations:**

*Next.js / React:*
- Vitest + React Testing Library for components (not Enzyme)
- Server Actions: integration test with real DB access, not mocked
- `playwright` for critical user flows (login, checkout)
- Snapshot tests sparingly — only for stable UI components

*FastAPI / Python:*
- `pytest` + `httpx.AsyncClient` for API endpoints
- `pytest-asyncio` for async tests
- Real DB for integration tests (`pytest-postgresql` / SQLite in-memory)
- `factory_boy` for test fixtures instead of manual fixtures

*Express / Node.js:*
- Vitest or Jest + Supertest for HTTP tests
- Test DB via Docker or in-memory (better isolation than mocking)

*General:*
- No mock cascades for own infrastructure — real DB in test is more reliable
- Mock external APIs (Stripe, SendGrid …) — but with realistic payloads

## Step 2 — Write or Improve Tests

Depending on the user's request:

**Generate new tests:**
1. Identify the unit to test (function / endpoint / component)
2. Determine sensible test cases: happy path, edge cases, error scenarios
3. Write tests in the existing format (filename convention, import style, fixture pattern)
4. No duplication of existing tests

**Design test strategy:**
1. Gap analysis: what is critical and untested?
2. Prioritization: auth > data mutations > business logic > UI
3. Effort estimate per area (S/M/L)
4. Roadmap: what first, what can wait?

**Improve existing tests:**
1. Flaky tests: identify timing dependencies, external state dependencies
2. Overly broad mocks: what is mocked that should not be mocked?
3. Test duplication: same logic in unit + integration + E2E → only at one level
4. Missing assertions: tests that only check "no error" instead of behavior

## Step 3 — Output

```text
## Test Analysis: [Context]

**Stack:** [detected stack + test framework]
**Current state:** [brief assessment of existing tests]

### Critical Gaps (prioritized)
1. [path/function] — [why critical] — Effort: S/M/L
2. …

### Generated Tests
[directly usable test file(s) in the correct format]

### Not covered (intentionally)
[What was omitted for scope reasons and why]
```

## Rules
- Write tests that check behavior, not implementation details.
- No test code that is more complex than the code it tests.
- Never leave `// TODO: add more tests` — either write them or document as a gap.
- Auto-write to files only when the user explicitly requests it.
- Cite coverage as a metric but not as a goal — poorly written tests that increase coverage are worthless.
