# ADMIN CHANGES REQUIRED — read before deploying this branch

**This branch's theme code will not work correctly on its own.**

`backup-dev` holds the session-14 work that aligned the storefront to the *EMBRAE Website
Developer + Claude Master Brief*. Part of that work lives in **Shopify Admin, not in git** —
collections, metafield definitions, navigation menus and product metafield values. All of it was
**reverted** when the store was rolled back on 2026-08-31, so none of it exists on the store today.

Deploy this branch without re-applying the items below and the homepage will render an empty
product row, the navigation will not match the templates, and one PDP section will silently render
nothing.

Everything here is reproducible from scripts in `tools/`. Nothing needs to be retyped by hand.

---

## 1. `essentials` collection — REQUIRED, or the homepage breaks

The homepage **"Start with your skin."** row (`templates/index.json` → `start-with-your-skin`,
a `featured-collection` section) points at `collection: "essentials"`. That collection was deleted
during the rollback, so the row currently resolves to nothing.

Run:

```powershell
pwsh -File .\tools\seed-essentials-collection.ps1 -WhatIf   # dry run first
pwsh -File .\tools\seed-essentials-collection.ps1
```

It creates a **manual** collection holding exactly the four core singles, in routine order, and
publishes it to the Online Store channel.

**Why manual and not an automated ruleset.** An automated collection can *select* the right four
(`tag=skincare` AND `type!=Bundle` AND `type!=Gift`) but it cannot *order* them — automated
collections reject `MANUAL` sort, and every other sort order breaks the routine sequence
(`ALPHA_ASC` gives RESET, ADAPT, PROTECT, DEFEND). The order is the point of the section.

**Why not `bestsellers`.** That collection holds six products — the four singles plus AM Defense
Routine and Daily Urban Defense Routine — so `products_to_show: 4` returns a non-deterministic
four.

The script publishes to the Online Store channel explicitly. Skipping that step leaves the
collection 404ing on the storefront while looking perfectly correct in Admin.

---

## 2. `embrae.texture` product metafield — REQUIRED for the PDP Texture section

`templates/product.json` gained a `texture` section (Master Brief §8.07) driven by
`sections/product-story.liquid` with `field: "texture"`, which reads
`product.metafields.embrae.texture`.

Create the definition:

| Field | Value |
|---|---|
| Namespace / key | `embrae.texture` |
| Name | Texture and sensory |
| Type | `rich_text_field` |
| Owner | Product |

**No values were ever written, deliberately.** Describing how a formula feels — texture, finish,
absorbency, scent — is a product fact, and Master Brief §0 and §19 forbid inventing those. The
copy must come from the brand or the manufacturer.

`product-story.liquid` is empty-safe, so until values exist the section renders **nothing at all** —
no heading, no broken layout, no placeholder text visible to a customer. Creating the definition
without content is therefore safe; it just means the section stays invisible.

---

## 3. `embrae-primary` navigation — REQUIRED, or the nav contradicts the templates

Run:

```powershell
pwsh -File .\tools\seed-navigation-v2.ps1
```

The version of that script **on this branch** produces the Master Brief §4 structure. Four changes
against the pre-session menu:

| Menu | Change |
|---|---|
| SHOP | **+ Shop the EMBRAE Routine** → `/products/daily-urban-defense-routine` |
| WHY EMBRAE | **+ Meet the Team** → `/pages/about#our-team` |
| SKIN SCIENCE | **+ Routine Guide** → `/pages/education#routine-builder` |
| SKIN QUIZ | **children removed** — becomes a direct link |

SKIN QUIZ loses its children because Master Brief §4 types it **"Direct CTA"** while the other four
rows are **"Mega menu"**. The two phrases in that row are CTA copy, not menu items. All three former
children also pointed at the same page.

Note the anchor is `#routine-builder`, **not** `#routines` — that is the `anchor` value actually set
on `templates/page.education.json`.

The same script also rewrites `embrae-secondary` and `footer-results`. That is expected; it owns
all three menus.

---

## 4. Bundle benefit lines — cosmetic, one line on four PDPs

Run:

```powershell
pwsh -File .\tools\seed-bundle-benefit-lines.ps1
```

Writes the Master Brief §9 "customer-facing purpose" wording to `embrae.benefit_line` on the four
bundles:

| Product | Line |
|---|---|
| `barrier-support-duo` | A simple foundation for daily cleansing and barrier-supportive hydration. |
| `am-defense-routine` | Your morning routine for cleansing, daily defense and UV protection. |
| `pm-recovery-routine` | Your evening routine to cleanse, support and replenish. |
| `daily-urban-defense-routine` | The complete EMBRAE routine. |

**Careful:** `tools/seed-pdp-attributes.ps1` also writes `benefit_line`, with the *older* wording.
Running that script after this one silently reverts all four. Run this one last.

---

## 5. Hero imagery — still placeholder

The hero (`hero-editorial`, an `image-with-text` section) points at
`embrae-hero-climate-skin.jpg` and `embrae-hero-routine.jpg`. **Neither is the specified subject.**

Master Brief §6.2/§17 asks for one contemporary Indian woman, authentic Indian appearance, natural
realistic skin texture, minimal or no visible makeup, calm and confident, modern urban context.
Explicitly not: flowers, leaves, Ayurveda imagery, heavy makeup, over-retouching, spa or lab
imagery, stock-photo look, generic AI skincare advertising.

Two separate files are required — the section has two image slots and will not CSS-crop one:

| Slot | Size | Composition |
|---|---|---|
| Desktop | 2560 × 1440 | **Left 45% held quiet.** Headline, subcopy and both buttons are live HTML sitting there. Anything painted into that zone renders twice. |
| Mobile | 1200 × 1200 | Subject centred, filling the frame. Cover-cropped into a full-width band ~435px tall, so ~28% is lost off each side. |

**No baked-in text of any kind.** `IMAGE-REQUIREMENTS.md` group 1 is the full spec.

---

## Order to run

```
1. seed-essentials-collection.ps1     <- blocks the homepage
2. create embrae.texture definition   <- Admin, or a metafieldDefinitionCreate call
3. seed-navigation-v2.ps1
4. seed-bundle-benefit-lines.ps1      <- must run AFTER seed-pdp-attributes.ps1, never before
```

All four need `.env` present with `SHOPIFY_ADMIN_TOKEN`, `SHOPIFY_STORE` and
`SHOPIFY_API_VERSION`. `.env` is gitignored and is **not** on this branch.

---

## Content still not cleared for launch

Carried from `docs/admin-tasks.md` §15b, and unchanged by this branch:

- **Four undocumented claims** appear on the PDP badge strip, the Trust Center and the FAQ page —
  Leaping Bunny certified, dermatologist/patch tested, small batches with a printed blend date,
  recyclable packaging with no plastic void fill. They were deliberately dropped from the homepage
  proof band on this branch, but **not** from those three surfaces.
- The homepage stat band (91% / 84% / 71%) and six fabricated testimonials are `"disabled": true`
  in `templates/index.json` — present in the file, not rendering. Do not re-enable without a real
  panel and a real review app.
- Every photograph on the store is CC-licensed and not owned.
