# Security Policy

## Supported Versions

This repository contains documentation and Claude Code plugin skills — no executable code.
All versions receive updates.

## Reporting a Vulnerability

If you discover a security issue (e.g. a skill workflow that could be used for prompt injection,
a rule that introduces a vulnerability into projects, or sensitive data accidentally committed):

1. **Do not open a public issue.**
2. Report privately via [GitHub Security Advisories](https://github.com/gerfru/dev-best-practices/security/advisories/new).
3. Include: what you found, which file/skill, potential impact.

You will receive a response within 7 days.

## Scope

- Skill workflows that give insecure advice (e.g. recommending weak crypto, bypassing auth)
- Rules in `claude/` or `reference/` that would introduce OWASP Top 10 vulnerabilities into projects
- Any accidentally committed credentials or personal data

Out of scope: general disagreements with best-practice recommendations (open an issue instead).
