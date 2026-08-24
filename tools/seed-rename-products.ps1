# Renames the EMBRAE catalogue to the approved product master.
#
#   . .\tools\seed-rename-products.ps1          # dry run, prints every change
#   .\tools\seed-rename-products.ps1 -Apply     # writes
#
# Renaming a product is not one field. The old names are quoted in product
# bodies, SEO fields, product metafields, routine and FAQ metaobjects, blog
# articles and a collection description. Missing any one of them leaves the
# store contradicting itself, so this script sweeps all of them from a single
# replacement map.
#
# Handles are renamed too. The store is not public and nothing is indexed, so
# no urlRedirect is needed - this is the only window in which that is true.
#
# WARNING FOR ANY REPO-WIDE SWEEP: this file CONTAINS the replacement map, so
# running a find-and-replace of the same map across tools/*.ps1 rewrites the
# map into identity pairs and silently destroys it. That already happened once.
# Exclude this filename from any such sweep.

param([switch]$Apply)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "gql.ps1")

# ---------------------------------------------------------------------------
# The product master.
# ---------------------------------------------------------------------------
$PRODUCTS = @(
  @{ old="clarity-cleanser";           handle="barrier-reset-cleanser";      title="Barrier Reset Cleanser" }
  @{ old="radiance-serum";             handle="urban-defense-serum";         title="Urban Defense Serum" }
  @{ old="barrier-moisturizer";        handle="climate-adapt-moisturizer";   title="Climate Adapt Moisturizer" }
  @{ old="daily-defense-sunscreen";    handle="daily-shield-spf50";          title="Daily Shield SPF 50 PA++++" }
  @{ old="starter-duo-set";            handle="barrier-support-duo";         title="Barrier Support Duo" }
  @{ old="morning-ritual-set";         handle="am-defense-routine";          title="AM Defense Routine" }
  @{ old="evening-ritual-set";         handle="pm-recovery-routine";         title="PM Recovery Routine" }
  @{ old="complete-routine-set";       handle="daily-urban-defense-routine"; title="Daily Urban Defense Routine" }
  @{ old="travel-barrier-moisturizer"; handle="travel-essentials-pouch";     title="Travel Essentials Pouch" }
)

# ---------------------------------------------------------------------------
# Prose replacements, LONGEST FIRST.
#
# Order is load-bearing twice over:
#   The travel-size name must be consumed before the bare moisturizer name, or
#   the travel size becomes "Climate Adapt Moisturizer Travel Size" and the
#   pouch loses its identity.
#   The sunscreen name carrying its SPF suffix must be consumed before the bare
#   sunscreen name, or the suffix is duplicated.
#
# British spellings are included because the US-English conversion did not
# reach content written before it, and a stray "Moisturiser" would survive the
# rename and look like a regression.
#
# Keys are assembled rather than written as literals, so a repo-wide sweep of
# the very map below cannot rewrite it into identity pairs. See the warning at
# the top of this file.
# ---------------------------------------------------------------------------
$oldCleanserLong = "Clarity" + " Gel Cleanser"
$oldCleanser     = "Clarity" + " Cleanser"
$oldSerum        = "Radiance" + " Serum"
$oldMoistUS      = "Barrier" + " Moisturizer"
$oldMoistUK      = "Barrier" + " Moisturiser"
$oldSunUS        = "Daily" + " Defense Sunscreen"
$oldSunUK        = "Daily" + " Defence Sunscreen"
$oldDuo          = "Starter" + " Duo"
$oldAM           = "Morning" + " Ritual"
$oldPM           = "Evening" + " Ritual"
$oldAll          = "Complete" + " Routine"
$spf             = " SPF 50 PA++++"
$travel          = " Travel Size"

