---
name: app-design
description: Von einer App-Idee zu fundierten Architektur- und Stack-Entscheidungen auf Basis der Dev-Best-Practices-Regeln. Use this skill whenever the user describes a new app idea and wants help choosing architecture, stack, structure, or a scaffolding plan; triggert bei "neue App", "App-Idee", "wie strukturiere ich", "welcher Stack", "Architektur fuer ...".
---

# App Design (regel-basiert)

Wandelt eine App-Idee in begruendete Entscheidungen um. Maszstab: die Regel-Files
unter `${CLAUDE_PLUGIN_ROOT}/rules/` (v.a. architecture-rules.md, app-rules.md,
github-rules.md). Keine generischen Ratschlaege - jede Entscheidung verweist auf die Regel.

## Schritt 0 - Idee & Rahmen klaeren
Erfasse aus der Beschreibung: Domaene, Nutzer, erwartete Last, Team-Groesse (Solo?),
ob Web-Frontend, ob sensible Daten (DSGVO/MDR). Fehlt Wesentliches: einmal nachfragen,
nicht raten.

## Schritt 1 - Entscheidungen entlang der Regeln treffen
Arbeite die Entscheidungsbaeume aus architecture-rules.md ab und begruende jede Wahl:
- Monolith vs. Microservices (Default: Monolith-First)
- Monorepo vs. Polyrepo
- Rendering (SSR/SSG/ISR/CSR)
- API-Typ (tRPC intern / REST extern / GraphQL)
- Datenbank + ORM/Query-Builder
- State-Management (Server- vs. Client-State)
- Schichtung passend zur Projektgroesse
- Ziel-ASVS-Level (Default L1 Solo, L2 Production) und relevante Security-Grundregeln
- CI/CD-Grundgeruest (Pipeline, Branch Protection, Scanning)

## Schritt 2 - Liefern
Schreibe nach `./app-design.md`:
1. Kurzes Architektur-Decision-Record: Entscheidung | Wahl | Begruendung (Regel-Referenz)
2. Empfohlene Ordnerstruktur (feature-basiert) fuer den gewaehlten Stack
3. "Tag 1"- und "Erste Woche"-Setup-Checkliste (aus github-rules.md / app-rules.md)
4. Offene Punkte / bewusste Trade-offs als "[zu verifizieren]"

## Regeln
- Kein Over-Engineering: fuer Solo/Prototyp die einfachste regelkonforme Variante.
- Jede Entscheidung nennt die zugrundeliegende Regel (Datei -> Section).
- Annahmen explizit als "[Annahme]" markieren statt still zu fuellen.
