---
name: design-ux
description: >
  Human-Centered UX Design skill grounded in the leading academic HCI curricula
  (CMU HCII, Stanford CS 247A/347, ETH, TU Wien, TU Graz) and the four canonical
  industry frameworks: Microsoft HAX 18 Guidelines (Amershi et al., CHI 2019),
  Google PAIR Guidebook (23 Patterns), CHI 2024 Generative AI Design Principles
  (IBM Research, 6 Principles), and Nielsen Norman Group AI Design.
  Use this skill whenever the user wants to design the UX/UI of a new product,
  feature, or AI-powered system — or when they ask "how should this feel to the
  user", "what's the right interaction model", "how do I handle AI outputs in the
  UI", "trust and transparency design", "onboarding for AI features",
  "how to avoid dark patterns / AI anti-patterns". Covers all product types:
  web apps, mobile, AI assistants, chatbots, dashboards, internal tools, voice UIs.
---

# UX Design (framework-basiert)

Wandelt eine Produkt- oder Feature-Idee in begründete UX-Entscheidungen um.
Maßstab: die vier kanonischen Frameworks (HAX · PAIR · CHI 2024 · NNG) plus
akademische HCI-Fundierung. Keine generischen Ratschläge — jede Entscheidung
verweist auf eine Guideline oder ein Prinzip.

---

## Core Philosophy

Gute UX-Entscheidungen sind nicht ein Stylesheet am Ende des Projekts. Sie sind:

1. **Nutzerzentriert**: Nutzerbedürfnisse und mentale Modelle vor Interface-Entscheidungen
2. **Kontextuell**: Interaktionsmodell folgt der Aufgabe, nicht der Technologie
3. **Vertrauensbildend**: Kalibriertes Vertrauen ist eine explizite Design-Entscheidung
4. **Erklärt**: Jede Wahl hat ein "Warum" das das Team versteht und verteidigen kann
5. **Iterativ**: UX-Entscheidungen revisitieren wenn sich Nutzerverhalten zeigt

Besonders für KI-Features gilt: **Das Interface ist der Kontrakt zwischen dem System
und dem Nutzer.** Ein schlecht kommuniziertes KI-Feature erzeugt Misstrauen oder
gefährliche Überabhängigkeit — beides ist ein UX-Fehler.

---

## Design Workflow

### Phase 0 — Kontext verstehen

Erfasse aus der Beschreibung oder durch Lesen vorhandener Dateien:

1. **Was macht das Produkt / Feature?** (1–2 Sätze)
2. **Wer sind die Nutzer?** (Expertise, Kontext, Zugangsmittel)
3. **Welche Aufgaben sollen erfüllt werden?** (primäre User Goals)
4. **Ist KI / ML beteiligt?** (Empfehlungen, Generierung, Klassifikation, Agenten)
5. **Was ist der Kanal?** (Web, Mobile, Voice, Embedded, Dashboard, Chat)
6. **Gibt es Accessibility-Anforderungen?** (gesetzlich: EU Accessibility Act / BFSG)

Fehlt Wesentliches: **einmal** nachfragen, nicht raten. Annahmen explizit als
`[Annahme]` markieren.

---

### Phase 1 — Interaktionsmodell wählen

Das Interaktionsmodell bestimmt alles Folgende. Wähle bewusst, nicht per Default.

| Modell | Wann geeignet | Risiko |
|--------|--------------|--------|
| Klassische GUI | Strukturierte Aufgaben, vorhersehbare Inputs | Kein direktes Risiko |
| Chat / Konversation | Explorative, unstrukturierte Anfragen | Articulation Barrier, leeres Input-Feld schreckt ab |
| Hybrid (GUI + Prompt) | KI-Features in strukturierten Produkten | Komplexität; zwei mentale Modelle |
| Ambient / Proaktiv | KI greift ein ohne explizite Aufforderung | HAX G3: falscher Zeitpunkt zerstört Vertrauen |
| Voice | Freihand-Szenarien, Accessibility | Kein visuelles Feedback; Fehlerkorrektur schwer |

**NNG-Regel:** Nicht Chat-First per Default. Chat validieren gegen echte Nutzerbedürfnisse.
Wenn Nutzer präzise, strukturierte Aufgaben haben → GUI. Wenn explorative, sprachliche
Aufgaben → Chat oder Hybrid.

---

### Phase 2 — Mentale Modelle & Onboarding

*Referenz: PAIR Kapitel 2 · CHI 2024 P2 · HAX G1–G2 · NNG ELIZA Effect*

