---
name: dev:review-public
description: >
  Pre-publication repository scan grounded in OpenSSF Best Practices, GitHub
  Security Hardening docs, CISA Security-by-Design (2023), OWASP DevSecOps
  Guideline, GitGuardian State of Secrets Sprawl, and OpenSSF Scorecard.
  Use this skill whenever the user wants to audit a repository before or after
  going public, check if a repo is safe to open-source, or find secrets/PII/
  configuration gaps before publication. Trigger for: "repo public scan",
  "is this safe to publish", "check before open source", "secrets check",
  "repo audit", "pre-publication review", "repo öffentlich machen check",
  "scan vor veröffentlichung". Produces a severity-rated findings report with
  concrete remediation steps for every issue found.
---
# Repo Public Scan Skill

A structured, concrete repository audit for safe publication.
Every finding includes what to run, what to look for, and how to fix it.

**Primary sources:** OpenSSF Best Practices Badge, GitHub Security Hardening,
CISA Security-by-Design (2023), OWASP DevSecOps Guideline v1.1,
GitGuardian State of Secrets Sprawl (annual), OpenSSF Scorecard,
NIST SSDF SP 800-218, SLSA v1.0.

---

## Core Philosophy

This is not a theoretical review. It is a scan. Every dimension either:
- **Passes** — evidence that the control exists and works
- **Fails** — concrete finding with remediation command or step
- **Needs manual check** — automated scan can't determine this; here's how to check

The scan covers five domains. Each domain has a reference file with full detail.

---

## Scan Workflow

### Step 1 — Orient

Before scanning, establish:
- **Repo path** (local or GitHub URL)
- **Stack** (determines which secret patterns and package managers to check)
- **Current state** (private-about-to-go-public, or already public)
- **CI/CD platform** (GitHub Actions, GitLab CI, other)

If the user provides a local path, work from that. If they provide a GitHub URL,
use `gh repo clone` or work from the GitHub UI data they share.

Ask: **"Is there existing CI/CD, and should I check it too?"**

---

### Step 2 — Run the Five-Domain Scan

Work through all five domains in risk order: Secrets → PII → Governance → Platform → CI/CD.
Load each domain's reference section as you start it. Do not load all at once.

---

## Domain 1 — Secrets & Credentials

Load `references/scan-checklist.md` → section "Secrets".

**Automated scan commands:**

```bash
# Full history scan (not just HEAD — this is critical)
gitleaks detect --source . --log-opts="--all" \
  --report-format json --report-path gitleaks-report.json

# Live credential verification
trufflehog git file://. --only-verified --json > trufflehog-report.json
```

**What to look for manually:**
- `.env` files committed (even if now in .gitignore — check history)
- Hardcoded API keys, tokens, passwords in source files
- Private keys (`.pem`, `.key`, `.p12`, `.pfx`) in any commit
- Database connection strings with credentials
- `config.yml` / `settings.py` / `appsettings.json` with real values
- `id_rsa`, `id_ed25519`, or similar SSH key files in history

**Critical rule:** Check git history, not just current state:
```bash
git log --all --full-history -- '*.env' '*.pem' '*.key' '*secret*' '*password*'
git log --all -p --follow -- path/to/sensitive-file
```

**If found → remediation:**
```bash
# 1. Rotate the credential IMMEDIATELY (treat as compromised)
# 2. Remove from history with git-filter-repo:
pip install git-filter-repo
git filter-repo --replace-text <(echo 'ACTUAL_SECRET==>REDACTED')
# 3. Force push and notify any forks
```

---

## Domain 2 — PII in Code and Test Data

Load `references/scan-checklist.md` → section "PII".

**Key insight (from GitGuardian 2024 report):** Developers most commonly
expose real data in test fixtures, seed files, database dumps, and
hard-coded example values — often copied from real systems "just for testing."

**Scan patterns:**

