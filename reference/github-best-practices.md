# GitHub Setup Best Practices

Referenz-Checkliste für neue Projekte (Stand: März 2026).
Framework-spezifische Abschnitte sind mit **[TS/Node]** bzw. **[Python]** markiert.

---

## 1. Pre-Commit Hooks

Lokale Quality-Gates bevor Code überhaupt ins Repo kommt.

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

**`package.json` (lint-staged Config):**

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
      - id: ruff          # Linting (ersetzt flake8, isort, pyflakes, etc.)
        args: [--fix]
      - id: ruff-format   # Formatting (ersetzt black)

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.14.0
    hooks:
      - id: mypy
        additional_dependencies: [types-requests]  # Type Stubs nach Bedarf
```

### Empfohlene Checks (beide Ökosysteme)

| Reihenfolge | Check | TS/Node Tool | Python Tool |
|-------------|-------|-------------|-------------|
| 1 | Secret Scanning | `gitleaks` | `gitleaks` |
| 2 | Linting + Auto-Fix | `eslint --fix` | `ruff --fix` |
| 3 | Formatting | `prettier --write` | `ruff format` |
| 4 | Type Check | `tsc --noEmit` | `mypy` |

**Optional:** `commitlint` für Conventional Commits – nur sinnvoll wenn man automated releases (semantic-release) nutzen will.

---

## 2. Linting & Formatting

### [TS/Node] ESLint + Prettier

**ESLint:**
- **Flat Config** (`eslint.config.mjs`) ist der Standard seit ESLint 9. Altes `.eslintrc` Format ist deprecated.
- Für Next.js: `eslint-config-next` (enthält bereits TypeScript, React Hooks, Import-Checks, Core Web Vitals)
- `eslint-config-prettier` um Konflikte mit Prettier zu vermeiden

**Empfohlene Zusatz-Plugins:**

| Plugin | Was es macht |
|--------|-------------|
| `eslint-plugin-security` | Fängt `eval()`, unsichere RegEx, etc. |
| `@typescript-eslint/no-floating-promises` | Vergessene `await` Statements |

**Prettier:**
- Als eigenständiges Tool, nicht als ESLint-Plugin
- `.prettierrc` im Repo für konsistente Formatierung
- `.prettierignore` für generierte Dateien

**Alternative: Biome**
- Rust-basiert, 15x schneller, Linter + Formatter in einem
- Stand 2026: Noch keine volle Parität mit `eslint-config-next`
- Für Non-Next.js Projekte bereits empfehlenswert

### [Python] Ruff (All-in-One)

Ruff ersetzt das gesamte alte Python-Tooling in einem einzigen Rust-basierten Tool:

| Alt (2023) | Neu (2025+) |
|------------|-------------|
| flake8 | `ruff check` |
| black | `ruff format` |
| isort | `ruff check --select I` |
| pyflakes | in ruff enthalten |
| pycodestyle | in ruff enthalten |
| bandit (Security) | `ruff check --select S` |

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
    "S",    # bandit (Security)
    "B",    # bugbear
    "UP",   # pyupgrade
    "RUF",  # ruff-spezifische Regeln
]

[tool.ruff.format]
quote-style = "double"
```

### [Python] Type Checking: mypy vs. pyright

| Tool | Stärke | Schwäche |
|------|--------|----------|
| **mypy** | Standard, großes Ökosystem, viele Type Stubs | Langsamer |
| **pyright** (Microsoft) | Schneller, besser bei Inferenz, VS Code Integration | Weniger verbreitet in CI |

**Empfehlung:** mypy für CI, pyright für IDE-Integration. Beide in `strict` Mode.

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

**Wichtigste Regel:** Jeder PR muss durch CI, bevor er gemergt werden kann.

### [TS/Node] Minimale CI-Pipeline

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

### [Python] Minimale CI-Pipeline

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

### Warum jeder Schritt wichtig ist

| Schritt | TS/Node | Python | Fängt ab |
|---------|---------|--------|----------|
| Install | `pnpm install --frozen-lockfile` | `uv sync --frozen` | Lockfile-Drift |
| Lint | `pnpm lint` | `ruff check` | Code-Qualität |
| Format-Check | (in lint enthalten) | `ruff format --check` | Inkonsistente Formatierung |
| Type Check | `tsc --noEmit` | `mypy` | Type-Fehler |
| Build/Test | `pnpm build` | `pytest` | Build-/Test-Fehler |
| Secrets | `gitleaks` | `gitleaks` | `--no-verify` Bypasses |

