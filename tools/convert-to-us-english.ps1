# Converts all Admin-side content from British to American spelling, and renames the
# handles, titles and tags that carry a British spelling in them.
#
# Run AFTER the local template conversion, because templates/index.json already points
# at `moisturizers` and the collection has to be renamed to match or the homepage row
# renders empty.
#
# Safe to re-run: every replacement is idempotent and renames are skipped if already done.

. (Join-Path $PSScriptRoot "gql.ps1")

# Visible copy only - same map as the local conversion.
$MAP = @(
  @("Moisturis","Moisturiz"), @("moisturis","moisturiz")
  @("Sulphate","Sulfate"),    @("sulphate","sulfate")
  @("Apologis","Apologiz"),   @("apologis","apologiz")
  @("Recognis","Recogniz"),   @("recognis","recogniz")
  @("Defence","Defense"),     @("defence","defense")
  @("Oxidis","Oxidiz"),       @("oxidis","oxidiz")
  @("Licence","License"),     @("licence","license")
  @("Ageing","Aging"),        @("ageing","aging")
  @("Grey","Gray"),           @("grey","gray")
  @("Catalogue","Catalog"),   @("catalogue","catalog")
  @("Neutralis","Neutraliz"), @("neutralis","neutraliz")
  @("Colour","Color"),        @("colour","color")
  @("Favourite","Favorite"),  @("favourite","favorite")
  @("Organis","Organiz"),     @("organis","organiz")
  @("Realis","Realiz"),       @("realis","realiz")
  @("Whilst","While"),        @("whilst","while")
  @("Programme","Program"),   @("programme","program")
)

function US([string]$t) {
  if ([string]::IsNullOrEmpty($t)) { return $t }
  foreach ($p in $MAP) { $t = $t.Replace($p[0], $p[1]) }
  return $t
}
function Changed([string]$a, [string]$b) { return ($a -ne $b) }

$mfSet = 'mutation set($m: [MetafieldsSetInput!]!) { metafieldsSet(metafields: $m) { metafields { id } userErrors { field message } } }'

# ============================================================ 1. collection rename
Write-Host "--- collections ---"
$r = Send-GQL 'query { collections(first: 40) { nodes { id handle title descriptionHtml seo { title description } ruleSet { rules { column relation condition } } metafields(first: 5, namespace: "embrae") { nodes { key type value } } } } }'
foreach ($c in $r.data.collections.nodes) {
  if ($c.handle -eq "frontpage") { continue }
  $newHandle = US $c.handle
  $newTitle  = US $c.title
  $newDesc   = US $c.descriptionHtml
  $newSeoT   = US $c.seo.title
  $newSeoD   = US $c.seo.description

  $input = @{ id = $c.id }
  $touch = $false
  if (Changed $c.handle $newHandle) { $input["handle"] = $newHandle; $touch = $true }
  if (Changed $c.title  $newTitle)  { $input["title"]  = $newTitle;  $touch = $true }
  if (Changed $c.descriptionHtml $newDesc) { $input["descriptionHtml"] = $newDesc; $touch = $true }
  if ((Changed $c.seo.title $newSeoT) -or (Changed $c.seo.description $newSeoD)) {
    $input["seo"] = @{ title = $newSeoT; description = $newSeoD }; $touch = $true
  }
  # the automated rule condition is a tag, and the tag itself changes
  if ($c.ruleSet -and $c.ruleSet.rules) {
    $rules = @(); $ruleTouch = $false
    foreach ($rule in $c.ruleSet.rules) {
      $nc = US $rule.condition
      if (Changed $rule.condition $nc) { $ruleTouch = $true }
      $rules += @{ column = $rule.column; relation = $rule.relation; condition = $nc }
    }
    if ($ruleTouch) { $input["ruleSet"] = @{ appliedDisjunctively = $false; rules = $rules }; $touch = $true }
  }

  if ($touch) {
    $u = Send-GQL 'mutation u($i: CollectionInput!) { collectionUpdate(input: $i) { collection { handle } userErrors { field message } } }' @{ i = $input }
    $e = @($u.data.collectionUpdate.userErrors | Where-Object { $_ })
    if ($e.Count -gt 0) { Write-Host ("FAIL  " + $c.handle + " " + ($e | ConvertTo-Json -Compress)) }
    else { Write-Host ("ok    collection " + $c.handle + " -> " + $u.data.collectionUpdate.collection.handle) }
  }

  # long-form copy metafields
  $sets = @()
  foreach ($m in $c.metafields.nodes) {
    $nv = US $m.value
    if (Changed $m.value $nv) { $sets += @{ ownerId = $c.id; namespace = "embrae"; key = $m.key; type = $m.type; value = $nv } }
  }
  if ($sets.Count -gt 0) {
    $s = Send-GQL $mfSet @{ m = $sets }
    $e = @($s.data.metafieldsSet.userErrors | Where-Object { $_ })
    if ($e.Count -gt 0) { Write-Host ("FAIL  copy/" + $c.handle + " " + ($e | ConvertTo-Json -Compress)) }
    else { Write-Host ("      copy updated: " + $c.handle) }
  }
}

