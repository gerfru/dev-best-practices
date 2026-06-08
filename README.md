# Dev Best Practices

[![CI](https://github.com/gerfru/dev-best-practices/actions/workflows/ci.yml/badge.svg)](https://github.com/gerfru/dev-best-practices/actions/workflows/ci.yml)

Opinionated best-practice rules for software projects — RAG systems, AI agents, data pipelines, full-stack web apps. Three detail levels: compact essential rules for `CLAUDE.md`, thematic rule files, and detailed reference docs.

Also a **Claude Code plugin**: install once, get 17 skills in every project.

---

## Quick Start

```bash
# Add marketplace (once per machine)
claude plugin marketplace add gerfru/dev-best-practices

# Install plugin
claude plugin install dev@gerald-dev-best-practices

# Open navigation menu
/dev:meta-help
```

**Windows (VS Code):** Claude icon → `/plugin` → Marketplaces → add `gerfru/dev-best-practices` → Plugins → Install `dev`.

---

## Skills

Start with `/dev:meta-help` — shows the full menu and launches any skill directly.

### Design

| Skill | What it does |
|---|---|
| `/dev:design-app` | Stack & architecture decisions from the rule files |
| `/dev:design-secure` | Threat model, crypto selection, auth, compliance |
| `/dev:design-api` | REST / GraphQL / gRPC contract design or review |
| `/dev:design-data` | Schema, normalization, indexes, CQRS / Event Sourcing |
| `/dev:design-migration` | Zero-downtime strategy: Expand-Contract, Strangler Fig, Saga |

### Review

| Skill | What it does |
|---|---|
| `/dev:review-app` | Full audit across 6 axes (architecture, security, tests, CI/CD, …) |
| `/dev:review-arch` | Coupling, anti-patterns, quality attributes, ADR recommendations |
| `/dev:review-secure` | Crypto, injection, memory safety, GDPR / ISO 27001 / EU AI Act |
| `/dev:review-ux` | UX audit based on HAX, PAIR, CHI 2024 and Nielsen Norman |

### Tools

| Skill | What it does |
|---|---|
| `/dev:tool-debug [error]` | Root-cause analysis with stack-aware fix suggestions |
| `/dev:tool-test [focus]` | Write missing tests or design test strategy per test pyramid |
| `/dev:tool-style [task]` | CSS solution matching your existing system (Tailwind, SCSS, …) |

### Meta

| Skill | What it does |
|---|---|
| `/dev:meta-help` | Navigation menu — shows all 17 skills, launches chosen one |
| `/dev:meta-install` | Insert `essential-rules.md` into project `CLAUDE.md` (detects install vs. update) |
| `/dev:meta-drift` | Compare installed rules block against current rule files |
| `/dev:meta-sync` | Repo-internal: check if `claude/*.md` still reflects `reference/*.md` |

---

## Repo Structure

```text
.claude-plugin/
  marketplace.json          Makes this repo installable as a marketplace

plugins/dev/
  .claude-plugin/
    plugin.json             Plugin metadata (name: "dev")
  commands/                 Slash-command definitions
  skills/                   Skill workflow definitions (auto-triggered)
  rules/                    Mirror of claude/*.md (used by skills as reference)

claude/                     Condensed rules for Claude Code
  essential-rules.md        ~80 lines — copy into project CLAUDE.md
  app-rules.md              App rules in detail
  github-rules.md           GitHub / CI rules in detail
  architecture-rules.md     Architecture rules in detail

reference/                  Detailed docs for humans
  app-best-practices.md     Security, auth, API, DB, monitoring, OWASP
  github-best-practices.md  CI/CD, linting, testing, Docker, code review
  architecture-best-practices.md  Layers, patterns, infra, 12-Factor

scripts/
  validate-skills.sh        Plugin structure validator (CI + pre-commit)
```

---

## Using Rules Without the Plugin

### Option 1 — Essential rules only (recommended for most projects)

Copy `claude/essential-rules.md` into your project's `CLAUDE.md` — or use `/dev:meta-install` to do it automatically with version markers.

### Option 2 — Add more depth

Pick sections from `claude/app-rules.md`, `claude/github-rules.md`, or `claude/architecture-rules.md` and append selectively.

### Option 3 — Global rules

Put rules that apply to every project in `~/.claude/CLAUDE.md`:

- Linting / formatting standards
- Git workflow
- Security baseline

---

## Typical Workflows

**New project:**

```text
/dev:meta-install        → inserts essential-rules.md into CLAUDE.md
/dev:design-app          → architecture & stack decisions
/dev:design-secure       → threat model & security design
```

**Before release:**

```text
/dev:review-app          → full audit
/dev:review-secure       → security code review
```

**During development:**

```text
/dev:tool-debug [error]  → root-cause analysis
/dev:tool-test           → write missing tests
/dev:tool-style [task]   → CSS fix in your system's style
```

**Keep rules up to date:**

```text
/dev:meta-drift          → what changed since last install?
/dev:meta-install        → update in-place (preserves project exceptions)
```

---

## Maintenance

```bash
# Sync rule mirrors after editing claude/*.md
cp claude/*.md plugins/dev/rules/

# Validate plugin structure locally
bash scripts/validate-skills.sh

# Run all checks (markdownlint + link check + skill validation)
pre-commit run --all-files
```

CI runs on every PR: markdown lint → skill validation → link check → secret scan.

---

## Troubleshooting

**Skills don't appear after install:** run `/reload-plugins`.

**`Unrecognized token` when adding marketplace:** a JSON file has a BOM. Fix:

```powershell
Get-ChildItem -Recurse -File -Path .claude-plugin,plugins | ForEach-Object {
  $c = Get-Content -Raw -LiteralPath $_.FullName
  [System.IO.File]::WriteAllText($_.FullName, $c, (New-Object System.Text.UTF8Encoding($false)))
}
```

Then push and re-add the marketplace on the client.

**`claude plugin marketplace ...` unknown command** (older Claude Code): use slash commands instead — `/plugin marketplace add ...`.
