# EMBRAE — image requirements

**For:** the photographer, graphic designer or AI image model producing EMBRAE's imagery.
**From:** the built storefront. Every pixel dimension below is measured from the theme's own
CSS, not estimated — deliver to these and the images drop in with no layout change and no
re-cropping.

Read sections 1–4 once. Then work through the tables in section 5; each row is one file.

---

## 1. What the brand looks like

EMBRAE is science-led skincare built for Indian urban climates. The visual register is
**clinical, warm and quiet** — a laboratory that someone has made beautiful, not a spa and not
a pharmacy.

| | |
|---|---|
| **Feels like** | Precise. Calm. Warm-neutral. Evidence you can read. |
| **Does not feel like** | Spa candles. Tropical leaves. Glitter. Water splashes. Marble slabs. Gold foil. Rose petals. Stock "wellness". |
| **Light** | Soft, directional, single source from the upper left. One soft shadow. Never flat ring-light, never hard studio flash. |
| **Depth of field** | Shallow but honest. The product stays sharp end to end. |
| **Colour grade** | Warm-neutral. Slightly lifted blacks. No teal-and-orange, no heavy contrast curve. |

### The palette — images must sit inside it

| Name | Hex | Where it is used |
|---|---|---|
| Cream | `#FBF3EA` | Default page ground. **The default packshot background.** |
| White | `#FFFFFF` | Cards |
| Deep green | `#034638` | Header, footer, the bundle-offer hero slide, one CTA band |
| Stone | `#F2F0EC` | Alternate band ground |
| Aqua | `#63C0AD` | Accent only — buttons on green, small highlights |
| Peach | `#F3CFB3` | Text on the deep green ground |
| Charcoal | `#2B2B2B` | All body text |

Backgrounds inside photographs should be one of **cream `#FBF3EA`, stone `#F2F0EC`, white
`#FFFFFF` or deep green `#034638`**. Aqua and peach are accents and should never fill a frame.

### Typography — do not put any of it in the image

The site sets **DM Serif Display** for headings and **Inter** for body text, live in HTML.

**No image may contain baked-in text.** No headlines, no price flashes, no "50% OFF" badges,
no logos composited onto photographs. Every word on the site is real text, so that it is
translatable, searchable and readable by screen readers. An image with text in it breaks all
three.

---

## 2. Global technical specification

| | |
|---|---|
| **Format** | JPEG, quality 85, for all photography. PNG-24 **only** where the table says transparent. SVG for the logo. |
| **Colour profile** | sRGB IEC61966-2.1, embedded. Not Adobe RGB, not ProPhoto — the browser will render those wrong. |
| **Bit depth** | 8-bit |
| **File size** | Aim under 500 KB per file after export. Shopify re-encodes and serves WebP, but a bloated source still costs page speed, and 70–80% of this store's traffic is mobile. |
| **Hard limits** | Shopify rejects anything over 20 megapixels or 20 MB. |
| **Metadata** | Strip GPS. Keep copyright. |
| **Never bake in** | Text, borders, drop shadows, rounded corners, watermarks, badges. The theme draws its own corners, shadows and badges — a baked-in one will be drawn twice. |

### The 8% safe margin

Most images on this site are cropped by the browser to fit their container (`object-fit:
cover`), and the crop is different at every screen width. So:

> **Keep everything important inside the middle 84% of the frame. Leave the outer 8% on every
> edge expendable.**

Where a row below says *contain*, the opposite applies — the whole subject must be inside the
frame with padding, because nothing will be cropped.

### Responsive reality

This store is checked at **360, 390, 414, 768, 820, 1024, 1280 and 1440 px wide**. A product
that reads clearly at 1440 px and turns to mush at 360 px has failed. The texture swatches in
particular display at **120 px** — they must read as one clear shape at thumbnail size.

---

## 3. File naming — please follow this exactly

**This is the part that saves us the most time.** Files are uploaded by name and wired to the
site by name. A file named `Serum_Final_v3 (2).jpg` has to be renamed by hand before it can be
used, and a renamed file is a file that can be mismatched.

Rules:

- **All lowercase.** No capitals anywhere.
- **Hyphens between words.** No spaces, no underscores, no brackets, no `v2`, no `final`.
- **Always prefixed `embrae-`.**
- **American spelling** — `defense`, `moisturizer`, `color`. The whole site is US English, and
  a British-spelled filename cannot be corrected later without a re-upload.
