# Beauty Storefront — Claude Code working rules

Shopify Online Store 2.0 theme, derived from **Sense** (Dawn family). Branch `shopify-theme`.

## Read before you change anything

At the start of **every** session, read all four files in `docs/` before making any edit:

1. `docs/plan.md` — the approved scope for this rebuild. Do not drift from it without saying so.
2. `docs/changes.md` — what has already been changed, and when.
3. `docs/session-handoff.md` — where the last session stopped and what to pick up.
4. `docs/admin-tasks.md` — work that can only be done from the Shopify Admin, not in code.

`docs/` is gitignored on purpose. It is local-only and must never be committed or pushed.

## Write before you finish

At the **end of every session**, append a new timestamped entry to both:

- `docs/changes.md` — every file created or modified, and why.
- `docs/session-handoff.md` — what this session covered, current state, next steps.

**Append. Never overwrite.** Both files are running logs. New entries go at the bottom.
Keep `docs/admin-tasks.md` current whenever new admin-only work is discovered.

## Theme rules

- **Colours and fonts live in `config/settings_data.json`**, driven by the colour-scheme pickers
  defined in `config/settings_schema.json`. Never hardcode a hex value in Liquid or CSS.
  There are five schemes; see `docs/plan.md` for what each one is for.
- **Layout belongs in JSON templates and section blocks**, not hardcoded Liquid. If a merchant
  should be able to move, remove or retitle it, it is a block.
- **Do not rewrite Dawn/Sense commerce code.** The cart drawer, facets, variant picker, predictive
  search, media gallery and product card all work. Restyle them; do not reimplement them.
- **Do not edit vendored files**: `assets/three.module.js`, `assets/motion.min.js`. They are
  upstream builds pinned at a version. Replace wholesale or leave alone.

## The safety contract (custom layer)

`assets/brand.css`, `assets/brand.js`, `assets/hero-scene.js` and `assets/sticky-atc.js` are an
additive layer on top of the theme. Any change to them must preserve all of the following:

- The store renders and sells correctly with the entire custom layer removed, failed, or with
  JS disabled.
- Nothing is hidden by default. Animated elements are visible and laid out in CSS; JS only
  transitions them *in*. Never ship an `opacity: 0` that JS is responsible for clearing.
- Every entry point is wrapped so a thrown error cannot reach Dawn's scripts.
- `Shopify.designMode` disables scroll-scrub and the WebGL canvas, so the theme editor stays
  predictable.
- `prefers-reduced-motion: reduce` disables all transform/opacity animation and the canvas.
- `three.module.js` is dynamically imported only on desktop, pointer-fine, non-reduced-motion,
  WebGL2-capable browsers, and only when the hero is in view. Mobile must never download it.

## Before saying it works

Run `shopify theme check`. Then check in the browser: homepage, product, collection, cart —
console clean, no horizontal scroll at 360px, keyboard focus visible throughout.
