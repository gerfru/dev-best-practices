---
name: dev:tool-style
description: Stack-aware frontend styling assistant. Automatically detects the CSS framework, design system, and component library, then delivers consistent, maintainable styling decisions and fixes. Includes visual design fundamentals (color, typography, spacing, loading states) for developers without a design background. Use this skill whenever the user has a frontend styling question, wants to fix visual inconsistencies, improve CSS architecture, work with a component library, or needs practical design guidance (colors, typography, dark mode, skeleton screens); triggers for "styling", "CSS", "design system", "component looks wrong", "theme", "responsive", "Tailwind", "SCSS", "colors", "color system", "skeleton", "loading state", UI questions.
---

# Styling (stack-aware)

First analyzes which CSS system is in use — then delivers solutions
that fit that system. No generic CSS when Tailwind is used.
No Tailwind suggestion when SCSS Modules are in use.

## Step 0 — Detect Frontend Stack & Design System

Scan automatically:

**Detect CSS approach:**
- `tailwind.config.*` → Tailwind CSS (v3 vs. v4?)
- `*.module.css` / `*.module.scss` → CSS Modules
- `styled-components` / `@emotion/` in package.json → CSS-in-JS
- `*.scss` / `variables.scss` → SCSS/Sass
- `styles/globals.css` + no modules → global CSS

**Component library:**
- `@radix-ui/` → Radix UI (headless)
- `shadcn/ui` / `components/ui/` → shadcn (Radix + Tailwind)
- `@mui/material` → Material UI
- `@nextui-org/` → NextUI
- `antd` → Ant Design
- `@mantine/` → Mantine
- Kendo UI / Telerik → Enterprise Kendo

**Design token system:**
- CSS Custom Properties (`--color-primary`) in `globals.css`?
- `tailwind.config` with `theme.extend`?
- Figma Tokens / Style Dictionary?
- Design tokens in `tokens.json` / `design-tokens/`?

**Framework:**
- Next.js App Router vs. Pages Router (different styling boundaries)
- Vite + React vs. Remix vs. SvelteKit

If no frontend present: report briefly, no styling context available.

## Step 0.5 — Visual Design Fundamentals (when no design system is given)

Apply only when no external system (MUI, shadcn, Carbon etc.) defines the visual framework.

Color system (3-tier), typography scale, spacing grid, platform design systems: `references/design-tokens.md`

Loading states (skeleton, optimistic UI, spinner): `references/visual-patterns.md`

## Step 1 — Classify the Task

**Fix a visual problem:**
Read the affected component, identify the styling conflict.
Common causes by stack:

*Tailwind:*
- Class order conflict (last `cn()` wins)
- Purge/safelist missing for dynamically built classes
- Dark mode classes (`dark:`) without `darkMode: 'class'` in config
- Tailwind v3 vs. v4 API differences (v4: `@import "tailwindcss"`, new utility names)

*CSS Modules:*
- `:global()` vs. local scope unclear
- Compiled class name vs. expected name
- Cascade conflict with global styles

*CSS-in-JS (Emotion/SC):*
- SSR hydration mismatch (class IDs differ)
- Theme context unavailable
- `css` vs. `styled` in Server Components (Next.js App Router → incompatible!)

*Component library override:*
- MUI: `sx` prop vs. `styled()` vs. theme override — which level?
- shadcn: override classes directly in component vs. use `cn()`
- Radix: `asChild` pattern for styling delegation

**Improve CSS architecture:**
Evaluate the existing system for:
- Design token consistency (hardcoded values instead of tokens?)
- Responsive strategy (mobile-first? breakpoints consistent?)
- Dark mode implementation (CSS Custom Properties recommended)
- Bundle size (unused CSS rules, PurgeCSS configuration)

**Restyle a component:**
Write styling in the existing system style:
- Use existing tokens/variables instead of introducing new ones
- Follow existing naming conventions
- Responsive using the existing breakpoint system

## Step 2 — Develop Solution

**Design-token-first principle:**
Before every styling suggestion check: is there an existing token that fits?
→ Use the token, do not introduce a new value.

**Consistency check:**
Look for similar components in the project — use the same patterns, do not invent new ones.

**Responsive strategy:**
- Mobile-first (min-width) unless the project already uses desktop-first (max-width)
- Use existing breakpoints from config/tokens

**Stack-specific best practices:**

*Tailwind + shadcn:*
```tsx
// Good: cn() for conditional classes
className={cn("base-classes", condition && "conditional-class", className)}

// Bad: string interpolation
className={`base-classes ${condition ? 'class-a' : ''}`}
```

*CSS Modules + SCSS:*
```scss
// Good: composition for variants
.button { composes: base from './base.module.scss'; }

// Good: CSS Custom Properties for theming
.card { background: var(--color-surface); }
```

*MUI Theme Override (never inline sx for global patterns):*
```ts
// Good: theme-level override
components: { MuiButton: { styleOverrides: { root: { borderRadius: 8 } } } }
```

### Anti-Slop Check

Before a component is considered finished: `references/visual-patterns.md`

## Step 3 — Output

```text
## Styling Analysis: [Context]

**Stack:** [CSS system] + [component library if present]
**Design Token System:** [present/not present/partial]

### Problem / Task
[What the goal is, what is currently wrong/inconsistent]

### Solution
[Code snippet in the correct system style]

### Why this approach
[Brief rationale — why this approach for this stack]

### Consistency Note
[If similar components in the project already take a different approach]
```

## Rules
- Do not suggest switching stacks (replacing Tailwind with SCSS etc.) unless the user explicitly asks.
- Do not introduce new design tokens when existing ones fit.
- CSS-in-JS (Emotion, Styled Components) in Next.js App Router explicitly mark as problematic — Server Components are incompatible.
- No `!important` solution except as a last resort with explanation why.
- Auto-write to files only when the user explicitly requests it.
