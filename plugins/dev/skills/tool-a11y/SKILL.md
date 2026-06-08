---
name: tool-a11y
description: >
  Accessibility Audit-Workflow grounded in WCAG 2.2 (W3C), CMU HCII 05-332
  (Prof. Carrington) und W3C WAI Digital Accessibility Foundations. Deckt
  automatisierten Audit (axe-core/Lighthouse), Keyboard-Navigation,
  Screen Reader Testing (NVDA, JAWS, VoiceOver) und EU Accessibility Act /
  EN 301 549 / BFSG Compliance ab — inkl. aller 9 neuen WCAG 2.2 SC.
  Use this skill whenever the user wants to audit, test, or improve accessibility
  of a web product, or needs to check EU Accessibility Act / BFSG compliance.
  Trigger: "Accessibility pruefen", "WCAG Audit", "Screen Reader testen",
  "axe-core", "Barrierefreiheit verbessern", "EU Accessibility Act", "BFSG",
  "EN 301 549", "Keyboard Navigation pruefen", "Focus Management",
  "alt-text pruefen", "ist meine App barrierefrei", "WCAG 2.2 neue Kriterien",
  "Kontrast pruefen", "ARIA korrekt", "Skip Link fehlt".
  Deckt ab: WCAG 2.2 Audit (A/AA/AAA), automatisierte Tests, Keyboard-Navigation,
  Screen Reader Testing, EU Accessibility Act / BFSG / EN 301 549 Compliance.
---

# Accessibility Audit (tool-a11y)

Strukturierter Accessibility-Audit-Workflow — von automatisierten Tests bis zu
Screen-Reader-Testing und EU-Compliance-Check. Grounded in WCAG 2.2 und CMU HCII 05-332.

---

## Core Philosophy (WCAG 2.2 + CMU HCII)

> "Accessibility is not a feature — it is a quality attribute. Permanent, temporary,
> and situational disabilities affect everyone at some point."
> — CMU HCII 05-332 (Carrington), Universal Design Principle

Automatisierte Tools finden ~30% aller Accessibility-Issues. Die restlichen 70%
erfordern manuelle Tests mit Keyboard und Screen Reader. WCAG 2.2 Level AA ist seit
Juni 2025 gesetzlicher Mindeststandard in der EU (Accessibility Act / BFSG).

---

## Schritt 0 — Scope klären

**Fragen:**
- Was wird auditiert? (Web-App, Mobile Web, Desktop-App, Dokument)
- Ziel-WCAG-Level: A / AA (gesetzlicher Standard EU) / AAA?
- EU Accessibility Act / BFSG relevant? (Produkt wird in der EU verkauft, ab Juni 2025)
- WCAG 2.2 oder noch 2.1? (2.2 ist aktuell, 2.1 wird weiter anerkannt)
- Zeitrahmen: Quick-Check (1–2h) oder vollstaendiger Audit?

---

## Schritt 1 — Automatisierter Audit

(→ `references/testing-tools.md` fuer Tool-Vergleich)

**1a — axe-core Browser Extension**

- Seiten nacheinander im Browser oeffnen
- axe DevTools starten → "Scan All of My Page"
- Findings nach Severity filtern: Critical → Serious → Moderate → Minor
- Alle Findings dokumentieren: SC-Nummer, Element, Beschreibung

**1b — Lighthouse Audit**

- Chrome DevTools → Lighthouse → Category: Accessibility → Generate Report
- Ergaenzende Findings zu axe-core notieren (keine Duplikate)

**Reminder:** Automatisierte Tests = ~30% Coverage. Schritt 2–4 sind Pflicht.

---

## Schritt 2 — Keyboard-Navigation

Komplette Seite nur mit Tastatur bedienen (kein Mauszeiger):

**Checkliste:**
- [ ] Tab-Reihenfolge logisch und vorhersehbar? (WCAG 2.4.3)
- [ ] Alle interaktiven Elemente per Tab erreichbar? (WCAG 2.1.1)
- [ ] Fokus-Indikator sichtbar bei jedem Element? (WCAG 2.4.7)
- [ ] Fokus nicht durch sticky Header/Footer verdeckt? (WCAG 2.4.11 — NEU 2.2)
- [ ] Kein Keyboard Trap (Enter/Escape loest Modals)? (WCAG 2.1.2)
- [ ] Skip-Link zu Main Content vorhanden und funktional? (WCAG 2.4.1)
- [ ] Alle Drag & Drop-Aktionen haben Tastatur-Alternative? (WCAG 2.5.7 — NEU 2.2)
- [ ] Klickziele mind. 24×24px? (WCAG 2.5.8 — NEU 2.2)

---

## Schritt 3 — Screen Reader Testing

(→ `references/testing-tools.md` fuer Shortcuts und Kombinationen)

Minimum: **NVDA + Chrome**. Zusaetzlich: **VoiceOver + Safari** fuer iOS.

