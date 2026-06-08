# Visual Design Grundlagen

Color System, Typografie, Spacing und Platform Design Systems für Projekte
ohne externes Design-System (MUI, shadcn, Carbon etc.).

---

## Color System

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

---

## Typografie-Skala

- Body: min. 16px
- Heading-Skala: Faktor 1.25–1.5x (z.B. 16 → 20 → 25 → 31px)
- Line-height: 1.5x für Fließtext, 1.2x für Headings
- Max. 2 Schriftfamilien

---

## Spacing-System (8px-Grid)

`space-1=4px, space-2=8px, space-3=12px, space-4=16px, space-6=24px, space-8=32px`

Keine Einzelwerte außerhalb des Grids (kein `margin: 11px`).

---

## Platform Design System

| Kontext | System | Referenz |
|---------|--------|---------|
| Android / Web (Google-Stil) | Material Design 3 | m3.material.io |
| iOS / macOS | Apple HIG | developer.apple.com/design/human-interface-guidelines |
| Enterprise / B2B | IBM Carbon | carbondesignsystem.com |
| Agnostisch / eigenes | Design Tokens + obige Grundlagen | — |

**Material Design 3 Kernprinzipien:** Color Roles (Primary, Secondary, Surface, Outline) statt Hex-Werte; Elevation via Tonal Color, kein Box-Shadow-Spam; Shape-System für konsistente Eckenradien.

**Apple HIG Kernprinzipien:** Clarity (Text lesbar, Icons präzise, kein Dekor-Spam); Deference (Inhalt im Fokus, UI tritt zurück); Depth (Layering kommuniziert Hierarchie).