### Erweiterte Pipeline (beide Ökosysteme)

```yaml
  # Container-Scanning mit Trivy
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

### [Python] Matrix-Testing (mehrere Python-Versionen)

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

Technische Durchsetzung von "nie direkt auf main pushen". Gilt für beide Ökosysteme identisch.

### Empfohlene Konfiguration für `main`

| Setting | Wert | Warum |
|---------|------|-------|
| Require pull request | Ja | Erzwingt Review-Prozess |
| Required approvals | 1 (oder 0 für Solo + CI) | Vier-Augen-Prinzip |
| Require status checks | Ja | Gate auf CI-Ergebnisse |
| Required checks | `quality`, `secrets` | Spezifische Jobs die passen müssen |
| Require up-to-date branch | Ja | Verhindert Merge-Konflikte auf main |
| Restrict force pushes | Ja | Kein History-Rewriting auf main |
| Restrict deletions | Ja | Kein versehentliches Branch-Löschen |

**GitHub Rulesets** (neuer) vs. **Branch Protection** (klassisch): Rulesets sind flexibler (mehrere Branches, Tag-Rules). Für neue Setups Rulesets bevorzugen.

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

Einmalig pro Repo konfigurieren. Gilt für beide Ökosysteme identisch.

### Merge-Strategie

Nur eine Strategie aktivieren — Konsistenz schlägt Flexibilität.

| Strategie | History | Wann verwenden |
|---|---|---|
| **Squash merge** | Ein Commit pro PR — sauber, lesbar | Solo oder kleine Teams mit kurzen Feature-Branches |
| Merge commit | Vollständige Branch-History | Teams die jeden WIP-Commit in `main` brauchen |
| Rebase merge | Lineare History, alle Commits einzeln | Teams mit disziplinierten Commits ohne WIP-Rauschen |

**Empfehlung: Squash only.** PR-Titel wird automatisch Commit-Message in `main`. WIP-Commits bleiben im PR sichtbar, verschwinden aber aus `main`.

### Empfohlene Konfiguration

| Setting | Wert | Warum |
|---|---|---|
| Allow squash merge | Ja | Saubere, lesbare `main`-History |
| Allow merge commit | Nein | Verhindert Merge-Commit-Noise |
| Allow rebase merge | Nein | Eine Strategie, kein Mix |
| Delete branch on merge | Ja | Kein manuelles Aufräumen alter Feature-Branches |

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

Defense in Depth: Mehrere Schichten. Gilt für beide Ökosysteme identisch.

| Schicht | Tool | Wann |
|---------|------|------|
| Pre-commit | gitleaks | Vor jedem Commit (lokal) |
| CI | gitleaks-action | Bei jedem PR (fängt `--no-verify` ab) |
| GitHub-nativ | Secret Scanning + Push Protection | Kontinuierlich (kostenlos für public Repos) |

### gitleaks Konfiguration

Standard-Config reicht meistens. Für Custom-Patterns:

```toml
# .gitleaks.toml
[allowlist]
  paths = ["docs/examples/"]  # Beispiel-Dateien ignorieren
```

### GitHub Secret Scanning aktivieren

Settings > Code security > Secret scanning > Enable

Mit **Push Protection** werden Pushes geblockt die bekannte Secret-Patterns enthalten, noch bevor sie das Repo erreichen.

Via GitHub CLI:

```bash
gh api repos/{owner}/{repo} --method PATCH \
  -f 'security_and_analysis[secret_scanning][status]=enabled' \
  -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'

