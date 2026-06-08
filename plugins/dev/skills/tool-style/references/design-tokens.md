# Visual Design Fundamentals

Color system, typography, spacing, and platform design systems for projects
without an external design system (MUI, shadcn, Carbon etc.).

---

## Color System

Three token levels — define all three:

- **Primitive**: raw values, kebab-case, scale 50–950 (`color-blue-500: #3B82F6`)
- **Semantic**: intention over value (`color-brand-primary`, `color-text-secondary`)
- **Component**: component-specific (`button-bg-hover`)

Rule: Always use semantic tokens in code, never primitive tokens directly.

**WCAG Contrast (required — #1 accessibility error on the web):**

- Normal text: min. 4.5:1
- Large text (≥18px / ≥14px bold): min. 3:1
- Check: webaim.org/resources/contrastchecker

**Dark Mode:** CSS Custom Properties (`--color-surface`, `--color-text-primary`).
Override values via `@media (prefers-color-scheme: dark)` or `.dark` class.
Never hardcoded hex values in the dark mode path.

---

## Typography Scale

- Body: min. 16px
- Heading scale: factor 1.25–1.5x (e.g. 16 → 20 → 25 → 31px)
- Line height: 1.5x for body text, 1.2x for headings
- Max. 2 font families

---

## Spacing System (8px grid)

`space-1=4px, space-2=8px, space-3=12px, space-4=16px, space-6=24px, space-8=32px`

No individual values outside the grid (no `margin: 11px`).

---

## Platform Design System

| Context | System | Reference |
|---------|--------|---------|
| Android / Web (Google style) | Material Design 3 | m3.material.io |
| iOS / macOS | Apple HIG | developer.apple.com/design/human-interface-guidelines |
| Enterprise / B2B | IBM Carbon | carbondesignsystem.com |
| Agnostic / custom | Design Tokens + above fundamentals | — |

**Material Design 3 core principles:** Color roles (Primary, Secondary, Surface, Outline) instead of hex values; elevation via tonal color, no box-shadow spam; shape system for consistent corner radii.

**Apple HIG core principles:** Clarity (text readable, icons precise, no decoration spam); Deference (content in focus, UI recedes); Depth (layering communicates hierarchy).
