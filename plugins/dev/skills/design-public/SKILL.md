---
name: dev:design-public
description: >
  Publication-readiness design skill grounded in OpenSSF Best Practices,
  GitHub Security Hardening docs, CISA Security-by-Design, OWASP DevSecOps
  Guideline, and SLSA v1.0. Use this skill whenever the user wants to plan
  making a private repository public, open-source a project, or prepare a
  codebase for public visibility. Trigger for: "repo public machen",
  "open source vorbereiten", "wie gehe ich public", "publication plan",
  "what do I need to do before open sourcing", "repo veröffentlichen".
  Produces a phased, actionable publication plan with specific commands,
  file templates, and ordered steps.
---
# Repo Publication Design Skill

A structured planning workflow for safely making a private repository public.
Grounded in industry standards — not academic theory.

**Primary sources:** OpenSSF Best Practices, GitHub Security Hardening,
CISA Security-by-Design (2023), OWASP DevSecOps Guideline, SLSA v1.0,
OpenSSF Scorecard, NIST SSDF SP 800-218.

---

## Core Philosophy

Going public is irreversible in practice. Every commit, every secret, every
real email address in a test fixture becomes permanently accessible — even
after deletion — because git history is immutable and forks may already exist.

The plan is built in order of urgency:
1. **Stop the bleeding** — what can never go public
2. **Fix the history** — remove what already slipped
3. **Set up the house** — governance, license, policy docs
4. **Harden the platform** — branch protection, CI/CD, supply chain
5. **Maintain ongoing** — scanning, dependency updates, disclosure

---

## Design Workflow

### Phase 0 — Understand the Repo

Before planning, ask (or infer from context):

1. **What does the repo contain?** (app, library, config, scripts, infra-as-code)
2. **Current visibility?** (private → public, or already public)
3. **Who contributed?** (solo, small team, company) — affects IP and license choice
4. **What tech stack?** — informs which secret patterns and package managers to scan
5. **Any compliance requirements?** (GDPR, EU AI Act, export control)
6. **Is there existing CI/CD?** (GitHub Actions, GitLab CI, CircleCI, etc.)

If the user skips context, ask the two most critical questions:
*"What language/stack?" and "Is there existing CI/CD?"*

---

### Phase 1 — Secrets & History Audit

Load `references/scan-checklist.md` for specific patterns and commands.

**1a. Pre-publication secret scan (current state)**

Run gitleaks across the FULL git history (not just HEAD):
```bash
# Install: brew install gitleaks / choco install gitleaks
gitleaks detect --source . --log-opts="--all" --report-format json \
  --report-path gitleaks-report.json
```

Also scan with truffleHog for live-verified leaks:
```bash
trufflehog git file://. --only-verified --json > trufflehog-report.json
```

**1b. If secrets found in history — remediate properly**

Deleting from HEAD is NOT sufficient. Git's immutable object model preserves
leaks in every clone and fork. Use:

```bash
# Recommended: git-filter-repo (modern, maintained)
pip install git-filter-repo
git filter-repo --path-glob '*.env' --invert-paths
git filter-repo --replace-text secrets-to-remove.txt

# Or: BFG Repo-Cleaner (faster for large repos)
java -jar bfg.jar --replace-text passwords.txt my-repo.git
```

After rewriting history:
- Force-push all branches: `git push --force --all`
- Force-push all tags: `git push --force --tags`
- Revoke and rotate ALL exposed credentials immediately — treat them as compromised
- Notify any forks (GitHub does not auto-update forks after history rewrite)
- Contact GitHub/GitLab support to purge cached data if repo was briefly public

**1c. PII in test data**

Search for real data patterns that must not be public:
```bash
# Phone numbers (international)
grep -rE '\+?[0-9]{1,3}[-.\s]?\(?[0-9]{1,4}\)?[-.\s]?[0-9]{1,4}[-.\s]?[0-9]{1,9}' \
  tests/ fixtures/ --include="*.json" --include="*.csv" --include="*.sql"

# Email addresses
grep -rE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
  tests/ fixtures/ --include="*.json" --include="*.py" --include="*.ts"

# Austrian/German IBANs
grep -rE 'AT[0-9]{18}|DE[0-9]{20}' tests/ fixtures/

# Austrian SSN / Sozialversicherungsnummer
grep -rE '\b[0-9]{4}[0-9]{6}\b' tests/ fixtures/
```

