# Seeds the FAQ Center, the skin quiz (options + questions) and the routine entries.
#
# MOCK CONTENT. Shipping times, return windows and support hours are invented and must be
# replaced with the real policy before launch. Nothing here should be quoted to a customer.

. (Join-Path $PSScriptRoot "gql.ps1")

function RT([string]$text) {
  $kids = @()
  foreach ($p in ($text -split "\|\|")) {
    $esc = $p.Replace('\', '\\').Replace('"', '\"')
    $kids += '{"type":"paragraph","children":[{"type":"text","value":"' + $esc + '"}]}'
  }
  return '{"type":"root","children":[' + ($kids -join ",") + ']}'
}

$upsert = 'mutation up($handle: MetaobjectHandleInput!, $mo: MetaobjectUpsertInput!) { metaobjectUpsert(handle: $handle, metaobject: $mo) { metaobject { id handle } userErrors { field message } } }'

function Upsert-MO([string]$type, [string]$handle, $fields) {
  $r = Send-GQL $upsert @{ handle = @{ type = $type; handle = $handle }; mo = @{ capabilities = @{ publishable = @{ status = "ACTIVE" } }; fields = $fields } }
  if (@($r.data.metaobjectUpsert.userErrors).Count -gt 0) {
    Write-Host ("FAIL  $type/$handle " + ($r.data.metaobjectUpsert.userErrors | ConvertTo-Json -Compress)); return $null
  }
  Write-Host ("ok    $type/$handle")
  return $r.data.metaobjectUpsert.metaobject.id
}

# --- resolve GIDs -----------------------------------------------------------
$prodGid = @{}; $conGid = @{}
$r = Send-GQL 'query { products(first: 30) { nodes { id handle } } }'
$r.data.products.nodes | ForEach-Object { $prodGid[$_.handle] = $_.id }
$r = Send-GQL 'query { metaobjects(type: "skin_concern", first: 20) { nodes { id handle } } }'
$r.data.metaobjects.nodes | ForEach-Object { $conGid[$_.handle] = $_.id }
function PL([string[]]$h) { '["' + (($h | ForEach-Object { $prodGid[$_] }) -join '","') + '"]' }
function CL([string[]]$h) { '["' + (($h | ForEach-Object { $conGid[$_] }) -join '","') + '"]' }

# --- FAQs -------------------------------------------------------------------
$faqs = @(
  @{ h="what-is-embrae"; cat="General"; q="What is EMBRAE?"
     a="EMBRAE is a skincare range built for Indian skin and Indian weather - heat, humidity, monsoon, hard water and air conditioning.||We publish the percentage of every active on the carton, not just the ingredient name, because a name without a number tells you nothing about whether it will work." }
  @{ h="which-product-first"; cat="General"; q="Which product should I start with?"
     a="If you are unsure, take the skin quiz - six questions, about a minute, and it recommends based on your concern and your city rather than on what we would most like to sell.||If you would rather not, the Starter Duo is the honest default: a cleanser and a moisturizer. Almost nobody needs more than that on day one." }
  @{ h="how-long-results"; cat="General"; q="How long before I see results?"
     a="It depends entirely on the concern. Barrier repair and hydration show in ten to fourteen days. Breakouts take four to six weeks. Tone and pigmentation take eight to twelve, and marks fade rather than disappear.||Anyone promising faster than that is describing an exfoliant or a filter." }
  @{ h="are-products-tested"; cat="Safety"; q="Do you test on animals?"
     a="No. We do not test on animals and we do not sell in markets that require animal testing as a condition of entry." }
  @{ h="pregnancy-safe"; cat="Safety"; q="Can I use these while pregnant or breastfeeding?"
     a="Most of the range is generally considered fine, but this is not a question a skincare brand should answer for you.||Take the ingredient list to your doctor or obstetrician and follow what they say, not what a website says." }
  @{ h="patch-test"; cat="Safety"; q="Should I patch test?"
     a="Yes, especially if your skin reacts easily. Apply a small amount behind the ear or on the inner forearm and leave it for two days.||If you are introducing more than one new product, introduce them a fortnight apart. If something reacts, you want to know which thing it was." }
  @{ h="fragrance"; cat="Ingredient"; q="Do your products contain fragrance?"
     a="No added fragrance anywhere in the range, and no essential oils used as fragrance.||Fragrance is the most common trigger for reactive skin, and it exists to make a product pleasant rather than to make it work." }
  @{ h="why-percentages"; cat="Ingredient"; q="Why do you print percentages on the pack?"
     a="Because an ingredient name without a percentage is not information. Niacinamide at 0.1% and niacinamide at 4% are the same word and completely different products.||If a brand lists actives but not doses, that is usually a decision rather than an oversight." }
  @{ h="inci-disclosure"; cat="Ingredient"; q="Where can I see the full ingredients list?"
     a="The full INCI list is on every product page and on the carton. Nothing is held back as a proprietary blend." }
  @{ h="vitamin-c-form"; cat="Ingredient"; q="Why ethyl ascorbic acid instead of L-ascorbic acid?"
     a="L-ascorbic acid is the most studied form and also the least stable. In a bathroom in Chennai in May it oxidizes quickly, and oxidized vitamin C is a brown liquid that does nothing.||Ethyl ascorbic acid holds up in heat and humidity. We would rather ship a form that survives the journey than a form that wins an argument on paper." }
  @{ h="oily-skin"; cat="Skin type"; q="I have oily skin. Do I still need a moisturizer?"
     a="Yes, and skipping it is the most common reason oily skin gets oilier.||Strip the skin and it compensates by producing more oil. A light moisturizer breaks that cycle. Ours is fragrance-free and non-comedogenic." }
  @{ h="sensitive-skin"; cat="Skin type"; q="My skin is very sensitive. Where do I start?"
     a="Cleanser, moisturizer, sunscreen. Nothing else, for three weeks.||Once your skin has settled, add one product at a time with a fortnight between each. Sensitivity is usually a damaged barrier rather than an allergy, and barriers repair if you stop provoking them." }
  @{ h="combination-skin"; cat="Skin type"; q="I have combination skin. Should I use different products on different areas?"
     a="Usually not necessary. A well-balanced routine suits most combination skin without zone-mapping.||If your T-zone is genuinely much oilier, use the moisturizer more sparingly there rather than buying a second one." }
  @{ h="order-of-application"; cat="Usage"; q="What order should I apply things in?"
     a="Thinnest to thickest. Cleanser, then serum, then moisturizer, then sunscreen in the morning.||Wait about a minute between steps. Not because of chemistry, but because layering onto a wet face means most of it ends up on your hands." }
  @{ h="how-much-sunscreen"; cat="Usage"; q="How much sunscreen should I actually use?"
     a="Roughly two finger-lengths for the face and neck. Almost everyone uses a third of that, which is how an SPF 50 becomes an SPF 15 in practice.||Reapply every three to four hours if you are outdoors." }
  @{ h="sunscreen-indoors"; cat="Usage"; q="Do I need sunscreen if I am indoors all day?"
     a="If you sit near a window, yes. UVA passes through glass and it is the wavelength most associated with pigmentation and aging.||If you are in a windowless room all day, it matters far less. Be honest about which one you are." }
  @{ h="mixing-brands"; cat="Usage"; q="Can I use these with products from other brands?"
     a="Yes. Nothing in the range depends on the rest of the range.||The only real caution is stacking too many actives at once, regardless of who made them." }
  @{ h="shipping-time"; cat="Shipping"; q="How long will my order take?"
     a="MOCK DATA - not the real policy. Metros in two to four working days, rest of India in four to seven. Orders placed before 2pm on a working day are dispatched the same day.||Free shipping on orders over Rs1,499." }
  @{ h="cod-available"; cat="Shipping"; q="Do you offer cash on delivery?"
     a="MOCK DATA - not the real policy. Cash on delivery is available on orders up to Rs3,000, with a confirmation message sent before dispatch." }
  @{ h="international-shipping"; cat="Shipping"; q="Do you ship outside India?"
     a="MOCK DATA - not the real policy. Not at present. The formulas are built around Indian climate conditions, and we would rather get one market right first." }
  @{ h="return-policy"; cat="Returns"; q="What is your return policy?"
     a="MOCK DATA - not the real policy. Unopened products can be returned within 15 days of delivery for a full refund.||If a product reacted with your skin, write to us with a photograph and we will sort it out regardless of whether it is opened." }
  @{ h="damaged-order"; cat="Returns"; q="My order arrived damaged. What now?"
     a="MOCK DATA - not the real policy. Photograph the parcel and the product and contact us within 48 hours of delivery. We replace it, and you do not need to send the damaged one back." }
  @{ h="batch-freshness"; cat="Product"; q="How fresh is the product I receive?"
     a="Every carton carries a blend date and a best-before date, not just an expiry.||Actives lose potency well before they become unsafe, which is why the blend date is the more useful of the two numbers." }
  @{ h="storage"; cat="Product"; q="How should I store these?"
     a="Somewhere cool, dry and out of direct sunlight. A bathroom cabinet is fine; a windowsill is not.||The vitamin C serum in particular will last longer away from heat." }
  @{ h="travel-size"; cat="Product"; q="Do you make travel sizes?"
     a="The Barrier Moisturizer comes in a 15 ml cabin-bag size. More sizes will follow if there is demand for them." }
)

Write-Output "--- FAQs ---"
$faqIds = @{}
foreach ($f in $faqs) {
  $id = Upsert-MO "faq" $f.h @(@{ key="question"; value=$f.q }, @{ key="answer"; value=(RT $f.a) }, @{ key="category"; value=$f.cat })
  if ($id) { $faqIds[$f.h] = $id }
}

# --- quiz options -----------------------------------------------------------
$options = @(
  @{ h="q1-oily";        label="Shiny by lunchtime";                        con=@("breakouts") }
  @{ h="q1-dry";         label="Tight and flaky by midday";                 con=@("dryness") }
  @{ h="q1-combination"; label="Oily T-zone, dry cheeks";                   con=@("breakouts","dryness") }
  @{ h="q1-normal";      label="Fairly steady most days";                   con=@("dullness") }
  @{ h="q2-dullness";    label="It looks flat and gray";                    con=@("dullness"); w=2 }
  @{ h="q2-breakouts";   label="Spots and congestion";                      con=@("breakouts"); w=2 }
  @{ h="q2-pigment";     label="Dark marks that outstay the spot";          con=@("pigmentation"); w=2 }
  @{ h="q2-dryness";     label="Dryness and flaking";                       con=@("dryness"); w=2 }
  @{ h="q2-lines";       label="Fine lines settling in";                    con=@("fine-lines"); w=2 }
  @{ h="q2-redness";     label="Redness and stinging";                      con=@("sensitivity"); w=2 }
  @{ h="q3-none";        label="Nothing else really";                       con=@() }
  @{ h="q3-texture";     label="Rough texture";                             con=@("dullness","dryness") }
  @{ h="q3-pores";       label="Visible pores";                             con=@("breakouts") }
  @{ h="q3-tone";        label="Uneven tone";                               con=@("pigmentation","dullness") }
  @{ h="q4-very";        label="Stings when I try anything new";            con=@("sensitivity"); w=3 }
  @{ h="q4-somewhat";    label="Occasionally reacts";                       con=@("sensitivity") }
  @{ h="q4-not";         label="Tolerates most things";                     con=@() }
  @{ h="q5-humid";       label="Humid and coastal - Mumbai, Chennai, Kochi"; con=@("breakouts") }
  @{ h="q5-dry-north";   label="Dry winters, harsh summers - Delhi, Jaipur"; con=@("dryness","dullness") }
  @{ h="q5-monsoon";     label="Long monsoon - Bengaluru, Pune";            con=@("breakouts","sensitivity") }
  @{ h="q5-ac";          label="Air conditioning most of the day";          con=@("dryness") }
  @{ h="q6-new";         label="Completely new to this";                    con=@() }
  @{ h="q6-basic";       label="Cleanser and moisturizer only";             con=@() }
  @{ h="q6-experienced"; label="I already use actives";                     con=@("sensitivity") }
)

Write-Output ""
Write-Output "--- quiz options ---"
$optIds = @{}
foreach ($o in $options) {
  $f = @(@{ key="label"; value=$o.label }, @{ key="weight"; value=([string]$(if ($o.w) { $o.w } else { 1 })) })
  if (@($o.con).Count -gt 0) { $f += @{ key="concerns"; value=(CL $o.con) } }
  $id = Upsert-MO "quiz_option" $o.h $f
  if ($id) { $optIds[$o.h] = $id }
}

# --- quiz questions ---------------------------------------------------------
$questions = @(
  @{ h="q1-skin-type"; step="Step 1"; q="How does your skin usually feel by the afternoon?"
     help="Think about a normal working day, not a day at the beach."
     multi=$false; opts=@("q1-oily","q1-dry","q1-combination","q1-normal") }
  @{ h="q2-main-concern"; step="Step 2"; q="What bothers you most when you look in the mirror?"
     help="Pick the one you would fix first if you could only fix one."
     multi=$false; opts=@("q2-dullness","q2-breakouts","q2-pigment","q2-dryness","q2-lines","q2-redness") }
  @{ h="q3-secondary"; step="Step 3"; q="Anything else going on?"
     help="Optional. Choose as many as apply."
     multi=$true; opts=@("q3-none","q3-texture","q3-pores","q3-tone") }
  @{ h="q4-sensitivity"; step="Step 4"; q="How does your skin handle new products?"
     help="This changes what we recommend more than anything else you tell us."
     multi=$false; opts=@("q4-very","q4-somewhat","q4-not") }
  @{ h="q5-climate"; step="Step 5"; q="Where do you spend most of your day?"
     help="Climate matters as much as skin type. A routine that works in Delhi in January will not work in Mumbai in July."
     multi=$false; opts=@("q5-humid","q5-dry-north","q5-monsoon","q5-ac") }
  @{ h="q6-experience"; step="Step 6"; q="How much skincare do you already do?"
     help="There is no right answer. It only tells us how fast to go."
     multi=$false; opts=@("q6-new","q6-basic","q6-experienced") }
)

Write-Output ""
Write-Output "--- quiz questions ---"
foreach ($q in $questions) {
  $ids = @($q.opts | ForEach-Object { $optIds[$_] } | Where-Object { $_ })
  Upsert-MO "quiz_question" $q.h @(
    @{ key="question"; value=$q.q }, @{ key="step_label"; value=$q.step }, @{ key="help_text"; value=$q.help }
    @{ key="multi_select"; value=([string]$q.multi).ToLower() }
    @{ key="options"; value=('["' + ($ids -join '","') + '"]') }
  ) | Out-Null
}

# --- routines ---------------------------------------------------------------
$routines = @(
  @{ h="morning-dullness"; name="Morning routine for dull skin"; tod="Morning"; lvl="Beginner"; con="dullness"
     sum="Three steps, under two minutes, aimed at tone."
     steps="1. Cleanse with lukewarm water to take off the night.||2. Radiance Serum on slightly damp skin. Two or three drops is enough for the whole face.||3. Daily Defense Sunscreen, two finger-lengths. This step is what makes step 2 worth doing."
     prods=@("clarity-cleanser","radiance-serum","daily-defense-sunscreen") }
  @{ h="evening-dryness"; name="Evening routine for dry skin"; tod="Evening"; lvl="Barrier repair"; con="dryness"
     sum="Stop the stripping, then rebuild. Two weeks to a visible difference."
     steps="1. Cleanse once, gently, with lukewarm water. Not hot.||2. Barrier Moisturizer while the skin is still slightly damp - it seals the water in rather than sitting on dry skin.||3. Nothing else. No acids, no retinol, for at least a fortnight."
     prods=@("clarity-cleanser","barrier-moisturizer") }
  @{ h="evening-breakouts"; name="Evening routine for breakouts"; tod="Evening"; lvl="Intermediate"; con="breakouts"
     sum="Clear the pore without stripping the skin around it."
     steps="1. Clarity Gel Cleanser, forty seconds of contact. Do not scrub - the salicylic acid does the work.||2. Barrier Moisturizer, lightly. Skipping this is what causes rebound oil.||3. Give it four to six weeks before deciding it has not worked."
     prods=@("clarity-cleanser","barrier-moisturizer") }
  @{ h="morning-pigmentation"; name="Morning routine for pigmentation"; tod="Morning"; lvl="Intermediate"; con="pigmentation"
     sum="Sunscreen is the treatment here, not the aftercare."
     steps="1. Cleanse.||2. Radiance Serum for tone and to slow pigment transfer.||3. Daily Defense Sunscreen, generously, and reapply if you are outdoors. Without this step the serum is wasted effort."
     prods=@("clarity-cleanser","radiance-serum","daily-defense-sunscreen") }
  @{ h="evening-sensitivity"; name="Reset routine for sensitive skin"; tod="Morning and evening"; lvl="Sensitive skin"; con="sensitivity"
     sum="Three weeks of doing less, then reintroduce slowly."
     steps="1. Lukewarm water and the gentlest cleanse you can manage.||2. Barrier Moisturizer, morning and night.||3. Sunscreen in the morning only.||4. Nothing else for three weeks. Then add one product per fortnight, patch tested first."
     prods=@("barrier-moisturizer","daily-defense-sunscreen","starter-duo-set") }
  @{ h="evening-fine-lines"; name="Evening routine for fine lines"; tod="Evening"; lvl="Intermediate"; con="fine-lines"
     sum="Hydration softens the look immediately. Prevention does the rest."
     steps="1. Cleanse.||2. Radiance Serum on damp skin.||3. Barrier Moisturizer over the top to hold the water in - hyaluronic acid without a seal makes lines look worse, not better."
     prods=@("clarity-cleanser","radiance-serum","barrier-moisturizer") }
)

Write-Output ""
Write-Output "--- routines ---"
foreach ($rt in $routines) {
  $f = @(
    @{ key="name"; value=$rt.name }, @{ key="time_of_day"; value=$rt.tod }, @{ key="level"; value=$rt.lvl }
    @{ key="summary"; value=$rt.sum }, @{ key="steps"; value=(RT $rt.steps) }, @{ key="products"; value=(PL $rt.prods) }
    @{ key="seo_title"; value=($rt.name + " | EMBRAE") }
    @{ key="seo_description"; value=$rt.sum }
  )
  if ($conGid[$rt.con]) { $f += @{ key="concern"; value=$conGid[$rt.con] } }
  Upsert-MO "routine" $rt.h $f | Out-Null
}
