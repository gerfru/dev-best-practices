---
name: dev:design-app
description: From an app idea to well-founded architecture and stack decisions based on the Dev-Best-Practices rules. Use this skill whenever the user describes a new app idea and wants help choosing architecture, stack, structure, or a scaffolding plan; triggers on "new app", "app idea", "how do I structure", "which stack", "architecture for ...".
---

# App Design (rule-based)

Turns an app idea into justified decisions. Standard: the rule files
under `${CLAUDE_PLUGIN_ROOT}/rules/` (especially architecture-rules.md, app-rules.md,
github-rules.md). No generic advice — every decision references the rule.

## Step 0 - Clarify Idea & Scope
Gather from the description: domain, users, expected load, team size (solo?),
whether there's a web frontend, whether sensitive data is involved (GDPR/MDR). If anything essential is missing: ask once, don't guess.

## Step 1 - Make Decisions Along the Rules
Work through the decision trees from architecture-rules.md and justify each choice:
- Monolith vs. Microservices (Default: Monolith-First)
- Monorepo vs. Polyrepo
- Rendering (SSR/SSG/ISR/CSR)
- API type (tRPC internal / REST external / GraphQL)
- Database + ORM/Query-Builder
- State management (Server vs. Client State)
- Layering appropriate to project size
- Target ASVS level (Default L1 Solo, L2 Production) and relevant security fundamentals
- CI/CD skeleton (pipeline, branch protection, scanning)

## Step 2 - Deliver
Write to `./design-app.md`:
1. Short Architecture Decision Record: Decision | Choice | Rationale (rule reference)
2. Recommended folder structure (feature-based) for the chosen stack
3. "Day 1" and "First Week" setup checklist (from github-rules.md / app-rules.md)
4. Open questions / deliberate trade-offs marked as "[to verify]"

## Rules
- No over-engineering: for solo/prototype use the simplest rule-compliant variant.
- Every decision cites the underlying rule (file -> section).
- Assumptions explicitly marked as "[Assumption]" rather than silently filled in.
