## What does this PR change?

<!-- Brief description of the change and why it's being made -->

## Type of change

- [ ] New skill
- [ ] Skill update / bugfix
- [ ] Rule change (`claude/` or `reference/`)
- [ ] Docs / Config
- [ ] Meta (`plugin.json`, `commands/`, `validate-skills.sh`)

## Checklist

- [ ] `pre-commit run --all-files` passes
- [ ] `bash scripts/validate-skills.sh` passes
- [ ] Mirror up to date: `cp claude/*.md plugins/dev/rules/` run (for rule changes)
- [ ] `CHANGELOG.md` updated (for new skills or breaking changes)

## Security

- [ ] No secrets or personal data in committed files
- [ ] No skill or rule that would introduce OWASP Top 10 vulnerabilities into projects
- [ ] No prompt injection vectors in new skill workflows
