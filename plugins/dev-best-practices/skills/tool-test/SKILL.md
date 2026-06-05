---
name: tool-test
description: Stack-aware Test-Assistent. Erkennt automatisch Sprache, Framework und vorhandenes Test-Setup, dann entwirft oder generiert passende Tests (Unit, Integration, E2E) gemäß der Testpyramide. Use this skill whenever the user wants to write, improve, or review tests; triggert bei "schreib Tests", "Test-Strategie", "Coverage erhöhen", "wie teste ich X", "fehlende Tests", "flaky Tests".
---

# Test (stack-aware)

Analysiert zuerst was vorhanden ist (Stack, Test-Framework, Coverage), dann entscheidet
er was fehlt und warum — keine generischen Templates, sondern Tests die in dieses Projekt passen.

## Schritt 0 — Stack & Test-Setup erkennen

Scanne automatisch:

**Test-Framework erkennen:**
- `package.json` → `jest`, `vitest`, `playwright`, `cypress`, `testing-library`
- `pyproject.toml` / `pytest.ini` → `pytest`, `unittest`, `hypothesis`
- `*.test.ts` / `*.spec.ts` / `test_*.py` → vorhandene Test-Konventionen

**Vorhandenes Setup bewerten:**
- Wie viel Coverage gibt es schon? (`coverage/`, `.coverage`, `jest.config`)
- Welche Test-Typen existieren? (Unit / Integration / E2E / Snapshot)
- Gibt es Fixtures, Mocks, Test-Utils?
- Läuft die Test-Suite in CI? (`.github/workflows/`)

**Projekt-Kontext:**
- Was ist das Kernstück der App? (Auth, Payment, API, Datenverarbeitung …)
- Welche Pfade sind kritisch und noch ungetestet?
- `CLAUDE.md` des Projekts auf bekannte Test-Ausnahmen prüfen

Falls unklar was getestet werden soll: einmal konkret nachfragen.

## Schritt 1 — Test-Strategie ableiten (Pyramide)

Bewerte den aktuellen Stand gegen die Testpyramide und identifiziere die größten Lücken:

```
        [E2E]          wenige, langsam, hoher Wert für kritische Flows
       [Integr.]       Service-Grenzen, DB, externe APIs
      [Unit Tests]     Funktionen, Klassen, pure Logic — schnell, viele
```

**Kritische Pfade die IMMER Tests brauchen:**
- Authentifizierung & Autorisierung (Login, Token-Validierung, Permission-Checks)
- Datenmutationen (Create/Update/Delete mit Validierung)
- Externe Integrationen (API-Calls, Webhooks, Payment)
- Fehlerbehandlung (was passiert wenn X fehlschlägt?)

**Stack-spezifische Test-Empfehlungen:**

*Next.js / React:*
- Vitest + React Testing Library für Komponenten (kein Enzyme)
- Server Actions: Integration-Test mit echtem DB-Zugriff, nicht mocken
- `playwright` für kritische User-Flows (Login, Checkout)
- Snapshot-Tests sparsam — nur für stabile UI-Komponenten

*FastAPI / Python:*
- `pytest` + `httpx.AsyncClient` für API-Endpoints
- `pytest-asyncio` für async-Tests
- Echte DB für Integration-Tests (`pytest-postgresql` / SQLite in-memory)
- `factory_boy` für Test-Fixtures statt manuelle Fixtures

*Express / Node.js:*
- Vitest oder Jest + Supertest für HTTP-Tests
- Test-DB via Docker oder in-memory (bessere Isolation als Mocking)

*Generell:*
- Keine Mock-Kaskaden für eigene Infrastruktur — echte DB im Test ist zuverlässiger
- External APIs (Stripe, SendGrid …) mocken — aber mit realistischen Payloads

## Schritt 2 — Tests schreiben oder verbessern

Je nach Anfrage des Nutzers:

**Neue Tests generieren:**
1. Identifiziere die zu testende Unit (Funktion / Endpoint / Komponente)
2. Bestimme sinnvolle Testfälle: Happy Path, Edge Cases, Fehler-Szenarien
3. Schreibe Tests im vorhandenen Format (Dateinamen-Konvention, Import-Stil, Fixture-Pattern)
4. Keine Duplikation von vorhandenen Tests

**Test-Strategie entwerfen:**
1. Lücken-Analyse: Was ist kritisch und ungetestet?
2. Priorisierung: Auth > Datenmutationen > Business Logic > UI
3. Aufwandsschätzung pro Bereich (S/M/L)
4. Roadmap: Was zuerst, was kann warten?

**Vorhandene Tests verbessern:**
1. Flaky Tests: Timing-Abhängigkeiten, externe State-Abhängigkeiten identifizieren
2. Zu breite Mocks: Was wird gemockt das nicht gemockt werden sollte?
3. Test-Dopplung: Gleiche Logik in Unit + Integration + E2E → nur auf einer Ebene
4. Fehlende Assertions: Tests die nur "kein Fehler" prüfen statt Verhalten

## Schritt 3 — Ausgabe

```
## Test-Analyse: [Kontext]

**Stack:** [erkannter Stack + Test-Framework]
**Aktueller Stand:** [kurze Bewertung der vorhandenen Tests]

### Kritische Lücken (priorisiert)
1. [Pfad/Funktion] — [warum kritisch] — Aufwand: S/M/L
2. …

### Generierte Tests
[direkt verwendbare Test-Datei(en) im richtigen Format]

### Nicht abgedeckt (bewusst)
[Was aus Scope-Gründen weggelassen wurde und warum]
```

## Regeln
- Tests schreiben die Verhalten prüfen, nicht Implementierungsdetails.
- Kein Test-Code der komplexer ist als der Code den er testet.
- `// TODO: add more tests` niemals stehen lassen — entweder schreiben oder als Lücke dokumentieren.
- Automatisch in Dateien schreiben nur wenn der Nutzer es explizit verlangt.
- Coverage als Metrik nennen aber nicht als Ziel — schlecht geschriebene Tests die Coverage erhöhen sind wertlos.
