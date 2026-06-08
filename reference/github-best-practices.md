# GitHub Setup Best Practices

Reference checklist for new projects (as of March 2026).
Framework-specific sections are marked with **[TS/Node]** and **[Python]** respectively.

---

## 1. Pre-Commit Hooks

Local quality gates before code even enters the repo.

### [TS/Node] Setup: Husky + lint-staged

```bash
pnpm add -D husky lint-staged
pnpm exec husky init
```

**`.husky/pre-commit`:**

```bash
gitleaks protect --staged
npx lint-staged
```

**`package.json` (lint-staged config):**

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml,yaml}": ["prettier --write"]
  }
}
```

### [Python] Setup: pre-commit Framework

```bash
pip install pre-commit
pre-commit install
```

**`.pre-commit-config.yaml`:**

```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.22.0
    hooks:
      - id: gitleaks

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.9.0
    hooks:
      - id: ruff          # Linting (replaces flake8, isort, pyflakes, etc.)
        args: [--fix]
      - id: ruff-format   # Formatting (replaces black)

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.14.0
    hooks:
      - id: mypy
        additional_dependencies: [types-requests]  # Type stubs as needed
```

### Recommended Checks (both ecosystems)

| Order | Check | TS/Node tool | Python tool |
|-------------|-------|-------------|-------------|
| 1 | Secret scanning | `gitleaks` | `gitleaks` |
| 2 | Linting + auto-fix | `eslint --fix` | `ruff --fix` |
| 3 | Formatting | `prettier --write` | `ruff format` |
| 4 | Type check | `tsc --noEmit` | `mypy` |

**Optional:** `commitlint` for Conventional Commits – only useful when using automated releases (semantic-release).

---

## 2. Linting & Formatting

### [TS/Node] ESLint + Prettier

**ESLint:**
- **Flat Config** (`eslint.config.mjs`) is the standard since ESLint 9. Old `.eslintrc` format is deprecated.
- For Next.js: `eslint-config-next` (already includes TypeScript, React Hooks, import checks, Core Web Vitals)
- `eslint-config-prettier` to avoid conflicts with Prettier

**Recommended additional plugins:**

| Plugin | What it does |
|--------|-------------|
| `eslint-plugin-security` | Catches `eval()`, unsafe regex, etc. |
| `@typescript-eslint/no-floating-promises` | Forgotten `await` statements |

**Prettier:**
- As a standalone tool, not as an ESLint plugin
- `.prettierrc` in repo for consistent formatting
- `.prettierignore` for generated files

**Alternative: Biome**
- Rust-based, 15x faster, linter + formatter in one
- As of 2026: Not yet full parity with `eslint-config-next`
- Already recommended for non-Next.js projects

### [Python] Ruff (All-in-One)

Ruff replaces the entire old Python tooling in a single Rust-based tool:

| Old (2023) | New (2025+) |
|------------|-------------|
| flake8 | `ruff check` |
| black | `ruff format` |
| isort | `ruff check --select I` |
| pyflakes | included in ruff |
| pycodestyle | included in ruff |
| bandit (security) | `ruff check --select S` |

**`pyproject.toml`:**

```toml
[tool.ruff]
target-version = "py312"
line-length = 120

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "S",    # bandit (security)
    "B",    # bugbear
    "UP",   # pyupgrade
    "RUF",  # ruff-specific rules
]

