# Writes SEO title/description and the embrae.seo_intro / embrae.seo_outro long-form
# copy onto all 21 collections. The intro sits above the product grid, the outro below it -
# that lower block is what gives a collection page enough substance to rank for the query
# it is named after, rather than being a bare grid of nine cards.
#
# MOCK CONTENT, but written to be structurally right. Replace claims before launch.

. (Join-Path $PSScriptRoot "gql.ps1")

function RT([string]$text) {
  $kids = @()
  foreach ($p in ($text -split "\|\|")) {
    $esc = $p.Replace('\', '\\').Replace('"', '\"')
    $kids += '{"type":"paragraph","children":[{"type":"text","value":"' + $esc + '"}]}'
  }
  return '{"type":"root","children":[' + ($kids -join ",") + ']}'
}

$copy = @(
  # --- category ---
  @{ h="serums"; t="Face Serums for Indian Skin | EMBRAE"; d="Concentrated actives with the percentage printed on the carton. Vitamin C, niacinamide and hyaluronic acid, in doses that survive Indian heat."
     i="A serum is the step where actives actually go in. Everything else in a routine either prepares the skin for it or protects it afterwards."
     o="We print the percentage of every active on the carton. An ingredient name on its own is not information - niacinamide at 0.1% and niacinamide at 4% are the same word and completely different products.||If you are not sure which serum suits you, the skin quiz takes about a minute and recommends on concern and climate rather than on margin." }
  @{ h="moisturisers"; t="Moisturisers for Barrier Repair | EMBRAE"; d="Fragrance-free ceramide and squalane moisturisers, light enough for humid months and cushioned enough for a Delhi winter."
     i="Most skin problems people bring us are barrier problems wearing another name - dryness, sensitivity, rebound oil, stinging."
     o="A moisturiser is not there to add water. It is there to stop water leaving, and to replace the lipids that hard water, hot showers and air conditioning strip out.||Oily skin needs one too. Skipping it is the most common reason oily skin gets oilier." }
  @{ h="cleansers"; t="Gentle Face Cleansers, Sulphate Free | EMBRAE"; d="Low-foam cleansers that remove sunscreen and city grime without stripping. pH 5.5, sulphate free, with buffered salicylic acid."
     i="A cleanser has one job that most get wrong: remove a full day without taking the barrier with it."
     o="Squeaky clean is a warning, not a result. That feeling is the sound of a stripped barrier, and it is followed within an hour by tightness and within a week by more oil.||Lukewarm water, forty seconds of contact, once at night. That is the whole method." }
  @{ h="sunscreen"; t="Sunscreen SPF 50 PA++++ No White Cast | EMBRAE"; d="Mineral-led broad spectrum SPF 50 with non-nano zinc oxide. No white cast on Indian skin tones, no sting, wears under makeup."
     i="Sunscreen is the highest-return step in any routine and the one most often skipped, because most of them sting, cast grey, or pill."
     o="Two finger-lengths for face and neck. Almost everyone uses a third of that, which is how an SPF 50 becomes an SPF 15 in practice.||UVA passes through window glass, so a desk by a window is not the indoors people assume it is." }
  @{ h="bundles"; t="Skincare Sets and Routine Bundles | EMBRAE"; d="Complete routines in the order they are applied, priced below the sum of their parts. Morning, evening, or the full four steps."
     i="Bought separately, these need a decision about order, timing and what goes with what. Bought together they do not."
     o="Every bundle is a complete routine rather than a sampler. Nothing in it is a size you would need to replace on a different schedule from the rest.||All bundles clear the free-shipping threshold." }
  @{ h="gift-sets"; t="Skincare Gift Sets and Travel Sizes | EMBRAE"; d="Travel sizes and gifting formats. Cabin-bag compliant, same formulas as the full sizes, nothing diluted."
     i="Travel sizes exist because a 50 ml jar does not clear cabin-bag rules and does not survive being packed loose."
     o="Nothing here is reformulated for the smaller size. Same ingredients, same percentages, smaller jar.||These also make sensible patch-test sizes if your skin reacts easily." }
  # --- base ---
  @{ h="skincare"; t="Shop All EMBRAE Skincare" ; d="The full EMBRAE range - cleansers, serums, moisturisers, sunscreen and routine bundles. Built for Indian skin and Indian weather."
     i="Nine products. Not ninety - we would rather make a small number of things that earn their place."
     o="Every formula is fragrance free, every active has its percentage on the carton, and every carton carries a blend date as well as an expiry.||If you are starting from scratch, the Starter Duo or the skin quiz are the two shortest routes in." }
  @{ h="bestsellers"; t="Bestselling Skincare | EMBRAE"; d="What people reorder. The cleanser, serum, moisturiser and SPF that make up most repeat orders, plus the bundles built from them."
     i="Reorders are the only review that cannot be gamed. These are the products people come back for."
     o="Popularity is not a recommendation for your skin specifically. If you have a concern in mind, the concern pages or the quiz will get you somewhere better than a bestseller list will." }
  # --- concerns ---
  @{ h="dullness"; t="Products for Dull Skin | EMBRAE"; d="Vitamin C, gentle cleansing and daily SPF for skin that looks flat and grey. What to use, and how long tone actually takes."
     i="Dullness is rarely one problem. Usually it is build-up, uneven pigment and dehydration at the same time."
     o="Give tone eight weeks. Anything promising faster is describing a scrub, which buffs the surface and changes nothing underneath.||Sunscreen matters here more than people expect - unprotected sun undoes vitamin C faster than it works." }
  @{ h="dryness"; t="Products for Dry Skin - Barrier Repair | EMBRAE"; d="Ceramides and squalane for tight, flaky skin. Usually a damaged barrier rather than a lack of water, and it repairs in about two weeks."
     i="Tight, flaky skin is more often a barrier problem than a water problem. Adding water on top of a broken barrier does nothing."
     o="Stop the stripping first - lukewarm water, gentler cleansing, and pause the acids for a fortnight. Then rebuild with ceramides.||This is one of the faster things to fix in skincare. Most people see a real difference in ten to fourteen days." }
  @{ h="breakouts"; t="Products for Breakouts and Congestion | EMBRAE"; d="Buffered salicylic acid and niacinamide for spots, blackheads and closed bumps. Why over-washing makes it worse."
     i="Congestion, closed bumps and inflamed spots, made worse by humidity - which is why the monsoon is the hardest season for it."
     o="Over-washing makes breakouts worse, not better. Stripped skin produces more oil to compensate.||Four to six weeks before judging a routine. Stopping at week two is the most common reason people conclude nothing worked." }
  @{ h="pigmentation"; t="Products for Pigmentation and Dark Marks | EMBRAE"; d="Vitamin C, niacinamide and daily SPF 50 for post-acne marks and melasma on Indian skin. A twelve-week plan."
     i="Indian skin produces more melanin, so it marks more readily and holds those marks longer. That needs a different approach, not a stronger one."
     o="Sunscreen is the treatment here, not the aftercare. Without it nothing else in this list works.||Twelve weeks minimum, and marks fade rather than vanish. Anyone promising otherwise is selling something." }
  @{ h="fine-lines"; t="Products for Fine Lines | EMBRAE"; d="Hydration, barrier support and daily SPF. Why sun does more ageing than time, and what changes the look of lines immediately."
     i="Sun exposure accelerates collagen loss more than age does - which is why the skin on your forearm and the skin on your hip age at different rates."
     o="Dehydration makes existing lines far more visible without creating new ones, so hydration changes the look within days.||The rest is prevention. What you do in your thirties shows in your fifties." }
  @{ h="sensitivity"; t="Products for Sensitive Skin | EMBRAE"; d="Fragrance-free ceramide and squalane formulas for skin that stings or flushes. A three-week reset, and how to reintroduce products."
     i="Sensitivity is almost always a compromised barrier rather than a true allergy. Barriers repair if you stop provoking them."
     o="Strip the routine back to cleanser, moisturiser and sunscreen for three weeks. Then reintroduce one product per fortnight, patch tested behind the ear for two days first.||Everything here is fragrance free, with no essential oils used as fragrance." }
  # --- ingredients ---
  @{ h="vitamin-c"; t="Vitamin C Skincare - 10% Ethyl Ascorbic Acid | EMBRAE"; d="Stabilised vitamin C that survives Indian heat. Why we use ethyl ascorbic acid rather than L-ascorbic acid."
     i="Vitamin C interrupts the step where skin makes pigment. Less new pigment, and existing marks fade sooner."
     o="Most L-ascorbic acid serums oxidise into a brown, useless liquid within weeks of arriving in an Indian bathroom.||A less-studied form that still works in month three beats the best-studied form that died in week two." }
  @{ h="niacinamide"; t="Niacinamide Skincare - 2% to 4% | EMBRAE"; d="Vitamin B3 for redness, oil control and barrier support. The percentage that works, and why more is not better."
     i="Niacinamide signals skin to make more of its own ceramides, which is why it settles redness and strengthens a stressed barrier."
     o="Well studied at 2 to 5 percent. Above that the returns flatten and the risk of flushing rises, which is why we stay in the lower band rather than chasing a number on the carton." }
  @{ h="hyaluronic-acid"; t="Hyaluronic Acid Skincare | EMBRAE"; d="Low molecular weight hyaluronic acid that holds water inside skin. And the mistake that makes skin drier instead."
     i="Hyaluronic acid binds many times its own weight in water, and low molecular weight fragments sit deeper than the surface."
     o="It is a humectant, not a moisturiser. Without something sealing it in, on a dry day it pulls water out of your skin rather than into it - the single most common way people use it wrong." }
  @{ h="salicylic-acid"; t="Salicylic Acid Skincare - BHA | EMBRAE"; d="Oil-soluble salicylic acid that works inside the pore. Why 0.5% in a cleanser beats a stronger leave-on for most people."
     i="Unlike glycolic or lactic acid, salicylic acid is oil soluble - so it travels into the pore rather than working only on the surface."
     o="Something that rinses off in forty seconds does not need to be aggressive to work. Buffered, at half a percent, it clears congestion without the irritation a leave-on causes." }
  @{ h="squalane"; t="Squalane Skincare - Light Plant Oil | EMBRAE"; d="Olive-derived squalane that restores skin lipids without an oily film. Suits humid weather and reactive skin."
     i="Squalane is a stable, plant-derived version of a lipid skin already makes - and makes less of with age and with harsh cleansing."
     o="It sinks in rather than sitting on top, which is why it suits humid months when a heavier facial oil would feel like a film.||Non-comedogenic and very well tolerated, including on reactive skin." }
  @{ h="ceramides"; t="Ceramide Skincare for Barrier Repair | EMBRAE"; d="Ceramide NP, AP and EOP in the ratio skin uses them. The strongest evidence in barrier repair."
     i="If skin cells are bricks, ceramides are the mortar. Strip them and water escapes while irritants get in."
     o="We use three types together in the ratio skin uses them. A single ceramide on an ingredients list is a marketing decision rather than a formulation one.||This is the least speculative thing in the range." }
  @{ h="zinc-oxide"; t="Zinc Oxide Sunscreen - Mineral SPF | EMBRAE"; d="Non-nano zinc oxide for broad spectrum protection without a white cast. Tolerated by reactive skin."
     i="Zinc oxide covers UVA and UVB in a single ingredient and works from the moment it is applied, with no wait."
     o="Non-nano particles in a fluid base avoid the chalky finish mineral sunscreens are known for on deeper skin tones.||Mineral filters are usually the better choice for skin that reacts to chemical ones." }
)

$coll = @{}
$r = Send-GQL 'query { collections(first: 40) { nodes { id handle } } }'
$r.data.collections.nodes | ForEach-Object { $coll[$_.handle] = $_.id }

$cUpd = 'mutation upd($i: CollectionInput!) { collectionUpdate(input: $i) { collection { id } userErrors { field message } } }'
$mSet = 'mutation set($m: [MetafieldsSetInput!]!) { metafieldsSet(metafields: $m) { metafields { id } userErrors { field message } } }'

$done = 0
foreach ($c in $copy) {
  $id = $coll[$c.h]
  if (-not $id) { Write-Host ("SKIP  " + $c.h); continue }

  $r1 = Send-GQL $cUpd @{ i = @{ id = $id; seo = @{ title = $c.t; description = $c.d } } }
  $e1 = @($r1.data.collectionUpdate.userErrors | Where-Object { $_ })
  if (-not $r1.data.collectionUpdate -or $e1.Count -gt 0) { Write-Host ("FAIL  seo/" + $c.h + " " + ($e1 | ConvertTo-Json -Compress)); continue }

  $r2 = Send-GQL $mSet @{ m = @(
    @{ ownerId=$id; namespace="embrae"; key="seo_intro"; type="rich_text_field"; value=(RT $c.i) }
    @{ ownerId=$id; namespace="embrae"; key="seo_outro"; type="rich_text_field"; value=(RT $c.o) }
  ) }
  $e2 = @($r2.data.metafieldsSet.userErrors | Where-Object { $_ })
  if ($e2.Count -gt 0) { Write-Host ("FAIL  copy/" + $c.h + " " + ($e2 | ConvertTo-Json -Compress)); continue }

  Write-Host ("ok    " + $c.h)
  $done++
}
Write-Host ""
Write-Host "collections written: $done of $($copy.Count)"
