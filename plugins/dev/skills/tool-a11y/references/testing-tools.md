# Testing Tools — Accessibility

## Tool Overview

| Tool | Type | Finds | Does NOT find |
|---|---|---|---|
| **axe-core** (Browser Extension) | Automated | ~30% of all WCAG issues: contrast, alt text, ARIA, labels | Keyboard traps, focus order, screen reader behavior |
| **Lighthouse** (Chrome DevTools) | Automated | Subset of axe-core + performance metrics | Anything requiring interaction |
| **NVDA** (Windows, free) | Screen Reader | How content is announced, ARIA live regions, navigation | — |
| **JAWS** (Windows, paid) | Screen Reader | Professional user experience, enterprise standard | — |
| **VoiceOver** (macOS/iOS, built-in) | Screen Reader | Apple ecosystem: Safari + iOS | Chrome/Firefox quirks |
| **TalkBack** (Android, built-in) | Screen Reader | Android mobile | — |
| **Colour Contrast Analyser** (free) | Manual | Contrast ratio for any colors (including screenshots) | — |
| **Text Spacing Bookmarklet** | Manual | WCAG 1.4.12: Text Spacing Override | — |

---

## Screen Reader Test Combinations

Recommended combinations (from WebAIM Screen Reader Survey):

| Combination | Usage | When to test |
|---|---|---|
| NVDA + Chrome | Most common desktop combination (free) | Always |
| NVDA + Firefox | — | For Firefox-specific features |
| JAWS + Chrome | Enterprise standard | For enterprise target audience |
| VoiceOver + Safari macOS | Mac users | For Mac audience or iOS app |
| VoiceOver + Safari iOS | Mobile | Every mobile web app |
| TalkBack + Chrome Android | Android Mobile | Every mobile web app |

Minimum for web: **NVDA + Chrome** + **VoiceOver + Safari iOS**

---

## Screen Reader Keyboard Shortcuts (NVDA)

| Action | Shortcut |
|---|---|
| Navigate headings | H (forward) / Shift+H (backward) |
| Navigate links | K / Shift+K |
| Navigate landmarks | D / Shift+D |
| Forms | F / Shift+F |
| Tables | T / Shift+T |
| Browse Mode / Forms Mode | NVDA+Space |
| Read all | NVDA+Down |

---

## Audit Sequence (efficiency-optimized)

```text
1. axe-core Browser Extension (5 min)
   → All automatically checkable issues immediately visible

2. Lighthouse Accessibility Audit (2 min)
   → Supplementary automatic checks

3. Keyboard navigation manually (15 min)
   → Tab through all interactive elements, check focus styles

4. NVDA + Chrome Screen Reader (30 min)
   → Headings, landmarks, forms, error messages

5. Manually check WCAG 2.2 new SC (15 min)
   → 2.4.11, 2.5.7, 2.5.8, 3.2.6, 3.3.7, 3.3.8

6. EU Compliance Check (10 min)
   → EN 301 549 / BFSG when relevant
```

Total: ~75 min for a baseline evaluation (without in-depth screen reader testing).