[tool.ruff.format]
quote-style = "double"
```

### [Python] Type Checking: mypy vs. pyright

| Tool | Strength | Weakness |
|------|--------|----------|
| **mypy** | Standard, large ecosystem, many type stubs | Slower |
| **pyright** (Microsoft) | Faster, better at inference, VS Code integration | Less common in CI |

**Recommendation:** mypy for CI, pyright for IDE integration. Both in `strict` mode.

**`pyproject.toml`:**

```toml
[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_configs = true
```

---

## 3. CI Pipeline (GitHub Actions)

**Most important rule:** Every PR must go through CI before it can be merged.

### [TS/Node] Minimal CI Pipeline

```yaml
name: CI
on:
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm exec tsc --noEmit
      - run: pnpm build

  secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### [Python] Minimal CI Pipeline

```yaml
name: CI
on:
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v5
      - run: uv sync --frozen
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run mypy .
      - run: uv run pytest

  secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Why Each Step Matters

| Step | TS/Node | Python | Catches |
|---------|---------|--------|----------|
| Install | `pnpm install --frozen-lockfile` | `uv sync --frozen` | Lockfile drift |
| Lint | `pnpm lint` | `ruff check` | Code quality |
| Format check | (included in lint) | `ruff format --check` | Inconsistent formatting |
| Type check | `tsc --noEmit` | `mypy` | Type errors |
| Build/test | `pnpm build` | `pytest` | Build/test failures |
| Secrets | `gitleaks` | `gitleaks` | `--no-verify` bypasses |

### Extended Pipeline (both ecosystems)

```yaml
  # Container scanning with Trivy
  container-scan:
    runs-on: ubuntu-latest
    needs: quality
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t app:ci .
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: app:ci
          severity: CRITICAL,HIGH
          exit-code: 1
```

### [Python] Matrix Testing (multiple Python versions)

```yaml
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.11", "3.12", "3.13"]
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v5
        with:
          python-version: ${{ matrix.python-version }}
      - run: uv sync --frozen
      - run: uv run pytest --cov=src --cov-report=xml
```

---

## 4. Branch Protection Rules

Technical enforcement of "never push directly to main". Applies identically to both ecosystems.

### Recommended Configuration for `main`

| Setting | Value | Why |
|---------|------|-------|
| Require pull request | Yes | Enforces review process |
| Required approvals | 1 (or 0 for solo + CI) | Four-eyes principle |
| Require status checks | Yes | Gate on CI results |
| Required checks | `quality`, `secrets` | Specific jobs that must pass |
| Require up-to-date branch | Yes | Prevents merge conflicts on main |
| Restrict force pushes | Yes | No history rewriting on main |
| Restrict deletions | Yes | No accidental branch deletion |

**GitHub Rulesets** (newer) vs. **Branch Protection** (classic): Rulesets are more flexible (multiple branches, tag rules). Prefer Rulesets for new setups.

### Setup via GitHub CLI

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["quality","secrets"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}'
```

---

## Repository Settings

Configure once per repo. Applies identically to both ecosystems.

### Merge Strategy

Only one strategy active — consistency beats flexibility.

| Strategy | History | When to use |
|---|---|---|
| **Squash merge** | One commit per PR — clean, readable | Solo or small teams with short feature branches |
| Merge commit | Full branch history | Teams that need every WIP commit in `main` |
| Rebase merge | Linear history, all commits individually | Teams with disciplined commits without WIP noise |

**Recommendation: Squash only.** PR title automatically becomes commit message in `main`. WIP commits stay visible in PR but disappear from `main`.

### Recommended Configuration

| Setting | Value | Why |
|---|---|---|
| Allow squash merge | Yes | Clean, readable `main` history |
| Allow merge commit | No | Prevents merge commit noise |
| Allow rebase merge | No | One strategy, no mix |
| Delete branch on merge | Yes | No manual cleanup of old feature branches |

### Setup via GitHub CLI

```bash
gh api repos/{owner}/{repo} --method PATCH \
  --field allow_squash_merge=true \
  --field allow_merge_commit=false \
  --field allow_rebase_merge=false \
  --field delete_branch_on_merge=true
```

---

## 5. Secret Scanning

Defense in depth: Multiple layers. Applies identically to both ecosystems.

| Layer | Tool | When |
|---------|------|------|
| Pre-commit | gitleaks | Before every commit (local) |
| CI | gitleaks-action | On every PR (catches `--no-verify` bypasses) |
| GitHub-native | Secret scanning + push protection | Continuously (free for public repos) |

### gitleaks Configuration

Default config is usually sufficient. For custom patterns:

```toml
# .gitleaks.toml
[allowlist]
  paths = ["docs/examples/"]  # Ignore example files
```

### Enable GitHub Secret Scanning

Settings > Code security > Secret scanning > Enable

With **Push Protection**, pushes containing known secret patterns are blocked before they reach the repo.

Via GitHub CLI:

```bash
gh api repos/{owner}/{repo} --method PATCH \
  -f 'security_and_analysis[secret_scanning][status]=enabled' \
  -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'

# Enable Dependabot alerts
gh api repos/{owner}/{repo}/vulnerability-alerts --method PUT
```

---

## 6. Package Management

### [TS/Node] pnpm (recommended)

| Manager | Strength | Weakness |
|---------|--------|----------|
| **pnpm** | Fast, disk-efficient (symlinks), strict | Needs its own setup action |
| npm | Available everywhere | Slower, flat node_modules |
| yarn | Workspaces, PnP | More complex config |
| bun | Extremely fast | Not yet 100% Node-compatible |

**Always commit lockfile** (`pnpm-lock.yaml`). Always use `--frozen-lockfile` in CI.

### [Python] uv (recommended, 2025+)

uv replaces the old Python tooling:

| Old | New (uv) |
|-----|----------|
| pip + pip-tools | `uv pip install` / `uv pip compile` |
| venv | `uv venv` |
| pyenv | `uv python install` |
| pipx | `uv tool install` |
| poetry / pipenv | `uv init` + `uv add` + `uv sync` |

**Why uv instead of poetry/pipenv:**
- 10-100x faster (Rust-based, by the Ruff makers)
- Unified tool for everything (venv, install, lock, run)
- PEP-compliant (`pyproject.toml` + `uv.lock`)
- Also replaces pyenv for Python version management

**`pyproject.toml` (uv project):**

```toml
[project]
name = "myapp"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
    "fastapi>=0.115.0",
    "httpx>=0.28.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "ruff>=0.9.0",
    "mypy>=1.14.0",
]
```

**Always commit lockfile** (`uv.lock`). Always use `uv sync --frozen` in CI.

---

## 7. Dependency Management (Renovate)

### Renovate (recommended) vs. Dependabot

| Aspect | Renovate | Dependabot |
|--------|----------|------------|
| PR noise | Groups related updates | One PR per dependency |
| Configuration | Extremely flexible | Basic YAML |
| Platforms | GitHub, GitLab, Bitbucket, Azure | GitHub only |
| Monorepo support | Excellent | Limited |
| Dashboard | Dependency Dashboard issue | None |
| Python support | pip, poetry, uv, pipenv | pip, poetry, pipenv |

### Recommended `renovate.json`

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "packageRules": [
    {
      "description": "Group all non-major devDependencies",
      "matchDepTypes": ["devDependencies"],
      "matchUpdateTypes": ["minor", "patch"],
      "groupName": "dev dependencies (non-major)"
    },
    {
      "description": "Automerge patch devDependencies",
      "matchDepTypes": ["devDependencies"],
      "matchUpdateTypes": ["patch"],
      "automerge": true
    },
    {
      "description": "Docker digest updates monthly",
      "matchDatasources": ["docker"],
      "schedule": ["before 6am on the first day of the month"],
      "automerge": false
    }
  ]
}
```

**Important:** Automerge only when CI pipeline exists and required status checks are active.

---

## 8. Code Review Automation

Supplements human review with automated checks.

| Layer | Tool | What it checks |
|---------|------|-------------|
| CI checks | Pipeline (lint, types, build, tests) | Objective quality |
| AI review | Claude Code Review / CodeRabbit | Logic, security, architecture |
| Human review | Required reviewer on PRs | Business logic, design decisions |

### Claude Code Review (GitHub Action)

```yaml
name: Code Review
on:
  pull_request:
    types: [opened, synchronize, ready_for_review, reopened]