```bash
# Real phone numbers (DE/AT/CH format + international)
grep -rEn '(\+43|\+49|\+41|0043|0049)[0-9\s\-/]{7,}' \
  tests/ fixtures/ data/ seeds/ --include="*.json,*.csv,*.sql,*.py,*.ts,*.yaml"

# Email addresses that look real (not @example.com)
grep -rEn '[a-zA-Z0-9._%+-]+@(?!example\.(com|org|net))[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
  tests/ fixtures/ data/ seeds/

# Austrian IBAN
grep -rEn 'AT[0-9]{2}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}' \
  tests/ fixtures/ data/

# Austrian Sozialversicherungsnummer (XXXX DDMMYY)
grep -rEn '\b[0-9]{3,4}[\s-]?[0-9]{6}\b' tests/ fixtures/

# IP addresses that are not private ranges
grep -rEn '\b(?!10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
  tests/ fixtures/ data/
```

**Acceptable replacements:**

| Real data type | Safe replacement |
|---|---|
| Phone | `+43 800 000000` (reserved) |
| Email | `test@example.com` (RFC 2606) |
| Name | `Max Mustermann` / `Erika Musterfrau` |
| IBAN | `AT12 3456 7890 1234 5678` (invalid checksum) |
| Credit card | `4111 1111 1111 1111` (Visa test card) |
| SSN / SV-Nummer | `0000 010160` (fictitious) |
| IP address | `192.0.2.x` (RFC 5737 documentation range) |

---

## Domain 3 — Governance & Compliance Files

**Check each file's existence and minimum content:**

```bash
# Quick existence check
for f in LICENSE README.md SECURITY.md .gitignore .env.example; do
  [ -f "$f" ] && echo "✅ $f" || echo "❌ MISSING: $f"
done
```

**LICENSE:**
- Does it exist? Is it a recognized SPDX license?
- Does it match the copyright holder (individual vs. company)?
- Is it compatible with all dependencies?

**SECURITY.md minimum requirements:**
- [ ] Lists supported versions
- [ ] Provides a private reporting channel (email, not GitHub Issues)
- [ ] States expected response time
- [ ] States disclosure policy (coordinated disclosure / 90-day embargo)
- [ ] Is linked from README

**README.md minimum for public repo:**
- [ ] Describes what the project does (first paragraph)
- [ ] Install/setup instructions
- [ ] Basic usage example
- [ ] License badge or mention
- [ ] Link to SECURITY.md or "Found a bug?" section

**.gitignore gaps:**
```bash
# Check for common missed patterns
grep -L "\.env" .gitignore        # .env should be listed
grep -L "*.pem\|*.key" .gitignore  # private keys
grep -L "node_modules\|__pycache__\|.venv" .gitignore
```

**.env hygiene:**
```bash
# Is .env tracked?
git ls-files | grep '\.env$'

# Is .env.example present?
ls -la .env.example 2>/dev/null || echo "MISSING .env.example"

# Does .env.example contain only keys (no real values)?
grep -E '=.+' .env.example | grep -vE '=(your_|<|YOUR_|CHANGE_ME|example)'
```

---

## Domain 4 — Platform Settings & Branch Protection

These require checking the GitHub/GitLab UI or API. Provide the user with
the exact location and what to verify.

**GitHub Settings Checklist:**

```text
Repository Settings → Branches:
✅ Branch protection rule on main/master
✅ Require PR before merging
✅ Require status checks to pass
✅ Do not allow force pushes
✅ Do not allow deletions

Repository Settings → Security:
✅ Dependency graph: ON
✅ Dependabot alerts: ON
✅ Dependabot security updates: ON
✅ Secret scanning: ON (auto for public)
✅ Secret scanning push protection: ON
✅ Private vulnerability reporting: ON

Repository Settings → Actions → General:
✅ Fork pull requests require approval
✅ Read repository contents (not write) as default token permission
```

**Via GitHub CLI (faster):**
```bash
gh api repos/{owner}/{repo}/branches/main/protection
gh api repos/{owner}/{repo} --jq '.security_and_analysis'
```

---

## Domain 5 — CI/CD Hardening & Supply Chain

Load `references/scan-checklist.md` → section "CI/CD".

**Check Action pins:**
```bash
# Find unpinned actions (version tag instead of SHA)
grep -rEn 'uses: [^@]+@v[0-9]' .github/workflows/
# All results are findings — each should be pinned to SHA
```

