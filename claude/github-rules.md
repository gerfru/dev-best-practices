# GitHub & CI/CD Rules

Binding rules for project setup and CI/CD. No theory -- decisions only.
Detailed explanations: `../reference/github-best-practices.md`

---

## Pre-Commit Hooks

Every project MUST have pre-commit hooks. Order:

1. **Secret scanning:** `gitleaks protect --staged`
2. **Linting + auto-fix:** TS → `eslint --fix`, Python → `ruff --fix`
3. **Formatting:** TS → `prettier --write`, Python → `ruff format`
4. **Type check:** TS → `tsc --noEmit`, Python → `mypy`

**Setup:** TS → Husky + lint-staged. Python → pre-commit framework.

---

## Linting & Formatting

### TypeScript/Node
- **ESLint** with flat config (`eslint.config.mjs`) -- old `.eslintrc` is deprecated
- **Prettier** as its own tool (not as an ESLint plugin)
- Additional plugins: `eslint-plugin-security`, `@typescript-eslint/no-floating-promises`
- Alternative for non-Next.js: Biome (15x faster)

### Python
- **Ruff** for everything (replaces flake8, black, isort, bandit)
- Config in `pyproject.toml`: `select = ["E", "W", "F", "I", "S", "B", "UP", "RUF"]`
- **mypy** strict for CI, **pyright** for IDE

---

## CI Pipeline (GitHub Actions)

Every PR MUST go through CI. Minimal pipeline:

### TypeScript/Node
```yaml
steps:
  - pnpm install --frozen-lockfile
  - pnpm lint
  - pnpm exec tsc --noEmit
  - pnpm build
```

### Python
```yaml
steps:
  - uv sync --frozen
  - uv run ruff check .
  - uv run ruff format --check .
  - uv run mypy .
  - uv run pytest
  - uv run semgrep scan --config=auto --error
  # semgrep extends ruff-S with cross-file taint analysis
```

### Both: Separate secrets job
```yaml
secrets:
  - uses: gitleaks/gitleaks-action@v2
```

### Extended (when using Docker)
- Container scanning with Trivy (`severity: CRITICAL,HIGH`, `exit-code: 1`)

---

## Branch Protection

These rules MUST be active on `main`:

- Require pull request: **Yes**
- Required approvals: **1** (or 0 for solo + CI)
- Require status checks: **Yes** (jobs: `quality`, `secrets`)
- Require up-to-date branch: **Yes**
- Restrict force pushes: **Yes**
- Restrict deletions: **Yes**

For new setups: prefer **GitHub Rulesets** (more flexible than branch protection).

---

## Repository Settings

Configure once after repo creation:

- **Merge strategy:** Squash merge only (clean `main` history, WIP commits stay in PR)
- **Merge commit + rebase:** Disable (one strategy, no mix)
- **Delete branch on merge:** Enable (no manual cleanup)
- **Secret scanning + push protection:** Enable (GitHub blocks secrets on push)
- **Dependabot alerts:** Enable

```bash
# Everything at once via GitHub CLI
gh api repos/{owner}/{repo} --method PATCH \
  --field allow_squash_merge=true \
  --field allow_merge_commit=false \
  --field allow_rebase_merge=false \
  --field delete_branch_on_merge=true

gh api repos/{owner}/{repo} --method PATCH \
  -f 'security_and_analysis[secret_scanning][status]=enabled' \
  -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'

gh api repos/{owner}/{repo}/vulnerability-alerts --method PUT
```

---

## Secret Scanning

Defense in depth -- 3 layers:

1. **Pre-commit:** gitleaks (local, before every commit)
2. **CI:** gitleaks-action (catches `--no-verify` bypasses)
3. **GitHub-native:** Secret scanning + push protection enabled

---

## Package Management

