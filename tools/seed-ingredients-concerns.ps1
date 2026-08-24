# Seeds the 6 ingredient and 6 skin_concern metaobject entries, with images, SEO fields,
# product links and the two-way collection link that makes each one shoppable.
#
# MOCK CONTENT. The mechanisms described are broadly accurate, but no concentration,
# claim or figure here has been checked against an actual formulation. Replace before launch.

. (Join-Path $PSScriptRoot "upload-image.ps1")

function RT([string]$text) {
  $paras = $text -split "\|\|"
  $kids = @()
  foreach ($p in $paras) {
    $esc = $p.Replace('\', '\\').Replace('"', '\"')
    $kids += '{"type":"paragraph","children":[{"type":"text","value":"' + $esc + '"}]}'
  }
  return '{"type":"root","children":[' + ($kids -join ",") + ']}'
}

# --- resolve GIDs by handle -------------------------------------------------
$prodGid = @{}; $collGid = @{}
$r = Send-GQL 'query { products(first: 30) { nodes { id handle } } collections(first: 40) { nodes { id handle } } }'
$r.data.products.nodes    | ForEach-Object { $prodGid[$_.handle] = $_.id }
$r.data.collections.nodes | ForEach-Object { $collGid[$_.handle] = $_.id }

function PL([string[]]$handles) { '["' + (($handles | ForEach-Object { $prodGid[$_] }) -join '","') + '"]' }

# --- content ----------------------------------------------------------------
$ingredients = @(
  @{ h="niacinamide"; name="Niacinamide"; inci="Niacinamide (Vitamin B3)"; conc="2% to 4%"; kw="serum,skincare"
     benefit="Calms redness, steadies oil, and rebuilds a stressed barrier."
     how="Niacinamide is vitamin B3. It signals the skin to produce more of its own ceramides, which is why it settles redness and strengthens a barrier stripped by air conditioning or over-exfoliation.||It also slows the transfer of pigment to the surface, so marks left behind by a spot fade sooner."
     ev="Well studied at 2 to 5 percent. Above that the returns flatten and the risk of flushing rises, which is why we stay in the lower band rather than chasing a number on the carton."
     prods=@("barrier-reset-cleanser","urban-defense-serum","daily-shield-spf50")
     seoT="Niacinamide in Skincare - Benefits, Percentage and Use | EMBRAE"
     seoD="What niacinamide actually does, the percentage that works, and which EMBRAE formulas use it. Written for Indian skin and Indian weather." }
  @{ h="vitamin-c"; name="Vitamin C"; inci="3-O-Ethyl Ascorbic Acid"; conc="10%"; kw="serum,orange"
     benefit="Evens tone and fades the marks a spot leaves behind."
     how="Vitamin C is an antioxidant that interrupts the pigment-making step in skin. Over weeks that shows up as a more even tone and lighter post-acne marks.||We use ethyl ascorbic acid rather than pure L-ascorbic acid because it survives Indian heat and humidity in a bathroom cabinet instead of oxidizing into a brown, useless liquid."
     ev="Ten percent is the point where the evidence is solid and the formula stays stable. Higher percentages exist and are mostly marketing."
     prods=@("urban-defense-serum")
     seoT="Vitamin C Serum for Indian Skin - 10% Ethyl Ascorbic Acid | EMBRAE"
     seoD="Why we use stabilised 10% ethyl ascorbic acid instead of L-ascorbic acid, what it fixes, and how long it takes to show." }
  @{ h="hyaluronic-acid"; name="Hyaluronic acid"; inci="Sodium Hyaluronate"; conc="1%"; kw="water,droplet"
     benefit="Holds water inside the skin rather than on top of it."
     how="Hyaluronic acid binds many times its own weight in water. Low molecular weight fragments sit deeper than the surface, so the hydration lasts past the first hour.||It is a humectant, not a moisturizer. On a dry day it needs something above it to seal, or it will pull water out of the skin instead of into it - which is the single most common way people use it wrong."
     ev="Established and uncontroversial. The variable that matters is molecular weight, not percentage."
     prods=@("urban-defense-serum","climate-adapt-moisturizer")
     seoT="Hyaluronic Acid - How to Use It Without Drying Your Skin | EMBRAE"
     seoD="Hyaluronic acid hydrates only if you seal it. What it does, why molecular weight matters, and the mistake that makes skin drier." }
  @{ h="salicylic-acid"; name="Salicylic acid"; inci="Salicylic Acid"; conc="0.5%, buffered"; kw="skincare,bathroom"
     benefit="Clears the inside of a pore, not just the surface."
     how="Salicylic acid is oil soluble, so unlike glycolic or lactic acid it can travel into the pore itself and loosen the plug of oil and dead skin sitting there.||We buffer it and keep it at half a percent in a cleanser, because something that rinses off in forty seconds does not need to be aggressive to work."
     ev="Long-established for congestion and blackheads. The failure mode is overuse, not weakness."
     prods=@("barrier-reset-cleanser")
     seoT="Salicylic Acid for Breakouts - How BHA Works | EMBRAE"
     seoD="Salicylic acid is oil soluble, so it works inside the pore. Why 0.5% in a cleanser beats a stronger leave-on for most people." }
  @{ h="squalane"; name="Squalane"; inci="Squalane (olive derived)"; conc="5%"; kw="oil,olive"
     benefit="Restores the natural oils skin loses to hard water and cleansing."
     how="Squalane is a stable, plant-derived version of squalene, a lipid skin already makes and makes less of with age and with harsh cleansing.||It sinks in rather than sitting on top, which is why it suits humid months when a heavier oil would feel like a film."
     ev="Non-comedogenic and very well tolerated, including on reactive skin."
     prods=@("climate-adapt-moisturizer","travel-essentials-pouch")
     seoT="Squalane - A Light Oil That Suits Humid Weather | EMBRAE"
     seoD="Plant-derived squalane restores the lipids skin loses to hard water and cleansing, without the heaviness of a facial oil." }
  @{ h="ceramides"; name="Ceramides"; inci="Ceramide NP, Ceramide AP, Ceramide EOP"; conc="Barrier-identical blend"; kw="cream,texture"
     benefit="The mortar between skin cells. Replaced when it has been stripped."
     how="If skin cells are bricks, ceramides are the mortar. Strip them - with hot water, harsh surfactants, or too many actives at once - and water escapes while irritants get in.||We use three types together in the ratio skin uses them, because a single ceramide on an ingredients list is a marketing decision rather than a formulation one."
     ev="The strongest evidence in barrier repair. This is the least speculative thing in the range."
     prods=@("climate-adapt-moisturizer","travel-essentials-pouch")
     seoT="Ceramides and Barrier Repair - What They Actually Do | EMBRAE"
     seoD="Ceramides are the mortar between skin cells. Why three types in the right ratio matters more than the word appearing on a label." }
)

$concerns = @(
  @{ h="dullness"; name="Dullness"; kw="face,portrait"
     short="Skin that looks flat and gray rather than lit."
     sym="Makeup sits rather than sinks. Photographs look washed out even when the light is good. There is no single blemish to point at, and that is exactly what makes it hard to describe to anyone."
     cause="Usually three things at once: a build-up of dead cells the skin has not shed, uneven pigment from past sun exposure, and dehydration flattening the way light bounces off the surface.||Delhi and Mumbai air adds a fourth - particulate matter that settles on skin through the day."
     rout="Cleanse properly at night so the day comes off. Vitamin C in the morning for tone. Sunscreen every single day, because unprotected sun undoes the vitamin C faster than it works.||Give it eight weeks. Tone changes slowly and anything promising faster is describing a scrub, not a result."
     ings=@("vitamin-c","niacinamide"); prods=@("urban-defense-serum","barrier-reset-cleanser","am-defense-routine")
     seoT="Dull Skin - Causes and What Actually Fixes It | EMBRAE"
     seoD="Dullness is rarely one problem. Build-up, uneven pigment and dehydration together. What to use, in what order, and how long it takes." }
  @{ h="dryness"; name="Dryness"; kw="cream,winter"
     short="Tight, flaky, and rough to the touch."
     sym="Skin feels tight within minutes of washing. Flaking around the nose and mouth. Foundation clings to patches. In winter it can sting for no obvious reason."
     cause="More often a barrier problem than a water problem. Hot showers, hard water, air conditioning running ten hours a day, and too many actives layered at once all strip the lipids that hold water in.||Adding more water on top of a broken barrier does nothing. The barrier has to be rebuilt first."
     rout="Stop the stripping first - lukewarm water, a gentler cleanser, and pause the acids for two weeks. Then ceramides and squalane twice a day.||Most people see a real difference in ten to fourteen days, which is faster than almost anything else in skincare."
     ings=@("ceramides","squalane","hyaluronic-acid"); prods=@("climate-adapt-moisturizer","barrier-support-duo","travel-essentials-pouch")
     seoT="Dry Skin - Barrier Repair, Not More Moisturizer | EMBRAE"
     seoD="Tight, flaky skin is usually a damaged barrier rather than a lack of water. What strips it, and the routine that rebuilds it in two weeks." }
  @{ h="breakouts"; name="Breakouts"; kw="face,skin"
     short="Congestion, closed bumps, and inflamed spots."
     sym="Small bumps under the surface that never quite come to a head, blackheads across the nose and chin, and painful spots that arrive in the same few places every time."
     cause="Oil, dead skin and bacteria blocking a pore, then inflammation. Humidity and sweat make it worse, which is why the monsoon is the worst season for it in most of India.||Over-washing makes it worse too - stripped skin produces more oil, not less."
     rout="A salicylic acid cleanser rather than a scrub. Niacinamide to settle the inflammation. A light moisturizer, because skipping it is what causes the rebound oil.||Four to six weeks. Stopping at week two because nothing has changed is the most common reason people conclude a routine did not work."
     ings=@("salicylic-acid","niacinamide"); prods=@("barrier-reset-cleanser","daily-shield-spf50")
     seoT="Breakouts and Congestion - What to Use and What to Stop | EMBRAE"
     seoD="Why over-washing makes breakouts worse, how salicylic acid works inside the pore, and a routine that takes four to six weeks." }
  @{ h="pigmentation"; name="Pigmentation"; kw="face,sun"
     short="Dark marks that outstay the spot, and patches that deepen in sunlight."
     sym="Brown marks where a spot used to be, months after it healed. Patches across the cheeks or upper lip that darken every summer and never fully fade."
     cause="Pigment-producing cells over-reacting - to inflammation, to sun, or to both. Indian skin produces more melanin, so it marks more readily and holds those marks longer. That is not a flaw, it is a different response that needs a different approach.||Sun exposure is the accelerant for all of it."
     rout="Sunscreen is the treatment, not the aftercare. Without it nothing else works. Vitamin C and niacinamide together to slow pigment transfer.||Twelve weeks minimum, and marks fade rather than vanish. Anyone promising otherwise is selling something."
     ings=@("vitamin-c","niacinamide"); prods=@("daily-shield-spf50","urban-defense-serum","am-defense-routine")
     seoT="Pigmentation on Indian Skin - Marks, Melasma and SPF | EMBRAE"
     seoD="Indian skin marks more readily and holds marks longer. Why sunscreen is the treatment rather than the aftercare, and a twelve-week plan." }
  @{ h="fine-lines"; name="Fine lines"; kw="face,eye"
     short="Early texture change around the eyes and mouth."
     sym="Lines visible when the face is still, not only when smiling. Skin around the eyes looks crepey in the morning. Foundation settles into creases it did not use to find."
     cause="Collagen production slows from the mid-twenties. Sun exposure accelerates it more than age does - which is why the skin on your forearm and the skin on your hip age at different rates.||Dehydration makes existing lines far more visible without creating new ones."
     rout="Daily sunscreen does more here than any active. Hydration to soften the appearance immediately, then barrier support to hold it.||This one is prevention-weighted. What you do in your thirties shows in your fifties."
     ings=@("hyaluronic-acid","ceramides","niacinamide"); prods=@("climate-adapt-moisturizer","daily-shield-spf50","pm-recovery-routine")
     seoT="Fine Lines - Prevention Beats Correction | EMBRAE"
     seoD="Sun does more aging than time. Why daily SPF outperforms every active for fine lines, and what hydration changes immediately." }
  @{ h="sensitivity"; name="Sensitivity"; kw="face,calm"
     short="Skin that stings, flushes, or reacts to anything new."
     sym="Burning or tingling within a minute of applying something. Redness that takes hours to settle. A reaction to a product that was fine last month."
     cause="Almost always a compromised barrier rather than a true allergy. Once the barrier is thin, ingredients that were previously harmless can reach nerve endings they should never have got near.||Fragrance, essential oils, and stacking three actives at once are the usual causes."
     rout="Strip the routine back to cleanser, moisturizer, sunscreen. Nothing else, for three weeks. Fragrance-free throughout.||Then reintroduce one product at a time, a fortnight apart, and patch test behind the ear for two days first. Slow is the only method that works here."
     ings=@("ceramides","squalane"); prods=@("climate-adapt-moisturizer","barrier-support-duo","travel-essentials-pouch")
     seoT="Sensitive Skin - Why It Started and How to Calm It | EMBRAE"
     seoD="Sensitivity is usually a damaged barrier, not an allergy. A three-week reset, and how to reintroduce products without setting it off again." }
)

# --- upload images ----------------------------------------------------------
$img = @{}
foreach ($set in @(@{ items=$ingredients; pre="ingredient" }, @{ items=$concerns; pre="concern" })) {
  foreach ($i in $set.items) {
    $fn = "embrae-" + $set.pre + "-" + $i.h + ".jpg"
    try {
      $img[$i.h] = Add-EmbraeFile -Source ("https://loremflickr.com/1280/1280/" + $i.kw) -Filename $fn -Alt ($i.name + " - EMBRAE " + $set.pre + " library")
      Write-Output ("img   " + $fn)
    } catch { Write-Output ("IMGFAIL " + $fn + " " + $_.Exception.Message) }
  }
}

# --- upsert ingredients -----------------------------------------------------
$upsert = 'mutation up($handle: MetaobjectHandleInput!, $mo: MetaobjectUpsertInput!) { metaobjectUpsert(handle: $handle, metaobject: $mo) { metaobject { id handle } userErrors { field message } } }'
$ingGid = @{}
foreach ($i in $ingredients) {
  $f = @(
    @{ key="name"; value=$i.name }, @{ key="inci_name"; value=$i.inci }, @{ key="concentration"; value=$i.conc }
    @{ key="benefit"; value=$i.benefit }, @{ key="how_it_works"; value=(RT $i.how) }, @{ key="evidence"; value=(RT $i.ev) }
    @{ key="related_products"; value=(PL $i.prods) }, @{ key="seo_title"; value=$i.seoT }, @{ key="seo_description"; value=$i.seoD }
  )
  if ($collGid[$i.h]) { $f += @{ key="collection"; value=$collGid[$i.h] } }
  if ($img[$i.h])     { $f += @{ key="image"; value=$img[$i.h] } }
  $r = Send-GQL $upsert @{ handle=@{ type="ingredient"; handle=$i.h }; mo=@{ capabilities=@{ publishable=@{ status="ACTIVE" } }; fields=$f } }
  if (@($r.data.metaobjectUpsert.userErrors).Count -gt 0) { Write-Output ("FAIL  ing/" + $i.h + " " + ($r.data.metaobjectUpsert.userErrors | ConvertTo-Json -Compress)) }
  else { $ingGid[$i.h] = $r.data.metaobjectUpsert.metaobject.id; Write-Output ("ok    ingredient/" + $i.h) }
}

# --- upsert concerns --------------------------------------------------------
$conGid = @{}
foreach ($c in $concerns) {
  $f = @(
    @{ key="name"; value=$c.name }, @{ key="short_description"; value=$c.short }
    @{ key="symptoms"; value=(RT $c.sym) }, @{ key="causes"; value=(RT $c.cause) }, @{ key="routine"; value=(RT $c.rout) }
    @{ key="key_ingredients"; value=('["' + (($c.ings | ForEach-Object { $ingGid[$_] }) -join '","') + '"]') }
    @{ key="recommended_products"; value=(PL $c.prods) }
    @{ key="seo_title"; value=$c.seoT }, @{ key="seo_description"; value=$c.seoD }
  )
  if ($collGid[$c.h]) { $f += @{ key="collection"; value=$collGid[$c.h] } }
  if ($img[$c.h])     { $f += @{ key="image"; value=$img[$c.h] } }
  $r = Send-GQL $upsert @{ handle=@{ type="skin_concern"; handle=$c.h }; mo=@{ capabilities=@{ publishable=@{ status="ACTIVE" } }; fields=$f } }
  if (@($r.data.metaobjectUpsert.userErrors).Count -gt 0) { Write-Output ("FAIL  con/" + $c.h + " " + ($r.data.metaobjectUpsert.userErrors | ConvertTo-Json -Compress)) }
  else { $conGid[$c.h] = $r.data.metaobjectUpsert.metaobject.id; Write-Output ("ok    concern/" + $c.h) }
}

# --- back-link: collection.embrae.concern -> the concern entry ---------------
$sets = @()
foreach ($c in $concerns) { if ($collGid[$c.h] -and $conGid[$c.h]) { $sets += @{ ownerId=$collGid[$c.h]; namespace="embrae"; key="concern"; type="metaobject_reference"; value=$conGid[$c.h] } } }
if ($sets.Count -gt 0) {
  $r = Send-GQL 'mutation set($m: [MetafieldsSetInput!]!) { metafieldsSet(metafields: $m) { metafields { id } userErrors { field message } } }' @{ m = $sets }
  if (@($r.data.metafieldsSet.userErrors).Count -gt 0) { Write-Output ("FAIL backlink " + ($r.data.metafieldsSet.userErrors | ConvertTo-Json -Compress)) }
  else { Write-Output ("ok    collection -> concern backlinks: " + @($r.data.metafieldsSet.metafields).Count) }
}
