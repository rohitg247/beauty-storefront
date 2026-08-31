# Sets embrae.benefit_line on the four bundles to the Master Brief section 9
# "customer-facing purpose" wording, verbatim.
#
#   pwsh -File .\tools\seed-bundle-benefit-lines.ps1
#   pwsh -File .\tools\seed-bundle-benefit-lines.ps1 -WhatIf
#
# The bundle NAMES already match section 9 exactly - they were seeded that way.
# Only the purpose line differed, and the brief is explicit that this column is
# the customer-facing description of each solution.
#
# benefit_line is rendered on the PDP directly under the title (added in scope
# (f) phase 4), so this is the line a customer reads before the price.

[CmdletBinding()]
param([switch]$WhatIf)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "gql.ps1")

# Master Brief section 9, verbatim.
$Lines = @(
  @{ h = "barrier-support-duo";         v = "A simple foundation for daily cleansing and barrier-supportive hydration." }
  @{ h = "am-defense-routine";          v = "Your morning routine for cleansing, daily defense and UV protection." }
  @{ h = "pm-recovery-routine";         v = "Your evening routine to cleanse, support and replenish." }
  @{ h = "daily-urban-defense-routine"; v = "The complete EMBRAE routine." }
)

$metafields = @()
foreach ($l in $Lines) {
  $r = Send-GQL 'query($h:String!){ productByIdentifier(identifier:{handle:$h}){ id title } }' @{ h = $l.h }
  Show-GQLErrors $r "lookup $($l.h)"
  $node = $r.data.productByIdentifier
  if (-not $node) { throw "Product not found: $($l.h). Nothing was written." }
  Write-Output ("  {0,-30} {1}" -f $l.h, $l.v)
  $metafields += @{ ownerId = $node.id; namespace = "embrae"; key = "benefit_line"; type = "single_line_text_field"; value = $l.v }
}

if ($WhatIf) { Write-Output "WHATIF: would write $($metafields.Count) benefit lines"; return }

$r = Send-GQL 'mutation($m:[MetafieldsSetInput!]!){ metafieldsSet(metafields:$m){ metafields{ key } userErrors{ field message } } }' @{ m = $metafields }
Show-GQLErrors $r "metafieldsSet"
if ($r.data.metafieldsSet.userErrors) { $r.data.metafieldsSet.userErrors | ConvertTo-Json -Compress; throw "metafieldsSet failed" }
Write-Output "wrote $($r.data.metafieldsSet.metafields.Count) benefit lines"

# Read back rather than trusting the write.
Start-Sleep -Seconds 2
$check = Send-GQL 'query { products(first:20, query:"product_type:Bundle"){ nodes{ handle metafield(namespace:"embrae", key:"benefit_line"){ value } } } }'
Show-GQLErrors $check "readback"
$check.data.products.nodes | ForEach-Object { "  readback {0,-30} {1}" -f $_.handle, $_.metafield.value }
