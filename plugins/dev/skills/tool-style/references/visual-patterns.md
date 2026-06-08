# Visual Patterns & Quality Checks

Loading States und Anti-Slop-Checkliste für Frontend-Komponenten.

---

## Loading States & Perceived Performance

Prinzip: Wahrgenommene Wartezeit ist wichtiger als tatsächliche Wartezeit.

| Pattern | Wann | Warum |
|---------|------|-------|
| **Skeleton Screen** | Content-heavy UIs (Listen, Cards, Feeds) | Zeigt Struktur statt leerer Fläche — reduziert gefühlte Wartezeit |
| **Optimistic UI** | Mutations mit hoher Erfolgswahrscheinlichkeit (Like, Toggle) | Sofortiges Feedback, bei Fehler zurückrollen |
| **Progressive Loading** | Bilder, lange Listen | Above-the-fold zuerst, Rest nachladen |
| **Spinner** | Kurze unbekannte Wartezeit, kein Content-Shape bekannt | Nur wenn Skeleton nicht sinnvoll |

Skeleton-Implementierung: `animate-pulse` (Tailwind) oder `@keyframes pulse` auf Placeholder-Divs
die die spätere Content-Struktur spiegeln.

---

## Anti-Slop Checkliste

Bevor eine Komponente als fertig gilt:

- [ ] Kein Framework-Default-Blau als einzige Markenfarbe
- [ ] Typografie-Hierarchie vorhanden (nicht alles gleiche Größe/Gewicht)
- [ ] Spacing konsistent (kein Mix aus 10px/15px/22px)
- [ ] Kontrast WCAG AA geprüft (4.5:1 für Text)
- [ ] Dark Mode: eigene Farbwerte, kein invertiertes Light-Theme
- [ ] Loading States: Skeleton oder Optimistic UI statt nur Spinner wo sinnvoll
- [ ] Icons: konsistente Library, nicht gemischt