**Testablauf:**
- Headings-Struktur: H-Taste → logische Hierarchie H1→H2→H3?
- Landmarks: D-Taste → main, nav, header, footer vorhanden?
- Formulare: F-Taste → alle Labels vorgelesen? Pflichtfelder erkennbar?
- Fehlermeldungen: ARIA live region? Werden Fehler automatisch vorgelesen?
- Bilder: Alt-Text sinnvoll (nicht "image123.png")?
- Links: Linktext aussagekraeftig ohne Kontext? (kein "hier klicken")
- Status-Meldungen: Werden dynamische Updates vorgelesen? (WCAG 4.1.3)

---

## Schritt 4 — WCAG 2.2 Neue SC manuell pruefen

(→ `references/wcag-checks.md` fuer vollstaendige Liste)

Alle 9 neuen SC in WCAG 2.2 pruefen (nicht von axe-core erkannt):

| SC | Was pruefen |
|---|---|
| 2.4.11 | Fokus-Indikator durch kein Element verdeckt (sticky nav, modals) |
| 2.4.12 | Fokus vollstaendig sichtbar (AAA) |
| 2.4.13 | Fokus-Indikator: mind. 2px Umrandung, 3:1 Kontrast (AAA) |
| 2.5.7 | Alle Drag & Drop-Aktionen haben Einzelklick-Alternative |
| 2.5.8 | Alle Klickziele mind. 24×24px (oder ausreichend Abstand) |
| 3.2.6 | Hilfe-Funktion (Chat, FAQ, Tel) immer an gleicher Stelle |
| 3.3.7 | Keine Doppeleingabe gleicher Daten im selben Prozess |
| 3.3.8 | Login/Auth erfordert kein Auswendiglernen von Zeichenfolgen |
| 3.3.9 | Login/Auth: keine Copy-Paste-Einschraenkung (AAA) |

---

## Schritt 5 — EU Compliance Check

**Relevant wenn:** Produkt wird in der EU angeboten und faellt unter EU Accessibility Act (Directive 2019/882 / BFSG in DE, in Kraft ab 28. Juni 2025).

**Betroffen:** E-Commerce, Banking, Mobilitaet, Telekommunikation, E-Books, Messenger — und alle oeffentlichen Stellen.

**Anforderung:** WCAG 2.2 Level AA via EN 301 549 (europaeische Norm).

**Checkliste EU Compliance:**
- [ ] WCAG 2.2 AA vollstaendig erfuellt?
- [ ] Barrierefreiheitserklaerung vorhanden? (Pflicht: URL + Erstellungsdatum + Kontakt)
- [ ] Feedback-Mechanismus fuer Barrierefreiheitsprobleme vorhanden?
- [ ] Enforcement-Stelle bekannt? (In DE: Marktaufsichtsbehoerde)

---

## Schritt 6 — Report erstellen

Findings nach Severity sortieren:

| Severity | WCAG Level | Bedeutung |
|---|---|---|
| Critical (Blocker) | A | Bestimmte Nutzergruppen komplett ausgeschlossen |
| Serious | A / AA | Erhebliche Erschwernis fuer bestimmte Gruppen |
| Moderate | AA | Nutzbar, aber mit Aufwand |
| Minor | AA / AAA | Komfort-Issue, kein Ausschluss |

---

## Output — `a11y-audit-report.md`

```markdown
# Accessibility Audit — [Produkt-Name]

**Datum:** [Datum]
**WCAG Version:** 2.2
**Ziel-Level:** AA
**EU Accessibility Act relevant:** ja/nein

## Summary
- Automatisierte Tests (axe-core): [X] Findings
- Keyboard-Navigation: [X] Findings
- Screen Reader (NVDA+Chrome): [X] Findings
- WCAG 2.2 neue SC: [X] Findings
- EU Compliance: [erfuellt / nicht erfuellt / teilweise]

## Findings

### Critical (Blocker)
| SC | Element | Beschreibung | Empfehlung |
|---|---|---|---|
| 1.1.1 | img.logo | Kein alt-Text | alt="[Firmenname] Logo" |

### Serious
| SC | Element | Beschreibung | Empfehlung |
|---|---|---|---|

### Moderate
| SC | Element | Beschreibung | Empfehlung |
|---|---|---|---|

## EU Compliance
- [ ] WCAG 2.2 AA erfuellt
- [ ] Barrierefreiheitserklaerung vorhanden
- [ ] Feedback-Mechanismus vorhanden
```

## Reference Files

- `references/curriculum-mapping.md` — Concept → WCAG SC + W3C WAI + CMU HCII Modul
- `references/wcag-checks.md` — Kritische SC mit Level + Test-Methode, alle 9 neuen WCAG 2.2 SC
- `references/testing-tools.md` — axe-core / Lighthouse / NVDA / VoiceOver Kurzreferenz + Audit-Reihenfolge
