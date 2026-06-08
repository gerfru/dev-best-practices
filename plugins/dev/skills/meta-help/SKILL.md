---
name: meta-help
description: >
  Navigationsmenü für alle Dev-Best-Practices Skills. Zeigt alle verfügbaren Skills
  gruppiert und startet den gewählten direkt. Trigger bei "welchen skill soll ich nutzen",
  "was gibt es", "help", "was kann ich nutzen", "zeig mir die skills",
  "welches tool", "ich weiß nicht welchen skill".
---

# Dev Best Practices — Skill Navigator

Zeige das Menü sofort. Kein langer Einleitungstext.

## Schritt 1 — Menü anzeigen

```text
Welcher Skill soll starten?

🏗️  DESIGN
  1  design-app              Stack & Architektur aus den Best-Practice-Regeln
  2  design-secure           Security Design: Threat Model, Krypto, Auth, Compliance
  3  design-api              REST / GraphQL / gRPC Contract entwerfen oder reviewen
  4  design-data             Schema, Normalisierung, Indexe, CQRS / Event Sourcing
  5  design-migration        Migrations-Strategie: Zero-Downtime, Strangler Fig, Saga
  6  design-ux               UX/UI Design: Interaktion, Vertrauen, AI-Features, Anti-Patterns
  7  design-llm              LLM-System: RAG, Fine-tune, Agent, Eval-Strategie, Guardrails
  8  design-observability    Observability: SLO/SLI, Golden Signals, Tracing, Alerting, Incident Response
  9  design-cicd             CI/CD Pipeline: Deployment-Strategien, DORA-Metriken, Trunk-Based Dev
 10  design-iac              Infrastructure as Code: Terraform, GitOps, State Management, Drift Detection

🔍  REVIEW
 11  review-app        Vollaudit: Architektur, Security, Tests, CI/CD, Observability
 12  review-arch       Architektur: Coupling, Anti-Patterns, Quality Attributes, ADR
 13  review-secure     Security: Crypto, Injection, Memory Safety, GDPR/ISO/EU AI Act
 14  review-ux         UX-Audit: AI Anti-Patterns, Dark Patterns, Trust Design
 15  review-llm        LLM-Audit: Architektur, Evals, Prompt Injection, OWASP LLM Top 10

🛠️  TOOLS
 16  tool-debug        Stack-aware Root-Cause-Analyse mit Fix-Vorschlägen
 17  tool-test         Tests schreiben, verbessern oder Strategie planen
 18  tool-style        CSS / Design System + Visual Basics (Farbe, Typo, Spacing, Loading)
 19  tool-a11y         Accessibility-Audit: WCAG 2.2, Screen Reader, EU Accessibility Act
 20  tool-perf         Performance Engineering: USE Method, Flamegraph, Bottleneck, Bentley Rules

📁  META
 21  meta-install        Best-Practice-Regeln in Projekt-CLAUDE.md einbauen
 22  meta-drift          Projekt-CLAUDE.md vs. aktuelle Rule-Files vergleichen
 23  meta-sync           reference/*.md vs. claude/*.md synchron halten
 24  meta-create-skill   Neuen Skill bauen: Recherche, Struktur, alle Dateien

→ Zahl eingeben, oder direkt beschreiben was du brauchst.
```

## Schritt 2 — Skill starten

**Bei Zahl:** Skill sofort starten.  
**Bei Beschreibung:** Besten passenden Skill wählen, kurz nennen ("→ starte review-secure …"), dann direkt starten.  
**Bei Argumenten:** An den gestarteten Skill weitergeben.

Lade und folge exakt: `${CLAUDE_PLUGIN_ROOT}/skills/<gewählter-skill>/SKILL.md`

## Regeln
- Menü sofort zeigen, kein Intro
- Nach der Wahl direkt starten, nicht nochmals erklären oder nachfragen
- Nie alle 24 Skills gleichzeitig laden — immer nur den gewählten
