# Attaches two images to each of the 9 EMBRAE products:
#   1. a keyword-matched photograph  (LoremFlickr, Flickr CC)   - primary
#   2. a branded pack card in EMBRAE colors (placehold.co)      - secondary
#
# ALL OF THIS IS MOCK. Every photograph here is CC-licensed and not owned, and must be
# replaced with real product photography before launch. Recorded in docs/mock-assets.md.

. (Join-Path $PSScriptRoot "upload-image.ps1")

$products = @(
  @{ handle = "clarity-cleanser";           kw = "facewash,skincare";  label = "Clarity+Gel+Cleanser"; size = "100+ml"; alt = "Clarity Gel Cleanser, a low-foam salicylic acid face wash in a 100 ml bottle" }
  @{ handle = "radiance-serum";             kw = "serum,skincare";     label = "Radiance+Serum";       size = "30+ml";  alt = "Radiance Serum, a 10% vitamin C serum in a 30 ml glass dropper bottle" }
  @{ handle = "barrier-moisturizer";        kw = "moisturizer,cream";  label = "Barrier+Moisturizer";  size = "50+ml";  alt = "Barrier Moisturizer, a ceramide and squalane cream in a 50 ml jar" }
  @{ handle = "daily-defense-sunscreen";    kw = "sunscreen";          label = "Daily+Defense+SPF+50"; size = "50+ml";  alt = "Daily Defense Sunscreen SPF 50 PA++++ in a 50 ml tube" }
  @{ handle = "starter-duo-set";            kw = "skincare,bottles";   label = "The+Starter+Duo";      size = "2+products"; alt = "The Starter Duo gift set containing the Clarity Gel Cleanser and Barrier Moisturizer" }
  @{ handle = "morning-ritual-set";         kw = "skincare,cosmetics"; label = "The+Morning+Ritual";   size = "3+products"; alt = "The Morning Ritual set containing cleanser, serum and sunscreen" }
  @{ handle = "evening-ritual-set";         kw = "skincare,night";     label = "The+Evening+Ritual";   size = "3+products"; alt = "The Evening Ritual set containing cleanser, serum and moisturizer" }
  @{ handle = "complete-routine-set";       kw = "cosmetics,skincare"; label = "The+Complete+Routine"; size = "4+products"; alt = "The Complete Routine set containing all four EMBRAE products" }
  @{ handle = "travel-barrier-moisturizer"; kw = "cream,travel";       label = "Travel+Size";          size = "15+ml";  alt = "Barrier Moisturizer travel size, a 15 ml cabin-bag jar" }
)

$manifest = @()

foreach ($p in $products) {
  $q = 'query($h: String!) { products(first: 1, query: $h) { nodes { id handle title media(first: 10) { nodes { id } } } } }'
  $r = Send-GQL $q @{ h = "handle:$($p.handle)" }
  $prod = $r.data.products.nodes | Select-Object -First 1
  if (-not $prod) { Write-Output ("SKIP  " + $p.handle + " - not found"); continue }
  if (@($prod.media.nodes).Count -gt 0) { Write-Output ("SKIP  " + $p.handle + " - already has media"); continue }

  $photoName = "embrae-" + $p.handle + ".jpg"
  $cardName  = "embrae-" + $p.handle + "-pack.png"
  $photoSrc  = "https://loremflickr.com/1280/1280/" + $p.kw
  $cardSrc   = "https://placehold.co/2048x2048/034638/F3CFB3.png?text=" + $p.label + "%0A" + $p.size

  try {
    $m1 = Add-EmbraeProductMedia -ProductId $prod.id -Source $photoSrc -Filename $photoName -Alt $p.alt
    $m2 = Add-EmbraeProductMedia -ProductId $prod.id -Source $cardSrc  -Filename $cardName  -Alt ($p.alt + " - EMBRAE pack shot")
    Write-Output ("ok    " + $p.handle)
    $manifest += [pscustomobject]@{ handle = $p.handle; file = $photoName; media = $m1; source = "loremflickr:" + $p.kw }
    $manifest += [pscustomobject]@{ handle = $p.handle; file = $cardName;  media = $m2; source = "placehold.co" }
  } catch {
    Write-Output ("FAIL  " + $p.handle + " - " + $_.Exception.Message)
  }
}

$manifest | Export-Csv -Path (Join-Path $PSScriptRoot "..\docs\mock-assets-products.csv") -NoTypeInformation -Encoding UTF8
Write-Output ""
Write-Output ("manifest rows: " + $manifest.Count)