# Dependabot alerts aktivieren
gh api repos/{owner}/{repo}/vulnerability-alerts --method PUT
```

---

## 6. Package Management

### [TS/Node] pnpm (empfohlen)

| Manager | Stärke | Schwäche |
|---------|--------|----------|
| **pnpm** | Schnell, disk-effizient (symlinks), strikt | Braucht eigene Setup-Action |
| npm | Überall vorhanden | Langsamer, flache node_modules |
| yarn | Workspaces, PnP | Komplexere Config |
| bun | Extrem schnell | Noch nicht 100% Node-kompatibel |

**Lockfile immer committen** (`pnpm-lock.yaml`). In CI immer `--frozen-lockfile`.

### [Python] uv (empfohlen, 2025+)

uv ersetzt das alte Python-Tooling:

| Alt | Neu (uv) |
|-----|----------|
| pip + pip-tools | `uv pip install` / `uv pip compile` |
| venv | `uv venv` |
| pyenv | `uv python install` |
| pipx | `uv tool install` |
| poetry / pipenv | `uv init` + `uv add` + `uv sync` |

**Warum uv statt poetry/pipenv:**
- 10-100x schneller (Rust-basiert, von den Ruff-Machern)
- Einheitliches Tool für alles (venv, install, lock, run)
- PEP-konform (`pyproject.toml` + `uv.lock`)
- Ersetzt auch pyenv für Python-Version-Management

**`pyproject.toml` (uv-Projekt):**

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

**Lockfile immer committen** (`uv.lock`). In CI immer `uv sync --frozen`.

---

## 7. Dependency Management (Renovate)

### Renovate (empfohlen) vs. Dependabot

| Aspekt | Renovate | Dependabot |
|--------|----------|------------|
| PR-Noise | Gruppiert verwandte Updates | Ein PR pro Dependency |
| Konfiguration | Extrem flexibel | Basic YAML |
| Plattformen | GitHub, GitLab, Bitbucket, Azure | Nur GitHub |
| Monorepo-Support | Exzellent | Eingeschränkt |
| Dashboard | Dependency Dashboard Issue | Keines |
| Python Support | pip, poetry, uv, pipenv | pip, poetry, pipenv |

### Empfohlene `renovate.json`

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "packageRules": [
    {
      "description": "Gruppiere alle non-major devDependencies",
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
      "description": "Docker Digest Updates monatlich",
      "matchDatasources": ["docker"],
      "schedule": ["before 6am on the first day of the month"],
      "automerge": false
    }
  ]
}
```

**Wichtig:** Automerge nur wenn CI-Pipeline existiert und required Status Checks aktiv sind.

---

## 8. Code Review Automation

Ergänzt menschliches Review mit automatischen Checks.

| Schicht | Tool | Was es prüft |
|---------|------|-------------|
| CI Checks | Pipeline (lint, types, build, tests) | Objektive Qualität |
| AI Review | Claude Code Review / CodeRabbit | Logik, Security, Architektur |
| Human Review | Required Reviewer auf PRs | Business-Logik, Design-Entscheidungen |

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
            Prüfe auf: Type Safety, Error Handling, Security, Performance.
```

### Danger.js (optional, für Teams)

Automatische PR-Regeln wie "Beschreibung muss Testplan enthalten", "API-Änderungen brauchen Type-Updates".

### Menschliche Code Review Guidelines

Automatisierung ersetzt kein menschliches Review. CI prüft _objektive Qualität_ (Syntax, Types, Tests). Menschen prüfen _subjektive Qualität_ (Design, Lesbarkeit, Wartbarkeit).

#### PR-Größe

| Größe | Lines of Code | Review-Qualität |
|-------|--------------|-----------------|
| **XS** | < 50 | Schnell, gründlich |
| **S** | 50-200 | Ideal |
| **M** | 200-500 | Noch okay, besser aufteilen |
| **L** | 500+ | Review-Qualität sinkt drastisch |

**Faustregel:** Wenn ein PR > 400 LOC ist, aufteilen. Lieber 3 kleine PRs als 1 großer. Ausnahme: generierte Dateien, Migrationen, Renames.

#### Was beim Review prüfen

| Kategorie | Worauf achten |
|-----------|--------------|
| **Korrektheit** | Tut der Code was er soll? Edge Cases? Off-by-one? |
| **Design** | Passt es zur bestehenden Architektur? Zu komplex? Zu clever? |
| **Lesbarkeit** | Verständlich ohne Erklärung? Gute Benennung? |
| **Sicherheit** | Input-Validierung? Secrets? SQL Injection? XSS? |
| **Performance** | N+1 Queries? Unnötige Loops? Große Payloads? |
| **Error Handling** | Was passiert bei Fehlern? Werden sie verschluckt? |
| **Tests** | Sind die richtigen Szenarien getestet? |
| **Breaking Changes** | API-Änderungen die andere Clients betreffen? |

#### Review-Etikette

| Regel | Warum |
|-------|-------|
| **Fragen statt Befehle** | "Wäre X hier besser?" statt "Mach X" |
| **Begründen** | "Lieber Y weil Z" statt nur "Mach Y" |
| **Nitpicks kennzeichnen** | `nit:` Prefix für Kleinigkeiten (optional, nicht blockierend) |
| **Positives erwähnen** | Gute Lösungen loben → fördert Motivation |
| **Blocker klar markieren** | Muss gefixt werden vs. Vorschlag/Idee |
| **Zeitnah reviewen** | Innerhalb von 24h, sonst wird es zum Bottleneck |

#### PR-Template (empfohlen)

```markdown
## Was ändert sich?
<!-- 1-3 Sätze: Was und Warum -->