$REPLACEMENTS = [ordered]@{}
$REPLACEMENTS[$oldSunUS + $spf]    = "Daily Shield SPF 50 PA++++"
$REPLACEMENTS[$oldSunUK + $spf]    = "Daily Shield SPF 50 PA++++"
$REPLACEMENTS[$oldMoistUS + $travel] = "Travel Essentials Pouch"
$REPLACEMENTS[$oldMoistUK + $travel] = "Travel Essentials Pouch"
$REPLACEMENTS[$oldSunUS]           = "Daily Shield"
$REPLACEMENTS[$oldSunUK]           = "Daily Shield"
$REPLACEMENTS[$oldCleanserLong]    = "Barrier Reset Cleanser"
$REPLACEMENTS[$oldCleanser]        = "Barrier Reset Cleanser"
$REPLACEMENTS[$oldSerum]           = "Urban Defense Serum"
$REPLACEMENTS[$oldMoistUS]         = "Climate Adapt Moisturizer"
$REPLACEMENTS[$oldMoistUK]         = "Climate Adapt Moisturizer"
$REPLACEMENTS["The " + $oldDuo]    = "Barrier Support Duo"
$REPLACEMENTS[$oldDuo]             = "Barrier Support Duo"
$REPLACEMENTS["The " + $oldAM]     = "AM Defense Routine"
$REPLACEMENTS[$oldAM]              = "AM Defense Routine"
$REPLACEMENTS["The " + $oldPM]     = "PM Recovery Routine"
$REPLACEMENTS[$oldPM]              = "PM Recovery Routine"
$REPLACEMENTS["The " + $oldAll]    = "Daily Urban Defense Routine"
$REPLACEMENTS[$oldAll]             = "Daily Urban Defense Routine"

# Handle rewrites. Two blog articles link to /products/<old-handle>, and a
# handle change turns those into 404s with no warning anywhere. Names alone
# are not enough.
$URLS = [ordered]@{}
foreach ($p in $PRODUCTS) { $URLS["/products/" + $p.old] = "/products/" + $p.handle }

function Rename-Text {
  param([string]$Text)
  if (-not $Text) { return $Text }
  foreach ($k in $REPLACEMENTS.Keys) { $Text = $Text.Replace($k, $REPLACEMENTS[$k]) }
  foreach ($k in $URLS.Keys)         { $Text = $Text.Replace($k, $URLS[$k]) }
  return $Text
}

function Changed { param([string]$a, [string]$b) return ($a -ne $b) }

$mode = if ($Apply) { "APPLY" } else { "DRY RUN" }
Write-Output "=== EMBRAE product rename - $mode ==="
$edits = 0

# ---------------------------------------------------------------------------
# 1. Products - title, handle, SEO, description.
# ---------------------------------------------------------------------------
Write-Output ""
Write-Output "--- products"
$byHandle = @{}
$r = Send-GQL 'query { products(first:50){edges{node{id handle title descriptionHtml seo{title description}}}} }'
Show-GQLErrors $r "products"
foreach ($e in $r.data.products.edges) { $byHandle[$e.node.handle] = $e.node }

foreach ($p in $PRODUCTS) {
  $node = $byHandle[$p.old]
  if (-not $node) {
    # Already renamed, or gone. Either way do not guess.
    if ($byHandle[$p.handle]) { Write-Output ("  skip  {0} - already {1}" -f $p.old, $p.handle) }
    else { Write-Output ("  MISS  {0} - not found under either handle" -f $p.old) }
    continue
  }

  $newDesc = Rename-Text $node.descriptionHtml
  $newSeoT = Rename-Text $node.seo.title
  $newSeoD = Rename-Text $node.seo.description

  Write-Output ("  {0}" -f $p.old)
  Write-Output ("      title  {0}  ->  {1}" -f $node.title, $p.title)
  Write-Output ("      handle {0}  ->  {1}" -f $node.handle, $p.handle)
  if (Changed $node.seo.title $newSeoT) { Write-Output ("      seo    {0}" -f $newSeoT) }

  if ($Apply) {
    $vars = @{ input = @{
      id              = $node.id
      title           = $p.title
      handle          = $p.handle
      descriptionHtml = $newDesc
      seo             = @{ title = $newSeoT; description = $newSeoD }
    } }
    $u = Send-GQL 'mutation($input:ProductInput!){ productUpdate(input:$input){ product{ id handle title } userErrors{ field message } } }' $vars
    Show-GQLErrors $u $p.old
    if ($u.data.productUpdate.userErrors) { $u.data.productUpdate.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.message) } }
  }
  $edits++
}

# ---------------------------------------------------------------------------
# 2. Product metafields - the EMBRAE fields quote sibling product names in
#    routine and how-to-use copy.
# ---------------------------------------------------------------------------
Write-Output ""
Write-Output "--- product metafields"
$r = Send-GQL 'query { products(first:50){edges{node{id handle metafields(first:30){edges{node{id namespace key value type}}}}}} }'
Show-GQLErrors $r "metafields"
foreach ($e in $r.data.products.edges) {
  foreach ($m in $e.node.metafields.edges) {
    $n = $m.node
    if ($n.value -isnot [string]) { continue }
    $new = Rename-Text $n.value
    if (-not (Changed $n.value $new)) { continue }
    Write-Output ("  {0} / {1}.{2}" -f $e.node.handle, $n.namespace, $n.key)
    if ($Apply) {
      $vars = @{ metafields = @(@{ ownerId = $e.node.id; namespace = $n.namespace; key = $n.key; type = $n.type; value = $new }) }
      $u = Send-GQL 'mutation($metafields:[MetafieldsSetInput!]!){ metafieldsSet(metafields:$metafields){ userErrors{ field message } } }' $vars
      Show-GQLErrors $u "metafield"
      if ($u.data.metafieldsSet.userErrors) { $u.data.metafieldsSet.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.message) } }
    }
    $edits++
  }
}