- **Use the exact filename in the table.** Not a variation of it.

✅ `embrae-urban-defense-serum.jpg`
❌ `EMBRAE_Urban Defence Serum_FINAL.jpg`

If a shot is re-taken, deliver it under the **same filename**. Do not add `-v2`.

---

## 4. The product master — the eight products

These names are final. Please use them exactly, including capitalisation, in any file, folder
or delivery note.

| # | Product | What is in the shot | Size on pack |
|---|---|---|---|
| 1 | **Barrier Reset Cleanser** | Low-foam gel cleanser bottle | 100 ml |
| 2 | **Urban Defense Serum** | Dropper bottle, amber or frosted glass | 30 ml |
| 3 | **Climate Adapt Moisturizer** | Wide jar with lid | 50 ml |
| 4 | **Daily Shield SPF 50 PA++++** | Squeeze tube | 50 ml |
| 5 | **Urban Defense Routine** | All four above, together, with the outer box | 4-product set |
| 6 | **The Morning Ritual** | Cleanser + Serum + SPF | 3-product set |
| 7 | **The Evening Repair Kit** | Cleanser + Serum + Moisturizer | 3-product set |
| 8 | **Travel Essentials Kit** | Travel-size minis of all four | 4-mini set |

Plus one item that is never sold:

| — | **Travel Essentials Pouch** | The empty branded pouch, free with the Urban Defense Routine | gift |

---

## 5. The shot list

**86 files.** Grouped by where they appear. Priority column: **P1** blocks launch, **P2** is
needed before the store is public, **P3** can follow.

---

### A. Brand identity — 3 files · P1

Vector, not photography.

| Filename | Spec | Where it is used | What it must be |
|---|---|---|---|
| `embrae-logo.svg` | SVG, horizontal lockup, single flat colour, transparent | Header on every page, footer, checkout, emails | The wordmark alone. Must stay legible at **120 px wide** (the mobile header) and must work in **one colour**, because it is drawn in cream on the deep green header. Supply outlined paths, not live text. |
| `embrae-logo-mark.svg` | SVG, square, transparent | Favicon, app icon, social share | The monogram or mark without the wordmark. Must read at **16 px**. |
| `embrae-favicon.png` | PNG-24, 512 × 512, transparent | Browser tab | Export of the mark above, on transparent. |

> Currently the header renders the shop name as text. Until these land, EMBRAE has no logo
> anywhere on the site.

---

### B. Homepage hero slideshow — 8 files · P1

**This is the most important image on the site**, and it has the most specific composition
requirement. Four slides, each needing a desktop and a mobile version.

**Desktop:** 2560 × 1440 px (16:9). **Mobile:** 1200 × 1200 px (1:1).

#### The desktop composition rule — please read this before shooting

The headline, the subheading and **the button already sit on the left side of the frame as live
text**. The image only has to hold the product and the ground behind it.

```
  2560 px wide
  ┌───────────────────────────┬────────────────────────────┐
  │                           │                            │
  │   LEFT 45% — KEEP QUIET   │   RIGHT 40% — THE PRODUCT  │
  │                           │                            │
  │   Flat ground, gradient   │   Product, vertically      │
  │   or soft out-of-focus    │   centred, well lit,       │
  │   texture only.           │   sharp.                   │
  │                           │                            │
  │   NO product.             │                            │
  │   NO text (we add it).    │                            │
  │   NO busy detail.         │                            │
  │   NO high contrast.       │                            │
  └───────────────────────────┴────────────────────────────┘
       ↑ headline + button      ↑ outer 8% may be cropped
         are drawn here
```

**Do not put "Take the quiz", an arrow, a badge or any call to action into the image.** The
button is already there in HTML, sitting exactly on top of that area. A painted-on button would
appear twice.

The left area must stay low-contrast so that charcoal or cream text stays readable over it. If
in doubt, make it plainer.

#### Mobile is a different crop, not a resize

On phones the text sits **below** the image, in its own block. So the mobile file has no quiet
zone requirement — **centre the product and fill the frame.** It is cropped to anything between
square and 2:1 depending on the handset, so keep the product inside the middle 84%.