jobs:
  review:
    if: github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          review_comment_prompt: |
            Check for: Type safety, error handling, security, performance.
```

### Danger.js (optional, for teams)

Automated PR rules like "description must contain test plan", "API changes require type updates".

### Human Code Review Guidelines

Automation does not replace human review. CI checks _objective quality_ (syntax, types, tests). Humans check _subjective quality_ (design, readability, maintainability).

#### PR Size

| Size | Lines of code | Review quality |
|-------|--------------|-----------------|
| **XS** | < 50 | Fast, thorough |
| **S** | 50-200 | Ideal |
| **M** | 200-500 | Still OK, better to split |
| **L** | 500+ | Review quality drops drastically |

**Rule of thumb:** If a PR is > 400 LOC, split it. Better 3 small PRs than 1 large one. Exception: generated files, migrations, renames.

#### What to Check in Review

| Category | What to look for |
|-----------|--------------|
| **Correctness** | Does the code do what it should? Edge cases? Off-by-one? |
| **Design** | Does it fit the existing architecture? Too complex? Too clever? |
| **Readability** | Understandable without explanation? Good naming? |
| **Security** | Input validation? Secrets? SQL injection? XSS? |
| **Performance** | N+1 queries? Unnecessary loops? Large payloads? |
| **Error handling** | What happens on errors? Are they swallowed? |
| **Tests** | Are the right scenarios tested? |
| **Breaking changes** | API changes affecting other clients? |

#### Review Etiquette

| Rule | Why |
|-------|-------|
| **Ask questions instead of commands** | "Would X be better here?" instead of "Do X" |
| **Give reasons** | "Prefer Y because Z" instead of just "Do Y" |
| **Mark nitpicks** | `nit:` prefix for small things (optional, not blocking) |
| **Mention positives** | Praise good solutions → encourages motivation |
| **Clearly mark blockers** | Must be fixed vs. suggestion/idea |
| **Review promptly** | Within 24 hours, otherwise becomes a bottleneck |

#### PR Template (recommended)

```markdown
## What changes?
<!-- 1-3 sentences: What and why -->

