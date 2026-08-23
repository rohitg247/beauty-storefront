# Seeds articles across the four Education Hub blogs, each with a header image, summary,
# tags, author and SEO. Internal links point at the concern, ingredient and collection
# pages - that link graph is what makes the Education Hub rank rather than just exist.
#
# MOCK CONTENT. Author names are invented. Replace before launch.

. (Join-Path $PSScriptRoot "gql.ps1")

$blogs = @{}
$r = Send-GQL 'query { blogs(first: 20) { nodes { id handle } } }'
$r.data.blogs.nodes | ForEach-Object { $blogs[$_.handle] = $_.id }

function Img([string]$text) { "https://placehold.co/1600x900/034638/F3CFB3.png?text=" + ($text -replace ' ', '+') }

$articles = @(
  # --- skin-school ---
  @{ blog="skin-school"; h="what-is-the-skin-barrier"; title="What the skin barrier actually is, and how you broke it"
     author="Dr Ananya Rao"; tags=@("basics","barrier","dryness")
     sum="The barrier is not a metaphor. It is a real, physical layer, and almost every skin problem people describe is a symptom of it being damaged."
     body="<p>If skin cells are bricks, ceramides are the mortar. That is not a simplification for a website - it is close to the literal structure of the outermost layer of your skin.</p><p>When that mortar is intact, water stays in and irritants stay out. When it is stripped, the opposite happens on both counts. Water escapes, so skin feels tight and looks dull. Irritants reach nerve endings they should never have got near, so products that were fine last month suddenly sting.</p><h2>What strips it</h2><p>Hot showers. Hard water, which most Indian cities have. Air conditioning running ten hours a day. Foaming cleansers built around harsh surfactants. And, more than any of these, stacking three actives at once because each one individually seemed reasonable.</p><h2>How to tell</h2><p>Tightness within minutes of washing. Stinging from products you have used for months. Redness that takes hours to settle. Flaking around the nose. Skin that is somehow both oily and dry.</p><h2>How to fix it</h2><p>Stop stripping it first. Lukewarm water, a gentler cleanser, and pause the acids for a fortnight. Then rebuild with <a href=""/collections/ceramides"">ceramides</a> and <a href=""/collections/squalane"">squalane</a>.</p><p>This is one of the faster things to fix in skincare. Most people see a real difference in ten to fourteen days - which is why it is worth doing before anything else. See <a href=""/collections/dryness"">dry skin</a> and <a href=""/collections/sensitivity"">sensitivity</a> for the full routines.</p>"
     seoT="What Is the Skin Barrier? Damage, Symptoms and Repair | EMBRAE"
     seoD="The skin barrier is a real physical layer, not a metaphor. What strips it, how to recognise the damage, and a routine that repairs it in two weeks." }
  @{ blog="skin-school"; h="how-to-layer-skincare"; title="The order to apply skincare in, and why it matters less than you think"
     author="Dr Ananya Rao"; tags=@("basics","routine","usage")
     sum="Thinnest to thickest covers ninety percent of it. The remaining ten percent is where people waste money."
     body="<p>The rule is thinnest to thickest. Cleanser, serum, moisturiser, and sunscreen last in the morning. That covers almost every routine anyone actually needs.</p><h2>The part people get wrong</h2><p>Waiting between steps. You should wait about a minute - not for any chemical reason, but because applying a cream onto a wet face means most of it ends up on your hands.</p><p>The exception that matters is <a href=""/collections/hyaluronic-acid"">hyaluronic acid</a>. It is a humectant, so it needs to go on damp skin and needs something sealing it in afterwards. On a dry day, with nothing over it, it will pull water out of your skin instead of into it.</p><h2>What does not matter</h2><p>Most of the pH-waiting advice circulating online. Most of the ingredient-conflict lists. Niacinamide and vitamin C were declared incompatible for years on the basis of a study run at temperatures no bathroom reaches.</p><h2>What does matter</h2><p>Sunscreen last, and enough of it. Two finger-lengths for face and neck. Almost everyone uses a third of that, which turns an SPF 50 into an SPF 15.</p>"
     seoT="What Order to Apply Skincare - A Simple Rule | EMBRAE"
     seoD="Thinnest to thickest covers most of it. The one exception that actually matters, and the ingredient-conflict advice you can safely ignore." }
  @{ blog="skin-school"; h="how-long-skincare-takes"; title="How long skincare actually takes to work"
     author="Dr Ananya Rao"; tags=@("basics","results","expectations")
     sum="Barrier repair in two weeks. Breakouts in six. Pigmentation in twelve. Anything faster is describing an exfoliant."
     body="<p>The single most common reason people conclude a routine did not work is stopping at week two. Skin turns over on its own schedule and no product changes that.</p><h2>What is fast</h2><p>Hydration is immediate - skin looks plumper the same day. Barrier repair shows in ten to fourteen days, which is the fastest genuine change in skincare.</p><h2>What is slow</h2><p><a href=""/collections/breakouts"">Breakouts</a> take four to six weeks, because you are waiting for a full skin cycle. <a href=""/collections/pigmentation"">Pigmentation</a> takes eight to twelve, and marks fade rather than vanish.</p><h2>What never happens</h2><p>Pores do not shrink. Scars do not disappear without a dermatologist. And nothing brightens skin in three days that is not either an exfoliant buffing the surface or a filter.</p><p>If a product promises faster than the numbers above, that is worth reading as a claim about the marketing rather than the formula.</p>"
     seoT="How Long Does Skincare Take to Work? Realistic Timelines | EMBRAE"
     seoD="Barrier repair in two weeks, breakouts in six, pigmentation in twelve. Honest timelines for every concern, and what never works at all." }
  # --- climate-skin ---
  @{ blog="climate-skin"; h="monsoon-skincare"; title="Monsoon skin: why everything breaks out in July"
     author="Meera Iyer"; tags=@("monsoon","humidity","breakouts")
     sum="Humidity does not hydrate skin. It just stops sweat evaporating, which is a completely different thing."
     body="<p>The monsoon is the hardest season for Indian skin, and the reason is not what most people assume.</p><p>High humidity does not moisturise. It slows evaporation, so sweat sits on the skin along with sunscreen, oil and whatever the day deposited. That mixture is what blocks pores.</p><h2>What changes in July</h2><p>Congestion rises. Closed bumps appear along the jaw and forehead. Products that felt right in February suddenly feel like a film.</p><h2>What to do</h2><p>Go lighter, not less. Skipping moisturiser because skin feels oily is the classic monsoon mistake - stripped skin produces more oil, not less.</p><p>Switch to a <a href=""/collections/salicylic-acid"">salicylic acid</a> cleanser if you are not already using one, and keep a light <a href=""/collections/moisturisers"">moisturiser</a> in the routine.</p><h2>The one people skip</h2><p>Sunscreen. An overcast monsoon sky blocks very little UVA, and UVA is the wavelength most associated with <a href=""/collections/pigmentation"">pigmentation</a>. Cloud cover is not protection.</p>"
     seoT="Monsoon Skincare in India - Humidity, Breakouts and SPF | EMBRAE"
     seoD="Why humidity causes congestion rather than hydration, what to change in July, and the step almost everyone drops when it is overcast." }
  @{ blog="climate-skin"; h="air-conditioning-and-skin"; title="What ten hours of air conditioning does to your face"
     author="Meera Iyer"; tags=@("air-conditioning","dryness","office")
     sum="An office at 22 degrees is drier than most deserts. Your barrier notices even if you do not."
     body="<p>Air conditioning cools by removing moisture from air. A room held at 22 degrees for ten hours has humidity low enough that skin loses water continuously through the day.</p><p>Most people do not notice because it is gradual. What they notice is that by 4pm their foundation looks patchy and their skin feels tight.</p><h2>Why it compounds</h2><p>The barrier is what stops water escaping. Sustained dry air puts that barrier under constant load, and a loaded barrier is a barrier that eventually fails - which is when previously fine products start stinging.</p><h2>What actually helps</h2><p>A <a href=""/collections/ceramides"">ceramide</a> moisturiser morning and night does more than anything sprayed on during the day. Facial mists evaporate and take skin moisture with them, which is worse than doing nothing.</p><p>If you can, a small humidifier at your desk. If you cannot, apply moisturiser to slightly damp skin so it has water to seal in.</p><p>See <a href=""/collections/dryness"">dry skin</a> for the full routine.</p>"
     seoT="Air Conditioning and Dry Skin - What to Do About It | EMBRAE"
     seoD="An office at 22 degrees is drier than most deserts. Why facial mists make it worse, and what actually holds water in through the day." }
  @{ blog="climate-skin"; h="pollution-and-skin"; title="City air, and what settles on your face by evening"
     author="Meera Iyer"; tags=@("pollution","dullness","cleansing")
     sum="Particulate matter does not just sit there. It generates free radicals, which is a slower and more annoying problem than dirt."
     body="<p>By the time you get home in Delhi or Mumbai, there is a measurable layer of particulate matter on your skin. Some of it is inert. Some of it generates free radicals, which drive both <a href=""/collections/dullness"">dullness</a> and premature ageing.</p><h2>The evening cleanse matters more than the morning one</h2><p>Morning cleansing removes what your skin did overnight, which is not much. Evening cleansing removes an entire day.</p><p>You do not need a double cleanse if your cleanser is good enough to remove sunscreen in one pass. You do need forty seconds of contact rather than ten.</p><h2>Antioxidants during the day</h2><p><a href=""/collections/vitamin-c"">Vitamin C</a> in the morning neutralises some of the free radical load before it accumulates. It is one of the few genuinely preventive steps available.</p><h2>What not to do</h2><p>Scrubbing. Physical exfoliants damage the barrier that is already under load, and a damaged barrier is more permeable to exactly the things you are trying to remove.</p>"
     seoT="Pollution and Skin - Dullness, Free Radicals, Cleansing | EMBRAE"
     seoD="What settles on your face during a day in an Indian city, why the evening cleanse matters more, and why scrubbing makes it worse." }
  # --- myth-vs-fact ---
  @{ blog="myth-vs-fact"; h="niacinamide-vitamin-c-myth"; title="Myth: you cannot use niacinamide with vitamin C"
     author="Dr Ananya Rao"; tags=@("myths","niacinamide","vitamin-c")
     sum="This came from a 1960s study run at temperatures no bathroom reaches. It has been repeated ever since."
     body="<p><strong>The myth:</strong> niacinamide and vitamin C cancel each other out, or convert into niacin and cause flushing.</p><p><strong>Where it came from:</strong> a study from the 1960s that heated both compounds to temperatures nothing on your bathroom shelf will ever reach. Under those conditions the conversion happens. Under normal conditions it does not, or does so slowly enough to be irrelevant.</p><p><strong>What is actually true:</strong> the two work well together. <a href=""/collections/niacinamide"">Niacinamide</a> reduces inflammation and slows pigment transfer; <a href=""/collections/vitamin-c"">vitamin C</a> reduces pigment production. They address the same problem from two directions.</p><p>Our <a href=""/products/radiance-serum"">Radiance Serum</a> contains both, deliberately.</p><p><strong>What to watch instead:</strong> if your skin is reactive, introduce them one at a time - not because they conflict with each other, but because introducing two new things at once means you cannot tell which one caused a reaction.</p>"
     seoT="Can You Use Niacinamide With Vitamin C? Myth Explained | EMBRAE"
     seoD="The niacinamide and vitamin C conflict comes from a 1960s study run at temperatures no bathroom reaches. What is actually true." }
  @{ blog="myth-vs-fact"; h="oily-skin-moisturiser-myth"; title="Myth: oily skin does not need moisturiser"
     author="Dr Ananya Rao"; tags=@("myths","oily-skin","moisturiser")
     sum="Skipping moisturiser is one of the most reliable ways to make oily skin oilier."
     body="<p><strong>The myth:</strong> adding moisture to oily skin makes it worse.</p><p><strong>What actually happens:</strong> oil and water are different things. Oily skin can be dehydrated, and very often is - which is why so much oily skin also feels tight.</p><p>Strip the skin and the barrier compensates by producing more oil. That is not a theory; it is the mechanism behind the cycle where a harsher cleanser leads to a shinier face by lunchtime.</p><p><strong>What to do instead:</strong> a light, fragrance-free, non-comedogenic <a href=""/collections/moisturisers"">moisturiser</a> morning and night. It breaks the cycle within a couple of weeks.</p><p><strong>What is true in the myth:</strong> heavy occlusive creams can worsen congestion on <a href=""/collections/breakouts"">breakout-prone</a> skin. The answer is a lighter texture, not no texture.</p>"
     seoT="Does Oily Skin Need Moisturiser? Yes - Here Is Why | EMBRAE"
     seoD="Skipping moisturiser makes oily skin oilier. The rebound-oil cycle explained, and what texture to use instead of skipping the step." }
  @{ blog="myth-vs-fact"; h="spf-indoors-myth"; title="Myth: you do not need sunscreen indoors"
     author="Meera Iyer"; tags=@("myths","sunscreen","spf")
     sum="It depends entirely on whether you sit near a window, and most advice refuses to say so."
     body="<p><strong>The myth, version one:</strong> you need SPF indoors, always, no exceptions.</p><p><strong>The myth, version two:</strong> indoors means you are safe.</p><p>Both are wrong, and the honest answer is more useful than either.</p><p><strong>What is true:</strong> UVB is largely blocked by window glass. UVA is not. UVA is the wavelength most associated with <a href=""/collections/pigmentation"">pigmentation</a> and photoageing.</p><p>So if you sit near a window for hours, you are getting meaningful UVA exposure and sunscreen is worth it. If you are in a windowless room all day, it matters far less.</p><p><strong>The part that is not a myth:</strong> screens and indoor lighting emit negligible UV. Blue light from devices is a real research area but the doses involved are nothing like sunlight.</p><p>Be honest about which room you are actually in. See <a href=""/collections/sunscreen"">sunscreen</a>.</p>"
     seoT="Do You Need Sunscreen Indoors? An Honest Answer | EMBRAE"
     seoD="UVA passes through window glass, UVB mostly does not. Why the answer depends on your desk, and what screens actually emit." }
  # --- journal ---
  @{ blog="journal"; h="why-we-print-percentages"; title="Why we print the percentage on the carton"
     author="EMBRAE"; tags=@("brand","transparency","formulation")
     sum="An ingredient name without a dose is not information. It is a word chosen to appear on a list."
     body="<p>Niacinamide at 0.1% and niacinamide at 4% are the same word on an ingredients list and completely different products.</p><p>The first is what the industry calls a label claim - present in a quantity too small to do anything, but present enough to print. The second does what the research says niacinamide does.</p><p>You cannot tell them apart from the front of a carton, which is precisely why so few brands print the number.</p><h2>What we do</h2><p>Every active in the range carries its percentage on the carton and on the product page. The full INCI list is published in both places. Nothing is withheld as a proprietary blend.</p><h2>What that costs us</h2><p>It removes the option of claiming an ingredient we have barely used. That is the point.</p><p>It also invites comparison on numbers, which sometimes goes against us - our <a href=""/collections/niacinamide"">niacinamide</a> sits at 2 to 4 percent rather than the 10 percent some brands advertise, because above 5 the returns flatten and the flushing risk rises.</p><p>We would rather explain that than win the number.</p>"
     seoT="Why EMBRAE Prints Active Percentages on the Carton | EMBRAE"
     seoD="An ingredient name without a dose is not information. Why we publish every percentage, and what that decision costs us." }
  @{ blog="journal"; h="built-for-indian-weather"; title="Formulating for a country with six climates"
     author="EMBRAE"; tags=@("brand","climate","india")
     sum="A serum that works in a Copenhagen winter can be a brown, useless liquid by its third week in Chennai."
     body="<p>Most skincare sold in India is formulated somewhere else, for somewhere else.</p><p>The clearest example is vitamin C. L-ascorbic acid is the most studied form and the least stable. It degrades with heat, light and time - and an Indian bathroom in May supplies all three generously.</p><p>By week three, a serum that tested beautifully in a European lab can be an oxidised brown liquid that does nothing.</p><h2>What we changed</h2><p>We use 3-O-ethyl ascorbic acid in the <a href=""/products/radiance-serum"">Radiance Serum</a>. Less studied, more stable, and still working in month three.</p><p>Textures are lighter across the range than a European equivalent would be, because a cream that feels right in January in Delhi feels like a film in July in Mumbai.</p><h2>What we have not solved</h2><p>Hard water. It strips barriers and there is nothing a leave-on product can do about what happens during the wash itself. The best we can offer is a cleanser that does not add to the problem, and a <a href=""/collections/ceramides"">ceramide</a> moisturiser that repairs afterwards.</p>"
     seoT="Skincare Formulated for Indian Climate | EMBRAE"
     seoD="Why a serum that works in a European winter fails by week three in Chennai, what we changed, and the one problem we cannot formulate around." }
)

$create = 'mutation add($article: ArticleCreateInput!) { articleCreate(article: $article) { article { id handle } userErrors { field message } } }'
$done = 0
foreach ($a in $articles) {
  $bid = $blogs[$a.blog]
  if (-not $bid) { Write-Host ("SKIP  " + $a.h + " - blog " + $a.blog + " not found"); continue }
  $input = @{
    blogId = $bid; title = $a.title; handle = $a.h; body = $a.body; summary = $a.sum
    isPublished = $true; tags = $a.tags
    author = @{ name = $a.author }
    image = @{ url = (Img $a.title); altText = $a.title }
  }
  $r = Send-GQL $create @{ article = $input }
  $e = @($r.data.articleCreate.userErrors | Where-Object { $_ })
  if (-not $r.data.articleCreate -or $e.Count -gt 0) { Write-Host ("FAIL  " + $a.h + " " + ($e | ConvertTo-Json -Compress)); if ($r.errors) { $r.errors | ConvertTo-Json -Depth 4 -Compress | Write-Host }; continue }
  Write-Host ("ok    " + $a.blog + "/" + $a.h)
  $done++
}
Write-Host ""
Write-Host "articles created: $done of $($articles.Count)"