KI-Systeme sind dynamisch, nicht statisch. Nutzer bringen falsche mentale Modelle
aus klassischer Software mit. Onboarding muss das explizit korrigieren.

**Onboarding-Sequenz (4 Fragen in dieser Reihenfolge):**

1. **Was kann es?** — Fähigkeiten klar zeigen, mit Beispielen (PAIR P3: "Benefit, not technology")
2. **Was kann es nicht?** — Grenzen explizit nennen bevor der erste Fehler passiert (HAX G1/G2)
3. **Wie ändert es sich?** — System lernt / verbessert sich / ändert sich; kommunizieren (HAX G14/G18)
4. **Wie verbessert man es?** — Feedback-Mechanismen sichtbar machen (HAX G15/G16)

**ELIZA-Effekt verhindern (NNG):**
- Anthropomorphe Formulierungen prüfen: "Ich verstehe dich" → besser "Ich interpretiere deine Anfrage als…"
- Limitierungen offen benennen, nicht verstecken
- Kompetenz zeigen statt Menschenähnlichkeit (NNG: "Prioritize smarts over sentience")

**Generative Variabilität kommunizieren (CHI 2024 P4):**
- Wenn gleiche Inputs variable Outputs erzeugen: explizit zeigen (Google Gemini: Multiple Drafts)
- Nicht als Fehler darstellen — als Feature erklären

---

### Phase 3 — Vertrauen kalibrieren

*Referenz: HAX G1–G2, G10–G11 · PAIR P11–P13, Kapitel 3 · CHI 2024 P3 · NNG*

**Kalibriertes Vertrauen** ist das Ziel — weder blindes Vertrauen noch Misstrauen.

| Entscheidung | Guideline | Konkret |
|-------------|-----------|---------|
| Konfidenz anzeigen? | PAIR P11 | Nutzertestgestützt entscheiden; nicht immer hilfreich |
| Erklärungen zeigen? | PAIR P12 | Entscheidungsrelevant, nicht vollständig |
| Reibung einbauen? | CHI 2024 P3 S3 | Multi-Draft-Review erzwingt kritische Prüfung |
| Quellen zeigen? | CHI 2024 P3 S2 | Quellentransparenz bei faktischen Claims |
| Rolle der KI benennen? | CHI 2024 P3 S4 | Partner / Assistent / Tool klar definieren |
| Formatierung vs. Genauigkeit | NNG | Hohe Formatierung hemmt kritische Evaluation |

**Risikobasierte Automatisierung (PAIR P14 · P17):**
- Geringes Risiko + hohes Nutzervertrauen → mehr Automatisierung
- Hohes Risiko / kritische Entscheidungen → mehr Kontrolle und Bestätigung
- Automatisierung in Phasen einführen: Keine → Vorschlag → Ausführung (PAIR P17: "Automate in phases")

---

### Phase 4 — Feedback & Nutzerkontrolle

*Referenz: HAX G7–G9, G15–G17 · PAIR P15–P18 · CHI 2024 P5*

**Kontroll-Hierarchie entwerfen:**

```
Globale Einstellungen (HAX G17)
  └─ Sitzungs-Level Kontrolle (HAX G8: effizientes Ablehnen)
       └─ Item-Level Feedback (HAX G15: granulares Feedback)
            └─ Direkte Korrektur (HAX G9: effiziente Fehlerkorrektur)
```

**Co-Creation Design (CHI 2024 P5):**
- Input-Hilfe: Prompting-Tipps, Beispiele, Parameterkontrollen zeigen
- Ko-Bearbeitung: Generierte Outputs direkt editierbar machen (Adobe Photoshop-Modell)
- Domain-Controls: Fachspezifische Parameter sichtbar machen (nicht nur generische)

**Implizites vs. explizites Feedback (PAIR P15, P20):**
- Implizit: Click-Verhalten, Verweilzeit, was weiterverwendet wird
- Explizit: Thumbs up/down, strukturierte Forms, direktes Editing
- Beide Typen brauchen klares Kommunikationsdesign über ihre Wirkung (HAX G16)

---

### Phase 5 — Fehler & Graceful Failure

*Referenz: HAX G9–G11 · PAIR Kapitel 6 · CHI 2024 P6 · NNG*

**Drei Fehlerkategorien:**

