# Builds the four footer navigation menus.
#
#   .\tools\seed-footer-menus.ps1            # dry run
#   .\tools\seed-footer-menus.ps1 -Apply     # writes
#
# RUN THIS BEFORE re-pointing sections/footer-group.json. CLAUDE.md is explicit:
# a link_list setting naming a handle with nothing behind it renders EMPTY and
# SILENTLY - no error in theme check, preflight, upload or console. That cost a
# full round trip on 2026-08-23.
#
# RUN tools\seed-policies.ps1 FIRST. The POLICY column points at four
# /policies/* URLs, and three of them did not exist until that script ran.
#
# Menus NOT deleted: footer-about, footer-education, footer-results,
# footer-connect. They simply stop being referenced. Unreferencing is
# reversible; deleting is not, and the theme may still name one.
#
# ONE DELIBERATE DIVERGENCE FROM THE SPEC, flagged rather than silent:
# the spec puts "Shipping" and "Returns" under SUPPORT and "Shipping Policy"
# and "Return Policy" under POLICY. Pointed at the same URLs those are four
# links to two destinations. So SUPPORT's two point at the FAQ Center's own
# shipping and returns sections - customer help - and POLICY's point at the
# legal documents. Both links then mean something different.

param([switch]$Apply)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "gql.ps1")

$MENUS = @(
  @{
    Handle = "footer-shop"; Title = "Footer - Shop"
    Items = @(
      @{ t = "All Products"; u = "/collections/all" }
      @{ t = "Serum";        u = "/collections/serums" }
      @{ t = "Moisturizer";  u = "/collections/moisturizers" }
      @{ t = "Cleanser";     u = "/collections/cleansers" }
      @{ t = "Sunscreen";    u = "/collections/sunscreen" }
      @{ t = "Bundles";      u = "/collections/bundles" }
    )
  }
  @{
    Handle = "footer-discover"; Title = "Footer - Discover"
    Items = @(
      @{ t = "Why Embrae";   u = "/pages/why" }
      @{ t = "Skin Science"; u = "/pages/education" }
      @{ t = "Results";      u = "/pages/results" }
      @{ t = "Take the Quiz"; u = "/pages/quiz" }
    )
  }
  @{
    Handle = "footer-support"; Title = "Footer - Support"
    Items = @(
      @{ t = "FAQs";        u = "/pages/faq" }
      @{ t = "Shipping";    u = "/pages/faq#faq-shipping" }
      @{ t = "Returns";     u = "/pages/faq#faq-returns" }
      @{ t = "Track Order"; u = "/pages/track-order" }
    )
  }
  @{
    Handle = "footer-policy"; Title = "Footer - Policy"
    Items = @(
      @{ t = "Privacy Policy";    u = "/policies/privacy-policy" }
      @{ t = "Shipping Policy";   u = "/policies/shipping-policy" }
      @{ t = "Return Policy";     u = "/policies/refund-policy" }
      @{ t = "Terms & Conditions"; u = "/policies/terms-of-service" }
    )
  }
)

$mode = if ($Apply) { "APPLY" } else { "DRY RUN" }
Write-Output "=== EMBRAE footer menus - $mode ==="

# Existing menus, so we update rather than duplicate a handle.
$existing = @{}
$r = Send-GQL 'query { menus(first:50){edges{node{id handle title}}} }'
Show-GQLErrors $r "menus"
foreach ($e in $r.data.menus.edges) { $existing[$e.node.handle] = $e.node.id }

foreach ($m in $MENUS) {
  $items = @()
  foreach ($i in $m.Items) { $items += @{ title = $i.t; type = "HTTP"; url = $i.u } }

  $verb = if ($existing.ContainsKey($m.Handle)) { "update" } else { "CREATE" }
  Write-Output ""
  Write-Output ("  {0} {1} - {2} item(s)" -f $verb, $m.Handle, $items.Count)
  foreach ($i in $m.Items) { Write-Output ("      {0,-20} {1}" -f $i.t, $i.u) }

  if (-not $Apply) { continue }

  if ($existing.ContainsKey($m.Handle)) {
    $vars = @{ id = $existing[$m.Handle]; title = $m.Title; handle = $m.Handle; items = $items }
    $u = Send-GQL 'mutation($id:ID!,$title:String!,$handle:String!,$items:[MenuItemUpdateInput!]!){ menuUpdate(id:$id,title:$title,handle:$handle,items:$items){ menu{ handle } userErrors{ field message } } }' $vars
    Show-GQLErrors $u $m.Handle
    if ($u.data.menuUpdate.userErrors) { $u.data.menuUpdate.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.message) } }
  } else {
    $vars = @{ title = $m.Title; handle = $m.Handle; items = $items }
    $u = Send-GQL 'mutation($title:String!,$handle:String!,$items:[MenuItemCreateInput!]!){ menuCreate(title:$title,handle:$handle,items:$items){ menu{ handle } userErrors{ field message } } }' $vars
    Show-GQLErrors $u $m.Handle
    if ($u.data.menuCreate.userErrors) { $u.data.menuCreate.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.message) } }
  }
}

if ($Apply) {
  # The menus index is a READ REPLICA and lags a write by seconds. Reading back
  # immediately once reported NOT FOUND for three menus that had just been
  # created successfully. 3s proved too short as well - footer-policy was
  # reported MISSING and was in fact already there. 8s.
  Write-Output ""
  Write-Output "Waiting 8s for the menus read replica..."
  Start-Sleep -Seconds 8

  Write-Output ""
  Write-Output "--- read-back"
  $r = Send-GQL 'query { menus(first:50){edges{node{handle items{title url}}}} }'
  $seen = @{}
  foreach ($e in $r.data.menus.edges) { $seen[$e.node.handle] = $e.node.items }
  $ok = $true
  foreach ($m in $MENUS) {
    if (-not $seen.ContainsKey($m.Handle)) { Write-Output ("  MISSING " + $m.Handle); $ok = $false; continue }
    $got = @($seen[$m.Handle]).Count
    $want = $m.Items.Count
    if ($got -ne $want) { Write-Output ("  COUNT   {0}: {1} items, expected {2}" -f $m.Handle, $got, $want); $ok = $false }
    else { Write-Output ("  ok      {0}: {1} items" -f $m.Handle, $got) }
  }
  Write-Output ""
  if ($ok) { Write-Output "All four menus verified. sections/footer-group.json can now be re-pointed." }
  else { Write-Output "VERIFICATION FAILED - do NOT re-point footer-group.json yet." }
} else {
  Write-Output ""
  Write-Output "Nothing was written. Re-run with -Apply."
}
