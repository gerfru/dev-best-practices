# Industry Sources — Repo Public Scan

Canonical, authoritative sources for repository publication security.
Academic coverage of this topic is sparse; these industry standards are the
primary knowledge base.

## Tier 1 — Primary Specifications (highest authority)

| Source | URL | What it covers |
|---|---|---|
| **OpenSSF Best Practices Badge** | https://bestpractices.coreinfrastructure.org | Full checklist for open source project health: SECURITY.md, signed commits, vulnerability reporting, CI, tests |
| **GitHub Security Hardening Docs** | https://docs.github.com/en/code-security | Platform-specific controls: secret scanning, Dependabot, branch protection, push protection |
| **SLSA Framework v1.0** | https://slsa.dev/spec/v1.0 | Supply chain security levels L1-L3; provenance requirements; build isolation |
| **Sigstore Documentation** | https://docs.sigstore.dev | Keyless signing via Fulcio/Rekor; cosign usage |
| **OpenSSF Scorecard** | https://github.com/ossf/scorecard | Automated scoring: branch protection, pinned deps, CI hardening, signed releases |
| **OpenSSF CVD Guide** | https://github.com/ossf/oss-vulnerability-guide | Coordinated Vulnerability Disclosure for open source; SECURITY.md templates |

## Tier 2 — Government & Standards Bodies

| Source | URL | What it covers |
|---|---|---|
| **CISA Security-by-Design** | https://www.cisa.gov/resources-tools/resources/secure-by-design | Hardening principles for software publishers; supply chain recommendations |
| **NIST SSDF SP 800-218** | https://csrc.nist.gov/publications/detail/sp/800-218/final | Secure Software Development Framework; source code management controls |
| **OWASP DevSecOps Guideline** | https://owasp.org/www-project-devsecops-guideline | CI/CD security, SAST/DAST/SCA integration, secrets management |
| **CIS Benchmark for GitHub** | https://www.cisecurity.org/insights/blog/cis-benchmark-for-github | GitHub settings hardening checklist (requires CIS account) |
| **ENISA — Open Source Software Security** | https://www.enisa.europa.eu/topics/cybersecurity-policy/nis-directive-new/open-source-software | EU perspective on OSS supply chain risks |

## Tier 3 — Industry Reports (data-driven)

| Source | What it covers | Cadence |
|---|---|---|
| **GitGuardian State of Secrets Sprawl** | Annual statistics on leaked credentials in public repos; detection rates | Annual |
| **Snyk State of Open Source Security** | Vulnerability trends in OSS dependencies; SCA data | Annual |
| **OpenSSF Alpha-Omega Project** | Investments in OSS security; most critical packages | Ongoing |

## Tool Documentation

| Tool | URL | Purpose |
|---|---|---|
| **gitleaks** | https://github.com/gitleaks/gitleaks | Secret detection in git history (150+ patterns, entropy) |
| **truffleHog** | https://github.com/trufflesecurity/trufflehog | Secret detection with live credential verification (800+ detectors) |
| **git-filter-repo** | https://github.com/newren/git-filter-repo | History rewriting (recommended over BFG for new projects) |
| **BFG Repo-Cleaner** | https://rtyley.github.io/bfg-repo-cleaner | Fast history rewriting for large repos |
| **pin-github-action** | https://github.com/mheap/pin-github-action | Automate SHA pinning of GitHub Actions |
| **cosign** | https://github.com/sigstore/cosign | Keyless artifact signing via Sigstore |
| **pip-audit** | https://github.com/pypa/pip-audit | Python dependency vulnerability scanning (SCA) |

## Key Findings from Research (adversarially verified)

1. **Secret scanning is free + automatic on public GitHub repos** — but only after the repo is already public. Pre-publication scan with gitleaks/truffleHog is essential.

2. **Deleting from HEAD is not remediation** — git's immutable history preserves the leak in every clone and fork. `git-filter-repo` or BFG required.

3. **SECURITY.md belongs in root, /docs, or /.github/** — only these locations populate GitHub's Security Policy tab.

4. **SLSA L2 is achievable with GitHub Actions** — hosted runners + `slsa-framework/slsa-github-generator` provide signed provenance without custom infrastructure.

5. **Sigstore keyless signing** — ephemeral X.509 certs (10 min TTL) via Fulcio, bound to OIDC identity. No long-lived key management required.

## License Resources

| Resource | URL |
|---|---|
| SPDX License List | https://spdx.org/licenses/ |
| choosealicense.com | https://choosealicense.com |
| OSI Approved Licenses | https://opensource.org/licenses |
| EUPL (EU Public License) | https://joinup.ec.europa.eu/collection/eupl |
| License compatibility matrix | https://www.gnu.org/licenses/license-list.html |