## How was it tested?
<!-- Manual / unit tests / E2E / screenshot -->

## Checklist
- [ ] Tests added/updated
- [ ] No breaking changes (or documented)
- [ ] No secrets in code
```

Place in GitHub under `.github/pull_request_template.md` – automatically pre-filled for every PR.

---

## 9. Testing

### [TS/Node] Recommended Stack

| Level | Tool | What to test | Priority |
|-------|------|-----------|-----------|
| Unit | **Vitest** + React Testing Library | Utilities, transformations, hooks | Must-have |
| Integration | **Vitest** + MSW | API routes, component interactions | Must-have |
| E2E | **Playwright** | Critical user flows | High-value |
| Accessibility | **axe-core** (via Playwright) | WCAG compliance | High-value |

**Why Vitest instead of Jest:**
- Native ESM (no transform needed for Next.js)
- First-class TypeScript support
- 2-5x faster execution
- Jest-compatible API
- Officially recommended by Next.js (since 2025)

**Minimal setup:**

```bash
pnpm add -D vitest @testing-library/react @testing-library/jest-dom msw
```

### [Python] Recommended Stack

| Level | Tool | What to test | Priority |
|-------|------|-----------|-----------|
| Unit | **pytest** | Functions, classes, modules | Must-have |
| Integration | **pytest** + **httpx** (for FastAPI TestClient) | API endpoints, DB interactions | Must-have |
| E2E | **Playwright** | Critical user flows (when frontend) | High-value |
| Coverage | **pytest-cov** | Measure test coverage | High-value |

**Why pytest instead of unittest:**
- Simpler syntax (no classes needed)
- Fixtures instead of setUp/tearDown
- Parametrize for multiple test cases
- Huge plugin ecosystem

**`pyproject.toml` (pytest config):**

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --strict-markers --tb=short"

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
fail_under = 80
show_missing = true
```

**Minimal setup:**

```bash
uv add --dev pytest pytest-cov pytest-asyncio httpx
```

### What to Test First (both ecosystems)

1. API route handlers / endpoints (error handling, edge cases)
2. Data transformations (parsing, validation, mapping)
3. E2E smoke test (app starts, main page loads without errors)

### Why Playwright Instead of Cypress (E2E)

- Multi-browser (Chromium, Firefox, WebKit) with one API
- Fewer dependencies, lighter
- Better async handling
- Built-in accessibility testing
- Same API for TS and Python (`playwright` npm / `pytest-playwright` pip)

---

## 10. Security Scanning (SAST / SCA / Container)

| Type | Tool | Languages | Cost |
|-----|------|----------|--------|
| SAST (code) | **Semgrep** | TS, Python, Go, Java, ... | Free (open source) |
| SCA (dependencies) | **Renovate alerts** / `npm audit` / `pip audit` | All | Free |
| Container | **Trivy** | Docker images | Free |
| Secrets | **gitleaks** | All | Free |

### Trivy in CI

```yaml
- uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:latest
    severity: CRITICAL,HIGH
    exit-code: 1  # Pipeline fails on findings
```

### Semgrep in CI

```yaml
# [TS/Node]
- uses: semgrep/semgrep-action@v1
  with:
    config: p/typescript p/nextjs p/owasp-top-ten

# [Python]
- uses: semgrep/semgrep-action@v1
  with:
    config: p/python p/django p/flask p/owasp-top-ten
```

### [Python] Additionally: pip-audit / safety

```yaml
- run: uv run pip-audit  # Checks installed packages against known CVEs
```

---

## 11. Release Management (Optional)

Only relevant when versioning / changelogs are needed.

| Tool | Approach | For whom |
|------|--------|---------|
| **semantic-release** | Fully automated from Conventional Commits | Hands-off releases |
| **Release Please** (Google) | Creates release PRs for review | Teams that want control |
| **Changesets** | Explicit changeset files | Monorepos, curated changelogs |

