# Attaches two images to each of the 9 EMBRAE products:
#   1. a keyword-matched photograph  (LoremFlickr, Flickr CC)   - primary
#   2. a branded pack card in EMBRAE colors (placehold.co)      - secondary
#
# ALL OF THIS IS MOCK. Every photograph here is CC-licensed and not owned, and must be
# replaced with real product photography before launch. Recorded in docs/mock-assets.md.

. (Join-Path $PSScriptRoot "upload-image.ps1")

$products = @(
  @{ handle = "barrier-reset-cleanser";           kw = "facewash,skincare";  label = "Barrier+Reset+Cleanser"; size = "100+ml"; alt = "Barrier Reset Cleanser, a low-foam salicylic acid face wash in a 100 ml bottle" }
  @{ handle = "urban-defense-serum";             kw = "serum,skincare";     label = "Urban+Defense+Serum";       size = "30+ml";  alt = "Urban Defense Serum, a 10% vitamin C serum in a 30 ml glass dropper bottle" }
  @{ handle = "climate-adapt-moisturizer";        kw = "moisturizer,cream";  label = "Climate+Adapt+Moisturizer";  size = "50+ml";  alt = "Climate Adapt Moisturizer, a ceramide and squalane cream in a 50 ml jar" }
  @{ handle = "daily-shield-spf50";    kw = "sunscreen";          label = "Daily+Shield+SPF+50"; size = "50+ml";  alt = "Daily Shield SPF 50 PA++++ in a 50 ml tube" }
  @{ handle = "barrier-support-duo";            kw = "skincare,bottles";   label = "Barrier+Support+Duo";      size = "2+products"; alt = "Barrier Support Duo gift set containing the Barrier Reset Cleanser and Climate Adapt Moisturizer" }
  @{ handle = "am-defense-routine";         kw = "skincare,cosmetics"; label = "AM+Defense+Routine";   size = "3+products"; alt = "AM Defense Routine set containing cleanser, serum and sunscreen" }
  @{ handle = "pm-recovery-routine";         kw = "skincare,night";     label = "PM+Recovery+Routine";   size = "3+products"; alt = "PM Recovery Routine set containing cleanser, serum and moisturizer" }
  @{ handle = "daily-urban-defense-routine";       kw = "cosmetics,skincare"; label = "Daily+Urban+Defense+Routine"; size = "4+products"; alt = "Daily Urban Defense Routine set containing all four EMBRAE products" }
  @{ handle = "travel-essentials-pouch"; kw = "cream,travel";       label = "Travel+Essentials+Pouch";          size = "15+ml";  alt = "Climate Adapt Moisturizer travel size, a 15 ml cabin-bag jar" }
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
