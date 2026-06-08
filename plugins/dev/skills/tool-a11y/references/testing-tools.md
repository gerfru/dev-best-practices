# Testing Tools — Accessibility

## Tool-Uebersicht

| Tool | Typ | Findet | Findet NICHT |
|---|---|---|---|
| **axe-core** (Browser Extension) | Automatisiert | ~30% aller WCAG-Issues: Kontrast, alt-Text, ARIA, Labels | Keyboard-Traps, Focus-Reihenfolge, Screen Reader Verhalten |
| **Lighthouse** (Chrome DevTools) | Automatisiert | Subset von axe-core + Performance-Metriken | Alles was Interaktion erfordert |
| **NVDA** (Windows, gratis) | Screen Reader | Wie Inhalte vorgelesen werden, ARIA live regions, Navigation | — |
| **JAWS** (Windows, kostenpflichtig) | Screen Reader | Professionelle Nutzer-Erfahrung, Enterprise-Standard | — |
| **VoiceOver** (macOS/iOS, built-in) | Screen Reader | Apple-Oekosystem: Safari + iOS | Chrome/Firefox-Eigenheiten |
| **TalkBack** (Android, built-in) | Screen Reader | Android mobile | — |
| **Colour Contrast Analyser** (gratis) | Manuell | Kontrast-Ratio fuer beliebige Farben (auch screenshots) | — |
| **Text Spacing Bookmarklet** | Manuell | WCAG 1.4.12: Text Spacing Override | — |

---

## Screen Reader Testkombinationen

Empfohlene Kombinationen (nach WebAIM Screen Reader Survey):

| Kombination | Verbreitung | Wann testen |
|---|---|---|
| NVDA + Chrome | Haeufigste Desktop-Kombination (gratis) | Immer |
| NVDA + Firefox | — | Bei Firefox-spezifischen Features |
| JAWS + Chrome | Enterprise-Standard | Bei Enterprise-Zielgruppe |
| VoiceOver + Safari macOS | Mac-User | Bei Mac-Zielgruppe oder iOS-App |
| VoiceOver + Safari iOS | Mobile | Jede mobile Web-App |
| TalkBack + Chrome Android | Android Mobile | Jede mobile Web-App |

Minimum fuer Web: **NVDA + Chrome** + **VoiceOver + Safari iOS**

---

## Screen Reader Keyboard-Shortcuts (NVDA)

| Aktion | Shortcut |
|---|---|
| Headings navigieren | H (vorwaerts) / Shift+H (rueckwaerts) |
| Links navigieren | K / Shift+K |
| Landmarks navigieren | D / Shift+D |
| Formulare | F / Shift+F |
| Tabellen | T / Shift+T |
| Browse Mode / Forms Mode | NVDA+Space |
| Alles vorlesen | NVDA+Down |

---

## Audit-Reihenfolge (Effizienz-optimiert)

```text
1. axe-core Browser Extension (5 min)
   → Alle automatisch pruefbaren Issues sofort sichtbar

2. Lighthouse Accessibility Audit (2 min)
   → Ergaenzende automatische Checks

3. Keyboard-Navigation manuell (15 min)
   → Tab durch alle interaktiven Elemente, Focus-Styles pruefen

4. NVDA + Chrome Screen Reader (30 min)
   → Headings, Landmarks, Formulare, Fehlermeldungen

5. WCAG 2.2 neue SC manuell pruefen (15 min)
   → 2.4.11, 2.5.7, 2.5.8, 3.2.6, 3.3.7, 3.3.8

6. EU Compliance Check (10 min)
   → EN 301 549 / BFSG wenn relevant
```

Gesamt: ~75 min fuer eine Basis-Evaluation (ohne tiefgehenden Screen Reader Test).