# ============================================================ 2. products
Write-Host ""
Write-Host "--- products ---"
$r = Send-GQL 'query { products(first: 30) { nodes { id handle title descriptionHtml tags seo { title description } metafields(first: 15, namespace: "embrae") { nodes { key type value } } } } }'
foreach ($p in $r.data.products.nodes) {
  $newHandle = US $p.handle
  $newTitle  = US $p.title
  $newDesc   = US $p.descriptionHtml
  $newSeoT   = US $p.seo.title
  $newSeoD   = US $p.seo.description
  $newTags   = @($p.tags | ForEach-Object { US $_ })

  $input = @{ id = $p.id }
  $touch = $false
  if (Changed $p.handle $newHandle) { $input["handle"] = $newHandle; $touch = $true }
  if (Changed $p.title  $newTitle)  { $input["title"]  = $newTitle;  $touch = $true }
  if (Changed $p.descriptionHtml $newDesc) { $input["descriptionHtml"] = $newDesc; $touch = $true }
  if ((Changed $p.seo.title $newSeoT) -or (Changed $p.seo.description $newSeoD)) {
    $input["seo"] = @{ title = $newSeoT; description = $newSeoD }; $touch = $true
  }
  if (($p.tags -join "|") -ne ($newTags -join "|")) { $input["tags"] = $newTags; $touch = $true }

  if ($touch) {
    $u = Send-GQL 'mutation u($p: ProductUpdateInput!) { productUpdate(product: $p) { product { handle } userErrors { field message } } }' @{ p = $input }
    $e = @($u.data.productUpdate.userErrors | Where-Object { $_ })
    if ($e.Count -gt 0) { Write-Host ("FAIL  " + $p.handle + " " + ($e | ConvertTo-Json -Compress)) }
    else { Write-Host ("ok    product " + $p.handle + " -> " + $u.data.productUpdate.product.handle) }
  }

  $sets = @()
  foreach ($m in $p.metafields.nodes) {
    if ($m.type -like "*reference*") { continue }   # GIDs, never text
    $nv = US $m.value
    if (Changed $m.value $nv) { $sets += @{ ownerId = $p.id; namespace = "embrae"; key = $m.key; type = $m.type; value = $nv } }
  }
  if ($sets.Count -gt 0) {
    $s = Send-GQL $mfSet @{ m = $sets }
    $e = @($s.data.metafieldsSet.userErrors | Where-Object { $_ })
    if ($e.Count -gt 0) { Write-Host ("FAIL  mf/" + $p.handle + " " + ($e | ConvertTo-Json -Compress)) }
    else { Write-Host ("      metafields updated: " + $p.handle + " (" + $sets.Count + ")") }
  }
}

