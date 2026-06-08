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

### Color System

Drei Token-Ebenen — alle drei definieren:

- **Primitive**: rohe Werte, kebab-case, Skala 50–950 (`color-blue-500: #3B82F6`)
- **Semantic**: Intention statt Wert (`color-brand-primary`, `color-text-secondary`)
- **Component**: komponentenspezifisch (`button-bg-hover`)

Regel: Im Code immer Semantic Tokens verwenden, nie Primitive direkt.

**WCAG Kontrast (Pflicht — #1 Accessibility-Fehler im Web):**

- Normaler Text: min. 4.5:1
- Große Schrift (≥18px / ≥14px bold): min. 3:1
- Prüfen: webaim.org/resources/contrastchecker

**Dark Mode:** CSS Custom Properties (`--color-surface`, `--color-text-primary`).
Werte per `@media (prefers-color-scheme: dark)` oder `.dark`-Klasse überschreiben.
Nie hardcodierte Hex-Werte im Dark-Mode-Pfad.

### Typografie-Skala

- Body: min. 16px
- Heading-Skala: Faktor 1.25–1.5x (z.B. 16 → 20 → 25 → 31px)
- Line-height: 1.5x für Fließtext, 1.2x für Headings
- Max. 2 Schriftfamilien

### Spacing-System (8px-Grid)

`space-1=4px, space-2=8px, space-3=12px, space-4=16px, space-6=24px, space-8=32px`

Keine Einzelwerte außerhalb des Grids (kein `margin: 11px`).

### Platform Design System wählen

| Kontext | System | Referenz |
|---------|--------|---------|
| Android / Web (Google-Stil) | Material Design 3 | m3.material.io |
| iOS / macOS | Apple HIG | developer.apple.com/design/human-interface-guidelines |
| Enterprise / B2B | IBM Carbon | carbondesignsystem.com |
| Agnostisch / eigenes | Design Tokens + obige Grundlagen | — |

**Material Design 3 Kernprinzipien:** Color Roles (Primary, Secondary, Surface, Outline) statt Hex-Werte; Elevation via Tonal Color, kein Box-Shadow-Spam; Shape-System für konsistente Eckenradien.

**Apple HIG Kernprinzipien:** Clarity (Text lesbar, Icons präzise, kein Dekor-Spam); Deference (Inhalt im Fokus, UI tritt zurück); Depth (Layering kommuniziert Hierarchie).

### Loading States & Perceived Performance

Prinzip: Wahrgenommene Wartezeit ist wichtiger als tatsächliche Wartezeit.

| Pattern | Wann | Warum |
|---------|------|-------|
| **Skeleton Screen** | Content-heavy UIs (Listen, Cards, Feeds) | Zeigt Struktur statt leerer Fläche — reduziert gefühlte Wartezeit |
| **Optimistic UI** | Mutations mit hoher Erfolgswahrscheinlichkeit (Like, Toggle) | Sofortiges Feedback, bei Fehler zurückrollen |
| **Progressive Loading** | Bilder, lange Listen | Above-the-fold zuerst, Rest nachladen |
| **Spinner** | Kurze unbekannte Wartezeit, kein Content-Shape bekannt | Nur wenn Skeleton nicht sinnvoll |

Skeleton-Implementierung: `animate-pulse` (Tailwind) oder `@keyframes pulse` auf Placeholder-Divs die die spätere Content-Struktur spiegeln.

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

Bevor eine Komponente als fertig gilt:

- [ ] Kein Framework-Default-Blau als einzige Markenfarbe
- [ ] Typografie-Hierarchie vorhanden (nicht alles gleiche Größe/Gewicht)
- [ ] Spacing konsistent (kein Mix aus 10px/15px/22px)
- [ ] Kontrast WCAG AA geprüft (4.5:1 für Text)
- [ ] Dark Mode: eigene Farbwerte, kein invertiertes Light-Theme
- [ ] Loading States: Skeleton oder Optimistic UI statt nur Spinner wo sinnvoll
- [ ] Icons: konsistente Library, nicht gemischt

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
