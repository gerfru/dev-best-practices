# Changelog

All notable changes to this project are documented here.
Format: [Semantic Versioning](https://semver.org). Dates: YYYY-MM-DD.

---

## [Unreleased]

### Added

- `meta-create-skill`: new meta skill for building skills using the established methodology (topic → academic research → SKILL.md + references/)
- All 9 skills with inline lookup tables now follow the consistent structure: SKILL.md = workflow only, `references/` = lookup material
  - Round 1 (new `references/` directories): `design-ux`, `review-ux`, `tool-style`
  - Round 2 (`curriculum-mapping.md` added): `design-secure`, `review-arch`, `review-secure`, `design-api`, `design-data`, `design-migration`
- `design-ux` and `review-ux` now have `commands/` entries (were missing, slash-command discovery now works)
- `docs/gap-analysis.md`: inventory of content gaps with academic source candidates
- `docs/academic-basis.md`: verified syllabi for 6 planned new skills (Stanford CS224N, CMU 11-667, Berkeley CS294-196, MIT 6.5940, MIT 6.5840, CMU 18-749, CMU 17-636, W3C WAI, NTNU IIKG3005, MIT 6.172, CMU 15-721, UT Austin CS395T)
- Feature Flags section in `claude/app-rules.md` and `reference/app-best-practices.md` (Kill Switch, Rollout-Reihenfolge, Flag-Hygiene, Tool-Vergleich)
- Mirror sync check in CI: `claude/` vs `plugins/dev/rules/` must be identical
- MSW + Testing Library added to essential-rules.md testing stack
- TLS zum DB-Server in essential-rules.md API & Datenbank section
- Secrets rotation frequency (90 days) in `claude/app-rules.md`

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

[Unreleased]: https://github.com/gerfru/dev-best-practices/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/gerfru/dev-best-practices/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/gerfru/dev-best-practices/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/gerfru/dev-best-practices/releases/tag/v1.0.0
