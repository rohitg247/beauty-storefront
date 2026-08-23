# Dot-source this to get Send-GQL in any script:
#   . .\tools\gql.ps1
#   $r = Send-GQL 'query { shop { name } }'
#
# Reads .env so the token never appears in a command line or shell history.
# Throws on HTTP failure; returns the parsed response (check .errors yourself).

$ErrorActionPreference = "Stop"

$script:EmbraeCfg = @{}
Get-Content (Join-Path $PSScriptRoot "..\.env") | ForEach-Object {
  if ($_ -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') { $script:EmbraeCfg[$Matches[1]] = $Matches[2].Trim() }
}
$script:EmbraeUri = "https://$($script:EmbraeCfg['SHOPIFY_STORE'])/admin/api/$($script:EmbraeCfg['SHOPIFY_API_VERSION'])/graphql.json"

Add-Type -AssemblyName System.Web.Extensions
$script:EmbraeSer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$script:EmbraeSer.MaxJsonLength = [int]::MaxValue

function Send-GQL {
  param([Parameter(Mandatory=$true)][string]$Query, [hashtable]$Variables)
  $payload = @{ query = $Query }
  if ($Variables) { $payload["variables"] = $Variables }
  # ConvertTo-Json in PS 5.1 mangles long strings into {"value":...}; JavaScriptSerializer does not.
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($script:EmbraeSer.Serialize($payload))
  try {
    return Invoke-RestMethod -Method Post -Uri $script:EmbraeUri `
      -Headers @{ "X-Shopify-Access-Token" = $script:EmbraeCfg['SHOPIFY_ADMIN_TOKEN'] } `
      -ContentType "application/json; charset=utf-8" -Body $bytes -ErrorAction Stop
  } catch {
    Write-Output "HTTP FAILURE: $($_.Exception.Message)"
    try { $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Output ("body: " + $sr.ReadToEnd()) } catch {}
    throw
  }
}

function Show-GQLErrors {
  param($Response, [string]$Label = "")
  if ($Response.errors) { Write-Output "GRAPHQL ERRORS $Label"; $Response.errors | ConvertTo-Json -Depth 6 -Compress }
}