Replace with obviously fake data:
- Phone: `+43 800 000000` (reserved/fictitious)
- Email: `test@example.com` (RFC 2606 reserved)
- IBAN: `AT12 3456 7890 1234 5678` (invalid checksum — won't pass validation)
- Names: `Max Mustermann` / `Erika Musterfrau` (Austrian standard test names)

---

### Phase 2 — Governance Files

These files are not bureaucracy — they are trust signals that the open-source
community, security researchers, and downstream users look for immediately.

**Required files:**

| File | Location | Purpose |
|---|---|---|
| `LICENSE` | `/` | Legal basis for use/modification (required by OSI) |
| `SECURITY.md` | `/` or `/.github/` | Vulnerability disclosure process |
| `README.md` | `/` | What it is, how to install/use it |
| `.gitignore` | `/` | Prevent accidental future leaks |
| `.env.example` | `/` | Documents required env vars without actual values |

**Optional but high-signal:**

| File | Purpose |
|---|---|
| `CONTRIBUTING.md` | How to contribute |
| `CODE_OF_CONDUCT.md` | Community standards |
| `CHANGELOG.md` | Version history |
| `CODEOWNERS` | Who reviews what |

**LICENSE selection guide:**

Load `references/license-guide.md` for detailed comparison. Quick guide:

| Use case | License |
|---|---|
| Maximum freedom, attribution only | MIT |
| Attribution + patent protection | Apache 2.0 |
| Copyleft (derivatives must stay open) | GPL-3.0 |
| Library, weak copyleft | LGPL-2.1 |
| "Don't use this commercially without paying" | AGPL-3.0 or BSL |

**SECURITY.md minimum content:**
```markdown
# Security Policy

## Supported Versions
| Version | Supported |
|---------|-----------|
| 1.x     | ✅        |
| < 1.0   | ❌        |

## Reporting a Vulnerability
Please DO NOT open a public GitHub issue for security vulnerabilities.

Email: security@yourdomain.com
Response time: 48 hours
Disclosure timeline: 90 days (coordinated disclosure)

We follow the [OpenSSF CVD Guide](https://github.com/ossf/oss-vulnerability-guide).
```

---

### Phase 3 — Repository Settings Hardening

**Branch Protection (main/master):**
```text
Settings → Branches → Branch protection rules → Add rule

✅ Require pull request before merging
✅ Require approvals: 1 (for solo: 0 but at least require PR)
✅ Require status checks to pass before merging
✅ Require branches to be up to date before merging
✅ Require signed commits (if using GPG/SSH signing)
✅ Do not allow bypassing the above settings
❌ Allow force pushes → OFF
❌ Allow deletions → OFF
```

**GitHub Security Features (Settings → Security):**
```text
✅ Dependency graph
✅ Dependabot alerts
✅ Dependabot security updates
✅ Secret scanning (auto-enabled for public repos)
✅ Secret scanning push protection (blocks commits with secrets)
✅ Private vulnerability reporting
```

**GitHub Actions Permissions (Settings → Actions):**
```text
Read repository contents and packages permissions (not write)
Allow only actions from GitHub and verified marketplace creators
Require approval for fork pull request workflows
```

---

### Phase 4 — CI/CD Hardening

**Pin all Actions to commit SHA** (supply chain attack prevention):
```yaml
# WRONG — version tag can be moved by attacker
- uses: actions/checkout@v4

# CORRECT — immutable SHA pin
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

Use [pin-github-action](https://github.com/mheap/pin-github-action) or Renovate
to automate SHA pinning and updates.

**Minimal permissions per job:**
```yaml
jobs:
  build:
    permissions:
      contents: read      # never write unless publishing
      id-token: write     # only if using OIDC/Sigstore
      packages: write     # only if publishing packages
```

**Secret scanning in CI (belt-and-suspenders):**
```yaml
- name: Gitleaks scan
  uses: gitleaks/gitleaks-action@v2
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Dependency scanning:**
```yaml
# Python
- run: pip-audit --require-hashes -r requirements.txt

# Node.js
- run: npm audit --audit-level=high

# Or use Dependabot (automatically configured via .github/dependabot.yml)
```

---

### Phase 5 — Supply Chain Readiness

**OpenSSF Scorecard** (automated scoring across 10+ security dimensions):
```yaml
# .github/workflows/scorecard.yml
- uses: ossf/scorecard-action@v2
  with:
    results_file: scorecard.sarif
    publish_results: true
```

**SLSA Provenance** (for published packages/releases):
- L1: Add provenance generation to CI (unsigned, documents build inputs)
- L2: Use GitHub Actions hosted runners + signed provenance (achievable now)
- L3: Hermetic builds + isolated signing (advanced, for critical infrastructure)

```yaml
# SLSA L2 provenance via slsa-framework
- uses: slsa-framework/slsa-github-generator/.github/workflows/generator_generic_slsa3.yml@v2
```

**Sigstore keyless signing** (for release artifacts):
```bash
# Sign a release artifact
cosign sign-blob --bundle artifact.bundle my-release.tar.gz

# Verify
cosign verify-blob --bundle artifact.bundle my-release.tar.gz
```

---

## Output — Publication Plan

Write the result to `./design-public-plan.md`:

```markdown
# Repository Publication Plan — [Repo Name]
Date: YYYY-MM-DD | Stack: ... | CI: ...

## Pre-flight Checklist
### 🔴 BLOCKER — Must complete before going public
- [ ] Run full history secret scan (gitleaks + truffleHog)
- [ ] Audit test fixtures for real PII (phone, email, IBAN, SSN)
- [ ] Remove/replace all real credentials from history
- [ ] Rotate any exposed secrets immediately

### 🟠 HIGH — Complete within first week
- [ ] Add LICENSE file
- [ ] Add SECURITY.md with disclosure process
- [ ] Add/update .gitignore
- [ ] Remove .env, add .env.example
- [ ] Enable branch protection on main
- [ ] Enable GitHub Secret Scanning + Push Protection
- [ ] Enable Dependabot alerts + security updates

### 🟡 MEDIUM — Complete within first month
- [ ] Pin all CI Actions to SHA
- [ ] Add gitleaks to CI pipeline
- [ ] Add dependency scanning to CI
- [ ] Set minimal permissions per CI job
- [ ] Add OpenSSF Scorecard workflow

### 🔵 ONGOING — Maintain
- [ ] Review Dependabot PRs weekly
- [ ] Monitor secret scanning alerts
- [ ] Respond to vulnerability reports within 48h
- [ ] Re-run gitleaks on major PRs

## Findings Summary
[Secrets found: N | PII patterns: N | Missing files: N]

## Estimated Effort
[Hours to completion per phase]
```

---

## Interaction Patterns

### When the user says "just give me the checklist"

Give Phase 1 blockers immediately. Don't gate on Phase 0 questions.

### When secrets are found in history

Pause the design and escalate: "Before we plan anything else — these
secrets need to be rotated NOW, regardless of whether the repo goes public.
Treat them as compromised."

### When the user says "we don't have real data in tests"

Don't take this at face value. Run the grep patterns from Phase 1c.
Developers often don't know what's in old test fixtures or seed files.

### When the user asks "which license?"

Ask one question: "Do you want derivatives to stay open source?" Yes → GPL/AGPL.
No → MIT or Apache 2.0 (Apache adds patent protection).

---

## Reference Files

Load on demand:

- `references/scan-checklist.md` — Tool commands, secret patterns, PII regex library
- `references/industry-sources.md` — Authoritative sources with URLs and authority ratings
- `references/license-guide.md` — License comparison, compatibility matrix, use cases
