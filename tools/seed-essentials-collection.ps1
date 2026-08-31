# Creates the `essentials` collection that the homepage "Start with your skin" row needs.
#
#   pwsh -File .\tools\seed-essentials-collection.ps1
#   pwsh -File .\tools\seed-essentials-collection.ps1 -WhatIf
#
# WHY THIS EXISTS
#
# Master Brief section 6.5 requires exactly the four core singles, in the routine order
# RESET -> DEFEND -> ADAPT -> PROTECT. The row cannot be driven off `bestsellers`: that
# collection carries six products (the four singles plus AM Defense Routine and Daily Urban
# Defense Routine), so `products_to_show: 4` returns a non-deterministic four.
#
# WHY MANUAL RATHER THAN AUTOMATED
#
# An automated ruleset can select the right four (tag=skincare AND type!=Bundle AND
# type!=Gift) but cannot ORDER them. Automated collections reject MANUAL sort, and every
# other sort order puts the routine out of sequence - ALPHA_ASC gives RESET, ADAPT, PROTECT,
# DEFEND. There will only ever be four core singles, so a manual collection is both correct
# and simpler.
#
# CLAUDE.md: this runs BEFORE templates/index.json is pointed at the handle. A collection
# setting naming a handle with nothing behind it renders empty and silently.

[CmdletBinding()]
param([switch]$WhatIf)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "gql.ps1")

$Handle = "essentials"
$Title  = "The EMBRAE Essentials"

# Routine order is the point of this collection. Do not sort this list.
$ProductHandles = @(
  "barrier-reset-cleanser",     # RESET
  "urban-defense-serum",        # DEFEND
  "climate-adapt-moisturizer",  # ADAPT
  "daily-shield-spf50"          # PROTECT
)

$DescriptionHtml = @"
<p>Four essentials. One climate-conscious routine. Each product does one job: reset the skin from daily environmental buildup, defend it against urban stressors, help it adapt to changing conditions, and protect it from UV.</p>
<p>Bought together as a routine, these four are the <a href="/products/daily-urban-defense-routine">Daily Urban Defense Routine</a>.</p>
"@

$SeoTitle = "The Four EMBRAE Essentials | Cleanser, Serum, Moisturizer, SPF"
$SeoDesc  = "The four core EMBRAE products in routine order: Barrier Reset Cleanser, Urban Defense Serum, Climate Adapt Moisturizer and Daily Shield SPF 50 PA++++."

# --- resolve product ids, in the order above -------------------------------------------
$ids = @()
foreach ($h in $ProductHandles) {
  $r = Send-GQL 'query($h:String!){ productByIdentifier(identifier:{handle:$h}){ id title } }' @{ h = $h }
  Show-GQLErrors $r "lookup $h"
  $node = $r.data.productByIdentifier
  if (-not $node) { throw "Product not found: $h. Nothing was created." }
  Write-Output ("  resolved {0,-30} {1}" -f $h, $node.title)
  $ids += $node.id
}

# --- does it already exist? -------------------------------------------------------------
$existing = Send-GQL 'query($q:String!){ collections(first:1, query:$q){ nodes{ id handle } } }' @{ q = "handle:$Handle" }
Show-GQLErrors $existing "existing lookup"
$existingId = $existing.data.collections.nodes[0].id

if ($WhatIf) {
  Write-Output "WHATIF: would $(if ($existingId) { 'update ' + $existingId } else { 'create /collections/' + $Handle }) with $($ids.Count) products"
  return
}

if ($existingId) {
  $r = Send-GQL 'mutation($in:CollectionInput!){ collectionUpdate(input:$in){ collection{ id handle } userErrors{ field message } } }' @{
    in = @{ id = $existingId; title = $Title; descriptionHtml = $DescriptionHtml
            seo = @{ title = $SeoTitle; description = $SeoDesc }
            sortOrder = "MANUAL"; products = $ids }
  }
  Show-GQLErrors $r "collectionUpdate"
  if ($r.data.collectionUpdate.userErrors) { $r.data.collectionUpdate.userErrors | ConvertTo-Json -Compress; throw "collectionUpdate failed" }
  $collectionId = $r.data.collectionUpdate.collection.id
  Write-Output "updated $collectionId"
} else {
  $r = Send-GQL 'mutation($in:CollectionInput!){ collectionCreate(input:$in){ collection{ id handle } userErrors{ field message } } }' @{
    in = @{ title = $Title; handle = $Handle; descriptionHtml = $DescriptionHtml
            seo = @{ title = $SeoTitle; description = $SeoDesc }
            sortOrder = "MANUAL"; products = $ids }
  }
  Show-GQLErrors $r "collectionCreate"
  if ($r.data.collectionCreate.userErrors) { $r.data.collectionCreate.userErrors | ConvertTo-Json -Compress; throw "collectionCreate failed" }
  $collectionId = $r.data.collectionCreate.collection.id
  Write-Output "created $collectionId"
}

# --- publish to the Online Store channel ------------------------------------------------
# Without this the collection 404s on the storefront while looking perfectly correct in
# Admin. That failure mode has already cost this project a session.
$pubs = Send-GQL 'query{ publications(first:20, catalogType:APP){ nodes{ id name } } }'
Show-GQLErrors $pubs "publications"
$online = $pubs.data.publications.nodes | Where-Object { $_.name -eq "Online Store" } | Select-Object -First 1
if (-not $online) { throw "Online Store publication not found - collection created but NOT published." }

$r = Send-GQL 'mutation($id:ID!,$pid:ID!){ publishablePublish(id:$id, input:{publicationId:$pid}){ userErrors{ field message } } }' @{ id = $collectionId; pid = $online.id }
Show-GQLErrors $r "publishablePublish"
if ($r.data.publishablePublish.userErrors) { $r.data.publishablePublish.userErrors | ConvertTo-Json -Compress; throw "publish failed" }

Write-Output "published to Online Store"

# --- read back, in order ----------------------------------------------------------------
Start-Sleep -Seconds 2
$check = Send-GQL 'query($h:String!){ collectionByIdentifier(identifier:{handle:$h}){ id handle title productsCount{count} products(first:10){nodes{handle}} } }' @{ h = $Handle }
Show-GQLErrors $check "readback"
$c = $check.data.collectionByIdentifier
if (-not $c) { throw "READBACK FAILED - /collections/$Handle does not resolve." }
Write-Output "/collections/$($c.handle) -> $($c.productsCount.count) products: $(($c.products.nodes | ForEach-Object { $_.handle }) -join ' -> ')"