**Check job permissions:**
```bash
# Find workflows with no explicit permissions (defaults to write-all)
grep -rL 'permissions:' .github/workflows/
```

**Check for secret exposure:**
```bash
# Secrets echoed to logs
grep -rEn 'echo \$\{\{ secrets\.' .github/workflows/

# Secrets in env vars that get logged
grep -rEn 'env:.*secrets\.' .github/workflows/
```

**Dependency files exposed:**
```bash
# Lockfiles committed (good) — check they exist
ls package-lock.json yarn.lock pnpm-lock.yaml requirements.txt Pipfile.lock \
   poetry.lock go.sum Gemfile.lock 2>/dev/null

# Dependency scanning present in CI?
grep -rEl 'pip-audit|npm audit|trivy|snyk|dependabot' .github/workflows/
```

---

## Standard Finding Format

```text
### [SEVERITY] Finding Title
**Domain:** Secrets | PII | Governance | Platform | CI/CD
**Location:** file or setting path
**Risk:** One sentence — what can go wrong if this is public.

**What was found:**
[Specific evidence or command output]

**Fix:**
[Concrete command or UI step — copy-pasteable]

**Reference:** [OpenSSF / GitHub Docs / CISA / OWASP link]
```

**Severity levels:**

| Level | Meaning |
|---|---|
| 🔴 BLOCKER | Do NOT go public until fixed. Active exposure risk. |
| 🟠 HIGH | Fix before or immediately after going public. |
| 🟡 MEDIUM | Fix within first week. Defense-in-depth gap. |
| 🔵 LOW | Good practice, low direct risk. |
| ⚪ INFO | Observation or enhancement suggestion. |

---

## Output — Scan Report

Write the complete results to `./review-public-report.md`:

```markdown
# Repository Public Scan Report — [Repo Name]
Date: YYYY-MM-DD | Stack: ... | Branch: ...

## Overall Verdict
[🔴 NOT SAFE TO PUBLISH / 🟠 PUBLISHABLE WITH FIXES / 🟢 READY]

One sentence rationale.

## Findings

### 🔴 BLOCKER (N)
[findings]

### 🟠 HIGH (N)
[findings]

### 🟡 MEDIUM (N)
[findings]

### 🔵 LOW / ⚪ INFO (N)
[findings]

## Domain Summary
| Domain | Status | Findings |
|---|---|---|
| Secrets & Credentials | 🔴/🟢 | N |
| PII in Test Data | 🔴/🟢 | N |
| Governance Files | 🟠/🟢 | N |
| Platform Settings | 🟡/🟢 | N |
| CI/CD & Supply Chain | 🟡/🟢 | N |

## Top 3 Immediate Actions
1. [Most critical fix]
2. [Second fix]
3. [Third fix — estimated remediation time: X hours]

---
*Generated with AI assistance (Claude Code + dev-best-practices plugin).
This scan supplements but does not replace manual review and gitleaks/truffleHog
full-history scans run locally.*
```

---

## Interaction Patterns

### When blockers are found

Stop immediately and escalate:
> "Found 🔴 BLOCKER items — this repo must NOT go public until these are fixed.
> Credentials found in history should be treated as already compromised and rotated now."

### When the user says "we already went public"

Shift to damage control:
1. Check if GitHub has cached/indexed the secret (use GitHub Code Search)
2. Rotate credentials immediately
3. Run history rewrite and force-push
4. File a support ticket with GitHub to purge cached data

### When asked "is this PII?"

Apply GDPR Article 4 definition: any data relating to an identifiable natural person.
Real names + email = PII. Real phone + city = PII. Test data with `Mustermann` + fake number = not PII.
When in doubt, use fake data. The cost of replacing it is lower than a GDPR incident.

### When no CI/CD exists

Flag this as 🟠 HIGH and suggest the minimum viable pipeline:
gitleaks scan + dependency audit on every PR. Two steps, five minutes of setup.

---

## Reference Files

- `references/scan-checklist.md` — Full command library: secret patterns, PII regex, CI checks
- `references/industry-sources.md` — Authority ratings for all referenced standards
