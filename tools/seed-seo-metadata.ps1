# Fills seo.title / seo.description on every page, blog and article.
#
# Products and collections are handled by their own seed scripts. This closes the gap on
# the remaining object types so that nothing on the store falls back to a bare store-name
# title in search results.
#
# Titles stay under ~60 characters where possible, descriptions 150-160.

. (Join-Path $PSScriptRoot "gql.ps1")

$pageSeo = @{
  "why"           = @{ t="Why EMBRAE Exists - Skincare Built for Indian Skin"; d="The problem we set out to solve: skincare formulated elsewhere, for elsewhere. What we changed, and the percentages we publish." }
  "results"       = @{ t="Real Results - Timelines and What to Expect | EMBRAE"; d="Honest timelines by concern. Barrier repair in two weeks, breakouts in six, pigmentation in twelve, and what never changes at all." }
  "trust"         = @{ t="Trust Center - Manufacturing, Testing and Safety | EMBRAE"; d="Where our products are made, how they are tested, what is on the label, and what we will not claim. Full ingredient transparency." }
  "about"         = @{ t="About EMBRAE - Our Mission and Our Values"; d="Who we are, why we started, and the decisions we made that cost us margin. Climate-adaptive skincare for Indian skin." }
  "education"     = @{ t="Education Hub - Skin School, Ingredients and Climate"; d="Learn how skin actually works. Ingredient library, climate guides, myth versus fact, and routines by concern. No sales pitch." }
  "quiz"          = @{ t="Skin Quiz - Find Your Routine in 60 Seconds | EMBRAE"; d="Six questions on skin type, concern, sensitivity and climate. Get a routine matched to your skin and your city, not to our margins." }
  "faq"           = @{ t="FAQ Center - Products, Ingredients, Shipping | EMBRAE"; d="Answers on products, ingredients, skin types, usage, safety, shipping and returns. Written the way customers actually ask." }
  "contact"       = @{ t="Contact EMBRAE - Support, Email and WhatsApp"; d="Get in touch about an order, a product question, or a reaction. Response times and every way to reach us." }
  "careers"       = @{ t="Careers at EMBRAE"; d="Open roles, how we hire, and what it is like to work on a skincare brand that publishes its percentages." }
  "press"         = @{ t="Press and Media - EMBRAE"; d="Press contact, brand assets and coverage. For media enquiries and interview requests." }
  "store-locator" = @{ t="Where to Buy EMBRAE - Stockists by City"; d="Find EMBRAE in store. Stockists and counters across India, listed by city." }
  "track-order"   = @{ t="Track Your EMBRAE Order"; d="Track a shipment, check delivery status, or find your order number. Support options if something has gone wrong." }
}

$blogSeo = @{
  "skin-school"  = @{ t="Skin School - Skincare Basics Explained | EMBRAE"; d="How skin actually works. The barrier, layering order, realistic timelines, and the mistakes that undo a good routine." }
  "climate-skin" = @{ t="Climate and Skin - Monsoon, AC, Pollution | EMBRAE"; d="Indian weather changes what your skin needs. Monsoon congestion, air-conditioned offices, city air, and what to change each season." }
  "myth-vs-fact" = @{ t="Myth vs Fact - Skincare Claims Examined | EMBRAE"; d="Ingredient conflicts, moisturiser myths and SPF advice, checked against the actual evidence rather than repeated." }
  "journal"      = @{ t="The EMBRAE Journal - Formulation and Decisions"; d="How and why we formulate the way we do. Transparency decisions, Indian climate constraints, and the trade-offs we made." }
}