- **TypeScript:** pnpm (fast, disk-efficient, strict). Always commit lockfile. CI: `--frozen-lockfile`
- **Python:** uv (10-100x faster than poetry/pipenv, Rust-based). Commit lockfile. CI: `uv sync --frozen`

---

## Dependency Management

- **Renovate** (not Dependabot) -- groups updates, less PR noise, dashboard issue
- devDependencies patch: **Automerge** (only when CI + required checks are active)
- **Dependabot alerts** enabled (security notifications, no conflict with Renovate)
- Docker digest updates: **Monthly**, no automerge
- Major updates: Review manually

---

## Code Review

### Automated
- CI checks (lint, types, build, tests) -- objective quality
- Claude Code Review Action for AI review (security, logic, architecture)

### Human
- PR size: Ideal < 200 LOC, maximum 400 LOC. Above that: split
- Check: correctness, design, readability, security, performance, error handling, tests
- Ask questions instead of commands, mark nitpicks with `nit:`, clearly flag blockers
- Review within 24 hours

### PR Template (`.github/pull_request_template.md`)
```markdown
## What changes?
<!-- 1-3 sentences -->

## How was it tested?
<!-- Manual / unit tests / E2E / screenshot -->

## Checklist
- [ ] Tests added/updated
- [ ] No breaking changes (or documented)
- [ ] No secrets in code
```

---

## Testing

### TypeScript/Node
- **Unit + integration:** Vitest + React Testing Library + MSW
- **E2E:** Playwright (not Cypress)
- **Accessibility:** axe-core via Playwright

### Python
- **Unit + integration:** pytest + httpx (FastAPI TestClient) + pytest-cov
- **E2E:** Playwright (pytest-playwright)
- Config in `pyproject.toml`: `fail_under = 80`

### Priority
1. API route handlers / endpoints
2. Data transformations (parsing, validation)
3. E2E smoke test (app starts, main page loads)

---

## Security Scanning

| Type | Tool | Cost |
|-----|------|--------|
| SAST (code) | **Semgrep** | Free |
| SCA (dependencies) | `npm audit` / `pip-audit` | Free |
| Container | **Trivy** | Free |
| Secrets | **gitleaks** | Free |
| SBOM | **syft** (CycloneDX format) | Free |

Integrate all into CI. Trivy and Semgrep with `exit-code: 1` (pipeline fails on findings).
Generate SBOM on every release (`syft . -o cyclonedx-json`) -- evidence for ISO 27001 and EU Cyber Resilience Act.

---

## Docker

- **Multi-stage build:** Builder + runner separated
- Pin base images with **digest** (not just tag)
- `--frozen-lockfile` / `--frozen` in build
- **Non-root user** (`USER nonroot`)
- Define HEALTHCHECK
- Maintain `.dockerignore` (`.env*`, `.git`, `node_modules`, `__pycache__`)
- Minimal base image (Alpine, Slim, Chainguard)

---

## Release Management

- Solo with auto-deploy (merge to main = deploy): **Not needed**
- When versioning is needed: **Release Please** (Google) for controlled releases
- Fully automated: **semantic-release** (requires Conventional Commits)

---

## Checklist: New Project

### Day 1
- [ ] git init + .gitignore
- [ ] Package manager (pnpm / uv)
- [ ] Linting + formatting (ESLint+Prettier / Ruff)
- [ ] Strict type checking (TypeScript / mypy)
- [ ] Pre-commit hooks (Husky / pre-commit)
- [ ] gitleaks hook
- [ ] Create CLAUDE.md

### First Week
- [ ] CI pipeline (lint, typecheck, build/test)
- [ ] Branch protection on main
- [ ] Configure Renovate
- [ ] gitleaks in CI
- [ ] Docker setup with pinned base images

### Production-ready
- [ ] Tests (Vitest / pytest)
- [ ] Security scanning (Trivy, Semgrep)
- [ ] Claude Code Review Action
- [ ] Secret scanning on GitHub
- [ ] Deployment pipeline
