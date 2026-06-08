# Visual Patterns & Quality Checks

Loading states and anti-slop checklist for frontend components.

---

## Loading States & Perceived Performance

Principle: Perceived wait time is more important than actual wait time.

| Pattern | When | Why |
|---------|------|-------|
| **Skeleton Screen** | Content-heavy UIs (lists, cards, feeds) | Shows structure instead of empty space — reduces perceived wait time |
| **Optimistic UI** | Mutations with high success probability (like, toggle) | Immediate feedback, roll back on error |
| **Progressive Loading** | Images, long lists | Above-the-fold first, rest loaded lazily |
| **Spinner** | Short unknown wait time, content shape not known | Only when skeleton is not sensible |

Skeleton implementation: `animate-pulse` (Tailwind) or `@keyframes pulse` on placeholder divs
that mirror the later content structure.

---

## Anti-Slop Checklist

Before a component is considered finished:

- [ ] No framework-default blue as the only brand color
- [ ] Typography hierarchy present (not everything the same size/weight)
- [ ] Spacing consistent (no mix of 10px/15px/22px)
- [ ] Contrast WCAG AA checked (4.5:1 for text)
- [ ] Dark mode: own color values, not inverted light theme
- [ ] Loading states: skeleton or optimistic UI instead of spinner where sensible
- [ ] Icons: consistent library, not mixed
