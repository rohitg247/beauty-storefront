# Creates the navigation menus the Phase 3 header and footer need.
#
#   pwsh -File .\tools\seed-navigation-v2.ps1
#   pwsh -File .\tools\seed-navigation-v2.ps1 -WhatIf
#
# WHY NEW MENUS RATHER THAN EDITING THE EXISTING ONE:
#
# CLAUDE.md is explicit - create the data first, then point the theme at it.
# A link_list setting naming a handle with nothing behind it renders empty and
# SILENTLY: no error in theme check, in preflight, in the upload, or in the
# console. That already cost a full round trip on 2026-08-23. So these are
# created and verified here, and only then does sections/header-group.json get
# re-pointed. `embrae-nav` is left intact the whole time as the fallback.
#
# WHAT CHANGES, against the Build Brief section 4 and the prototype boards:
#
#   - Desktop top level goes 9 -> 5. Nine items is why the header needed a
#     tracking hack at 990-1279px to stop wrapping.
#   - ABOUT is consolidated into WHY EMBRAE, exactly as the brief instructs.
#   - EDUCATION HUB -> SKIN SCIENCE, TRUST CENTER -> TRUST & TRANSPARENCY,
#     FAQ CENTER -> FAQ. The brief names these directly.
#   - TRUST / FAQ / CONTACT become a secondary tier: below a rule in the mobile
#     drawer, as drawn on the boards, and in the footer. They are NOT dropped.
#   - "Media Mentions" leaves RESULTS. The brief puts press under About/footer,
#     not under Results.
#
# HANDLES ARE NOT RENAMED. The store uses /pages/why, /pages/education,
# /pages/quiz and plural collection handles. The brief's page map wants
# different slugs, but renaming means urlRedirect on every one plus re-pointing
# 50-odd links, for no user-visible benefit. Recorded as accepted divergence in
# docs/plan.md.

[CmdletBinding()]
param([switch]$WhatIf)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "gql.ps1")

# Every URL below was verified to resolve before being written here:
# all collections return products, and every /pages/ handle exists.
$Menus = @(
  @{
    Handle = "embrae-primary"; Title = "EMBRAE primary navigation"
    Items = @(
      @{ t = "SHOP"; u = "/collections/all"; kids = @(
        @{ t = "All Products";   u = "/collections/all" }
        @{ t = "Serum";          u = "/collections/serums" }
        @{ t = "Moisturizer";    u = "/collections/moisturizers" }
        @{ t = "Cleanser";       u = "/collections/cleansers" }
        @{ t = "Sunscreen";      u = "/collections/sunscreen" }
        @{ t = "Bundles & Kits"; u = "/collections/bundles" }
        @{ t = "Shop the EMBRAE Routine"; u = "/products/daily-urban-defense-routine" }
      )}
      @{ t = "WHY EMBRAE"; u = "/pages/why"; kids = @(
        @{ t = "Why We Exist";   u = "/pages/why#why-we-exist" }
        @{ t = "Our Philosophy"; u = "/pages/why#our-philosophy" }
        @{ t = "Our Difference"; u = "/pages/why#our-difference" }
        @{ t = "Our Promise";    u = "/pages/why#our-promise" }
        @{ t = "Founder Story";  u = "/pages/about#founder-story" }
        @{ t = "Our Mission";    u = "/pages/about#our-mission" }
        @{ t = "Our Values";     u = "/pages/about#our-values" }
        @{ t = "Meet the Team";  u = "/pages/about#our-team" }
      )}
      @{ t = "SKIN SCIENCE"; u = "/pages/education"; kids = @(
        @{ t = "Skin School";       u = "/blogs/skin-school" }
        @{ t = "Ingredient Library"; u = "/pages/education#ingredient-library" }
        @{ t = "Climate & Skin";    u = "/blogs/climate-skin" }
        @{ t = "Skin Concerns";     u = "/pages/education#skin-concerns" }
        @{ t = "Routine Guide";     u = "/pages/education#routine-builder" }
        @{ t = "Myth vs Fact";      u = "/blogs/myth-vs-fact" }
        @{ t = "Journal";           u = "/blogs/journal" }
      )}
      @{ t = "RESULTS"; u = "/pages/results"; kids = @(
        @{ t = "Real Results";       u = "/pages/results#real-results" }
        @{ t = "Before & After";     u = "/pages/results#before-after" }
        @{ t = "Customer Stories";   u = "/pages/results#customer-stories" }
        @{ t = "Reviews";            u = "/pages/results#reviews" }
        @{ t = "Video Testimonials"; u = "/pages/results#video-testimonials" }
      )}
      @{ t = "SKIN QUIZ"; u = "/pages/quiz"; kids = @() }
    )
  }
  @{
    # The secondary tier. Rendered below a rule in the mobile drawer, as drawn
    # on the boards, and never on the desktop bar.
    Handle = "embrae-secondary"; Title = "EMBRAE secondary navigation"
    Items = @(
      @{ t = "TRUST & TRANSPARENCY"; u = "/pages/trust"; kids = @() }
      @{ t = "FAQ";                  u = "/pages/faq";   kids = @() }
      @{ t = "CONTACT";              u = "/pages/contact"; kids = @() }
    )
  }
  @{
    # The sixth footer column. Five of the six already exist.
    Handle = "footer-results"; Title = "Footer - Results"
    Items = @(
      @{ t = "Real Results";       u = "/pages/results#real-results"; kids = @() }
      @{ t = "Before & After";     u = "/pages/results#before-after"; kids = @() }
      @{ t = "Customer Stories";   u = "/pages/results#customer-stories"; kids = @() }
      @{ t = "Reviews";            u = "/pages/results#reviews"; kids = @() }
      @{ t = "Video Testimonials"; u = "/pages/results#video-testimonials"; kids = @() }
    )
  }
)

