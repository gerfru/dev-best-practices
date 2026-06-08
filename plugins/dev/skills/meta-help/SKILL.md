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

🔍  REVIEW
  6  review-app        Vollaudit: Architektur, Security, Tests, CI/CD, Observability
  7  review-arch       Architektur: Coupling, Anti-Patterns, Quality Attributes, ADR
  8  review-secure     Security: Crypto, Injection, Memory Safety, GDPR/ISO/EU AI Act

🛠️  TOOLS
  9  tool-debug        Stack-aware Root-Cause-Analyse mit Fix-Vorschlägen
 10  tool-test         Tests schreiben, verbessern oder Strategie planen
 11  tool-style        CSS / Design System konsistent und wartbar halten

📁  META
 12  meta-install      Best-Practice-Regeln in Projekt-CLAUDE.md einbauen
 13  meta-drift        Projekt-CLAUDE.md vs. aktuelle Rule-Files vergleichen
 14  meta-sync         reference/*.md vs. claude/*.md synchron halten

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
- Nie alle 14 Skills gleichzeitig laden — immer nur den gewählten
