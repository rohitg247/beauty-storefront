# EMBRAE — Claude Code working rules

**EMBRAE is a custom Shopify Online Store 2.0 theme.** It is ours, not a marketplace theme, and
it identifies itself as EMBRAE in `config/settings_schema.json`.

Its **commerce layer is inherited from Shopify Sense 16.0.0** (Dawn family). That lineage is
recorded here on purpose: it is the only way a future session can tell which files are upstream
code that must not be rewritten, and the only way an upstream Dawn security or compatibility
patch can ever be diffed in. Branch `shopify-theme`.

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
- **Do not rewrite the inherited commerce code.** The cart drawer, facets, variant picker,
  predictive search, media gallery and product card come from Sense 16 / Dawn, and they all work.
  Restyle them; do not reimplement them. Renaming the theme to EMBRAE did not make this code ours
  to rewrite — it is still upstream, and it is still the part that takes the money.
- **Do not edit vendored files**: `assets/three.module.js`, `assets/motion.min.js`. They are
  upstream builds pinned at a version. Replace wholesale or leave alone.

## Never point the theme at Admin data that does not exist yet (mandatory)

A `link_list`, `collection`, `blog`, `page` or `metaobject_list` setting that names a handle
with nothing behind it **renders empty, silently.** There is no error anywhere — not in
`shopify theme check`, not in `tools/preflight.py`, not in the upload, not in the browser
console. The store just looks broken and the cause is invisible.

This has already cost a full round trip. On 2026-08-23 the header was pointed at `embrae-nav`
and the footer at five `footer-*` handles, none of which existed yet, which turned a
working-but-sparse navbar and footer into completely empty ones.

So, whenever a change makes the theme depend on Admin data:

- **Create the data first, then point the theme at it.** Not the other way round.
- If the data cannot be created yet, **leave the setting on a handle that already exists**
  (`main-menu`, `footer`) and switch it over as the final step.
- If neither is possible, say so explicitly in the handoff and in the response — "the navbar
  will be empty until X is run" — rather than letting the merchant discover it.

`sunscreen` and `gift-sets` in the SHOP menu are a live example of the softer version of this:
the collections can be created, but no product carries those tags, so they resolve to empty
pages.

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

## Responsive is a requirement, not a polish pass (mandatory)

Beauty traffic is 70–80% mobile, so mobile is the primary surface and desktop is the
secondary one. **Nothing is "done" until it is verified at every width below.** This applies
to every section, snippet and CSS change, with no exception for "it's only a small change".

The inherited Dawn/Sense grid breaks at **750px** and **990px**; `--page-width` caps at 1400px.
Four bands:

| Band | Width | Note |
|---|---|---|
| Small mobile | 320–479 | **Hard floor is 360px.** No horizontal scroll, ever. |
| Mobile | 480–749 | Primary revenue surface. |
| **Tablet** | **750–989** | **The band that rots.** Dawn applies desktop grids here, so `columns_desktop: 4` becomes four ~170px cards. Every grid needs an explicit intermediate count. |
| Desktop | 990+ | |

Check at **360, 390, 414, 768, 820, 1024, 1280, 1440**, and in landscape at 768 and 820 —
landscape tablet is 1024px wide but only 768px tall, which breaks anything sized to viewport
height.

Non-negotiable rules for any new or changed UI:

- **No horizontal overflow at 360px.** Long product titles, ₹ prices with thousands
  separators, and ingredient names are the usual culprits.
- **Tap targets ≥44×44px**, with ≥8px between them.
- **`env(safe-area-inset-bottom)` on anything fixed to the bottom**, or it sits under the iOS
  home indicator.
- **Inputs ≥16px font-size**, or iOS Safari zooms the page on focus.
- **No layout shift as images load** — every image carries width/height or an aspect ratio.
- **Use the existing fluid tokens** (`--space-2xs` … `--space-xl`, all `clamp()`) before
  reaching for a new media query.
- **Mobile gets its own answer where a squeezed desktop layout would be dishonest** — a
  six-item row becomes a snap-scroll, not six stacked rows; large figures stack rather than
  shrink below legibility.

Real devices for anything sticky, fixed or snap-scrolling. Emulators do not reproduce
safe-area insets, momentum scroll, or iOS input-zoom.

## Before saying it works

Run `shopify theme check`. Then check in the browser: homepage, product, collection, cart —
console clean, no horizontal scroll at 360px, keyboard focus visible throughout, and the full
responsive matrix above.

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
