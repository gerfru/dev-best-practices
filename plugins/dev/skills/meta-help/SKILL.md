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
  1  design-app        Stack & Architektur aus den Best-Practice-Regeln
  2  design-secure     Security Design: Threat Model, Krypto, Auth, Compliance
  3  design-api        REST / GraphQL / gRPC Contract entwerfen oder reviewen
  4  design-data       Schema, Normalisierung, Indexe, CQRS / Event Sourcing
  5  design-migration  Migrations-Strategie: Zero-Downtime, Strangler Fig, Saga
  6  design-ux         UX/UI Design: Interaktion, Vertrauen, AI-Features, Anti-Patterns
  7  design-llm        LLM-System: RAG, Fine-tune, Agent, Eval-Strategie, Guardrails

🔍  REVIEW
  8  review-app        Vollaudit: Architektur, Security, Tests, CI/CD, Observability
  9  review-arch       Architektur: Coupling, Anti-Patterns, Quality Attributes, ADR
 10  review-secure     Security: Crypto, Injection, Memory Safety, GDPR/ISO/EU AI Act
 11  review-ux         UX-Audit: AI Anti-Patterns, Dark Patterns, Trust Design
 12  review-llm        LLM-Audit: Architektur, Evals, Prompt Injection, OWASP LLM Top 10

🛠️  TOOLS
 13  tool-debug        Stack-aware Root-Cause-Analyse mit Fix-Vorschlägen
 14  tool-test         Tests schreiben, verbessern oder Strategie planen
 15  tool-style        CSS / Design System + Visual Basics (Farbe, Typo, Spacing, Loading)

📁  META
 16  meta-install        Best-Practice-Regeln in Projekt-CLAUDE.md einbauen
 17  meta-drift          Projekt-CLAUDE.md vs. aktuelle Rule-Files vergleichen
 18  meta-sync           reference/*.md vs. claude/*.md synchron halten
 19  meta-create-skill   Neuen Skill bauen: Recherche, Struktur, alle Dateien

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
- Nie alle 19 Skills gleichzeitig laden — immer nur den gewählten
