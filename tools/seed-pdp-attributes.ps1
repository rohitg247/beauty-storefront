# Populates the two PDP metafields added for the Phase 4 product page:
# embrae.benefit_line and embrae.attributes.
#
#   pwsh -File .\tools\seed-pdp-attributes.ps1
#   pwsh -File .\tools\seed-pdp-attributes.ps1 -WhatIf
#
# ---------------------------------------------------------------------------
# READ THIS BEFORE THE STORE GOES LIVE
#
# The attribute rows below are CLAIMS, and none of them is documented. They are
# here so the design can be reviewed against board panel 4, on a development
# store that is explicitly not launching on this data.
#
# "Dermatologist tested" and "Non-comedogenic" in particular are tested claims,
# not descriptions - each needs a report behind it. Per the Build Brief, an
# undocumented claim gets DELETED, not softened. Every value is itemised in
# docs/admin-tasks.md section 15b.
#
# Benefit lines are written from the Build Brief section 7 routine architecture
# (RESET / DEFEND / ADAPT / PROTECT), which is strategic positioning rather than
# product data, so they are safe as placeholder copy. They still need brand
# sign-off before launch.
#
# NOTE ON NAMES: the catalogue uses Clarity Cleanser, Radiance Serum, Barrier
# Moisturizer and Daily Defense Sunscreen. The Build Brief and the prototype
# boards use Barrier Reset Cleanser, Urban Defense Serum, Climate Adapt
# Moisturizer and Daily Shield SPF50 PA++++. That is an open discrepancy for the
# merchant - renaming changes handles and needs urlRedirects - so this script
# keeps the store's own names.
# ---------------------------------------------------------------------------

[CmdletBinding()]
param([switch]$WhatIf)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "gql.ps1")

$Data = @(
  @{ handle = "clarity-cleanser"
     benefit = "Clears the day off your skin without stripping the barrier."
     attrs = @("Lightweight", "Fragrance-free", "Non-comedogenic", "Dermatologist tested") }
  @{ handle = "radiance-serum"
     benefit = "Strengthens the barrier and helps skin defend against daily urban stress."
     attrs = @("Fast absorbing", "Fragrance-free", "Non-comedogenic", "Dermatologist tested") }
  @{ handle = "barrier-moisturizer"
     benefit = "Replenishes hydration and helps skin adapt to changing conditions."
     attrs = @("Lightweight", "Fragrance-free", "Non-comedogenic", "Dermatologist tested") }
  @{ handle = "daily-defense-sunscreen"
     benefit = "High UV protection that stays comfortable enough to wear every day."
     attrs = @("No white cast", "Fragrance-free", "Non-comedogenic", "Dermatologist tested") }
  @{ handle = "starter-duo-set"
     benefit = "Two steps to start with, chosen to work together."
     attrs = @("Two full-size products", "Fragrance-free") }
  @{ handle = "morning-ritual-set"
     benefit = "The morning sequence, in the order it should be used."
     attrs = @("Three full-size products", "Fragrance-free") }
  @{ handle = "evening-ritual-set"
     benefit = "The evening sequence, for when skin does its repair work."
     attrs = @("Three full-size products", "Fragrance-free") }
  @{ handle = "complete-routine-set"
     benefit = "All four routine steps together: reset, defend, adapt, protect."
     attrs = @("Four full-size products", "Fragrance-free") }
  @{ handle = "travel-barrier-moisturizer"
     benefit = "The same barrier support, sized for cabin baggage."
     attrs = @("Travel size", "Fragrance-free", "Non-comedogenic") }
)

$ok = 0; $skipped = @()

foreach ($d in $Data) {
  $q = 'query { productByIdentifier(identifier: { handle: "' + $d.handle + '" }) { id title } }'
  $r = Send-GQL $q
  $prod = $r.data.productByIdentifier
  if (-not $prod) { Write-Warning "not found: $($d.handle)"; $skipped += $d.handle; continue }

  if ($WhatIf) {
    Write-Output ("  [plan] {0,-30} {1} attrs" -f $d.handle, $d.attrs.Count)
    continue
  }

  # attributes is list.single_line_text_field, so the value is a JSON array
  # encoded as a string.
  $attrsJson = ConvertTo-Json $d.attrs -Compress
  if ($d.attrs.Count -eq 1) { $attrsJson = "[" + (ConvertTo-Json $d.attrs[0]) + "]" }

  $mut = 'mutation { metafieldsSet(metafields: [' +
    '{ ownerId: ' + (ConvertTo-Json $prod.id) + ', namespace: "embrae", key: "benefit_line", type: "single_line_text_field", value: ' + (ConvertTo-Json $d.benefit) + ' },' +
    '{ ownerId: ' + (ConvertTo-Json $prod.id) + ', namespace: "embrae", key: "attributes", type: "list.single_line_text_field", value: ' + (ConvertTo-Json $attrsJson) + ' }' +
    ']) { metafields { key } userErrors { field message } } }'

  $res = Send-GQL $mut
  if ($res.errors) { Write-Warning "$($d.handle): $($res.errors | ConvertTo-Json -Depth 5)"; $skipped += $d.handle; continue }
  $ue = $res.data.metafieldsSet.userErrors
  if ($ue -and $ue.Count) { Write-Warning "$($d.handle): $($ue | ConvertTo-Json -Depth 5)"; $skipped += $d.handle; continue }

  Write-Output ("  [ok]   {0,-30} benefit + {1} attributes" -f $d.handle, $d.attrs.Count)
  $ok++
}

if ($WhatIf) { Write-Output ""; Write-Output "WhatIf: nothing written."; return }
Write-Output ""
Write-Output "Set metafields on $ok of $($Data.Count) products."
if ($skipped.Count) { Write-Output "Skipped: $($skipped -join ', ')" }
