---
name: review-ux
description: >
  Systematischer UX-Audit eines bestehenden Produkts, Features oder Designs gegen
  die vier kanonischen Human-AI Interaction Frameworks: Microsoft HAX 18 Guidelines
  (Amershi et al., CHI 2019), Google PAIR Guidebook (23 Patterns), CHI 2024
  Generative AI Design Principles (IBM Research, 6 Prinzipien), und Nielsen Norman
  Group AI Design Anti-Patterns.
  Use this skill whenever the user wants to audit, evaluate, or critique existing
  UX/UI — or asks "is this good UX?", "what's wrong with this interface?",
  "review this design", "what dark patterns or AI anti-patterns are here?",
  "is the trust design right?", "UX-Feedback für mein Feature", "can you check
  my onboarding flow". Covers all product types: web apps, mobile, AI assistants,
  chatbots, dashboards, internal tools, voice UIs, design mockups.
---

# UX Review (framework-basiert)

Bewertet bestehendes UX/UI gegen die kanonischen HCI-Frameworks.
SOLL = HAX · PAIR · CHI 2024 · NNG. IST = das beschriebene oder vorgelegte Design.
Jeder Befund zitiert die verletzte Guideline.

---

## Schritt 0 — Kontext & Prüfumfang bestimmen

**Auto-Discovery: Was liegt vor?**

| Input-Typ | Vorgehen |
|-----------|---------|
| Screenshot / Mockup | Direkt analysieren; UI-Elemente beschreiben |
| Code (HTML/JSX/Templates) | Lesen und UI-Struktur ableiten |
| Verbal beschriebenes Feature | Beschreibung als Grundlage; Annahmen markieren |
| Link zu Live-Produkt (vom Nutzer angegeben) | Beschreibung des Nutzers als Basis |
| Design-Spec (Figma-Export, MD-Dokument) | Lesen und Struktur ableiten |

**Aus Kontext ableiten:**
- **KI-Beteiligung:** Empfehlungen / Generierung / Klassifikation / Agenten vorhanden?
  → Wenn ja: CHI 2024 + HAX Phase 3+4 vollständig anwenden
- **Nutzertyp:** Experten / Laien / gemischt → Komplexitätslevel der Findings anpassen
- **Produktphase:** Prototype / Beta / Production → Severity-Schwellwert anpassen
- **Kanal:** Web / Mobile / Voice / Dashboard → kanalspezifische Guidelines aktivieren

Nenne dem Nutzer kompakt was erkannt wurde: `Typ: Web-App | KI: Empfehlungs-Engine | Nutzer: Konsumenten | Phase: Production`.

---

## Schritt 1 — Sechs Audit-Dimensionen

Alle sechs Dimensionen systematisch durchgehen. Befunde im Format:

```text
[G-Code / P-Code] Titel · Severity (Critical/High/Medium/Low) · Befund · Fix
```

Severity-Definition:
- **Critical** — Vertrauensbruch, gefährliche Überreliance, vollständige Desorientierung
- **High** — Wichtige Guideline verletzt; schadet User Experience messbar
- **Medium** — Verbesserung empfohlen; kein sofortiger Schaden
- **Low** — Kosmetisch oder nur bei Skalierung relevant

---

### Dimension 1 — Erwartungen & Mentale Modelle
*HAX G1–G2 · PAIR Ch.2 · CHI 2024 P2 · NNG ELIZA Effect*

Fragen:
- Kommuniziert das Interface klar, was das System **kann** und **nicht kann**? (HAX G1/G2)
- Gibt es ein Onboarding das die vier PAIR-Fragen beantwortet (kann / kann nicht / ändert sich / verbessern)?
- Gibt es Anzeichen von ELIZA-Effekt — anthropomorphe Sprache die falsche Erwartungen weckt? (NNG)
- Bei GenAI: Wird kommuniziert, dass gleiche Inputs variable Outputs erzeugen können? (CHI 2024 P4 S1)
- Gibt es Beispiele oder Demos die effektive Nutzung lehren? (CHI 2024 P2 S2)