| Typ | Beispiel | Design-Antwort |
|-----|---------|----------------|
| Scope-Fehler | Anfrage außerhalb der Fähigkeiten | HAX G10: konservativ einschränken, klar kommunizieren |
| Qualitätsfehler | Output nicht gut genug | CHI 2024 P6: Unsicherheit sichtbar machen; Edit/Regenerate |
| Vertrauensfehler | Nutzer erkennt Fehler nicht | NNG: Reibung einbauen; Verifikations-Hinweise |

**Fallback-Design (PAIR P18):**
- Wenn Automatisierung scheitert: nahtloser Rückfall zu manueller Kontrolle
- Kein "Error 500" für KI-Fehler — Nutzer zu handhabbarer Aktion führen
- Fehlermeldungen aus Nutzerperspektive formulieren (nicht technisch)

**Unsicherheit kommunizieren (CHI 2024 P6 S1):**
- Disclaimers, Konfidenz-Highlights, visuelle Differenzierung zwischen sicher/unsicher
- Domänenspezifische Qualitätsmetriken zeigen wenn vorhanden

---

### Phase 6 — Langfristiges Design

*Referenz: HAX G12–G18*

| Guideline | Design-Implikation |
|-----------|-------------------|
| G12: Recent interactions | Session-Kontext und History-Zugriff designen |
| G13: Learn from behavior | Feedback-Loops sichtbar machen; Personalisierung erklären |
| G14: Update cautiously | Modell-Updates graduell und transparent kommunizieren |
| G16: Consequences of actions | Sichtbar machen wie Nutzerchoices das System beeinflussen |
| G18: Notify about changes | Change-Log oder In-App-Benachrichtigungen bei relevanten Änderungen |

---

### Phase 7 — Anti-Patterns prüfen

Bevor das Design finalisiert wird: explizit gegen diese Liste prüfen.

| Anti-Pattern | Test | Lösung |
|-------------|------|--------|
| Technology-first design | Gibt es ein validiertes Nutzerproblem? | Problem First, dann KI |
| "Powered by AI" als Value Prop | Zeigt das Interface konkreten Nutzernutzen? | Benefit zeigen, nicht Tech |
| Chat löst alles | Ist Chat das richtige Modell für diese Aufgabe? | Interaktionsmodell validieren |
| Unscoped AI | Sind Fähigkeitsgrenzen klar kommuniziert? | HAX G1/G2 anwenden |
| Prompts ohne Hilfe | Haben Nutzer Unterstützung beim Formulieren? | Beispiele + Templates |
| Über-Anthropomorphisierung | Suggeriert die Sprache falsche Menschenähnlichkeit? | Formulierungen prüfen |
| Hochformatierung statt Genauigkeit | Verhindert Formatierung kritische Prüfung? | Balance prüfen |
| Kein Feedback-Weg | Können Nutzer Fehler melden und korrigieren? | HAX G9/G15 implementieren |
| Proaktiv zum falschen Zeitpunkt | Unterbricht das System laufende Aufgaben? | HAX G3: Timing |

---

## Output — Design-Datei

Schreibe das Ergebnis nach `./design-ux.md`:

```markdown
# UX Design: [Produkt / Feature Name]
Datum: YYYY-MM-DD

## Kontext
[Produkt, Nutzer, Kanal, KI-Beteiligung: ja/nein/wie]

## Entscheidungen
| Dimension | Entscheidung | Begründung | Framework-Referenz |
|-----------|-------------|-----------|-------------------|
| Interaktionsmodell | … | … | NNG / PAIR P… |
| Mental Model Onboarding | … | … | HAX G1/G2, PAIR Ch.2 |
| Vertrauenskalibrierung | … | … | CHI 2024 P3, PAIR P11 |
| Feedback & Kontrolle | … | … | HAX G7-G9, G15-G17 |
| Fehlerbehandlung | … | … | HAX G9-G11, CHI 2024 P6 |
| Langzeit-Design | … | … | HAX G12-G18 |

## Anti-Pattern Check
| Anti-Pattern | Status | Maßnahme |
|-------------|--------|----------|
| … | ✅ Ausgeschlossen / ⚠️ Risiko / ❌ Vorhanden | … |

## Annahmen & offene Punkte
- [Annahme]: …
- [zu verifizieren]: …

---
## ✅ UX Setup-Todos
- [ ] Onboarding-Flow skizzieren (Phase 2)
- [ ] Konfidenz-Anzeige nutzertesten (PAIR P11)
- [ ] Feedback-Mechanismus implementieren (HAX G15)
- [ ] Anti-Pattern Review mit Team (Phase 7)

## 📋 Nächste Schritte (priorisiert)
1. …
```

---

## Interaction Patterns

### Wenn der Nutzer sagt "mach es einfach schön"

