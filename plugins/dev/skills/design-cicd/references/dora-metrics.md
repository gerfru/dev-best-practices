# DORA Metrics — Referenz

Quelle: DORA State of DevOps Report 2024 (dora.dev). Empirisch validiert über 10+ Jahre und 36.000+ Befragte.

## 4 Key Metrics

| Metric | Definition | Elite | High | Medium | Low |
|---|---|---|---|---|---|
| **Deployment Frequency** | Wie oft in Prod deployt | On-demand (mehrmals/Tag) | 1×/Tag – 1×/Woche | 1×/Woche – 1×/Monat | < 1×/Monat |
| **Lead Time for Changes** | Commit → Prod | < 1h | 1 Tag – 1 Woche | 1 Woche – 1 Monat | > 6 Monate |
| **Change Failure Rate** | % Deployments die Incident verursachen | 0–5% | 5–10% | 10–15% | > 15% |
| **MTTR** | Zeit bis Wiederherstellung nach Incident | < 1h | < 1 Tag | < 1 Woche | > 6 Monate |

**Deployment Frequency + Lead Time** = Throughput (Speed)
**CFR + MTTR** = Stability (Quality)

Elite-Teams verbessern alle 4 gleichzeitig — kein Speed-vs-Stability-Tradeoff.

---

## Messung

| Metric | Datenquelle |
|---|---|
| Deployment Frequency | CI/CD-System: Anzahl Production-Deployments / Zeitraum |
| Lead Time | Git: Commit-Timestamp → CD: Deploy-Timestamp |
| Change Failure Rate | Incidents / Deployments (aus Incident-Tracking + CD-System) |
| MTTR | Incident-Tracking: Created-at → Resolved-at |

---

## DORA Capabilities (2024 Report)

Die 24 Capabilities die laut DORA-Forschung Performance vorhersagen:

**Technische Practices:**
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

Vollständige Liste: dora.dev/research/

---

## Trunk-Based Development

Kernprinzipien (aus "Accelerate", Kap. 4):
- Alle Entwickler committen mindestens 1× täglich auf main/trunk
- Feature Branches leben maximal 1–2 Tage
- Feature Flags für unfertige Features, nicht Long-Lived Branches
- CI läuft bei jedem Commit auf main

**Warum:** Long-Lived Branches = verzögertes Integration-Feedback = große Merge-Konflikte = seltene Deployments = niedrige DORA-Performance. Empirisch belegt.
