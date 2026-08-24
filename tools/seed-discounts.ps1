# Creates the two discounts the storefront copy already promises:
#   1. WELCOME10  - 10% off a first order, one use per customer
#   2. Automatic  - spend Rs2,499, get the travel-size Climate Adapt Moisturizer free
#
# MOCK THRESHOLDS. Rs1,499 free shipping and Rs2,499 for the gift are assumed, not
# confirmed by the merchant. Confirm before launch - the homepage advertises them.

. (Join-Path $PSScriptRoot "gql.ps1")

$r = Send-GQL 'query { products(first: 30, query: "handle:travel-essentials-pouch") { nodes { id handle variants(first: 1) { nodes { id } } } } collections(first: 40, query: "handle:skincare") { nodes { id handle } } }'
$gift = $r.data.products.nodes | Select-Object -First 1
if (-not $gift) { Write-Host "FAIL - travel-essentials-pouch not found"; exit 1 }
# BXGY rejects `items: { all: true }` on customerBuys with "Items in 'customer buys' must be
# defined" - it needs explicit products or collections. The `skincare` collection holds all
# nine products, so it stands in for "anything in the catalog".
$all = $r.data.collections.nodes | Where-Object { $_.handle -eq "skincare" } | Select-Object -First 1
if (-not $all) { Write-Host "FAIL - skincare collection not found"; exit 1 }

$start = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# --- 1. WELCOME10 -----------------------------------------------------------
$q1 = 'mutation c($d: DiscountCodeBasicInput!) { discountCodeBasicCreate(basicCodeDiscount: $d) { codeDiscountNode { id } userErrors { field message } } }'
$v1 = @{ d = @{
  title = "Welcome - 10% off first order"
  code = "WELCOME10"
  startsAt = $start
  appliesOncePerCustomer = $true
  usageLimit = $null
  customerSelection = @{ all = $true }
  customerGets = @{
    value = @{ percentage = 0.1 }
    items = @{ all = $true }
  }
  minimumRequirement = @{ subtotal = @{ greaterThanOrEqualToSubtotal = "999.00" } }
} }
$r1 = Send-GQL $q1 $v1
$e1 = @($r1.data.discountCodeBasicCreate.userErrors | Where-Object { $_ })
if (-not $r1.data.discountCodeBasicCreate -or $e1.Count -gt 0) {
  Write-Host ("FAIL  WELCOME10 " + ($e1 | ConvertTo-Json -Compress))
  if ($r1.errors) { Write-Host ($r1.errors | ConvertTo-Json -Depth 5 -Compress) }
} else { Write-Host "ok    WELCOME10 - 10% off, min Rs999, once per customer" }

# --- 2. free gift over Rs2,499 ---------------------------------------------
# Written as an inline mutation rather than with variables: JavaScriptSerializer
# flattens the deeply nested `effect` hashtable into the string "@{percentage=1}",
# and collapses a single-element productsToAdd array into a bare string. Inlining
# the literals avoids both.
$q2 = @"
mutation {
  discountAutomaticBxgyCreate(automaticBxgyDiscount: {
    title: "Free travel size over Rs2,499"
    startsAt: "$start"
    usesPerOrderLimit: "1"
    customerBuys: {
      value: { amount: "2499.00" }
      items: { collections: { add: ["$($all.id)"] } }
    }
    customerGets: {
      value: { discountOnQuantity: { quantity: "1", effect: { percentage: 1.0 } } }
      items: { products: { productsToAdd: ["$($gift.id)"] } }
    }
  }) {
    automaticDiscountNode { id }
    userErrors { field message }
  }
}
"@
$r2 = Send-GQL $q2
$e2 = @($r2.data.discountAutomaticBxgyCreate.userErrors | Where-Object { $_ })
if (-not $r2.data.discountAutomaticBxgyCreate -or $e2.Count -gt 0) {
  Write-Host ("FAIL  free gift " + ($e2 | ConvertTo-Json -Compress))
  if ($r2.errors) { Write-Host ($r2.errors | ConvertTo-Json -Depth 5 -Compress) }
} else { Write-Host "ok    free travel size on orders over Rs2,499" }