---

### Dimension 2 — Vertrauen & Transparenz
*HAX G10–G11 · PAIR P11–P13, Ch.3 · CHI 2024 P3 · NNG*

Fragen:
- Ist Konfidenz-Anzeige vorhanden? Ist die Darstellungsform für diese Nutzergruppe geeignet? (PAIR P11)
- Gibt es Erklärungen für KI-Entscheidungen? Sind sie entscheidungsrelevant statt vollständig? (PAIR P12)
- Gibt es Quellentransparenz bei faktischen Claims? (CHI 2024 P3 S2)
- Ist die Rolle der KI klar definiert (Partner / Assistent / Tool)? (CHI 2024 P3 S4)
- Ist Reibung vorhanden wo Überreliance gefährlich wäre? (CHI 2024 P3 S3)
- Verhindert hohe Formatierung kritische Prüfung von Outputs? (NNG)

---

### Dimension 3 — Feedback & Nutzerkontrolle
*HAX G7–G9, G15–G17 · PAIR P15–P18 · CHI 2024 P5*

Fragen:
- Können Nutzer KI-Features effizient **aktivieren** und **ablehnen**? (HAX G7/G8)
- Können Nutzer Fehler effizient **korrigieren**? (HAX G9)
- Gibt es granulares Feedback (Item-Level, nicht nur "Thumbs up/down global")? (HAX G15)
- Sehen Nutzer, wie ihre Aktionen das System **beeinflussen**? (HAX G16)
- Gibt es **globale Kontrollen** für systemweite Einstellungen? (HAX G17)
- Ist der Automatisierungsgrad dem Vertrauen und dem Risiko angemessen? (PAIR P14/P17)

---

### Dimension 4 — Fehlerbehandlung & Graceful Failure
*HAX G9–G11 · PAIR Ch.6 · CHI 2024 P6 · NNG*

Fragen:
- Werden Fehlerzustände der KI dem Nutzer verständlich kommuniziert?
- Gibt es einen nahtlosen Fallback zu manueller Kontrolle wenn Automatisierung scheitert? (PAIR P18)
- Wird Unsicherheit sichtbar gemacht — oder werden unsichere Outputs selbstbewusst präsentiert? (CHI 2024 P6 S1)
- Gibt es "Edit / Regenerate / Undo"-Pfade für KI-Outputs? (CHI 2024 P6 S3)
- Gibt es Feedback-Wege wenn Nutzer einen Fehler erkennen? (CHI 2024 P6 S4)
- Schränkt das System Aktionen konservativ ein wenn es unsicher ist? (HAX G10)

---

### Dimension 5 — Langzeit & Adaptation
*HAX G12–G18*

Fragen:
- Behält das System relevanten Kontext aus früheren Sessions? (HAX G12)
- Lernt das System aus Nutzerverhalten? Ist das kommuniziert? (HAX G13)
- Werden Updates/Änderungen an Verhalten oder Fähigkeiten kommuniziert? (HAX G18)
- Werden System-Updates graduell eingeführt, nicht überraschend? (HAX G14)
- Gibt es Mechanismen für Nutzer um ihre History oder gelernten Präferenzen zu verwalten?

---

### Dimension 6 — Anti-Pattern Check
*NNG · PAIR P1–P3 · CHI 2024 P1*

Checkliste — jedes identifizierte Anti-Pattern als Befund melden:

| Anti-Pattern | Test |
|-------------|------|
| Technology-first: KI ohne validiertes Nutzerproblem | Gibt es ein konkretes Nutzerproblem hinter dem Feature? |
| "Powered by AI" als Value Prop | Wird Nutzernutzen gezeigt oder nur die Technologie? |
| Chat-Default ohne Validierung | Ist Chat das richtige Modell für diese Aufgabe? |
| Broad unscoped AI | Sind Fähigkeitsgrenzen klar begrenzt und kommuniziert? |
| Kein Prompt-Support | Haben Nutzer Hilfe beim Formulieren von Anfragen? |
| Über-Anthropomorphisierung | Suggeriert Sprache/Design falsche Menschenähnlichkeit? |
| Hochformatierung statt Genauigkeit | Verhindert polished Output kritische Evaluation? |
| Kein Feedback-Weg | Können Nutzer Fehler des Systems melden und korrigieren? |
| Proaktiv zum falschen Timing | Unterbricht das System laufende Aufgaben? (HAX G3) |
| Überreliance ohne Reibung | Werden kritische Entscheidungen ausreichend gebremst? |

---

### Dimension 7 — Dark Patterns & Ethisches Design
*EU Digital Services Act · DSGVO Art. 7 · FTC Guidelines*

Unterschied zu Dimension 6: Dimension 6 prüft schlechte AI UX.
Dimension 7 prüft absichtliche Manipulation des Users — unabhängig von KI-Beteiligung.

| Pattern | Test | Severity |
|---------|------|----------|
| Roach Motel | Anmelden leicht, kündigen versteckt/schwer? | Critical |
| Forced Continuity | Kostenlos-Periode endet ohne deutliche Vorwarnung in Abo? | Critical |
| Privacy Zuckering | Cookie-Banner: Ablehnen schwerer als Akzeptieren? | Critical |
| Hidden Costs | Preise erst im letzten Checkout-Schritt vollständig sichtbar? | Critical |
| Trick Questions | Doppelte Verneinung / unklare Opt-out Checkboxen? | High |
| Fake Urgency | Countdown der sich zurücksetzt / falsche Verfügbarkeitsangaben? | High |
| Confirmshaming | Ablehnen-Button formuliert als Selbstverurteilung? | High |
| Disguised Ads | Werbung optisch nicht von Content unterscheidbar? | High |
| Bait & Switch | Etwas versprochen, anderes geliefert? | High |
| Misdirection | Wichtige Info visuell versteckt oder im Kleingedruckten? | Medium |

**Severity-Regel:** Verstöße gegen DSGVO Art. 7 / DSA → immer Critical.
EU-Kontext: 97% der populären Apps enthielten 2025 Dark Pattern Elemente (EU-Sweep).
Bußgeld bis 6% Jahresumsatz. FTC-Präzedenz: Epic Games 245M$ Strafe (2023).

---

## Schritt 2 — Befunde konsolidieren

1. Alle Befunde nach **Severity** sortieren (Critical → Low)
2. Je Dimension eine **Ampel** vergeben: 🟢 / 🟡 / 🔴
3. Top-3 Quick Wins (hohe Wirkung, niedriger Aufwand) separat ausweisen
4. Befunde ohne Datei/Screen-Bezug als `[Annahme - zu verifizieren]` markieren

---

## Schritt 3 — Report schreiben

Ausgabe nach `./review-ux-report.md`:

```markdown
# UX Review: [Produkt / Feature Name]
Datum: YYYY-MM-DD
Framework-Basis: HAX (18 Guidelines) · PAIR (23 Patterns) · CHI 2024 (6 Prinzipien) · NNG

## Erkannter Kontext
[Typ, KI-Beteiligung, Nutzertyp, Phase, Kanal]

## Ampel-Übersicht
| Dimension | Ampel | #Critical | #High | Wichtigste verletzte Guideline |
|-----------|-------|-----------|-------|-------------------------------|
| Erwartungen & Mentale Modelle | 🟡 | 0 | 1 | HAX G1: Fähigkeiten nicht kommuniziert |
| Vertrauen & Transparenz | 🔴 | 1 | 2 | NNG: Über-Anthropomorphisierung |
| Feedback & Kontrolle | 🟢 | 0 | 0 | — |
| Fehlerbehandlung | 🟡 | 0 | 1 | PAIR P18: Kein manueller Fallback |
| Langzeit & Adaptation | 🟢 | 0 | 0 | — |
| AI Anti-Pattern Check | 🔴 | 1 | 1 | Chat-Default ohne Validierung |
| Dark Patterns | 🟢 | 0 | 0 | — |

## Top-3 Quick Wins
1. [Titel] · [HAX/PAIR/CHI-Code] · Aufwand: S (<30min) · [konkreter Fix]
2. …
3. …

## Vollständige Befundliste

### Critical
- [G-Code] **Titel** · Befund: … · Fix: … · Referenz: HAX G11

### High
- …

### Medium
- …

### Low
- …

## Nicht bewertet / Annahmen
- [Zu verifizieren]: …

---
*Erstellt mit KI-Unterstützung (Claude Code + dev-best-practices Plugin).
Findings sind zu verifizieren — kein Ersatz für manuelle Usability-Tests mit echten Nutzern.*
```