# ============================================================ 3. metaobjects
Write-Host ""
Write-Host "--- metaobjects ---"
foreach ($type in @("ingredient","skin_concern","faq","quiz_option","quiz_question","routine")) {
  $r = Send-GQL ('query { metaobjects(type: "' + $type + '", first: 100) { nodes { id handle fields { key value type } } } }')
  $n = 0
  foreach ($mo in $r.data.metaobjects.nodes) {
    $f = @()
    foreach ($fld in $mo.fields) {
      if (-not $fld.value) { continue }
      if ($fld.type -like "*reference*") { continue }
      $nv = US $fld.value
      if (Changed $fld.value $nv) { $f += @{ key = $fld.key; value = $nv } }
    }
    if ($f.Count -gt 0) {
      $u = Send-GQL 'mutation u($id: ID!, $mo: MetaobjectUpdateInput!) { metaobjectUpdate(id: $id, metaobject: $mo) { userErrors { field message } } }' @{ id = $mo.id; mo = @{ fields = $f } }
      $e = @($u.data.metaobjectUpdate.userErrors | Where-Object { $_ })
      if ($e.Count -gt 0) { Write-Host ("FAIL  $type/" + $mo.handle + " " + ($e | ConvertTo-Json -Compress)) }
      else { $n++ }
    }
  }
  Write-Host ("ok    $type - $n entries updated")
}

# ============================================================ 4. articles
Write-Host ""
Write-Host "--- articles ---"
$r = Send-GQL 'query { articles(first: 50) { nodes { id handle title body summary metafields(first: 5, namespace: "global") { nodes { key type value } } } } }'
foreach ($a in $r.data.articles.nodes) {
  $nt = US $a.title; $nb = US $a.body; $ns = US $a.summary
  if ((Changed $a.title $nt) -or (Changed $a.body $nb) -or (Changed $a.summary $ns)) {
    $u = Send-GQL 'mutation u($id: ID!, $article: ArticleUpdateInput!) { articleUpdate(id: $id, article: $article) { article { handle } userErrors { field message } } }' `
                  @{ id = $a.id; article = @{ title = $nt; body = $nb; summary = $ns } }
    $e = @($u.data.articleUpdate.userErrors | Where-Object { $_ })
    if ($e.Count -gt 0) { Write-Host ("FAIL  " + $a.handle + " " + ($e | ConvertTo-Json -Compress)) }
    else { Write-Host ("ok    article " + $a.handle) }
  }
  $sets = @()
  foreach ($m in $a.metafields.nodes) {
    $nv = US $m.value
    if (Changed $m.value $nv) { $sets += @{ ownerId = $a.id; namespace = "global"; key = $m.key; type = $m.type; value = $nv } }
  }
  if ($sets.Count -gt 0) { Send-GQL $mfSet @{ m = $sets } | Out-Null }
}

# ============================================================ 5. page + blog SEO metafields
Write-Host ""
Write-Host "--- page / blog SEO ---"
foreach ($q in @('query { pages(first: 30) { nodes { id handle metafields(first: 5, namespace: "global") { nodes { key type value } } } } }',
                 'query { blogs(first: 20) { nodes { id handle metafields(first: 5, namespace: "global") { nodes { key type value } } } } }')) {
  $r = Send-GQL $q
  $nodes = if ($r.data.pages) { $r.data.pages.nodes } else { $r.data.blogs.nodes }
  $sets = @()
  foreach ($n in $nodes) {
    foreach ($m in $n.metafields.nodes) {
      $nv = US $m.value
      if (Changed $m.value $nv) { $sets += @{ ownerId = $n.id; namespace = "global"; key = $m.key; type = $m.type; value = $nv } }
    }
  }
  if ($sets.Count -gt 0) {
    Send-GQL $mfSet @{ m = $sets } | Out-Null
    Write-Host ("      updated " + $sets.Count + " SEO metafields")
  } else { Write-Host "      nothing to change" }
}

Write-Host ""
Write-Host "done. Menus are rebuilt separately - their URLs point at /collections/moisturizers now."
