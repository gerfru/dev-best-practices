---
name: dev:meta-help
description: >
  Navigation menu for all Dev Best Practices skills. Shows all available skills
  grouped and starts the chosen one directly. Trigger for "which skill should I use",
  "what is available", "help", "what can I use", "show me the skills",
  "which tool", "I don't know which skill".
---

# Dev Best Practices — Skill Navigator

Show the menu immediately. No long introduction.

## Step 1 — Display Menu

```text
Which skill should start?

🏗️  DESIGN
  1  design-app              Stack & architecture from the best-practice rules
  2  design-secure           Security design: threat model, crypto, auth, compliance
  3  design-api              REST / GraphQL / gRPC contract design or review
  4  design-data             Schema, normalization, indexes, CQRS / Event Sourcing
  5  design-migration        Migration strategy: zero-downtime, Strangler Fig, Saga
  6  design-ux               UX/UI design: interaction, trust, AI features, anti-patterns
  7  design-llm              LLM system: RAG, fine-tune, agent, eval strategy, guardrails
  8  design-observability    Observability: SLO/SLI, golden signals, tracing, alerting, incident response
  9  design-cicd             CI/CD pipeline: deployment strategies, DORA metrics, trunk-based dev
 10  design-iac              Infrastructure as Code: Terraform, GitOps, state management, drift detection

🔍  REVIEW
 11  review-app        Full audit: architecture, security, tests, CI/CD, observability
 12  review-arch       Architecture: coupling, anti-patterns, quality attributes, ADR
 13  review-secure     Security: crypto, injection, memory safety, GDPR/ISO/EU AI Act
 14  review-ux         UX audit: AI anti-patterns, dark patterns, trust design
 15  review-llm        LLM audit: architecture, evals, prompt injection, OWASP LLM Top 10
 16  review-public     Repo public scan: secrets in history, PII in tests, governance files, CI/CD hardening

🏗️  DESIGN (continued)
 17  design-public     Publication plan: secrets audit, license, governance docs, branch protection, supply chain

🛠️  TOOLS
 18  tool-debug        Stack-aware root cause analysis with fix suggestions
 19  tool-test         Write, improve, or plan tests
 20  tool-style        CSS / design system + visual basics (color, typography, spacing, loading)
 21  tool-a11y         Accessibility audit: WCAG 2.2, screen reader, EU Accessibility Act
 22  tool-perf         Performance engineering: USE Method, flamegraph, bottleneck, Bentley Rules

📁  META
 23  meta-install        Add best-practice rules to a project CLAUDE.md
 24  meta-drift          Compare project CLAUDE.md against current rule files
 25  meta-sync           Keep reference/*.md and claude/*.md in sync
 26  meta-create-skill   Build a new skill: research, structure, all files

→ Enter a number, or directly describe what you need.
```

## Step 2 — Start Skill

**With a number:** Start skill immediately.
**With a description:** Choose the best matching skill, mention it briefly ("→ starting review-secure …"), then start directly.
**With arguments:** Pass to the started skill.

Load and follow exactly: `${CLAUDE_PLUGIN_ROOT}/skills/<chosen-skill>/SKILL.md`

## Rules
- Show menu immediately, no intro
- After the choice: start directly, do not explain or ask again
- Never load all 26 skills at once — always only the chosen one