## Wie getestet?
<!-- Manuell / Unit Tests / E2E / Screenshot -->

## Checkliste
- [ ] Tests hinzugefügt/angepasst
- [ ] Keine Breaking Changes (oder dokumentiert)
- [ ] Keine Secrets im Code
```

In GitHub unter `.github/pull_request_template.md` ablegen – wird automatisch bei jedem PR vorausgefüllt.

---

## 9. Testing

### [TS/Node] Empfohlener Stack

| Level | Tool | Was testen | Priorität |
|-------|------|-----------|-----------|
| Unit | **Vitest** + React Testing Library | Utilities, Transformationen, Hooks | Must-Have |
| Integration | **Vitest** + MSW | API Routes, Component-Interaktionen | Must-Have |
| E2E | **Playwright** | Kritische User Flows | High-Value |
| Accessibility | **axe-core** (via Playwright) | WCAG Compliance | High-Value |

**Warum Vitest statt Jest:**
- Natives ESM (kein Transform nötig für Next.js)
- First-class TypeScript Support
- 2-5x schnellere Ausführung
- Jest-kompatibles API
- Offiziell von Next.js empfohlen (seit 2025)

**Minimales Setup:**

```bash
pnpm add -D vitest @testing-library/react @testing-library/jest-dom msw
```

### [Python] Empfohlener Stack

| Level | Tool | Was testen | Priorität |
|-------|------|-----------|-----------|
| Unit | **pytest** | Funktionen, Klassen, Module | Must-Have |
| Integration | **pytest** + **httpx** (für FastAPI TestClient) | API Endpoints, DB-Interaktionen | Must-Have |
| E2E | **Playwright** | Kritische User Flows (wenn Frontend) | High-Value |
| Coverage | **pytest-cov** | Test-Abdeckung messen | High-Value |

**Warum pytest statt unittest:**
- Einfachere Syntax (keine Klassen nötig)
- Fixtures statt setUp/tearDown
- Parametrize für mehrere Testfälle
- Riesiges Plugin-Ökosystem

**`pyproject.toml` (pytest Config):**

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

**Minimales Setup:**

```bash
uv add --dev pytest pytest-cov pytest-asyncio httpx
```

### Was zuerst testen (beide Ökosysteme)

1. API Route Handler / Endpoints (Error-Handling, Edge Cases)
2. Data Transformationen (Parsing, Validierung, Mapping)
3. E2E Smoke Test (App startet, Hauptseite lädt ohne Fehler)

### Warum Playwright statt Cypress (E2E)

- Multi-Browser (Chromium, Firefox, WebKit) mit einem API
- Weniger Dependencies, leichter
- Besseres Async-Handling
- Built-in Accessibility Testing
- Gleiche API für TS und Python (`playwright` npm / `pytest-playwright` pip)

---

## 10. Security Scanning (SAST / SCA / Container)

| Typ | Tool | Sprachen | Kosten |
|-----|------|----------|--------|
| SAST (Code) | **Semgrep** | TS, Python, Go, Java, ... | Free (Open Source) |
| SCA (Dependencies) | **Renovate Alerts** / `npm audit` / `pip audit` | Alle | Free |
| Container | **Trivy** | Docker Images | Free |
| Secrets | **gitleaks** | Alle | Free |

### Trivy in CI

```yaml
- uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:latest
    severity: CRITICAL,HIGH
    exit-code: 1  # Pipeline schlägt fehl bei Findings
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

### [Python] Zusätzlich: pip-audit / safety

```yaml
- run: uv run pip-audit  # Prüft installierte Packages gegen bekannte CVEs
```

---

## 11. Release Management (Optional)

Nur relevant wenn man Versioning / Changelogs braucht.

| Tool | Ansatz | Für wen |
|------|--------|---------|
| **semantic-release** | Voll automatisiert aus Conventional Commits | Hands-off Releases |
| **Release Please** (Google) | Erstellt Release-PRs zum Review | Teams die Kontrolle wollen |
| **Changesets** | Explizite Changeset-Dateien | Monorepos, kuratierte Changelogs |

