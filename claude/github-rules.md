# GitHub & CI/CD Rules

Verbindliche Regeln fuer Projekt-Setup und CI/CD. Keine Theorie -- nur Entscheidungen.
Detaillierte Erklaerungen: `../reference/github-best-practices.md`

---

## Pre-Commit Hooks

Jedes Projekt MUSS Pre-Commit Hooks haben. Reihenfolge:

1. **Secret Scanning:** `gitleaks protect --staged`
2. **Linting + Auto-Fix:** TS → `eslint --fix`, Python → `ruff --fix`
3. **Formatting:** TS → `prettier --write`, Python → `ruff format`
4. **Type Check:** TS → `tsc --noEmit`, Python → `mypy`

**Setup:** TS → Husky + lint-staged. Python → pre-commit Framework.

---

## Linting & Formatting

### TypeScript/Node
- **ESLint** mit Flat Config (`eslint.config.mjs`) -- altes `.eslintrc` ist deprecated
- **Prettier** als eigenes Tool (nicht als ESLint-Plugin)
- Zusatz-Plugins: `eslint-plugin-security`, `@typescript-eslint/no-floating-promises`
- Alternative fuer Non-Next.js: Biome (15x schneller)

### Python
- **Ruff** fuer alles (ersetzt flake8, black, isort, bandit)
- Config in `pyproject.toml`: `select = ["E", "W", "F", "I", "S", "B", "UP", "RUF"]`
- **mypy** strict fuer CI, **pyright** fuer IDE

---

## CI Pipeline (GitHub Actions)

Jeder PR MUSS durch CI. Minimale Pipeline:

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
  # semgrep ergaenzt ruff-S um cross-file Taint-Analyse
```

### Beide: Separater Secrets-Job
```yaml
secrets:
  - uses: gitleaks/gitleaks-action@v2
```

### Erweitert (wenn Docker)
- Container-Scanning mit Trivy (`severity: CRITICAL,HIGH`, `exit-code: 1`)

---

## Branch Protection

Auf `main` MUESSEN diese Rules aktiv sein:

- Require pull request: **Ja**
- Required approvals: **1** (oder 0 fuer Solo + CI)
- Require status checks: **Ja** (Jobs: `quality`, `secrets`)
- Require up-to-date branch: **Ja**
- Restrict force pushes: **Ja**
- Restrict deletions: **Ja**

Fuer neue Setups: **GitHub Rulesets** bevorzugen (flexibler als Branch Protection).

---

## Repository Settings

Einmalig nach Repo-Erstellung konfigurieren:

- **Merge-Strategie:** Squash merge only (saubere `main`-History, WIP-Commits bleiben im PR)
- **Merge commit + Rebase:** deaktivieren (eine Strategie, kein Mix)
- **Delete branch on merge:** aktivieren (kein manuelles Aufräumen)
- **Secret Scanning + Push Protection:** aktivieren (GitHub blockt Secrets beim Push)
- **Dependabot alerts:** aktivieren

```bash
# Alles auf einmal via GitHub CLI
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

Defense in Depth -- 3 Schichten:

1. **Pre-commit:** gitleaks (lokal, vor jedem Commit)
2. **CI:** gitleaks-action (faengt `--no-verify` ab)
3. **GitHub-nativ:** Secret Scanning + Push Protection aktivieren

---

## Package Management

- **TypeScript:** pnpm (schnell, disk-effizient, strikt). Lockfile immer committen. CI: `--frozen-lockfile`
- **Python:** uv (10-100x schneller als poetry/pipenv, Rust-basiert). Lockfile committen. CI: `uv sync --frozen`

---

## Dependency Management

- **Renovate** (nicht Dependabot) -- gruppiert Updates, weniger PR-Noise, Dashboard Issue
- devDependencies patch: **Automerge** (nur wenn CI + required checks aktiv)
- Docker Digest Updates: **Monatlich**, kein Automerge
- Major Updates: Manuell reviewen

---

## Code Review

### Automatisiert
- CI Checks (lint, types, build, tests) -- objektive Qualitaet
- Claude Code Review Action fuer AI-Review (Security, Logic, Architecture)

### Menschlich
- PR-Groesse: Ideal < 200 LOC, Maximum 400 LOC. Darueber: aufteilen
- Pruefen: Korrektheit, Design, Lesbarkeit, Sicherheit, Performance, Error Handling, Tests
- Fragen statt Befehle, Nitpicks mit `nit:` markieren, Blocker klar kennzeichnen
- Innerhalb 24h reviewen

### PR Template (`.github/pull_request_template.md`)
```markdown
## Was aendert sich?
<!-- 1-3 Saetze -->

## Wie getestet?
<!-- Manuell / Unit Tests / E2E / Screenshot -->

## Checkliste
- [ ] Tests hinzugefuegt/angepasst
- [ ] Keine Breaking Changes (oder dokumentiert)
- [ ] Keine Secrets im Code
```

---

## Testing

### TypeScript/Node
- **Unit + Integration:** Vitest + React Testing Library + MSW
- **E2E:** Playwright (nicht Cypress)
- **Accessibility:** axe-core via Playwright

### Python
- **Unit + Integration:** pytest + httpx (FastAPI TestClient) + pytest-cov
- **E2E:** Playwright (pytest-playwright)
- Config in `pyproject.toml`: `fail_under = 80`

### Prioritaet
1. API Route Handler / Endpoints
2. Data Transformationen (Parsing, Validierung)
3. E2E Smoke Test (App startet, Hauptseite laedt)

---

## Security Scanning

| Typ | Tool | Kosten |
|-----|------|--------|
| SAST (Code) | **Semgrep** | Free |
| SCA (Dependencies) | `npm audit` / `pip-audit` | Free |
| Container | **Trivy** | Free |
| Secrets | **gitleaks** | Free |

Alle in CI integrieren. Trivy und Semgrep mit `exit-code: 1` (Pipeline schlaegt fehl bei Findings).

---

## Docker

- **Multi-Stage Build:** Builder + Runner getrennt
- Base Images mit **Digest pinnen** (nicht nur Tag)
- `--frozen-lockfile` / `--frozen` im Build
- **Non-root User** (`USER nonroot`)
- HEALTHCHECK definieren
- `.dockerignore` pflegen (`.env*`, `.git`, `node_modules`, `__pycache__`)
- Minimales Base Image (Alpine, Slim, Chainguard)

---

## Release Management

- Solo mit Auto-Deploy (merge to main = deploy): **Nicht noetig**
- Wenn Versioning noetig: **Release Please** (Google) fuer kontrollierte Releases
- Voll automatisiert: **semantic-release** (braucht Conventional Commits)

---

## Checkliste: Neues Projekt

### Tag 1
- [ ] git init + .gitignore
- [ ] Package Manager (pnpm / uv)
- [ ] Linting + Formatting (ESLint+Prettier / Ruff)
- [ ] Type Checking strict (TypeScript / mypy)
- [ ] Pre-commit Hooks (Husky / pre-commit)
- [ ] gitleaks Hook
- [ ] CLAUDE.md anlegen

### Erste Woche
- [ ] CI Pipeline (lint, typecheck, build/test)
- [ ] Branch Protection auf main
- [ ] Renovate konfigurieren
- [ ] gitleaks in CI
- [ ] Docker Setup mit pinned Base Images

### Production-ready
- [ ] Tests (Vitest / pytest)
- [ ] Security Scanning (Trivy, Semgrep)
- [ ] Claude Code Review Action
- [ ] Secret Scanning auf GitHub
- [ ] Deployment Pipeline
