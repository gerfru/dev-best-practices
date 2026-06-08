# Alert & Runbook — Reference

## Burn Rate Alert Table (SLO 99.9%, Error Budget 43.2 min/30d)

| Alert Name | Burn Rate | Window | Budget consumed | Severity | Response |
|---|---|---|---|---|---|
| SLOCritical | > 14.4× | 1h | ~3 min | Page immediately | < 5 min |
| SLOHigh | > 6× | 6h | ~36 min | Page | < 30 min |
| SLOMedium | > 3× | 24h | ~6h | Ticket | Next day |
| SLOLow | > 1× | 72h | Slow burn | Info | Sprint backlog |

For other SLOs: Burn Rate = `(1 - SLO) × Budget_total / Alert_window`

---

## Alert Severity Matrix

| Severity | When | Response time | Who |
|---|---|---|---|
| **Critical (Page)** | Immediate action needed, user impact now | < 5 min | On-call primary |
| **High (Page)** | Action needed in < 1h, impending user impact | < 30 min | On-call primary |
| **Warning (Ticket)** | Fix by next business day | < 24h | Team |
| **Info** | No action needed, for awareness only | — | Nobody paged |

---

## Runbook Template (per alert)

```markdown
# Runbook: [Alert Name]

**Alert condition:** [PromQL / condition]
**Severity:** Critical / High / Warning

## Symptom
What does the on-call see? (dashboard link, typical error message)

## Impact
- Affected users / features:
- SLO impact: [yes/no, how much budget]

## Diagnosis
1. Check [dashboard link]: [what to look for]
2. [Query or log search]
3. [Next diagnosis step]

## Mitigation
- Fastest workaround: [step]
- Permanent fix: [step or ticket]

## Escalation
If mitigation doesn't help after [X min] → contact [name/role]
```

---

## Postmortem Template (after SEV-1 / SEV-2)

```markdown
# Postmortem: [Incident Title]

**Date:** [date]
**Duration:** [start] – [end] ([X] minutes)
**Severity:** SEV-1 / SEV-2
**SLO violation:** yes/no — [X min error budget consumed]

## Impact
- Affected users:
- Affected features / services:

## Root Cause
[What happened — 5-Why or Fishbone]

## Contributing Factors
[Systemic causes that made the incident possible]

## Timeline
| Time | Event |
|---|---|
| HH:MM | [What happened] |
| HH:MM | [Detected by ...] |
| HH:MM | [First action] |
| HH:MM | [Resolved] |

## Detection
- Detected by: [alert / user report / monitoring]
- Time to detection: [X min]
- Could have been detected earlier: yes/no — [how?]

## Action Items
| Task | Owner | Due Date |
|---|---|---|
| [Concrete action, not "we should..."] | [Name] | [Date] |

## Lessons Learned
- What worked:
- What didn't work:
- What we change in the process:
```