Für Solo-Projekte mit Auto-Deploy (merge to main = deploy): Nicht nötig.

---

## Docker Best Practices (beide Ökosysteme)

### Multi-Stage Builds

```dockerfile
# [TS/Node]
FROM node:22-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM cgr.dev/chainguard/node:latest  # Minimales, sicheres Base Image
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

### Checkliste

- [ ] Multi-Stage Build (Builder + Runner getrennt)
- [ ] Base Images mit Digest pinnen (nicht nur Tag)
- [ ] `--frozen-lockfile` / `--frozen` im Build
- [ ] Non-root User wenn möglich (`USER nonroot`)
- [ ] HEALTHCHECK definieren
- [ ] `.dockerignore` pflegen (`.env*`, `.git`, `node_modules`, `__pycache__`)
- [ ] Minimales Base Image (Alpine, Slim, Chainguard)

---

## Checkliste: Neues Projekt aufsetzen

### Tag 1 (Minimum Viable Setup)

| Schritt | TS/Node | Python |
|---------|---------|--------|
| Repo init | `git init` | `git init` |
| .gitignore | `.env*`, `node_modules`, `.next` | `.env*`, `__pycache__`, `.venv`, `.mypy_cache` |
| Package Manager | `pnpm init` | `uv init` |
| Linting | ESLint Flat Config + Prettier | Ruff (`ruff check` + `ruff format`) |
| Type Checking | TypeScript strict | mypy strict |
| Pre-commit | Husky + lint-staged | pre-commit Framework |
| Secret Scanning | gitleaks Hook | gitleaks Hook |
| Projekt-Config | `CLAUDE.md` anlegen | `CLAUDE.md` anlegen |

### Erste Woche

- [ ] CI Pipeline für PRs (lint, typecheck, build/test)
- [ ] Branch Protection auf `main` aktivieren (force push + deletion blockieren, status checks required)
- [ ] Repository Settings: Squash merge only + delete branch on merge aktivieren
- [ ] Secret Scanning + Push Protection auf GitHub aktivieren
- [ ] Dependabot alerts aktivieren
- [ ] Renovate konfigurieren
- [ ] gitleaks in CI (nicht nur lokal)
- [ ] Docker Setup mit pinned Base Images (Digest, nicht Tag)

### Wenn Production-ready

- [ ] Tests einrichten (Vitest / pytest minimum)
- [ ] Security Scanning (Trivy für Container, Semgrep für Code)
- [ ] Claude Code Review Action
- [ ] Deployment Pipeline (Build > Test > Scan > Deploy)

---

## Tool-Vergleich auf einen Blick

| Kategorie | TS/Node | Python |
|-----------|---------|--------|
| Package Manager | **pnpm** | **uv** |
| Linter | **ESLint** (Flat Config) | **Ruff** |
| Formatter | **Prettier** | **Ruff** (built-in) |
| Type Checker | **TypeScript** (tsc) | **mypy** / pyright |
| Test Runner | **Vitest** | **pytest** |
| E2E Tests | **Playwright** | **Playwright** (pytest-playwright) |
| HTTP Mocking | **MSW** | **respx** / httpx MockTransport |
| Pre-commit | **Husky** + lint-staged | **pre-commit** Framework |
| CI Lockfile | `pnpm install --frozen-lockfile` | `uv sync --frozen` |

---

## Referenzen

### Allgemein
- [gitleaks GitHub](https://github.com/gitleaks/gitleaks)
- [Renovate Docs](https://docs.renovatebot.com/)
- [Trivy GitHub Action](https://github.com/aquasecurity/trivy-action)
- [Semgrep Rules](https://semgrep.dev/r)
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- [Playwright Docs](https://playwright.dev/)

### TS/Node
- [Next.js Testing Guide](https://nextjs.org/docs/app/guides/testing)
- [Vitest Setup für Next.js](https://nextjs.org/docs/app/guides/testing/vitest)
- [ESLint Flat Config](https://eslint.org/docs/latest/use/configure/configuration-files)
- [pnpm Docs](https://pnpm.io/)

### Python
- [uv Docs](https://docs.astral.sh/uv/)
- [Ruff Docs](https://docs.astral.sh/ruff/)
- [mypy Docs](https://mypy.readthedocs.io/)
- [pytest Docs](https://docs.pytest.org/)
- [pre-commit Framework](https://pre-commit.com/)