| Filename | Slide | What is in it |
|---|---|---|
| `embrae-hero-climate-skin.jpg` | 1 — "Skincare for changing climates" | Ground: cream `#FBF3EA` or a soft warm gradient. Right side: one or two products, hero-lit. Optional: a suggestion of weather — condensation, warm haze, low sun — but abstract, never a literal weather photo. |
| `embrae-hero-climate-skin-mobile.jpg` | 1 — mobile | Same products, centred, filling the frame. |
| `embrae-hero-routine.jpg` | 2 — "Reset. Defend. Adapt. Protect." | Right side: **all four products in a row**, evenly spaced, same baseline, shot straight on. Ground: stone `#F2F0EC`. This is the range shot — it must be readable as four distinct products. |
| `embrae-hero-routine-mobile.jpg` | 2 — mobile | The same four, but tighter — two rows of two, or a closer row. Four across does not read at 360 px. |
| `embrae-hero-urban-defense-serum.jpg` | 3 — the serum | Right side: **the Urban Defense Serum alone**, three-quarter angle, dropper visible. This is the flagship product shot. Ground: cream. |
| `embrae-hero-urban-defense-serum-mobile.jpg` | 3 — mobile | The serum, centred, larger in frame. |
| `embrae-hero-bundle-offer.jpg` | 4 — the bundle offer | ⚠️ **This slide runs on the deep green `#034638` ground.** Shoot the Urban Defense Routine box and contents **on deep green**, lit so the packaging separates from it. Peach `#F3CFB3` text is drawn over the left side, so keep that area dark and even. |
| `embrae-hero-bundle-offer-mobile.jpg` | 4 — mobile | Same green ground, box centred. |

---

### C. Product packshots — 18 files · P1

Two per product, nine products (eight sellable plus the gift pouch).

**All packshots: 2048 × 2048 px, square (1:1).**

#### The packshot rules

1. **Ground: seamless cream `#FBF3EA`.** No visible horizon line, no surface edge, no props.
   Exception: the gift pouch, which may be shot on stone `#F2F0EC`.
2. **The product occupies the middle 55–60% of the width.** This matters: product cards crop
   these square files to a **2:3 portrait**, which cuts roughly a third off each side. A product
   sized to the full frame will have its edges sliced off on every listing page.
3. **Vertically centred**, with equal air above and below.
4. **One soft shadow**, grounded, falling to the lower right. No mirror reflection, no floating.
5. **Label facing camera, level, legible, in focus.** Someone will read the ingredient
   percentages off this image.
6. **Consistency across the range is more important than any single shot.** Same camera height,
   same lens, same light, same shadow direction, same distance for all nine. They appear in a
   row on the homepage and any drift shows immediately.

The `-alt` file is the second gallery image: a three-quarter angle, the carton beside the
bottle, or the product held in hand. Same ground, same light.

| Filename | Product | Notes |
|---|---|---|
| `embrae-barrier-reset-cleanser.jpg` | Barrier Reset Cleanser | Front, straight on |
| `embrae-barrier-reset-cleanser-alt.jpg` | Barrier Reset Cleanser | Three-quarter with carton |
| `embrae-urban-defense-serum.jpg` | Urban Defense Serum | Front, straight on. Dropper in. |
| `embrae-urban-defense-serum-alt.jpg` | Urban Defense Serum | Dropper lifted, a bead of serum visible |
| `embrae-climate-adapt-moisturizer.jpg` | Climate Adapt Moisturizer | Front, lid on |
| `embrae-climate-adapt-moisturizer-alt.jpg` | Climate Adapt Moisturizer | Lid off, cream surface visible |
| `embrae-daily-shield-spf50.jpg` | Daily Shield SPF 50 PA++++ | Front, cap up, SPF marking legible |
| `embrae-daily-shield-spf50-alt.jpg` | Daily Shield SPF 50 PA++++ | Angled, with carton |
| `embrae-urban-defense-routine.jpg` | Urban Defense Routine | All four products **plus the box**. This is a ₹3,000+ purchase — it must look like a considered object. |
| `embrae-urban-defense-routine-alt.jpg` | Urban Defense Routine | Box open, contents arranged |
| `embrae-morning-ritual.jpg` | The Morning Ritual | Cleanser, serum, SPF — in that order left to right |
| `embrae-morning-ritual-alt.jpg` | The Morning Ritual | Angled group |
| `embrae-evening-repair-kit.jpg` | The Evening Repair Kit | Cleanser, serum, moisturizer, left to right |
| `embrae-evening-repair-kit-alt.jpg` | The Evening Repair Kit | Angled group, warmer light |
| `embrae-travel-essentials-kit.jpg` | Travel Essentials Kit | Four minis, with the pouch behind |
| `embrae-travel-essentials-kit-alt.jpg` | Travel Essentials Kit | Minis inside the pouch, packed |
| `embrae-travel-essentials-pouch.jpg` | Travel Essentials Pouch | The empty pouch alone, branding visible |
| `embrae-travel-essentials-pouch-alt.jpg` | Travel Essentials Pouch | Pouch held, or shown with the bundle it comes free with |