function ConvertTo-MenuItems($items) {
  # Everything is type HTTP: most of these carry a #fragment, and only HTTP
  # preserves one. A PAGE-typed item drops the anchor and lands at the top of
  # the page, which is what makes 30-odd nav links look broken.
  $parts = foreach ($i in $items) {
    $kids = ""
    if ($i.kids -and $i.kids.Count -gt 0) { $kids = ", items: " + (ConvertTo-MenuItems $i.kids) }
    '{ title: ' + (ConvertTo-Json $i.t) + ', type: HTTP, url: ' + (ConvertTo-Json $i.u) + $kids + ' }'
  }
  "[" + ($parts -join ", ") + "]"
}

# Existing handles, so a re-run updates instead of failing on a duplicate.
$existing = @{}
$r = Send-GQL 'query { menus(first: 50) { nodes { id handle } } }'
foreach ($n in $r.data.menus.nodes) { $existing[$n.handle] = $n.id }

foreach ($m in $Menus) {
  $count = ($m.Items | ForEach-Object { 1 + $_.kids.Count } | Measure-Object -Sum).Sum
  if ($WhatIf) {
    $verb = if ($existing.ContainsKey($m.Handle)) { "update" } else { "create" }
    Write-Output ("  [plan] {0,-20} {1}  {2} top-level, {3} links total" -f $m.Handle, $verb, $m.Items.Count, $count)
    continue
  }

  $itemsGql = ConvertTo-MenuItems $m.Items
  if ($existing.ContainsKey($m.Handle)) {
    $q = 'mutation { menuUpdate(id: ' + (ConvertTo-Json $existing[$m.Handle]) + ', title: ' + (ConvertTo-Json $m.Title) +
         ', handle: ' + (ConvertTo-Json $m.Handle) + ', items: ' + $itemsGql +
         ') { menu { id handle } userErrors { field message } } }'
    $res = Send-GQL $q; $payload = $res.data.menuUpdate; $verb = "updated"
  } else {
    $q = 'mutation { menuCreate(title: ' + (ConvertTo-Json $m.Title) + ', handle: ' + (ConvertTo-Json $m.Handle) +
         ', items: ' + $itemsGql + ') { menu { id handle } userErrors { field message } } }'
    $res = Send-GQL $q; $payload = $res.data.menuCreate; $verb = "created"
  }

  if ($res.errors) { Write-Warning "$($m.Handle): $($res.errors | ConvertTo-Json -Depth 5)"; continue }
  if ($payload.userErrors -and $payload.userErrors.Count) {
    Write-Warning "$($m.Handle): $($payload.userErrors | ConvertTo-Json -Depth 5)"; continue
  }
  Write-Output ("  [ok]   {0,-20} {1}  ({2} links)" -f $m.Handle, $verb, $count)
}

if ($WhatIf) { Write-Output ""; Write-Output "WhatIf: nothing written."; return }

# Verify by reading back, because the whole point of this script is that the
# theme must never be pointed at a menu that returns nothing.
Write-Output ""
Write-Output "Verifying:"
# The menus index is a read replica and lags the write by a second or two. Reading
# back immediately reports NOT FOUND for a menu that was in fact created, which is
# a false alarm on exactly the check that gates pointing the theme at it.
Start-Sleep -Seconds 3
$check = Send-GQL 'query { menus(first: 50) { nodes { handle items { title url items { title url } } } } }'
foreach ($m in $Menus) {
  $node = $check.data.menus.nodes | Where-Object { $_.handle -eq $m.Handle }
  if (-not $node) { Write-Warning "  $($m.Handle) NOT FOUND after write"; continue }
  $total = ($node.items | ForEach-Object { 1 + $_.items.Count } | Measure-Object -Sum).Sum
  if ($total -lt 1) { Write-Warning "  $($m.Handle) is EMPTY - do not point the theme at it" }
  else { Write-Output ("  {0,-20} {1} top-level, {2} links - safe to reference" -f $m.Handle, $node.items.Count, $total) }
}
