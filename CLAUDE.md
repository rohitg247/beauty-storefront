# Beauty Storefront — Claude Code working rules

Shopify Online Store 2.0 theme, derived from **Sense** (Dawn family). Branch `shopify-theme`.

## When I paste an error, read the files it names

If I paste an error, a stack trace, a CLI failure or an upload log that names a file path,
**read that file immediately.** Do not ask permission, do not ask me to confirm, do not ask me
to paste the contents. The path in the error is the permission. This overrides the global
"only read files I explicitly name" rule — an error naming a file *is* me naming it.

Follow the trail one hop: if the named file's problem clearly lives in a file it references
(a schema for a settings value, a snippet for a section), read that too. Beyond one hop, ask.

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

## Preflight — run before every push (mandatory)

`shopify theme check` must be run locally and pass before **any** `shopify theme push`,
`git push`, or "this is ready" claim. No exceptions, no "it's only a small change".
If it reports offenses, fix them or say explicitly which ones are being left and why.

`shopify theme check` is a local linter. It does **not** catch Shopify's server-side upload
validation, which has burned this theme before. Check these by hand in the same preflight:

- **Rich-text settings** (`"type": "richtext"` defaults in `templates/*.json`, `sections/*.liquid`
  schemas, `config/settings_schema.json`): every top-level node must be `<p>`, `<ul>`, `<ol>` or
  `<h1>`–`<h6>`. Bare text, `<div>`, `<span>` or a leading `<br>` is rejected on upload.
- **Font handles**: any `"type": "font_picker"` default must be a real Shopify font handle
  (e.g. `assistant_n4`). Google-only families such as `cormorant_garamond_n6` do not exist in
  Shopify's font library and fail upload. If the design needs one, load it as a webfont in
  `assets/brand.css` and leave the picker on a valid Shopify handle.
- **Range settings**: any value in `config/settings_data.json` must sit inside the `min`/`max`
  of its `config/settings_schema.json` range, and `max` itself must respect Shopify's own cap
  (e.g. `spacing_grid_vertical` cannot exceed 40). Changing a schema `max` downward invalidates
  saved values already stored in `settings_data.json` — update both together.

`shopify theme dev` proxies the store's live settings and will happily render a theme that
cannot be uploaded. A clean local preview is **not** evidence the push will succeed.