---

### D. Routine architecture cards — 8 files · P1

The homepage "Four actions. One climate-ready routine." band. Four cards — RESET, DEFEND,
ADAPT, PROTECT — each holding a product cut-out and a small texture swatch.

#### D1. Product cut-outs — 4 files, **transparent PNG**

**1200 × 1500 px (4:5), PNG-24 with a transparent background.**

⚠️ These are the one exception to the 8% crop rule. They are displayed **contained**, so
nothing is cropped — but equally, **the whole product must fit inside the frame with about 8%
padding on all sides**, or it will look cramped against the card edge.

Clean cut-out: no background, no shadow, no ground. Anti-aliased edges, no white halo.

| Filename | Step | Product |
|---|---|---|
| `embrae-routine-reset-product.png` | RESET | Barrier Reset Cleanser |
| `embrae-routine-defend-product.png` | DEFEND | Urban Defense Serum |
| `embrae-routine-adapt-product.png` | ADAPT | Climate Adapt Moisturizer |
| `embrae-routine-protect-product.png` | PROTECT | Daily Shield SPF 50 PA++++ |

#### D2. Texture macros — 4 files

**800 × 800 px, square.** ⚠️ **Displayed at 120 px.** Everything about these must survive being
shrunk to the size of a thumbnail: one clear shape, strong tonal separation, no fine detail.

Macro of the formula itself on cream or white, top-down, hard-ish raking light so the texture
has relief.

| Filename | Formula | What it looks like |
|---|---|---|
| `embrae-texture-gel.jpg` | Cleanser | Clear gel, one smooth swipe or a single dome. Slight bubbles are fine. |
| `embrae-texture-serum.jpg` | Serum | Two or three distinct droplets, glossy, with visible surface tension |
| `embrae-texture-cream.jpg` | Moisturizer | One thick swirl with a peak, matte finish |
| `embrae-texture-fluid.jpg` | Sunscreen | A smooth fluid swipe, opaque white, no white cast on the ground |

---

### E. Morning / Evening band — 2 files · P1

Two full-bleed panels sitting edge to edge. **2000 × 1200 px (5:3).**

⚠️ **Composition:** the copy sits across the **bottom** of each panel, under a soft gradient
scrim. So put the subject in the **top 55% of the frame**, and let the bottom 45% be quiet — it
will be partly covered.

| Filename | Panel | What it must be |
|---|---|---|
| `embrae-daypart-morning.jpg` | Morning | Cool, bright daylight. Cream and white ground. Morning products, or a bathroom surface with real daylight falling across it. Awake, not clinical. |
| `embrae-daypart-evening.jpg` | Evening | Warm, low, directional light. Deeper tones. The same surface at night. Calm, not gloomy — no near-black frames. |

---

### F. Homepage editorial — 3 files · P1/P2

| Filename | Spec | Where | What it must be | Priority |
|---|---|---|---|---|
| `embrae-urban-skyline.jpg` | 2000 × 1500 (4:3) | Homepage — "The Problem" band | Indian city, hazy air, warm light. Sells the climate premise: pollution, heat, humidity. Recognisably India. **Not** a generic glass-tower skyline. | P1 |
| `embrae-founder.jpg` | 1600 × 2000 (4:5) | Homepage founder block, About page | The founder, real, environmental portrait — at a bench, a desk, near the product. Natural light. Looking at camera. Not a corporate headshot, not a stock model. **A model release is required.** | P2 |
| `embrae-story.jpg` | 2000 × 1500 (4:3) | About page, brand story band | Formulation or packing in progress. Hands, tools, materials. Documentary, not staged. | P2 |

---

### G. Ingredient library — 6 files · P2

Displayed in a **4:5 portrait** frame, cropped to fill. **1200 × 1500 px.**

Consistent treatment across all six — this is a library, and it should read as a set. Suggested
approach: the raw active as a macro on cream, shot the same way each time. Abstract and
material, not lifestyle.

