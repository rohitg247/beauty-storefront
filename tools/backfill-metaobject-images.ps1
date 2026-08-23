# Fills the `image` field on any ingredient or skin_concern entry that does not have one.
#
# Split out from the main seed because LoremFlickr rate-limits: hammering it returns 500,
# and the seed run lost 10 of 12 images that way. This paces requests and retries with
# backoff, and it is safe to re-run - entries that already have an image are skipped.

. (Join-Path $PSScriptRoot "upload-image.ps1")

$keywords = @{
  "niacinamide"="serum,skincare"; "vitamin-c"="orange,fruit"; "hyaluronic-acid"="water,drop"
  "salicylic-acid"="soap,bathroom"; "squalane"="olive,oil"; "ceramides"="cream,lotion"
  "dullness"="portrait,face"; "dryness"="desert,dry"; "breakouts"="portrait,skin"
  "pigmentation"="sun,light"; "fine-lines"="eye,portrait"; "sensitivity"="flower,soft"
}

function Get-ImageWithRetry {
  param([string]$Keyword, [string]$Filename, [string]$Alt, [int]$Tries = 4)
  for ($i = 1; $i -le $Tries; $i++) {
    try {
      return Add-EmbraeFile -Source ("https://loremflickr.com/1280/1280/" + $Keyword) -Filename $Filename -Alt $Alt
    } catch {
      if ($i -eq $Tries) {
        # Last resort: a branded card always works, and a branded card beats a blank slot.
        Write-Host ("      photo source gave up after $Tries tries, using branded card")
        $label = ($Filename -replace '^embrae-(ingredient|concern)-', '' -replace '\.jpg$', '') -replace '-', '+'
        return Add-EmbraeFile -Source ("https://placehold.co/1600x1600/034638/F3CFB3.png?text=" + $label) -Filename ($Filename -replace '\.jpg$', '.png') -Alt $Alt
      }
      Start-Sleep -Seconds ($i * 12)
    }
  }
}

$q = 'query($t: String!) { metaobjects(type: $t, first: 30) { nodes { id handle displayName field(key: "image") { value } } } }'
$done = 0; $skipped = 0

foreach ($type in @("ingredient", "skin_concern")) {
  $r = Send-GQL $q @{ t = $type }
  foreach ($n in $r.data.metaobjects.nodes) {
    if ($n.field.value) { $skipped++; continue }
    $pre = if ($type -eq "ingredient") { "ingredient" } else { "concern" }
    $kw = $keywords[$n.handle]
    if (-not $kw) { $kw = "skincare" }
    $fn = "embrae-$pre-$($n.handle).jpg"
    $alt = "$($n.displayName) - EMBRAE $pre library"
    Write-Output ("  fetching $fn")
    try {
      $gid = Get-ImageWithRetry -Keyword $kw -Filename $fn -Alt $alt
      $u = Send-GQL 'mutation($id: ID!, $mo: MetaobjectUpdateInput!) { metaobjectUpdate(id: $id, metaobject: $mo) { userErrors { field message } } }' `
                    @{ id = $n.id; mo = @{ fields = @(@{ key = "image"; value = $gid }) } }
      if (@($u.data.metaobjectUpdate.userErrors).Count -gt 0) { Write-Output ("FAIL  $($n.handle) " + ($u.data.metaobjectUpdate.userErrors | ConvertTo-Json -Compress)) }
      else { Write-Output ("ok    $type/$($n.handle)"); $done++ }
    } catch { Write-Output ("FAIL  $($n.handle) - " + $_.Exception.Message) }
    Start-Sleep -Seconds 3
  }
}

Write-Output ""
Write-Output "images attached: $done   already had one: $skipped"
