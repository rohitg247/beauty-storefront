# Brings the discounts in line with the announcement bar.
#
#   .\tools\seed-offers.ps1            # dry run
#   .\tools\seed-offers.ps1 -Apply     # writes
#
# The announcement bar rotates three offers. Two of them have to be real
# discounts or the bar advertises something checkout cannot honour:
#
#   1. "Extra 5% off on prepaid orders"        NOT BUILDABLE HERE - see below
#   2. "Rs100 off your first order above Rs999"  code discount, replaces WELCOME10
#   3. "Free shipping on orders over Rs599"      shipping rate, merchant-only
#
# ON THE PREPAID DISCOUNT: Shopify cannot natively discount by payment method.
# It needs Shopify Functions or an Indian checkout app - Razorpay Magic, GoKwik
# or Shiprocket Checkout all do prepaid-vs-COD pricing. This rides with the
# payment-gateway decision. Until then the announcement promises something the
# checkout will not apply.
#
# ON "FIRST ORDER": Shopify has no native first-order-only condition on a basic
# code discount. "One use per customer" is the closest native equivalent and is
# what the previous WELCOME10 used. A returning customer who never used the code
# can still use it once.
#
# ON THE FREE GIFT: re-pointed from a Rs2,499 spend threshold to buying the
# Daily Urban Defense Routine specifically, per the merchant's decision.

param([switch]$Apply)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "gql.ps1")

$mode = if ($Apply) { "APPLY" } else { "DRY RUN" }
Write-Output "=== EMBRAE offers - $mode ==="

# --- resolve the two products the gift discount needs -----------------------
$prods = @{}
$r = Send-GQL 'query { products(first:50){edges{node{id handle title}}} }'
Show-GQLErrors $r "products"
foreach ($e in $r.data.products.edges) { $prods[$e.node.handle] = $e.node.id }

$BUY  = "daily-urban-defense-routine"
$GIFT = "travel-essentials-pouch"
foreach ($h in @($BUY, $GIFT)) {
  if (-not $prods.ContainsKey($h)) { Write-Output ("FAIL - product not found: " + $h); exit 1 }
}
Write-Output ("  buy  " + $BUY  + "  " + $prods[$BUY])
Write-Output ("  gift " + $GIFT + "  " + $prods[$GIFT])

# --- find the existing discounts --------------------------------------------
$existing = @{}
$r = Send-GQL 'query { discountNodes(first:50){edges{node{id discount{
  ... on DiscountCodeBasic { title }
  ... on DiscountAutomaticBasic { title }
  ... on DiscountAutomaticBxgy { title }
}}}} }'
Show-GQLErrors $r "discounts"
foreach ($e in $r.data.discountNodes.edges) { if ($e.node.discount.title) { $existing[$e.node.discount.title] = $e.node.id } }

# ---------------------------------------------------------------------------
# 1. Rs100 off first order above Rs999 - replaces the 10% version.
# ---------------------------------------------------------------------------
Write-Output ""
Write-Output "--- code discount: Rs100 off above Rs999 (code WELCOME100)"
$oldTitle = "Welcome - 10% off first order"
if ($existing.ContainsKey($oldTitle)) {
  Write-Output ("  updating in place: " + $existing[$oldTitle])
  if ($Apply) {
    $vars = @{
      id = $existing[$oldTitle]
      discount = @{
        title = "Rs100 off your first order above Rs999"
        code  = "WELCOME100"
        customerGets = @{
          value = @{ discountAmount = @{ amount = 100.0; appliesOnEachItem = $false } }
          items = @{ all = $true }
        }
        minimumRequirement = @{ subtotal = @{ greaterThanOrEqualToSubtotal = 999.0 } }
        appliesOncePerCustomer = $true
      }
    }
    $u = Send-GQL 'mutation($id:ID!,$discount:DiscountCodeBasicInput!){ discountCodeBasicUpdate(id:$id, basicCodeDiscount:$discount){ codeDiscountNode{ id } userErrors{ field message } } }' $vars
    Show-GQLErrors $u "welcome100"
    if ($u.data.discountCodeBasicUpdate.userErrors) { $u.data.discountCodeBasicUpdate.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.field + ": " + $_.message) } }
    else { Write-Output "      ok" }
  }
} else {
  Write-Output ("  NOT FOUND: '" + $oldTitle + "' - nothing updated. Check the title by hand.")
}