---

## Regeln

- Keine spekulativen Befunde. Nur mit konkretem Bezug zum vorgelegten Design oder
  klar belegbarer Lücke. Unsicheres als `[zu verifizieren]` kennzeichnen.
- Jeder Befund nennt die konkrete verletzte Guideline (HAX G-Nr. / PAIR P-Nr. / CHI P-Nr. / NNG), nicht nur ein generisches Prinzip.
- **Nichts automatisch fixen.** Erst Report, dann auf Nachfrage gezielt umsetzen.
- Accessibility-Probleme die gegen EU Accessibility Act / BFSG verstoßen → immer als **High** oder **Critical** melden.
- Anti-Patterns nicht doppelt melden (einmal in Dimension 1–5 und einmal in Dimension 6).
- Positive Befunde explizit erwähnen — was funktioniert gut und warum. UX-Review ist kein reiner Bug-Report.

---

## Framework-Kurzreferenz

### Microsoft HAX — 18 Guidelines nach Phase

| Phase | Guidelines |
|-------|-----------|
| Initially | G1 (Fähigkeiten kommunizieren), G2 (Qualität kommunizieren) |
| During | G3 (Timing), G4 (Kontextrelevanz), G5 (Soziale Normen), G6 (Bias), G7 (Aktivierung), G8 (Ablehnung) |
| When Wrong | G9 (Korrektur), G10 (Einschränken bei Unsicherheit), G11 (Erklärung) |
| Over Time | G12 (History), G13 (Lernen), G14 (Updates vorsichtig), G15 (Granulares Feedback), G16 (Konsequenzen), G17 (Globale Kontrollen), G18 (Änderungen kommunizieren) |

### Google PAIR — 23 Patterns nach Kapitel

| Kapitel | Patterns |
|---------|---------|
| Nutzerbedürfnisse & Erfolg | P1–P4 |
| Mentale Modelle | P8–P10 |
| Erklärbarkeit & Vertrauen | P11–P13 |
| Datenerhebung & Evaluation | P5–P7, P19–P22 |
| Feedback & Kontrolle | P14–P18 |
| Fehler & Graceful Failure | P18 (Fallback), P23 (Domain Experts) |

### CHI 2024 — 6 Prinzipien

| # | Prinzip | GenAI-spezifisch |
|---|---------|-----------------|
| P1 | Design Responsibly | Nein (reinterpretiert) |
| P2 | Design for Mental Models | Nein (reinterpretiert) |
| P3 | Design for Appropriate Trust | Nein (reinterpretiert) |
| P4 | Design for Generative Variability | **Ja** |
| P5 | Design for Co-Creation | **Ja** |
| P6 | Design for Imperfection | **Ja** |

### NNG — 4 KI-Superkräfte & Antipatterns

Superkräfte: Content Creation · Summarization · Basic Data Analysis · Perspective Taking

Kritischste Antipatterns: Technology-first · Chat-Default · Über-Anthropomorphisierung · Hochformatierung hemmt Verifikation