$articleSeo = @{
  "what-is-the-skin-barrier"     = @{ t="What Is the Skin Barrier? Damage and Repair | EMBRAE"; d="The skin barrier is a real physical layer, not a metaphor. What strips it, how to recognise damage, and a routine that repairs it in two weeks." }
  "how-to-layer-skincare"        = @{ t="What Order to Apply Skincare - A Simple Rule | EMBRAE"; d="Thinnest to thickest covers most of it. The one exception that matters, and the ingredient-conflict advice you can safely ignore." }
  "how-long-skincare-takes"      = @{ t="How Long Does Skincare Take to Work? | EMBRAE"; d="Barrier repair in two weeks, breakouts in six, pigmentation in twelve. Honest timelines by concern, and what never works at all." }
  "monsoon-skincare"             = @{ t="Monsoon Skincare in India - Humidity and Breakouts | EMBRAE"; d="Why humidity causes congestion rather than hydration, what to change in July, and the step almost everyone drops when it is overcast." }
  "air-conditioning-and-skin"    = @{ t="Air Conditioning and Dry Skin - What Helps | EMBRAE"; d="An office at 22 degrees is drier than most deserts. Why facial mists make it worse, and what actually holds water in through the day." }
  "pollution-and-skin"           = @{ t="Pollution and Skin - Dullness and Cleansing | EMBRAE"; d="What settles on your face during a day in an Indian city, why the evening cleanse matters more, and why scrubbing makes it worse." }
  "niacinamide-vitamin-c-myth"   = @{ t="Can You Use Niacinamide With Vitamin C? | EMBRAE"; d="The supposed conflict comes from a 1960s study run at temperatures no bathroom reaches. What is actually true, and what to watch instead." }
  "oily-skin-moisturiser-myth"   = @{ t="Does Oily Skin Need Moisturiser? Yes | EMBRAE"; d="Skipping moisturiser makes oily skin oilier. The rebound-oil cycle explained, and what texture to use instead of skipping the step." }
  "spf-indoors-myth"             = @{ t="Do You Need Sunscreen Indoors? An Honest Answer | EMBRAE"; d="UVA passes through window glass, UVB mostly does not. Why the answer depends on your desk, and what screens actually emit." }
  "why-we-print-percentages"     = @{ t="Why We Print Active Percentages on the Carton | EMBRAE"; d="An ingredient name without a dose is not information. Why we publish every percentage, and what that decision costs us." }
  "built-for-indian-weather"     = @{ t="Skincare Formulated for Indian Climate | EMBRAE"; d="Why a serum that works in a European winter fails by week three in Chennai, and the one problem we cannot formulate around." }
}

# Pages, blogs and articles do NOT expose `seo` on their update inputs the way products
# and collections do. Shopify stores their SEO as metafields in the reserved `global`
# namespace instead: global.title_tag and global.description_tag. Verified by the API
# rejecting `seo` as "Field is not defined on PageUpdateInput".

$mSet = 'mutation set($m: [MetafieldsSetInput!]!) { metafieldsSet(metafields: $m) { metafields { id } userErrors { field message } } }'
$batch = @()

function Queue($id, $s) {
  $script:batch += @{ ownerId = $id; namespace = "global"; key = "title_tag";       type = "single_line_text_field"; value = $s.t }
  $script:batch += @{ ownerId = $id; namespace = "global"; key = "description_tag"; type = "single_line_text_field"; value = $s.d }
}

$r = Send-GQL 'query { pages(first: 30) { nodes { id handle } } }'
foreach ($p in $r.data.pages.nodes) { if ($pageSeo[$p.handle]) { Queue $p.id $pageSeo[$p.handle]; Write-Host ("queued page/" + $p.handle) } }

$r = Send-GQL 'query { blogs(first: 20) { nodes { id handle } } }'
foreach ($b in $r.data.blogs.nodes) { if ($blogSeo[$b.handle]) { Queue $b.id $blogSeo[$b.handle]; Write-Host ("queued blog/" + $b.handle) } }

$r = Send-GQL 'query { articles(first: 50) { nodes { id handle } } }'
foreach ($a in $r.data.articles.nodes) { if ($articleSeo[$a.handle]) { Queue $a.id $articleSeo[$a.handle]; Write-Host ("queued article/" + $a.handle) } }

# metafieldsSet caps at 25 per call
$written = 0
for ($i = 0; $i -lt $batch.Count; $i += 25) {
  $chunk = $batch[$i..([Math]::Min($i + 24, $batch.Count - 1))]
  $res = Send-GQL $mSet @{ m = $chunk }
  $e = @($res.data.metafieldsSet.userErrors | Where-Object { $_ })
  if ($e.Count -gt 0) { Write-Host ("FAIL chunk at $i : " + ($e | ConvertTo-Json -Compress)) }
  else { $written += @($res.data.metafieldsSet.metafields).Count }
}

Write-Host ""
Write-Host ("SEO metafields written: $written of " + $batch.Count)
