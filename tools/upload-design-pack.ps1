# Uploads the EMBRAE dummy design pack into Shopify Files.
#
#   pwsh -File .\tools\upload-design-pack.ps1
#   pwsh -File .\tools\upload-design-pack.ps1 -WhatIf     # print the plan, upload nothing
#
# WHAT THESE FILES ARE, so nobody mistakes them for photography later:
#
# Every source file is a CROP out of the 1536x1024 contact sheet in
# EMBRAE_Dummy_Website_Image_Asset_Pack. The hero is 490x240. Packshots are
# 150x240. Textures are ~110x140. They are an art-direction board, not an
# image library, and they WILL render soft wherever they are used. They are
# here as development placeholders by merchant decision, and every one of them
# is recorded in docs/mock-assets.md so the cleanup runs off a manifest rather
# than off filename guesswork.
#
# Two files from the pack are deliberately NOT uploaded:
#   00_MASTER_...BOARD  - the contact sheet itself, a reference not an asset.
#   33_icons_placeholder - a contact sheet of eight icons. Icons are code:
#                          snippets/icon-embrae.liquid replaces it.
#
# Filenames are written clean and descriptive rather than prefixed "mock-",
# because the filename is part of the image's SEO surface and the manifest is
# what tracks provenance. Replacement order for anything already referenced is
# ALWAYS: upload new -> re-point the reference -> delete old. Deleting first
# breaks the reference silently, with no error anywhere.

