# Runs one named operation from a .graphql file against the store's Admin API.
#
#   .\tools\admin-run.ps1 -File sample-data\embrae-catalogue.graphql -Operation Step1_Collections
#   .\tools\admin-run.ps1 -File sample-data\embrae-catalogue.graphql -Operation Step4_Verify -Raw
#
# Reads credentials from .env so the token never appears in a command line or in
# shell history. Prints one line per aliased mutation: ok + handle, or FAIL + the
# userErrors. -Raw dumps the whole data payload instead, for queries.

param(
  [Parameter(Mandatory = $true)][string]$File,
  [Parameter(Mandatory = $true)][string]$Operation,
  [switch]$Raw
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$envPath = Join-Path $root ".env"
if (-not (Test-Path $envPath)) { throw ".env not found at $envPath" }

$cfg = @{}
Get-Content $envPath | ForEach-Object {
  if ($_ -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') { $cfg[$Matches[1]] = $Matches[2].Trim() }
}
foreach ($k in @("SHOPIFY_ADMIN_TOKEN", "SHOPIFY_STORE", "SHOPIFY_API_VERSION")) {
  if (-not $cfg.ContainsKey($k) -or [string]::IsNullOrWhiteSpace($cfg[$k])) { throw "$k missing from .env" }
}

$uri = "https://$($cfg['SHOPIFY_STORE'])/admin/api/$($cfg['SHOPIFY_API_VERSION'])/graphql.json"

# ConvertTo-Json in Windows PowerShell 5.1 serialises long strings as
# {"value":...,"Count":...} instead of a plain string, which Shopify rejects with
# `expected Hash to be a String`. JavaScriptSerializer does not have that bug.
Add-Type -AssemblyName System.Web.Extensions
$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$ser.MaxJsonLength = [int]::MaxValue
$json = $ser.Serialize(@{ query = [string](Get-Content $File -Raw); operationName = $Operation })
$body = [System.Text.Encoding]::UTF8.GetBytes($json)

try {
  $r = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ "X-Shopify-Access-Token" = $cfg['SHOPIFY_ADMIN_TOKEN'] } -ContentType "application/json; charset=utf-8" -Body $body -ErrorAction Stop
}
catch {
  Write-Output "HTTP FAILURE: $($_.Exception.Message)"
  try {
    $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    Write-Output ("body: " + $sr.ReadToEnd())
  }
  catch {}
  exit 1
}

if ($r.errors) {
  Write-Output "GRAPHQL ERRORS"
  $r.errors | ConvertTo-Json -Depth 6
}

if ($Raw) {
  $r.data | ConvertTo-Json -Depth 10
  return
}

$ok = 0; $bad = 0
foreach ($p in $r.data.PSObject.Properties) {
  $v = $p.Value
  $errs = @($v.userErrors)
  if ($errs.Count -gt 0) {
    $bad++
    $msg = ($errs | ForEach-Object { "[$($_.field -join '.')] $($_.message)" }) -join "  |  "
    Write-Output ("FAIL  {0,-22} {1}" -f $p.Name, $msg)
  }
  else {
    $ok++
    $node = $v.collection; if (-not $node) { $node = $v.page }
    if (-not $node) { $node = $v.blog }; if (-not $node) { $node = $v.menu }
    Write-Output ("ok    {0,-22} -> {1}" -f $p.Name, $node.handle)
  }
}
Write-Output ""
Write-Output "$Operation : $ok ok, $bad failed"