Konkret nachfragen: Schön für wen? In welchem Kontext? Mit welchem Ziel?
"Schön" ohne Nutzerziel ist dekorativ, nicht UX. Umlenken auf Aufgabe und Nutzer.

### Wenn der Nutzer fragt "soll ich Chat oder GUI nehmen?"

NNG-Entscheidungsbaum anwenden: Aufgabe präzise + strukturiert → GUI.
Aufgabe explorativ + sprachlich + variabel → Chat oder Hybrid.
Nie Chat per Default ohne Validierung.

### Wenn KI-Features neu hinzukommen

Phase 2 (Mentale Modelle) besonders sorgfältig: Nutzer haben ein bestehendes Modell
des Produkts. Die KI-Erweiterung muss in dieses Modell integriert werden, nicht
daruntergeworfen. HAX G18 (notify about changes) ist Pflicht.

### Wenn das Produkt generative KI verwendet (LLM, Bildgenerierung, Code)

CHI 2024 P4–P6 vollständig durchgehen: Variabilität kommunizieren, Co-Creation
designen, Imperfection handling planen. Diese drei Prinzipien sind GenAI-spezifisch
und in klassischen UX-Frameworks nicht abgedeckt.

### Wenn Accessibility relevant ist

EU Accessibility Act / BFSG ist gesetzlich verpflichtend. Semantisches HTML,
Heading-Hierarchie, alt-Texte, Fokus-Styles. KI-generierte Inhalte brauchen
zugängliche Ausgabeformate. axe-core + Lighthouse für automatisierte Prüfung.

---

## Framework-Referenz Mapping

| Design-Entscheidung | Primäre Referenz | Sekundär |
|--------------------|-----------------|---------|
| Was das System kann kommunizieren | HAX G1–G2 | PAIR P2/P3 |
| Timing von KI-Interventionen | HAX G3 | — |
| Kontextrelevante Info zeigen | HAX G4 | PAIR P4 |
| Soziale Normen & Bias | HAX G5–G6 | CHI 2024 P1 S3/S4 |
| Aktivierung / Ablehnung | HAX G7–G8 | PAIR P15–P16 |
| Fehlerkorrektur | HAX G9 | PAIR P18 |
| Einschränken bei Unsicherheit | HAX G10 | — |
| Erklärungen | HAX G11 | PAIR P12–P13, CHI 2024 P3 S2 |
| Session-Kontext beibehalten | HAX G12 | — |
| Personalisierung / Lernen | HAX G13–G14 | PAIR P15, P20 |
| Granulares Feedback | HAX G15–G16 | PAIR P15 |
| Globale Kontrollen | HAX G17 | — |
| Change-Kommunikation | HAX G18 | — |
| KI-Mehrwert evaluieren | PAIR P1 | NNG: Lead with value |
| Mentale Modelle | PAIR Ch.2 | CHI 2024 P2, NNG ELIZA |
| Vertrauen & Reliance | PAIR Ch.3 | CHI 2024 P3 |
| Datenverantwortung | PAIR P5–P8 | CHI 2024 P1 |
| Feedback-Loops | PAIR P15, P20–P21 | CHI 2024 P6 S4 |
| Graduelle Automatisierung | PAIR P14, P17 | — |
| Graceful Failure | PAIR Ch.6 | HAX G9–G11 |
| Verantwortungsvolles Design | CHI 2024 P1 | — |
| Generative Variabilität | CHI 2024 P4 | — |
| Co-Creation | CHI 2024 P5 | — |
| Imperfection Handling | CHI 2024 P6 | HAX G9–G11 |
| Interaktionsmodell-Wahl | NNG | PAIR P1 |
| Anti-Patterns | NNG | — |

### Akademische Vertiefung

| Thema | Kurs / Quelle |
|-------|--------------|
| KI als Designmaterial | CMU 05-617, Stanford CS 247A |
| Human-AI Interaction Theorie | CMU 05-618, TU Graz 706.008/012 |
| Konversationsdesign | CMU 05-897, TU Graz 706.328 |
| Persuasion & Verhalten | CMU 05-615 |
| Mental Models + LLM-UX | ETH/UZH 22MI0038 (Dan Russell) |
| Interactive ML / XAI | ETH 263-5052-00L (El-Assady) |
| Human-Centered AI | TU Wien 193.162, TU Graz 706.034 |
| GenAI UX | MIT 6.S061 (gesamter Kurs), CHI 2024 |
| Cognitive Modeling | CMU 05-811 |
