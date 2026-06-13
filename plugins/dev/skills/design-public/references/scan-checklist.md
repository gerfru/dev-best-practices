# Scan Checklist — Commands & Patterns

## Secrets Detection

### Tools

```bash
# gitleaks — full history scan
gitleaks detect --source . --log-opts="--all" \
  --report-format json --report-path gitleaks-report.json

# truffleHog — live credential verification
trufflehog git file://. --only-verified --json > trufflehog-report.json

# git native — find files that should never have been committed
git log --all --full-history -- '*.env' '*.pem' '*.key' '*.p12' '*.pfx' \
  '*secret*' '*password*' '*credential*' '*token*' 'id_rsa' 'id_ed25519'
```

### Common Secret Patterns (manual grep fallback)

```bash
# AWS keys
grep -rEn 'AKIA[0-9A-Z]{16}' .

# Generic API key patterns
grep -rEn '(api_key|apikey|api-key)\s*[=:]\s*["\x27][A-Za-z0-9_\-]{20,}' . --include="*.py,*.ts,*.js,*.yaml,*.yml,*.json"

# Private key headers
grep -rn 'BEGIN (RSA|EC|OPENSSH|PRIVATE) PRIVATE KEY' .

# Bearer tokens
grep -rEn 'Bearer\s+[A-Za-z0-9\-._~+/]+=*' . --include="*.py,*.ts,*.js"

# Password assignments
grep -rEn '(password|passwd|pwd)\s*=\s*["\x27][^"\x27]{6,}["\x27]' . \
  --include="*.py,*.ts,*.js,*.env,*.yaml,*.yml"

# Database connection strings with credentials
grep -rEn '(mysql|postgres|mongodb|redis):\/\/[^:]+:[^@]+@' .

# GitHub/GitLab tokens
grep -rEn 'gh[pousr]_[A-Za-z0-9_]{36}|glpat-[A-Za-z0-9\-_]{20}' .
```

---

## PII Patterns

### Phone Numbers

```bash
# AT/DE/CH international
grep -rEn '(\+43|\+49|\+41|0043|0049|0041)[0-9\s\-/()]{7,15}' \
  tests/ fixtures/ data/ seeds/

# Generic 10+ digit numbers (catches most international formats)
grep -rEn '\b[0-9]{3,4}[\s\-.]?[0-9]{3,4}[\s\-.]?[0-9]{3,6}\b' \
  tests/ fixtures/ --include="*.json,*.csv,*.sql"
```

### Email Addresses

```bash
# Any email that isn't a known test domain
grep -rEn '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
  tests/ fixtures/ data/ seeds/ | \
  grep -v '@example\.\|@test\.\|@localhost\|@invalid\.'
```

### Austrian/German-Specific

```bash
# IBAN AT/DE
grep -rEn '(AT|DE)[0-9]{2}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}(\s?[0-9]{4})?' \
  tests/ fixtures/ data/

# Austrian Sozialversicherungsnummer
grep -rEn '\b[0-9]{3,4}[\s-]?[0-9]{6}\b' tests/ fixtures/

# Austrian ZMR-Zahl (Zentrales Melderegister)
grep -rEn '\b[0-9]{12}\b' tests/ fixtures/

# Steueridentifikationsnummer
grep -rEn '\b[0-9]{2}-[0-9]{3}/[0-9]{4}\b|\b[0-9]{9}\b' tests/ fixtures/
```

### IP Addresses (non-private)

```bash
# Public IPs (excludes RFC 1918 private ranges)
grep -rEn '\b(?!10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|127\.|0\.)([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
  tests/ fixtures/ data/
```

---

## Safe Test Data Replacements

| Category | Safe value | Standard |
|---|---|---|
| Phone (AT) | `+43 800 000000` | ÖTK reserved number |
| Phone (DE) | `+49 800 0000000` | BNetzA reserved |
| Email | `test@example.com` | RFC 2606 |
| Email | `noreply@example.org` | RFC 2606 |
| Name (AT/DE) | `Max Mustermann` / `Erika Musterfrau` | Standard Testperson |
| IBAN (AT) | `AT12 3456 7890 1234 5678` | Invalid checksum |
| IBAN (DE) | `DE02 3705 0198 0000 0604 40` | Deutsche Bundesbank test |
| Credit card | `4111 1111 1111 1111` | Visa test (Luhn valid) |
| IP address | `192.0.2.1` – `192.0.2.254` | RFC 5737 TEST-NET-1 |
| IP address | `198.51.100.x` / `203.0.113.x` | RFC 5737 TEST-NET-2/3 |
| Domain | `example.com` / `example.org` / `example.net` | RFC 2606 |
| URL | `https://www.example.com/path` | RFC 2606 |
| UUID | `00000000-0000-0000-0000-000000000001` | Obvious test value |
| Geo coords | `48.2083537, 16.3725042` | Vienna city center (public) |

---

## CI/CD Checks

### Unpinned Actions

```bash
# Find version-tag pins (should be SHA pins)
grep -rEn 'uses: [^@]+@v[0-9]' .github/workflows/
grep -rEn "uses: [^@]+@v[0-9]" .gitlab-ci.yml

# Example fix:
# actions/checkout@v4  →  actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
# Use: https://github.com/mheap/pin-github-action to automate
```

### Missing Permissions

```bash
# Workflows with no explicit permissions block
grep -rL 'permissions:' .github/workflows/
# Each result defaults to write-all — reduce to minimum needed
```

### Secret Exposure in Logs

```bash
# Secrets echoed directly
grep -rEn 'echo.*\$\{\{\s*secrets\.' .github/workflows/

# Env var with secret that may be logged
grep -rEn -A2 'env:' .github/workflows/ | grep 'secrets\.'
```

### Dependency Scanning Presence

```bash
# Is any SCA tool configured?
grep -rEl 'pip-audit|safety|npm audit|yarn audit|trivy|snyk|dependabot|renovate' \
  .github/workflows/ .github/dependabot.yml 2>/dev/null
```

---

## .gitignore Coverage Check

```bash
# Files that should be ignored but aren't
git check-ignore -v .env .env.local .env.production \
  *.pem *.key *.p12 *.pfx id_rsa id_ed25519 \
  node_modules/ __pycache__/ .venv/ venv/ \
  *.log *.sqlite *.db

# Or check if patterns exist in .gitignore
for pattern in '.env' '*.pem' '*.key' 'node_modules' '__pycache__' '.venv'; do
  grep -q "$pattern" .gitignore && echo "✅ $pattern" || echo "❌ MISSING: $pattern"
done
```