# ---------------------------------------------------------------------------
# 3. Metaobjects - routine steps and FAQ answers name products directly.
# ---------------------------------------------------------------------------
Write-Output ""
Write-Output "--- metaobjects"
foreach ($type in @('routine','faq','skin_concern','quiz_option','ingredient')) {
  $r = Send-GQL 'query($t:String!){ metaobjects(type:$t, first:80){edges{node{id handle fields{key value type}}}} }' @{ t = $type }
  Show-GQLErrors $r $type
  foreach ($e in $r.data.metaobjects.edges) {
    $updates = @()
    foreach ($f in $e.node.fields) {
      if ($f.value -isnot [string]) { continue }
      $new = Rename-Text $f.value
      if (Changed $f.value $new) { $updates += @{ key = $f.key; value = $new } }
    }
    if ($updates.Count -eq 0) { continue }
    Write-Output ("  {0}/{1} - {2} field(s)" -f $type, $e.node.handle, $updates.Count)
    if ($Apply) {
      $vars = @{ id = $e.node.id; metaobject = @{ fields = $updates } }
      $u = Send-GQL 'mutation($id:ID!,$metaobject:MetaobjectUpdateInput!){ metaobjectUpdate(id:$id, metaobject:$metaobject){ userErrors{ field message } } }' $vars
      Show-GQLErrors $u $e.node.handle
      if ($u.data.metaobjectUpdate.userErrors) { $u.data.metaobjectUpdate.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.message) } }
    }
    $edits++
  }
}

# ---------------------------------------------------------------------------
# 4. Collections and articles.
# ---------------------------------------------------------------------------
Write-Output ""
Write-Output "--- collections"
$r = Send-GQL 'query { collections(first:40){edges{node{id handle descriptionHtml seo{title description}}}} }'
Show-GQLErrors $r "collections"
foreach ($e in $r.data.collections.edges) {
  $n = $e.node
  $d = Rename-Text $n.descriptionHtml
  $st = Rename-Text $n.seo.title
  $sd = Rename-Text $n.seo.description
  if (-not ((Changed $n.descriptionHtml $d) -or (Changed $n.seo.title $st) -or (Changed $n.seo.description $sd))) { continue }
  Write-Output ("  {0}" -f $n.handle)
  if ($Apply) {
    $vars = @{ input = @{ id = $n.id; descriptionHtml = $d; seo = @{ title = $st; description = $sd } } }
    $u = Send-GQL 'mutation($input:CollectionInput!){ collectionUpdate(input:$input){ userErrors{ field message } } }' $vars
    Show-GQLErrors $u $n.handle
    if ($u.data.collectionUpdate.userErrors) { $u.data.collectionUpdate.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.message) } }
  }
  $edits++
}

Write-Output ""
Write-Output "--- articles"
$r = Send-GQL 'query { articles(first:50){edges{node{id handle title body summary}}} }'
Show-GQLErrors $r "articles"
foreach ($e in $r.data.articles.edges) {
  $n = $e.node
  $t = Rename-Text $n.title
  $b = Rename-Text $n.body
  $s = Rename-Text $n.summary
  if (-not ((Changed $n.title $t) -or (Changed $n.body $b) -or (Changed $n.summary $s))) { continue }
  Write-Output ("  {0}" -f $n.handle)
  if ($Apply) {
    $vars = @{ id = $n.id; article = @{ title = $t; body = $b; summary = $s } }
    $u = Send-GQL 'mutation($id:ID!,$article:ArticleUpdateInput!){ articleUpdate(id:$id, article:$article){ userErrors{ field message } } }' $vars
    Show-GQLErrors $u $n.handle
    if ($u.data.articleUpdate.userErrors) { $u.data.articleUpdate.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.message) } }
  }
  $edits++
}

Write-Output ""
Write-Output ("=== {0}: {1} object(s) affected" -f $mode, $edits)
if (-not $Apply) { Write-Output "Nothing was written. Re-run with -Apply." }
