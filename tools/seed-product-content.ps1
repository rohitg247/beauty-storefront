# Fills the 9 EMBRAE metafields on every product, plus product-level SEO title and
# description. This is what makes the PDP grow the modules the architecture diagram shows:
# why it exists, key benefits, ingredient story, how it works, how to use, who it is for,
# product FAQs and a results timeline.
#
# MOCK CONTENT. No claim, percentage or timeline here has been checked against a real
# formulation. Replace before launch.

. (Join-Path $PSScriptRoot "gql.ps1")

function RT([string]$text) {
  $kids = @()
  foreach ($p in ($text -split "\|\|")) {
    $esc = $p.Replace('\', '\\').Replace('"', '\"')
    $kids += '{"type":"paragraph","children":[{"type":"text","value":"' + $esc + '"}]}'
  }
  return '{"type":"root","children":[' + ($kids -join ",") + ']}'
}
function BulletRT([string[]]$items) {
  $lis = @()
  foreach ($i in $items) {
    $esc = $i.Replace('\', '\\').Replace('"', '\"')
    $lis += '{"type":"list-item","children":[{"type":"text","value":"' + $esc + '"}]}'
  }
  return '{"type":"root","children":[{"type":"list","listType":"unordered","children":[' + ($lis -join ",") + ']}]}'
}

# --- resolve GIDs -----------------------------------------------------------
$prod = @{}; $ing = @{}; $con = @{}; $faq = @{}
$r = Send-GQL 'query { products(first: 30) { nodes { id handle } } }'
$r.data.products.nodes | ForEach-Object { $prod[$_.handle] = $_.id }
foreach ($pair in @(@{t="ingredient";m=$ing}, @{t="skin_concern";m=$con}, @{t="faq";m=$faq})) {
  $r = Send-GQL ('query { metaobjects(type: "' + $pair.t + '", first: 100) { nodes { id handle } } }')
  $r.data.metaobjects.nodes | ForEach-Object { $pair.m[$_.handle] = $_.id }
}
function Refs($map, [string[]]$handles) {
  $ids = @($handles | ForEach-Object { $map[$_] } | Where-Object { $_ })
  if ($ids.Count -eq 0) { return $null }
  return '["' + ($ids -join '","') + '"]'
}
function ToStrList([string[]]$vals) { '["' + (($vals | ForEach-Object { $_.Replace('"','\"') }) -join '","') + '"]' }

# --- content ----------------------------------------------------------------
$content = @(
  @{ h="clarity-cleanser"
     why="Most cleansers solve one problem and cause another. They take the sunscreen off and take the barrier with it, so skin feels squeaky for ten minutes and tight for the rest of the evening.||This one is built to remove a full day - sunscreen, sweat, and whatever Indian city air has settled on your face - and stop there."
     ben=@("Removes sunscreen and grime in one wash, no double cleanse needed","Buffered salicylic acid keeps pores clear without stripping","Niacinamide settles the flush that acids usually cause","pH 5.5 and sulfate free, so the barrier stays intact")
     how="Salicylic acid is oil soluble, so it travels into the pore rather than working only on the surface. At 0.5% in a rinse-off format it has enough contact time to loosen a plug of oil and dead skin without the irritation a leave-on would cause.||Niacinamide runs alongside it to keep inflammation down, which is why this does not leave the tightness most acid cleansers do."
     use="Morning and night, on damp skin. Massage for about forty seconds - the acid needs contact time, not pressure.||Rinse with lukewarm water. Hot water undoes most of the point of a gentle cleanser."
     ings=@("salicylic-acid","niacinamide"); cons=@("breakouts","dullness")
     skin=@("Oily","Combination","Normal","Congestion-prone")
     faqs=@("order-of-application","oily-skin","patch-test","batch-freshness")
     time="Congestion softens in 2 to 3 weeks. Breakouts take 4 to 6."
     seoT="Clarity Gel Cleanser - Salicylic Acid Face Wash 100 ml | EMBRAE"
     seoD="A low-foam gel cleanser with 0.5% buffered salicylic acid and 2% niacinamide. Removes sunscreen and city grime without stripping the barrier." }

  @{ h="radiance-serum"
     why="Vitamin C is the most oversold ingredient in skincare and one of the few that genuinely earns its place - if the form survives the climate it is sold into.||Most L-ascorbic acid serums oxidize into a brown, useless liquid within weeks of arriving in an Indian bathroom. This one is built around a form that does not."
     ben=@("Evens tone and fades post-acne marks over 8 to 12 weeks","10% ethyl ascorbic acid, stable in heat and humidity","Layers under sunscreen without pilling","Niacinamide alongside it, which the old advice said was impossible")
     how="Vitamin C interrupts the step where skin makes pigment. Less new pigment, and the marks already there fade sooner.||We use 3-O-ethyl ascorbic acid rather than L-ascorbic acid because it stays stable at Indian room temperature. A less-studied form that still works in month three beats the best-studied form that died in week two."
     use="Mornings, on clean and slightly damp skin. Two or three drops for the whole face.||Follow with sunscreen, always. Without it the serum is working against something it cannot beat."
     ings=@("vitamin-c","niacinamide","hyaluronic-acid"); cons=@("dullness","pigmentation","fine-lines")
     skin=@("All skin types","Dull","Uneven tone","Pigmentation-prone")
     faqs=@("vitamin-c-form","how-long-results","storage","order-of-application")
     time="Brightness at 4 weeks. Marks fade over 8 to 12."
     seoT="Radiance Serum - 10% Vitamin C for Indian Skin 30 ml | EMBRAE"
     seoD="Stabilised 10% ethyl ascorbic acid with niacinamide. Fades post-acne marks and evens tone without oxidizing in Indian heat." }

  @{ h="barrier-moisturizer"
     why="Almost every skin problem people bring us turns out to be a barrier problem wearing a different name. Dryness, sensitivity, rebound oiliness, stinging - all of it traces back to a barrier that has been stripped.||This exists to rebuild that, and to be light enough that people actually use it in July."
     ben=@("Visible barrier repair in 10 to 14 days","Three ceramide types in the ratio skin uses them","Squalane restores lipids without an oily film","Fragrance free, so it suits reactive skin")
     how="Ceramides are the mortar between skin cells. Strip them and water escapes while irritants get in.||We use Ceramide NP, AP and EOP together rather than one, because a single ceramide on a label is a marketing choice. Squalane and hyaluronic acid handle the lipid and water sides of the same problem."
     use="Morning and night, on slightly damp skin so it seals water in rather than sitting on top.||If your skin is currently reacting to things, use this and nothing else for two weeks before reintroducing anything."
     ings=@("ceramides","squalane","hyaluronic-acid"); cons=@("dryness","sensitivity","fine-lines")
     skin=@("Dry","Sensitive","Compromised barrier","All skin types")
     faqs=@("sensitive-skin","oily-skin","order-of-application","fragrance")
     time="Tightness eases within days. Barrier repair in 10 to 14."
     seoT="Barrier Moisturizer - Ceramide and Squalane Cream 50 ml | EMBRAE"
     seoD="Fragrance-free ceramide and squalane cream for barriers stripped by air conditioning, hard water and actives. Visible repair in two weeks." }

  @{ h="daily-defense-sunscreen"
     why="Sunscreen is the single highest-return step in any routine and the one most people skip, because most sunscreens sting, leave a gray cast, or pill under makeup.||The formulation brief here was simple: make one people will actually wear every day. Nothing else about a sunscreen matters if it stays in the drawer."
     ben=@("Broad spectrum SPF 50 PA++++","Non-nano zinc oxide, no white cast on Indian skin tones","Niacinamide to keep it from stinging","Sits under makeup without pilling")
     how="Zinc oxide is a mineral filter - it works from the moment it is on, and it covers UVA and UVB in one ingredient.||Non-nano particles in a fluid base avoid the chalky finish mineral sunscreens are known for. Niacinamide handles the irritation that pushes people off sunscreen entirely."
     use="Every morning, as the last step. Roughly two finger-lengths for face and neck - most people use a third of that, which turns an SPF 50 into an SPF 15.||Reapply every three to four hours outdoors."
     ings=@("zinc-oxide","niacinamide"); cons=@("pigmentation","fine-lines","sensitivity")
     skin=@("All skin types","Sensitive","Pigmentation-prone","Daily use")
     faqs=@("how-much-sunscreen","sunscreen-indoors","pregnancy-safe","order-of-application")
     time="Protection is immediate. Pigmentation benefit shows over months."
     seoT="Daily Defense Sunscreen SPF 50 PA++++ No White Cast 50 ml | EMBRAE"
     seoD="Mineral-led broad spectrum SPF 50 PA++++ with non-nano zinc oxide and niacinamide. No white cast, no sting, wears under makeup." }

  @{ h="starter-duo-set"
     why="Most people starting a routine buy six things and abandon four. The two that actually matter on day one are a cleanser that does not strip and a moisturizer that rebuilds.||This is those two, and deliberately nothing else."
     ben=@("The two steps a barrier needs before anything else","Cheaper than buying the pair separately","No actives to react to while your skin settles","A complete routine on its own, not a starter for a bigger one")
     how="Cleansing removes the day without damaging the barrier. The moisturizer puts back the ceramides and lipids that cleansing, hard water and air conditioning take out.||Get these two right and most people find they need far less than they expected."
     use="Cleanser morning and night, moisturizer after each. That is the whole routine.||Add sunscreen in the morning when you are ready for a third step."
     ings=@("salicylic-acid","ceramides","squalane"); cons=@("dryness","sensitivity")
     skin=@("Beginners","Sensitive","Dry","All skin types")
     faqs=@("which-product-first","sensitive-skin","how-long-results","return-policy")
     time="Barrier improvement in 10 to 14 days."
     seoT="The Starter Duo - Cleanser and Moisturizer Set | EMBRAE"
     seoD="The two steps that matter on day one: Clarity Gel Cleanser and Barrier Moisturizer. A complete routine, not a starter for a bigger one." }

  @{ h="morning-ritual-set"
     why="The daylight routine is where tone and pigmentation are won or lost, and the order matters more than most people realize.||Cleanse, brighten, protect - in that sequence, every morning. This is those three steps in one box."
     ben=@("A full morning routine in the order it is applied","Vitamin C and SPF work together, and neither works alone","Saves against buying the three separately","Enough for roughly two months")
     how="Vitamin C reduces new pigment. Sunscreen stops the sun making more. Doing one without the other is the most common reason a brightening routine disappoints.||The cleanser prepares the skin without stripping it, so the serum absorbs instead of sitting."
     use="Cleanse. Serum on damp skin, two or three drops. Sunscreen last, two finger-lengths.||About ninety seconds start to finish once you are used to it."
     ings=@("vitamin-c","niacinamide","zinc-oxide"); cons=@("dullness","pigmentation")
     skin=@("All skin types","Dull","Uneven tone","Pigmentation-prone")
     faqs=@("order-of-application","how-much-sunscreen","how-long-results","which-product-first")
     time="Brightness at 4 weeks, tone over 8 to 12."
     seoT="The Morning Ritual - Cleanser, Vitamin C and SPF 50 Set | EMBRAE"
     seoD="Cleanse, brighten, protect. A full morning routine where the vitamin C and the sunscreen do the work together rather than separately." }

  @{ h="evening-ritual-set"
     why="Skin repairs overnight, and the evening routine is what it has to work with.||Cleanse, treat, seal - three steps that take under two minutes and do more than any single product can."
     ben=@("A complete evening routine in application order","Treats and repairs in the same session","Saves against buying the three separately","Suits most skin types without adjustment")
     how="The cleanser takes off the day. The serum works on tone while skin is in its repair window. The moisturizer seals both in and rebuilds the barrier overnight.||Hyaluronic acid without something over it makes skin drier, which is why the moisturizer is not optional here."
     use="Cleanse, then serum on damp skin, then moisturizer while the serum is still tacky.||Every night. Consistency matters more than any individual step."
     ings=@("vitamin-c","ceramides","hyaluronic-acid"); cons=@("dullness","fine-lines")
     skin=@("All skin types","Dry","Dull","Fine lines")
     faqs=@("order-of-application","how-long-results","mixing-brands","storage")
     time="Texture in 2 weeks, tone over 8 to 12."
     seoT="The Evening Ritual - Night Routine Set | EMBRAE"
     seoD="Cleanse, treat, seal. Three steps for the window when skin actually repairs, in the order they should be applied." }

  @{ h="complete-routine-set"
     why="Everything we make, morning and night, with nothing left to work out.||Bought separately these four require a decision about order, timing and combination. Bought together they do not."
     ben=@("All four steps, morning and evening covered","The largest saving in the range","No decisions about what goes with what","Roughly two months of a full routine")
     how="Morning is cleanse, vitamin C, sunscreen - tone and protection. Evening is cleanse, serum, moisturizer - repair.||The same cleanser serves both. That is deliberate, not a shortcut."
     use="Morning: cleanser, Radiance Serum, sunscreen.||Evening: cleanser, Radiance Serum, Barrier Moisturizer.||If your skin is reactive, start with the cleanser and moisturizer only and add the serum in week three."
     ings=@("vitamin-c","niacinamide","ceramides","zinc-oxide"); cons=@("dullness","dryness","pigmentation")
     skin=@("All skin types","Complete routine","Gifting")
     faqs=@("which-product-first","order-of-application","how-long-results","return-policy")
     time="Barrier in 2 weeks, breakouts in 4 to 6, tone in 8 to 12."
     seoT="The Complete Routine - Full Four-Step Skincare Set | EMBRAE"
     seoD="All four EMBRAE products for morning and night in one box. Cleanser, serum, moisturizer and SPF 50, with nothing left to work out." }

  @{ h="travel-barrier-moisturizer"
     why="The 50 ml jar does not clear cabin-bag rules and does not survive being packed loose.||This is the same formula in a size that travels, and the one we add to qualifying orders so people can try it before committing to the full size."
     ben=@("Identical formula to the 50 ml","Cabin-bag compliant at 15 ml","Enough for roughly three weeks","Useful as a patch-test size for reactive skin")
     how="Ceramide NP, AP and EOP with squalane and hyaluronic acid - the same barrier repair as the full size, in a smaller jar.||Nothing is reformulated or diluted for the travel size."
     use="Morning and night, on slightly damp skin. A pea-sized amount covers the face.||If you are patch testing, use it behind the ear for two days first."
     ings=@("ceramides","squalane"); cons=@("dryness","sensitivity")
     skin=@("Dry","Sensitive","Travel","Trial size")
     faqs=@("travel-size","sensitive-skin","patch-test","storage")
     time="Same as the full size - barrier repair in 10 to 14 days."
     seoT="Barrier Moisturizer Travel Size 15 ml | EMBRAE"
     seoD="The 15 ml cabin-bag size of the ceramide and squalane Barrier Moisturizer. Same formula, smaller jar." }
)

# --- write ------------------------------------------------------------------
$mfSet = 'mutation set($m: [MetafieldsSetInput!]!) { metafieldsSet(metafields: $m) { metafields { id } userErrors { field message } } }'
$pUpd  = 'mutation upd($p: ProductUpdateInput!) { productUpdate(product: $p) { product { id } userErrors { field message } } }'

foreach ($c in $content) {
  $id = $prod[$c.h]
  if (-not $id) { Write-Host ("SKIP  " + $c.h + " - product not found"); continue }

  $mf = @(
    @{ ownerId=$id; namespace="embrae"; key="why_exists";       type="rich_text_field";              value=(RT $c.why) }
    @{ ownerId=$id; namespace="embrae"; key="key_benefits";     type="rich_text_field";              value=(BulletRT $c.ben) }
    @{ ownerId=$id; namespace="embrae"; key="how_it_works";     type="rich_text_field";              value=(RT $c.how) }
    @{ ownerId=$id; namespace="embrae"; key="how_to_use";       type="rich_text_field";              value=(RT $c.use) }
    @{ ownerId=$id; namespace="embrae"; key="skin_types";       type="list.single_line_text_field";  value=(ToStrList $c.skin) }
    @{ ownerId=$id; namespace="embrae"; key="results_timeline"; type="single_line_text_field";       value=$c.time }
  )
  $iv = Refs $ing $c.ings; if ($iv) { $mf += @{ ownerId=$id; namespace="embrae"; key="ingredients"; type="list.metaobject_reference"; value=$iv } }
  $cv = Refs $con $c.cons; if ($cv) { $mf += @{ ownerId=$id; namespace="embrae"; key="concerns";    type="list.metaobject_reference"; value=$cv } }
  $fv = Refs $faq $c.faqs; if ($fv) { $mf += @{ ownerId=$id; namespace="embrae"; key="faqs";        type="list.metaobject_reference"; value=$fv } }

  $r = Send-GQL $mfSet @{ m = $mf }
  if (@($r.data.metafieldsSet.userErrors).Count -gt 0) { Write-Host ("FAIL  mf/" + $c.h + " " + ($r.data.metafieldsSet.userErrors | ConvertTo-Json -Compress)) }
  else { Write-Host ("ok    metafields/" + $c.h + " (" + @($r.data.metafieldsSet.metafields).Count + ")") }

  $r2 = Send-GQL $pUpd @{ p = @{ id = $id; seo = @{ title = $c.seoT; description = $c.seoD } } }
  if (-not $r2.data.productUpdate -or @($r2.data.productUpdate.userErrors | Where-Object { $_ }).Count -gt 0) { Write-Host ("FAIL  seo/" + $c.h + " " + ($r2.data.productUpdate.userErrors | ConvertTo-Json -Compress)) }
  else { Write-Host ("ok    seo/" + $c.h) }
}
