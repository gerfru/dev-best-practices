# Deployment Strategies — Comparison

| Strategy | Description | Downtime | Rollback | Infra Cost | Risk |
|---|---|---|---|---|---|
| **Recreate** | Stop old version, start new | Yes | New deployment | 1× | High |
| **Rolling Update** | Replace instances incrementally | No | Stop rollout / reverse | 1× | Medium |
| **Blue-Green** | Two parallel envs, traffic switch | No | Switch traffic back | 2× | Low |
| **Canary** | % traffic to new version, increase gradually | No | Traffic to 0% | 1.x× | Low |
| **Feature Flags** | Code deployed, feature activated via flag | No | Disable flag | 1× | Minimal |
| **Shadow** | Mirror prod traffic to new version (no user impact) | No | No traffic impact | 1.x× | None |

---

## Decision Tree

```text
Can there be downtime?
├─ Yes → Recreate (Non-Prod / Low-Traffic only)
└─ No:
   Is new version + old version API-compatible?
   ├─ Uncertain / Breaking Change → Feature Flag
   └─ Compatible:
      Do I need granular rollout feedback?
      ├─ Yes → Canary (with metrics gate)
      └─ No:
         Is fast rollback via traffic switch sufficient?
         ├─ Yes → Blue-Green
         └─ No → Rolling Update
```

---

## Feature Flags — Decision

**Use Feature Flags when:**
- New feature is uncertain whether production-stable
- Breaking change to existing API (run both versions in parallel)
- A/B test or gradual rollout by user segment
- Kill switch needed for immediate rollback without deployment

**Do not use when:**
- Purely technical refactorings without behavior change
- Feature is already fully tested and stable
- Too many flags accumulate (tech debt: delete flags after rollout)

---

## Canary Release — Rollout Plan

| Phase | Traffic % | Wait for | Abort if |
|---|---|---|---|
| 1 | 1% | 30 min, error rate stable | Error rate > baseline + 0.1% |
| 2 | 10% | 1h, latency stable | p95 latency > baseline + 20% |
| 3 | 50% | 2h, DORA metrics stable | CFR increases |
| 4 | 100% | — | — |