[CmdletBinding()]
param(
  [string]$PackDir = "$env:USERPROFILE\Downloads\EMBRAE_Dummy_Website_Image_Asset_Pack",
  [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "upload-image.ps1")

# source file, target filename, alt text, where it is used
$Assets = @(
  @{ Src = "01_hero_climate_skin.jpg";        Name = "embrae-hero-climate-skin.jpg";        Alt = "The four EMBRAE products arranged on a pale stone plinth against a soft green field"; Use = "Homepage hero slideshow, slide 1" }
  @{ Src = "02_hero_routine.jpg";             Name = "embrae-hero-routine.jpg";             Alt = "The complete EMBRAE routine photographed together on a neutral ground";                 Use = "Homepage hero slideshow, slide 2; routine daypart section" }
  @{ Src = "03_product_cleanser.jpg";         Name = "embrae-barrier-reset-cleanser.jpg";   Alt = "Barrier Reset Cleanser in a cream pump bottle";                                        Use = "Product: Barrier Reset Cleanser; routine step RESET" }
  @{ Src = "04_product_serum.jpg";            Name = "embrae-urban-defense-serum.jpg";      Alt = "Urban Defense Serum in an amber dropper bottle";                                       Use = "Product: Urban Defense Serum; hero slide 3; routine step DEFEND" }
  @{ Src = "05_product_moisturizer.jpg";      Name = "embrae-climate-adapt-moisturizer.jpg"; Alt = "Climate Adapt Moisturizer in a wide cream jar with a dark lid";                       Use = "Product: Climate Adapt Moisturizer; routine step ADAPT" }
  @{ Src = "06_product_sunscreen.jpg";        Name = "embrae-daily-shield-spf50.jpg";       Alt = "Daily Shield SPF50 in a slim white tube";                                              Use = "Product: Daily Shield SPF50; routine step PROTECT" }
  @{ Src = "07_texture_gel.jpg";              Name = "embrae-texture-gel.jpg";              Alt = "Clear gel texture in a shallow glass dish";                                            Use = "Routine module texture swatch; PDP gallery" }
  @{ Src = "08_texture_drops.jpg";            Name = "embrae-texture-drops.jpg";            Alt = "Serum droplets beading on a pale surface";                                             Use = "Routine module texture swatch; PDP gallery" }
  @{ Src = "09_texture_clear_serum.jpg";      Name = "embrae-texture-serum.jpg";            Alt = "A smear of clear serum catching the light";                                            Use = "Routine module texture swatch; PDP gallery" }
  @{ Src = "10_texture_cream.jpg";            Name = "embrae-texture-cream.jpg";            Alt = "A swipe of white moisturizer showing its thickness";                                   Use = "Routine module texture swatch; PDP gallery" }
  @{ Src = "11_texture_ingredient_powder.jpg"; Name = "embrae-texture-active-powder.jpg";   Alt = "Fine active powder in a petri dish beside a green leaf";                               Use = "Ingredient library; formulation section" }
  @{ Src = "12_climate_city.jpg";             Name = "embrae-urban-skyline.jpg";            Alt = "A hazy Indian city skyline at dusk";                                                   Use = "Homepage: The Problem section" }
  @{ Src = "13_lifestyle_climate.jpg";        Name = "embrae-lifestyle-city.jpg";           Alt = "A woman outdoors in a city, looking upward in daylight";                               Use = "Climate and Skin page; lifestyle band" }
  @{ Src = "14_leaf_water.jpg";               Name = "embrae-leaf-water.jpg";               Alt = "Water droplets held on a dark green leaf";                                             Use = "Skin Science; ingredient education backgrounds" }
  @{ Src = "15_rain_window.jpg";              Name = "embrae-rain-window.jpg";              Alt = "Rain running down a window against a blurred green background";                        Use = "Climate and Skin; humidity education" }
  @{ Src = "16_leaf_shadow.jpg";              Name = "embrae-leaf-shadow.jpg";              Alt = "Soft leaf shadows falling across a warm neutral wall";                                 Use = "Section background texture; editorial breaks" }
  @{ Src = "17_routine_reset.jpg";            Name = "embrae-routine-reset.jpg";            Alt = "Cleanser being worked over damp skin";                                                 Use = "Routine step RESET; How to Use" }
  @{ Src = "18_routine_defend.jpg";           Name = "embrae-routine-defend.jpg";           Alt = "Serum being applied to the cheek from a dropper";                                      Use = "Routine step DEFEND; How to Use" }
  @{ Src = "19_routine_adapt.jpg";            Name = "embrae-routine-adapt.jpg";            Alt = "Moisturizer being smoothed across the cheek";                                          Use = "Routine step ADAPT; How to Use" }
  @{ Src = "20_routine_protect.jpg";          Name = "embrae-routine-protect.jpg";          Alt = "Sunscreen being pressed into the skin with fingertips";                                Use = "Routine step PROTECT; How to Use" }
  @{ Src = "21_lab_glassware.jpg";            Name = "embrae-lab-glassware.jpg";            Alt = "Laboratory glassware holding green plant cuttings";                                    Use = "Trust and Transparency; Why EMBRAE" }
  @{ Src = "22_lab_dropper.jpg";              Name = "embrae-lab-dropper.jpg";              Alt = "A pipette releasing liquid into a laboratory flask";                                   Use = "Testing and Efficacy" }
  @{ Src = "23_lab_microscope.jpg";           Name = "embrae-lab-microscope.jpg";           Alt = "A microscope on a laboratory bench";                                                   Use = "Testing and Efficacy; Our Standards" }
  @{ Src = "24_lab_formulator.jpg";           Name = "embrae-lab-formulator.jpg";           Alt = "A formulator in a lab coat and gloves working at a bench";                             Use = "Manufacturing and Quality" }
  @{ Src = "25_packaging_hand.jpg";           Name = "embrae-packaging-in-hand.jpg";        Alt = "A hand holding an EMBRAE pump bottle";                                                 Use = "PDP gallery; packaging detail" }
  @{ Src = "26_packaging_carton.jpg";         Name = "embrae-packaging-carton.jpg";         Alt = "An EMBRAE outer carton standing upright";                                             Use = "PDP gallery; packaging detail" }
  @{ Src = "27_packaging_detail.jpg";         Name = "embrae-packaging-emboss.jpg";         Alt = "Close detail of the embossed EMBRAE mark on the carton";                               Use = "PDP gallery; brand detail" }
  @{ Src = "28_packaging_product.jpg";        Name = "embrae-packaging-bottle.jpg";         Alt = "An EMBRAE bottle photographed close, showing the label";                               Use = "PDP gallery" }
  @{ Src = "29_results_placeholder.jpg";      Name = "embrae-results-placeholder.jpg";      Alt = "Placeholder panel reserved for verified results content";                              Use = "Results page. PLACEHOLDER - never present as real results" }
  @{ Src = "30_customer_lifestyle_1.jpg";     Name = "embrae-customer-story-1.jpg";         Alt = "A person holding an EMBRAE serum bottle";                                              Use = "Customer Stories. PLACEHOLDER - not a real customer" }
  @{ Src = "31_customer_lifestyle_2.jpg";     Name = "embrae-customer-story-2.jpg";         Alt = "A person applying EMBRAE product to the face";                                         Use = "Customer Stories. PLACEHOLDER - not a real customer" }
  @{ Src = "32_customer_lifestyle_3.jpg";     Name = "embrae-customer-story-3.jpg";         Alt = "A person holding an EMBRAE bottle beside the face";                                    Use = "Customer Stories. PLACEHOLDER - not a real customer" }
  @{ Src = "34_promo_free_shipping.jpg";      Name = "embrae-promo-shipping.jpg";           Alt = "Free shipping promotional strip on a deep green ground";                               Use = "Hero slideshow slide 4; promotional strip" }
  @{ Src = "35_promo_skin_quiz.jpg";          Name = "embrae-promo-skin-quiz.jpg";          Alt = "Build your routine promotional strip showing the product range";                       Use = "Skin quiz CTA banner" }
  @{ Src = "36_background_textures.jpg";      Name = "embrae-background-texture.jpg";       Alt = "Soft neutral and aqua background textures";                                            Use = "Section background texture" }
)

if (-not (Test-Path $PackDir)) { throw "Asset pack not found at $PackDir" }

Write-Output "EMBRAE design pack -> Shopify Files"
Write-Output "Source: $PackDir"
Write-Output "$($Assets.Count) files to upload (00 board and 33 icon sheet deliberately excluded)"
Write-Output ""

$manifest = @()
$failed = @()

foreach ($a in $Assets) {
  $path = Join-Path $PackDir $a.Src
  if (-not (Test-Path $path)) { Write-Warning "MISSING: $($a.Src)"; $failed += $a.Src; continue }

  if ($WhatIf) {
    Write-Output ("  [plan] {0,-34} -> {1}" -f $a.Src, $a.Name)
    continue
  }

  try {
    $gid = Add-EmbraeFile -Source $path -Filename $a.Name -Alt $a.Alt
    Write-Output ("  [ok]   {0,-34} -> {1}" -f $a.Src, $a.Name)
    $manifest += [pscustomobject]@{ File = $a.Name; Gid = $gid; Source = $a.Src; Use = $a.Use }
  } catch {
    Write-Warning "FAILED $($a.Src): $($_.Exception.Message)"
    $failed += $a.Src
  }
}

if ($WhatIf) { Write-Output ""; Write-Output "WhatIf: nothing uploaded."; return }

# Append to the manifest that cleanup will run off.
$docPath = Join-Path $PSScriptRoot "..\docs\mock-assets.md"
if (-not (Test-Path $docPath)) {
  @(
    "# Mock asset manifest"
    ""
    "Every non-owned asset in the store, recorded at upload time. Cleanup runs off THIS FILE,"
    "not off filename patterns - which is why filenames are clean and SEO-useful rather than"
    "prefixed ``mock-``."
    ""
    "Replacement order for anything referenced: **upload new -> re-point -> delete old.**"
    "Deleting first breaks the reference silently, with no error anywhere."
  ) -join "`n" | Set-Content -Path $docPath -Encoding utf8
}

$stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$lines = @(
  ""
  "---"
  ""
  "## $stamp - EMBRAE_Dummy_Website_Image_Asset_Pack"
  ""
  "**Source:** ``EMBRAE_Dummy_Website_Image_Asset_Pack``, supplied by the brand team."
  "**Provenance:** generated placeholder imagery. NOT owned photography, NOT real customers,"
  "NOT real results. Every file is a crop out of the 1536x1024 contact sheet - the largest is"
  "490x240 - so all of them render soft. Replace against the shot list in ``docs/admin-tasks.md`` section 15a."
  ""
  "| File | Used by | GID |"
  "|---|---|---|"
)
foreach ($m in $manifest) { $lines += "| ``$($m.File)`` | $($m.Use) | ``$($m.Gid)`` |" }
$lines += ""
$lines += "Uploaded $($manifest.Count) of $($Assets.Count)."
if ($failed.Count) { $lines += "**Failed:** $($failed -join ', ')" }

Add-Content -Path $docPath -Value ($lines -join "`n") -Encoding utf8

Write-Output ""
Write-Output "Uploaded $($manifest.Count) of $($Assets.Count). Manifest appended to docs/mock-assets.md"
if ($failed.Count) { Write-Output "Failed: $($failed -join ', ')" }
