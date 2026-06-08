# DORA Metrics — Reference

Source: DORA State of DevOps Report 2024 (dora.dev). Empirically validated over 10+ years and 36,000+ respondents.

## 4 Key Metrics

| Metric | Definition | Elite | High | Medium | Low |
|---|---|---|---|---|---|
| **Deployment Frequency** | How often deployed to Prod | On-demand (multiple times/day) | 1×/day – 1×/week | 1×/week – 1×/month | < 1×/month |
| **Lead Time for Changes** | Commit → Prod | < 1h | 1 day – 1 week | 1 week – 1 month | > 6 months |
| **Change Failure Rate** | % deployments causing an incident | 0–5% | 5–10% | 10–15% | > 15% |
| **MTTR** | Time to restore after incident | < 1h | < 1 day | < 1 week | > 6 months |

**Deployment Frequency + Lead Time** = Throughput (Speed)
**CFR + MTTR** = Stability (Quality)

Elite teams improve all 4 simultaneously — no speed-vs-stability trade-off.

---

## Measurement

| Metric | Data Source |
|---|---|
| Deployment Frequency | CI/CD system: number of production deployments / time period |
| Lead Time | Git: commit timestamp → CD: deploy timestamp |
| Change Failure Rate | Incidents / Deployments (from incident tracking + CD system) |
| MTTR | Incident tracking: created-at → resolved-at |

---

## DORA Capabilities (2024 Report)

The 24 capabilities that DORA research shows predict performance:

**Technical Practices:**
- Trunk-Based Development
- Continuous Integration
- Test Automation
- Deployment Automation
- Continuous Delivery
- Loosely Coupled Architecture
- Empowering Teams to Choose Tools
- Shifting Left on Security

**Process Practices:**
- Working in Small Batches
- Team Experimentation
- Visual Management
- Proactive Failure Notification
- Customer Feedback

**Cultural Practices:**
- Generative Organizational Culture (Westrum)
- Learning Culture
- Transformational Leadership
- Well-being

Full list: dora.dev/research/

---

## Trunk-Based Development

Core principles (from "Accelerate", Ch. 4):
- All developers commit at least 1× daily to main/trunk
- Feature branches live at most 1–2 days
- Feature flags for incomplete features, not long-lived branches
- CI runs on every commit to main

**Why:** Long-lived branches = delayed integration feedback = large merge conflicts = infrequent deployments = low DORA performance. Empirically proven.