For solo projects with auto-deploy (merge to main = deploy): Not needed.

---

## Docker Best Practices (both ecosystems)

### Multi-Stage Builds

```dockerfile
# [TS/Node]
FROM node:22-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM cgr.dev/chainguard/node:latest  # Minimal, secure base image
COPY --from=builder /app/.next/standalone ./
CMD ["server.js"]
```

```dockerfile
# [Python]
FROM python:3.12-slim AS builder
WORKDIR /app
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /app/.venv ./.venv
COPY src ./src
ENV PATH="/app/.venv/bin:$PATH"
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0"]
```

### Checklist

- [ ] Multi-stage build (builder + runner separated)
- [ ] Pin base images with digest (not just tag)
- [ ] `--frozen-lockfile` / `--frozen` in build
- [ ] Non-root user where possible (`USER nonroot`)
- [ ] Define HEALTHCHECK
- [ ] Maintain `.dockerignore` (`.env*`, `.git`, `node_modules`, `__pycache__`)
- [ ] Minimal base image (Alpine, Slim, Chainguard)

---

## Checklist: Setting Up a New Project

### Day 1 (Minimum Viable Setup)

| Step | TS/Node | Python |
|---------|---------|--------|
| Repo init | `git init` | `git init` |
| .gitignore | `.env*`, `node_modules`, `.next` | `.env*`, `__pycache__`, `.venv`, `.mypy_cache` |
| Package manager | `pnpm init` | `uv init` |
| Linting | ESLint flat config + Prettier | Ruff (`ruff check` + `ruff format`) |
| Type checking | TypeScript strict | mypy strict |
| Pre-commit | Husky + lint-staged | pre-commit framework |
| Secret scanning | gitleaks hook | gitleaks hook |
| Project config | Create `CLAUDE.md` | Create `CLAUDE.md` |

### First Week

- [ ] CI pipeline for PRs (lint, typecheck, build/test)
- [ ] Branch protection on `main` (block force push + deletion, require status checks)
- [ ] Repository settings: squash merge only + delete branch on merge
- [ ] Enable secret scanning + push protection on GitHub
- [ ] Enable Dependabot alerts
- [ ] Configure Renovate
- [ ] gitleaks in CI (not just locally)
- [ ] Docker setup with pinned base images (digest, not tag)

### When Production-Ready

- [ ] Set up tests (Vitest / pytest minimum)
- [ ] Security scanning (Trivy for containers, Semgrep for code)
- [ ] Claude Code Review Action
- [ ] Deployment pipeline (build > test > scan > deploy)

---

## Tool Comparison at a Glance

| Category | TS/Node | Python |
|-----------|---------|--------|
| Package manager | **pnpm** | **uv** |
| Linter | **ESLint** (flat config) | **Ruff** |
| Formatter | **Prettier** | **Ruff** (built-in) |
| Type checker | **TypeScript** (tsc) | **mypy** / pyright |
| Test runner | **Vitest** | **pytest** |
| E2E tests | **Playwright** | **Playwright** (pytest-playwright) |
| HTTP mocking | **MSW** | **respx** / httpx MockTransport |
| Pre-commit | **Husky** + lint-staged | **pre-commit** framework |
| CI lockfile | `pnpm install --frozen-lockfile` | `uv sync --frozen` |

---

## References

### General
- [gitleaks GitHub](https://github.com/gitleaks/gitleaks)
- [Renovate Docs](https://docs.renovatebot.com/)
- [Trivy GitHub Action](https://github.com/aquasecurity/trivy-action)
- [Semgrep Rules](https://semgrep.dev/r)
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- [Playwright Docs](https://playwright.dev/)

### TS/Node
- [Next.js Testing Guide](https://nextjs.org/docs/app/guides/testing)
- [Vitest Setup for Next.js](https://nextjs.org/docs/app/guides/testing/vitest)
- [ESLint Flat Config](https://eslint.org/docs/latest/use/configure/configuration-files)
- [pnpm Docs](https://pnpm.io/)

### Python
- [uv Docs](https://docs.astral.sh/uv/)
- [Ruff Docs](https://docs.astral.sh/ruff/)
- [mypy Docs](https://mypy.readthedocs.io/)
- [pytest Docs](https://docs.pytest.org/)
- [pre-commit Framework](https://pre-commit.com/)