| Filename | Ingredient |
|---|---|
| `embrae-ingredient-niacinamide.jpg` | Niacinamide |
| `embrae-ingredient-vitamin-c.jpg` | Vitamin C (ethyl ascorbic acid) |
| `embrae-ingredient-hyaluronic-acid.jpg` | Hyaluronic acid |
| `embrae-ingredient-salicylic-acid.jpg` | Salicylic acid |
| `embrae-ingredient-squalane.jpg` | Squalane |
| `embrae-ingredient-ceramides.jpg` | Ceramides |

---

### H. Skin concern library — 6 files · P2

Same frame as above: **1200 × 1500 px, 4:5.**

⚠️ **This set is the easiest one to get legally and ethically wrong.** These must **not** show
distressed skin, before-and-after comparisons, or anything that reads as a clinical result. We
make no efficacy claims we cannot document. Use abstract, textural or atmospheric imagery that
suggests the condition — light, moisture, dryness, heat — rather than depicting it on a face.

If a face is used at all, it must be healthy, unretouched, and covered by a model release.

| Filename | Concern |
|---|---|
| `embrae-concern-dullness.jpg` | Dullness |
| `embrae-concern-dryness.jpg` | Dryness |
| `embrae-concern-breakouts.jpg` | Breakouts |
| `embrae-concern-pigmentation.jpg` | Pigmentation |
| `embrae-concern-fine-lines.jpg` | Fine lines |
| `embrae-concern-sensitivity.jpg` | Sensitivity |

---

### I. Collection covers — 8 files · P2

Shown in a **2:3 portrait** frame on the homepage "Start here" row and the collections page.
**1600 × 2400 px.** Currently **all 22 collections have no image at all.**

The twelve concern and ingredient collections reuse the files from G and H — only these eight
need their own.

| Filename | Collection | What it must be |
|---|---|---|
| `embrae-collection-skincare.jpg` | Skincare | The full range, grouped |
| `embrae-collection-serums.jpg` | Serums | The serum, tall crop |
| `embrae-collection-moisturizers.jpg` | Moisturizers | The jar, tall crop |
| `embrae-collection-cleansers.jpg` | Cleansers | The cleanser, tall crop |
| `embrae-collection-sunscreen.jpg` | Sunscreen | The SPF tube, brighter light |
| `embrae-collection-bundles.jpg` | Bundles | Two or three boxes stacked |
| `embrae-collection-gift-sets.jpg` | Gift sets | The travel kit and pouch |
| `embrae-collection-bestsellers.jpg` | Bestsellers | The three strongest sellers together |

---

### J. Packaging detail — 4 files · P2

Product page gallery. **2048 × 2048 px, square.** These are the shots that carry the "premium
object" feeling and answer "what does it actually feel like".

| Filename | What it must be |
|---|---|
| `embrae-packaging-carton.jpg` | The outer carton, angled, ingredient panel partly readable |
| `embrae-packaging-in-hand.jpg` | The bottle held. Hands must be unretouched and natural. **Model release required.** |
| `embrae-packaging-emboss.jpg` | Extreme macro of the embossed logo or the batch-date print, raking light |
| `embrae-packaging-bottle.jpg` | The bottle detail — cap threads, dropper, pump — the engineering |

---

### K. Trust and lab — 4 files · P2

Trust Center, Why EMBRAE and Testing pages. **1600 × 1200 px (4:3).**

Real lab or manufacturing where possible. If a real facility cannot be photographed, say so —
**a stock lab photograph presented as our lab is a claim we cannot support**, and this brand's
whole positioning is documented transparency.

| Filename | Where |
|---|---|
| `embrae-lab-glassware.jpg` | Trust Center, Why EMBRAE |
| `embrae-lab-dropper.jpg` | Testing and Efficacy |
| `embrae-lab-microscope.jpg` | Testing and Efficacy, Our Standards |
| `embrae-lab-formulator.jpg` | Manufacturing and Quality. **Model release required.** |

---

### L. Article headers — 11 files · P3

Blog post headers. **1600 × 900 px (16:9).**

These are also the images that appear when an article is shared on WhatsApp, Instagram or
LinkedIn, so each must make sense at a glance and with no caption.

