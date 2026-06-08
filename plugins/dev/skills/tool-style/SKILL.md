---
name: tool-style
description: Stack-aware Frontend-Styling-Assistent. Erkennt automatisch das CSS-Framework, Design-System und Komponenten-Library, dann liefert konsistente, wartbare Styling-Entscheidungen und -Korrekturen. Enthält Visual Design Grundlagen (Farbe, Typografie, Spacing, Loading States) für Entwickler ohne Design-Hintergrund. Use this skill whenever the user has a frontend styling question, wants to fix visual inconsistencies, improve CSS architecture, work with a component library, or needs practical design guidance (colors, typography, dark mode, skeleton screens); triggert bei "Styling", "CSS", "Design System", "Komponente sieht falsch aus", "Theme", "responsive", "Tailwind", "SCSS", "Farben", "Color System", "Skeleton", "Loading State", UI-Fragen.
---

# Styling (stack-aware)

Analysiert zuerst welches CSS-System im Einsatz ist — dann liefert er Lösungen
die in dieses System passen. Kein generisches CSS wenn Tailwind benutzt wird.
Kein Tailwind-Vorschlag wenn SCSS-Modules im Einsatz sind.

## Schritt 0 — Frontend-Stack & Design-System erkennen

Scanne automatisch:

**CSS-Ansatz erkennen:**
- `tailwind.config.*` → Tailwind CSS (v3 vs. v4?)
- `*.module.css` / `*.module.scss` → CSS Modules
- `styled-components` / `@emotion/` in package.json → CSS-in-JS
- `*.scss` / `variables.scss` → SCSS/Sass
- `styles/globals.css` + keine Modules → globales CSS

**Komponenten-Library:**
- `@radix-ui/` → Radix UI (headless)
- `shadcn/ui` / `components/ui/` → shadcn (Radix + Tailwind)
- `@mui/material` → Material UI
- `@nextui-org/` → NextUI
- `antd` → Ant Design
- `@mantine/` → Mantine
- Kendo UI / Telerik → Enterprise Kendo

**Design-Token-System:**
- CSS Custom Properties (`--color-primary`) in `globals.css`?
- `tailwind.config` mit `theme.extend`?
- Figma-Tokens / Style-Dictionary?
- Design-Tokens in `tokens.json` / `design-tokens/`?

**Framework:**
- Next.js App Router vs. Pages Router (unterschiedliche Styling-Grenzen)
- Vite + React vs. Remix vs. SvelteKit

Falls kein Frontend vorhanden: kurz melden, kein Styling-Kontext vorhanden.

## Schritt 0.5 — Visual Design Grundlagen (wenn kein Design-System vorgegeben)

Nur anwenden wenn kein externes System (MUI, shadcn, Carbon etc.) den visuellen Rahmen vorgibt.

Color System (3-Tier), Typografie-Skala, Spacing-Grid, Platform Design Systems: `references/design-tokens.md`

Loading States (Skeleton, Optimistic UI, Spinner): `references/visual-patterns.md`

## Schritt 1 — Aufgabe klassifizieren

**Visuelles Problem beheben:**
Lies die betroffene Komponente, identifiziere den Styling-Konflikt.
Häufige Ursachen je nach Stack:

*Tailwind:*
- Class-Reihenfolge Konflikt (letztes `cn()` gewinnt)
- Purge/Safelist fehlt für dynamisch gebaute Klassen
- Dark-Mode-Klassen (`dark:`) ohne `darkMode: 'class'` in Config
- Tailwind v3 vs. v4 API-Unterschiede (v4: `@import "tailwindcss"`, neue Utility-Namen)

*CSS Modules:*
- `:global()` vs. lokaler Scope unklar
- Kompilierter Klassenname vs. erwarteter Name
- Cascade-Konflikt mit globalen Styles

*CSS-in-JS (Emotion/SC):*
- SSR-Hydration-Mismatch (Klassen-IDs unterschiedlich)
- Theme-Context nicht verfügbar
- `css` vs. `styled` in Server Components (Next.js App Router → inkompatibel!)

*Komponenten-Library-Override:*
- MUI: `sx` prop vs. `styled()` vs. theme override — welche Ebene?
- shadcn: Klassen direkt in der Komponente überschreiben vs. `cn()` verwenden
- Radix: `asChild` Pattern für Styling-Delegation

**CSS-Architektur verbessern:**
Bewertet das vorhandene System auf:
- Design-Token-Konsistenz (hardcodierte Werte statt Tokens?)
- Responsive-Strategie (mobile-first? Breakpoints konsistent?)
- Dark-Mode-Implementierung (CSS Custom Properties empfohlen)
- Bundle-Size (ungenutzte CSS-Regeln, PurgeCSS-Konfiguration)

**Komponente neu stylen:**
Schreibt Styling im vorhandenen System-Stil:
- Nutzt vorhandene Tokens/Variablen statt neue einzuführen
- Folgt vorhandenen Naming-Konventionen
- Responsive nach vorhandenem Breakpoint-System

## Schritt 2 — Lösung erarbeiten

**Design-Token-First-Prinzip:**
Vor jedem Styling-Vorschlag prüfen: Gibt es einen vorhandenen Token der passt?
→ Token verwenden, keinen neuen Wert einführen.

**Konsistenz-Check:**
Ähnliche Komponenten im Projekt suchen — gleiche Muster verwenden, keine neuen erfinden.

**Responsive-Strategie:**
- Mobile-First (min-width) außer das Projekt nutzt bereits Desktop-First (max-width)
- Vorhandene Breakpoints aus Config/Tokens verwenden

**Stack-spezifische Best Practices:**

*Tailwind + shadcn:*
```tsx
// Gut: cn() für konditionelle Klassen
className={cn("base-classes", condition && "conditional-class", className)}

// Schlecht: String-Interpolation
className={`base-classes ${condition ? 'class-a' : ''}`}
```

*CSS Modules + SCSS:*
```scss
// Gut: Composition für Varianten
.button { composes: base from './base.module.scss'; }

// Gut: CSS Custom Properties für Theming
.card { background: var(--color-surface); }
```

*MUI Theme Override (nie inline sx für globale Muster):*
```ts
// Gut: Theme-Level Override
components: { MuiButton: { styleOverrides: { root: { borderRadius: 8 } } } }
```

### Anti-Slop Check

Bevor eine Komponente als fertig gilt: `references/visual-patterns.md`

## Schritt 3 — Ausgabe

```text
## Styling-Analyse: [Kontext]

**Stack:** [CSS-System] + [Komponenten-Library falls vorhanden]
**Design-Token-System:** [vorhanden/nicht vorhanden/teilweise]

### Problem / Aufgabe
[Was das Ziel ist, was aktuell falsch/inkonsistent ist]

### Lösung
[Code-Snippet im richtigen System-Stil]

### Warum so
[Kurze Begründung — warum dieser Ansatz für diesen Stack]

### Konsistenz-Hinweis
[Falls ähnliche Komponenten im Projekt bereits einen anderen Weg gehen]
```

## Regeln
- Kein Stack-Wechsel vorschlagen (Tailwind durch SCSS ersetzen etc.) außer der Nutzer fragt explizit.
- Keine neuen Design-Tokens einführen wenn vorhandene passen.
- CSS-in-JS (Emotion, Styled Components) in Next.js App Router explizit als problematisch markieren — Server Components sind inkompatibel.
- Keine `!important` Lösung außer als letzter Ausweg mit Erklärung warum.
- Automatisch in Dateien schreiben nur wenn der Nutzer es explizit verlangt.
