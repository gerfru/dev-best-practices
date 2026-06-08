---
name: dev:review-app
description: Complete end-to-end evaluation of an app/codebase — measures the codebase against the dev-best-practices rules of this repo (essential/app/github/architecture). Axes: Architecture (12-Factor), Security (OWASP ASVS 5.0/Top 10), CI-CD-Delivery (DORA), Code Quality, Tests, Observability. Use this skill whenever the user wants to audit, evaluate, review or assess an entire app or codebase, check production/release readiness, find technical debt, or do a security/architecture review. Trigger also for "evaluate/audit/review my app", "is my app release-ready", "security review", "architecture check" — even if only a single axis is mentioned. If you want to review architecture OR security: use this skill — it covers both. review-arch and review-secure are deep-dives for the respective focus; review-app is the complete overview.
---

# App Evaluation (repo-integrated)

Evaluates a target codebase against the rules of this dev-best-practices repo.
EXPECTED = the rule files. ACTUAL = the codebase. Findings cite the violated rule.

## Step 0 - Load Standards & Context

**Auto-Discovery (never guess — read):**

| What to read | Derived information |
|---|---|
| `package.json` | Language (TS/JS), framework (Next.js/Express/NestJS/…), test tool |
| `pyproject.toml` / `requirements.txt` | Python, framework (FastAPI/Django/Flask), package manager (uv/pip) |
| `go.mod` / `Cargo.toml` | Go / Rust |
| `Dockerfile` / `docker-compose.yml` | Container context, services, network |
| `.github/workflows/*.yml` | CI pipeline present, which steps |
| `CLAUDE.md` of the project | Documented exceptions, known constraints |
| Lock files (`pnpm-lock.yaml`, `uv.lock`, `package-lock.json`) | Actually used versions |

**Derive from discovery (do not ask):**
- **Team size:** Solo if no team context in `CLAUDE.md` → ASVS L1 default
- **ASVS level:** L1 for solo/prototype, L2 when auth/payment/sensitive data is visible, L3 only if explicit
- **Compliance:** GDPR if EU users in description or privacy concept present
- **Deployment target:** derive from Dockerfile/CI (container, serverless, classic)

Only ask if discovery yields no clear answer (e.g., no config files at all).
Report discovered values compactly to the user: `Stack: Next.js 14 + TypeScript | DB: Postgres | CI: GitHub Actions | ASVS: L2`.

1. Determine the **rule source** in this order:
   a) Rule files of this repo, if reachable (`claude/essential-rules.md`,
      `claude/app-rules.md`, `claude/github-rules.md`, `claude/architecture-rules.md`;
      depth from `reference/*.md` as needed).
   b) Otherwise the `CLAUDE.md` of the target project (often contains the copied essential rules).
   c) Otherwise default standards (12-Factor, ASVS L2, DORA).
   Tell the user which source is active.
2. Carry over documented **exceptions** from `CLAUDE.md`/`REVIEW.md` (e.g., intentionally
   public routes) so re-runs remain consistent.

## Step 1 - Plan First
Briefly outline which six sub-agents run with which scope, which rule source
applies, and which tools are missing (e.g., no CI history → DORA estimate only).
Only proceed after a brief confirmation.

## Step 2 - Six Sub-Agents IN PARALLEL
Start all six as task sub-agents in ONE message. Each returns a
**compressed** finding list (no raw dumps); main context stays clean.

Each finding:
`Title · File:Line · Severity (Critical/High/Medium/Low) · Confidence (1-10) ·
violated rule (File -> Section) · Fix · Effort (S<30min / M<2h / L>2h)`.

### Agent 1 - Architecture & 12-Factor
Standard: `architecture-rules.md` (+ `reference/architecture-best-practices.md`).
Check: feature-based structure, layering (Routes→Service→Data Access),
monolith-first, the 12 factors (config in env, stateless, logs to stdout, port
binding, disposability), Docker architecture (127.0.0.1 binding, health checks, limits).

### Agent 2 - Security (ASVS 5.0 + Top 10)
Standard: `app-rules.md` security sections (+ `reference/app-best-practices.md`).
Check against TARGET ASVS LEVEL: security headers (CSP/HSTS/…), auth at 3 layers
(especially data access layer), input validation (Zod/Pydantic), prepared statements,
DOM XSS, secrets handling, cookie flags, CORS, file uploads, PostgreSQL hardening.
Tooling requirements: gitleaks, bandit/ruff-S, semgrep, pip-audit, trivy.
If the official `/security-review` component is installed, this agent may use it
instead of duplicating the work.
**False-positive filter:** only confidence >= 7. Missing UUID validation,
resource leaks, and env-var-dependent attacks do NOT count as vulnerabilities.
Missing audit logs → report as ⚪ COMPLIANCE (ISO 27001 A.8.15 / GDPR Art. 32),
not as Security HIGH/CRITICAL.

### Agent 3 - Code Quality
Default thresholds (adjustable, should eventually belong in a dedicated rule file):
Complexity/function warning >10 / fail >20; function >50 lines; file >400 lines;
duplication >3%; nesting >4. Plus naming, dead code, missing type annotations.

### Agent 4 - Tests & Reliability
Standard: `architecture-rules.md` (testing strategy) + `github-rules.md` (testing).
Assess test pyramid; measure coverage if tooling is available (target: 70-80% lines,
critical paths ~100%). Explicitly list untested critical paths (auth, payment, data mutations).
Flag flaky/skip/smoke-only tests.

### Agent 5 - CI/CD & Delivery (DORA)
Standard: `github-rules.md` (pipeline, branch protection, scanning).
Check: build/lint/type-check/test/gitleaks per PR? semgrep+trivy with exit-code 1?
Branch protection on main? Renovate? Deployment reproducible + rollback?
Locate the DORA levers (Deployment Frequency, Lead Time for Changes,
Change Failure Rate, Failed Deployment Recovery Time). **Honestly mark**
which values are truly measurable from CI history and which are estimates only.

### Agent 6 - Observability & Operations (Bash allowed)
Standard: `app-rules.md` (Logging/Monitoring/Observability) + `reference/`.
Check: structured JSON logging (Pino/structlog), no secrets in logs, Sentry,
uptime, four golden signals, health/ready endpoints, OpenTelemetry readiness.
Run dependency audit CLI (`npm audit`/`pip-audit`) and summarize.
Container hygiene if Dockerfile present (non-root, digest pin, multi-stage, `--check`).

## Step 3 - Consolidate & Report
1. Merge all findings into ONE list sorted by severity; discard security findings < 7.
2. Per axis: a traffic light (green/yellow/red) + one sentence of rationale.
3. Fix order: shared utilities/security first, then refactors, then tests, then cosmetics.
4. Write report to `./review-app-report.md` with table:
   `Axis | Traffic light | #Critical | #High | most important violated rule`.

## Rules
- No speculative findings. Only with File:Line reference or clearly evidenced gap.
  Uncertain findings marked as "[to verify]".
- Every finding names the concrete violated rule (File -> Section), not just a generic principle.
- **Fix nothing automatically.** Report first, then implement selectively on request.
- Verification before "done": Would a staff engineer sign off on this report?
- New deliberate exceptions discovered during the run: propose adding them to the target project's `CLAUDE.md`.

## Report Footer

Every generated report ends with:

```markdown
---
*Created with AI assistance (Claude Code + dev-best-practices plugin).
Findings are to be verified — not a substitute for manual penetration testing.*
```