| Filename | Article |
|---|---|
| `embrae-article-what-is-the-skin-barrier.jpg` | What is the skin barrier |
| `embrae-article-how-to-layer-skincare.jpg` | How to layer skincare |
| `embrae-article-how-long-skincare-takes.jpg` | How long skincare takes to work |
| `embrae-article-monsoon-skincare.jpg` | Monsoon skincare |
| `embrae-article-air-conditioning-and-skin.jpg` | Air conditioning and skin |
| `embrae-article-pollution-and-skin.jpg` | Pollution and skin |
| `embrae-article-niacinamide-vitamin-c-myth.jpg` | Niacinamide + vitamin C myth |
| `embrae-article-oily-skin-moisturizer-myth.jpg` | Oily skin needs no moisturizer — myth |
| `embrae-article-spf-indoors-myth.jpg` | SPF indoors — myth |
| `embrae-article-why-we-print-percentages.jpg` | Why we print percentages |
| `embrae-article-built-for-indian-weather.jpg` | Built for Indian weather |

---

### M. Customer stories — 3 files · P3, blocked

**1200 × 1500 px (4:5).**

⚠️ **Do not produce these from models or stock.** They appear on the site as real customers.
These stay as placeholders until there are genuine customers who have given written permission
for their photograph and their words. A stock portrait presented as a customer testimonial is
misrepresentation, not a design shortcut.

| Filename | |
|---|---|
| `embrae-customer-story-1.jpg` | Real customer, release signed |
| `embrae-customer-story-2.jpg` | Real customer, release signed |
| `embrae-customer-story-3.jpg` | Real customer, release signed |

---

### N. Promotional banners — 2 files · P3

**2000 × 800 px (5:2).** Text is added by the theme — **none in the image.**

| Filename | Where | What |
|---|---|---|
| `embrae-promo-shipping.jpg` | Free shipping strip | Packed order, tape, dispatch bench. Warm and real. |
| `embrae-promo-skin-quiz.jpg` | Skin quiz call-to-action | Calm, inviting, product-light. The quiz is the entry point, not a product sale. |

---

## 6. Summary — what to deliver

| Group | Files | Priority |
|---|---|---|
| A. Brand identity | 3 | P1 |
| B. Hero slideshow | 8 | P1 |
| C. Product packshots | 18 | P1 |
| D. Routine cards (cut-outs + textures) | 8 | P1 |
| E. Morning / Evening band | 2 | P1 |
| F. Homepage editorial | 3 | P1 / P2 |
| G. Ingredient library | 6 | P2 |
| H. Skin concern library | 6 | P2 |
| I. Collection covers | 8 | P2 |
| J. Packaging detail | 4 | P2 |
| K. Trust and lab | 4 | P2 |
| L. Article headers | 11 | P3 |
| M. Customer stories | 3 | P3 — blocked, real customers only |
| N. Promotional banners | 2 | P3 |
| **Total** | **86** | |

**If capacity is limited, shoot in this order:** C (packshots) → B (hero) → D (routine cards) →
A (logo) → E → F → everything else. The first four groups are what a customer sees before
deciding whether this is a real brand.

### Delivery

One flat folder — no subfolders, no nesting — containing every file named exactly as specified.
A ZIP or a shared drive link both work.

Please do **not** rename, re-number or re-organise on delivery. The filenames in this document
are how each image finds its place on the site.

---

## 7. If you are an AI image model

Use section 1 as the style prompt for every generation, and the per-row "what it must be"
column as the subject.

Constraints that apply to every image, and that are usually got wrong:

- **No text, letters, numbers or logos anywhere in the image.** Product labels should read as
  texture, not as legible invented words.
- **No hands or faces** unless the row explicitly asks for them.
- **One consistent light direction across the whole set** — soft, from the upper left.
- **Warm-neutral grade.** No teal-and-orange, no heavy vignette, no bloom.
- **Real, plausible product forms.** No impossible glass, no floating liquid ribbons, no
  crystalline sparkle.
- **Backgrounds must be one flat brand colour** — `#FBF3EA`, `#F2F0EC`, `#FFFFFF` or `#034638`
  — not a gradient sky, a marble slab or a leaf.
- **Square means square.** Generate at the stated aspect ratio; do not deliver a 1:1 file for a
  4:5 slot and let it be stretched.

Generated imagery is acceptable for the routine textures, the ingredient library and abstract
backgrounds. It is **not** acceptable for the founder, customers, the lab, or anything the site
presents as a photograph of a real person, place or result.