# ---------------------------------------------------------------------------
# 2. Free Travel Essentials Pouch with the Daily Urban Defense Routine.
# ---------------------------------------------------------------------------
Write-Output ""
Write-Output "--- automatic: free pouch with the Daily Urban Defense Routine"
$giftTitle = "Free travel size over Rs2,499"
$newGift = "Free Travel Essentials Pouch with the Daily Urban Defense Routine"

$bxgy = @{
  title = $newGift
  startsAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  customerBuys = @{
    value = @{ quantity = "1" }
    items = @{ products = @{ productsToAdd = @($prods[$BUY]) } }
  }
  customerGets = @{
    value = @{ discountOnQuantity = @{ quantity = "1"; effect = @{ percentage = 1.0 } } }
    items = @{ products = @{ productsToAdd = @($prods[$GIFT]) } }
  }
  usesPerOrderLimit = "1"
}

if ($existing.ContainsKey($giftTitle)) {
  Write-Output ("  replacing: " + $giftTitle)
  if ($Apply) {
    $d = Send-GQL 'mutation($id:ID!){ discountAutomaticDelete(id:$id){ deletedAutomaticDiscountId userErrors{ message } } }' @{ id = $existing[$giftTitle] }
    Show-GQLErrors $d "delete-gift"
  }
} else {
  Write-Output "  no existing spend-threshold gift found; creating fresh"
}

if ($Apply) {
  $u = Send-GQL 'mutation($discount:DiscountAutomaticBxgyInput!){ discountAutomaticBxgyCreate(automaticBxgyDiscount:$discount){ automaticDiscountNode{ id } userErrors{ field message } } }' @{ discount = $bxgy }
  Show-GQLErrors $u "gift"
  if ($u.data.discountAutomaticBxgyCreate.userErrors) { $u.data.discountAutomaticBxgyCreate.userErrors | ForEach-Object { Write-Output ("      ERROR " + $_.field + ": " + $_.message) } }
  else { Write-Output "      ok" }
}

# ---------------------------------------------------------------------------
Write-Output ""
if ($Apply) {
  Start-Sleep -Seconds 3
  Write-Output "--- read-back"
  $r = Send-GQL 'query { discountNodes(first:30){edges{node{discount{
    ... on DiscountCodeBasic { title status summary codes(first:2){edges{node{code}}} }
    ... on DiscountAutomaticBasic { title status summary }
    ... on DiscountAutomaticBxgy { title status summary }
  }}}} }'
  foreach ($e in $r.data.discountNodes.edges) {
    $d = $e.node.discount
    if (-not $d.title) { continue }
    $codes = ""
    if ($d.codes) { $codes = "  [" + (($d.codes.edges | ForEach-Object { $_.node.code }) -join ",") + "]" }
    Write-Output ("  {0,-58} {1}{2}" -f $d.title, $d.status, $codes)
    Write-Output ("      " + $d.summary)
  }
  Write-Output ""
  Write-Output "STILL NOT BUILT: the 5% prepaid discount. Needs the payment gateway."
  Write-Output "STILL NOT BUILT: free shipping over Rs599 is a SHIPPING RATE -"
  Write-Output "  Admin > Settings > Shipping and delivery > add a free rate with a"
  Write-Output "  Rs599 minimum. The theme's progress bar already counts to Rs599."
} else {
  Write-Output "Nothing was written. Re-run with -Apply."
}
