# Changelog

All notable changes to this project are documented here.
Format: [Semantic Versioning](https://semver.org). Dates: YYYY-MM-DD.

---

## [Unreleased]

---

## [2.0.0] — 2026-06-08

### Added

- `design-iac`: Infrastructure as Code design grounded in Kief Morris "Infrastructure as Code" (O'Reilly 2021) and NTNU IIKG3005 — IaC principles (immutable infra, idempotency, snowflake anti-pattern), module design, remote state management, drift detection and remediation, GitOps workflow, IaC testing (3 reference files)
- `tool-perf`: Performance engineering grounded in MIT 6.172 (Leiserson/Shun, Bentley Rules) and Brendan Gregg "Systems Performance" (USE Method, flamegraphs) — USE Method resource checklist, profiling tool selection by stack, flamegraph reading guide, Bentley Rules (5 categories), before/after benchmark workflow (3 reference files)
- `design-migration` — schema evolution: Added Kleppmann "Designing Data-Intensive Applications" Kap. 4+11 coverage — Forward/Backward Compatibility rules, Dual-Write problem and solutions, Change Data Capture (CDC/Debezium), Avro Schema Registry, Expand-Contract pattern; new `references/schema-evolution.md`
- plugin.json: 22 → 24 skills, v1.2.0 → v2.0.0; meta-help renumbered 1–24
- `docs/skill-research-basis.md`: new reference document — academic & industry sources per skill (replaces work-in-progress `docs/academic-basis.md`)
- CLAUDE.md: updated to reflect full plugin structure (24 skills, docs/ directory, plugin install command)

### Removed

- `docs/gap-analysis.md`: all items resolved — content lives in Git history
- `docs/academic-basis.md`: replaced by `docs/skill-research-basis.md`

- `design-observability`: Observability architecture skill grounded in Google SRE Books (Beyer et al.) and Observability Engineering (Majors/Fong-Jones) — SLO/SLI/Error-Budget, Golden Signals, OpenTelemetry tracing, Burn Rate alerting, Incident Response + blameless postmortem (4 reference files)
- `design-cicd`: CI/CD pipeline design grounded in "Accelerate" (Forsgren/Humble/Kim) and "Continuous Delivery" (Humble/Farley) — pipeline architecture, Blue-Green/Canary/Feature Flags decision tree, DORA metrics with benchmarks, Trunk-Based Development (3 reference files)
- `tool-a11y`: Accessibility audit grounded in WCAG 2.2 (W3C) and CMU HCII 05-332 — axe-core/Lighthouse, keyboard navigation, NVDA/VoiceOver screen reader testing, all 9 new WCAG 2.2 SC, EU Accessibility Act / BFSG / EN 301 549 compliance (3 reference files)
- `design-llm` + `review-llm`: LLM system design and audit grounded in Stanford CS224N, CMU 11-667 and Berkeley CS294-196 — RAG, fine-tuning, agents, evals, OWASP LLM Top 10, prompt injection (PR #14)
- `commands/design-ux.md` and `commands/review-ux.md`: missing command files added — slash-command discovery now works for both skills
- Skill discovery improvements: overlap disambiguation (review-app/review-arch/review-secure), German trigger phrases for review-arch and review-secure, scope guard for meta-sync
- `docs/gap-analysis.md`: status tracking table (✅ Erledigt / 🔲 Offen) for all planned skills
- `docs/academic-basis.md`: verified syllabi for all planned new skills (Stanford CS224N, CMU 11-667, Berkeley CS294-196, MIT 6.5940, MIT 6.5840, CMU 18-749, CMU 17-636, W3C WAI, NTNU IIKG3005, MIT 6.172, CMU 15-721, UT Austin CS395T)
- `meta-create-skill`: new meta skill for building skills using the established methodology (topic → academic research → SKILL.md + references/)
- All 9 skills with inline lookup tables now follow the consistent structure: SKILL.md = workflow only, `references/` = lookup material
- Feature Flags section in `claude/app-rules.md` and `reference/app-best-practices.md`
- Mirror sync check in CI: `claude/` vs `plugins/dev/rules/` must be identical
- MSW + Testing Library added to essential-rules.md testing stack
- TLS zum DB-Server in essential-rules.md API & Datenbank section
- Secrets rotation frequency (90 days) in `claude/app-rules.md`
- plugin.json: 17 → 22 skills; meta-help renumbered 1–22

### Fixed

- Link check: exclude `github.com/.*/actions/` URLs (returned 504 on CI runners, causing every PR to fail)

---

## [1.2.0] — 2026-06-08

### Added

- Repository Settings best practices: Merge strategy (Squash/Merge Commit/Rebase comparison), delete-branch-on-merge, Secret Scanning + Push Protection, Dependabot — in `reference/github-best-practices.md` and `claude/github-rules.md`
- GitHub CLI commands for activating Secret Scanning, Push Protection, Dependabot via API
- Updated Checkliste in `reference/github-best-practices.md`

### Fixed

- `scripts/validate-skills.sh`: removed `pipefail` (not POSIX-portable), converted to LF line endings for Windows compatibility

---

## [1.1.0] — 2026-06-07

### Added

- Plugin renamed from `dev-best-practices` to `dev` (shorter prefix: `/dev:skill-name`)
- Pre-commit hooks: `markdownlint-cli2` + `validate-skills.sh` run before every commit
- CI pipeline (`.github/workflows/ci.yml`): lint → validate-skills → secrets (gitleaks), triggered on `master`
- `scripts/validate-skills.sh`: validates plugin.json fields, marketplace.json source paths, SKILL.md frontmatter, command references
- Branch protection on `master`: required status checks, no force push, enforce_admins
- README rewrite: CI badge, skills table with `dev:` prefix, repo structure, workflows, troubleshooting

### Fixed

- CI branch trigger: `main` → `master`
- Link check: exclude `report-uri.com` (returns 403 to bots)
- All markdownlint violations (MD025, MD026, MD034, MD036, MD040, MD060)
- CRLF compatibility in `validate-skills.sh` (`tr -d '\r'`)

### Removed

- `Uebersicht-UI-UX.md` (research scratch file)

---

## [1.0.0] — 2026-05-01

### Added

- Initial plugin structure: 17 skills across Design, Review, Tools, Meta categories
- `claude/essential-rules.md` — ~80 lines, copy-paste ready for project CLAUDE.md
- `claude/app-rules.md`, `claude/github-rules.md`, `claude/architecture-rules.md` — thematic rule files
- `reference/app-best-practices.md`, `reference/github-best-practices.md`, `reference/architecture-best-practices.md` — detailed reference docs
- Skills: design-app, design-secure, design-api, design-data, design-migration, design-ux
- Skills: review-app, review-arch, review-secure, review-ux
- Skills: tool-debug, tool-test, tool-style
- Skills: meta-help, meta-install, meta-drift, meta-sync
- `.claude-plugin/marketplace.json` — installable as GitHub marketplace
- Security skill references: security-checks.md (ISEC/Stanford/MIT), compliance-checks.md, quality-checks.md

---

[Unreleased]: https://github.com/gerfru/dev-best-practices/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/gerfru/dev-best-practices/compare/v1.2.0...v2.0.0
[1.2.0]: https://github.com/gerfru/dev-best-practices/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/gerfru/dev-best-practices/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/gerfru/dev-best-practices/releases/tag/v1.0.0
