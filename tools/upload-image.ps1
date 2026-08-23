# Image upload helpers for the EMBRAE store.
#
#   . .\tools\upload-image.ps1
#   $gid = Add-EmbraeFile        -Source <url|path> -Filename x.jpg -Alt "..."
#   $ok  = Add-EmbraeProductMedia -ProductId gid://... -Source <url|path> -Filename x.jpg -Alt "..."
#
# Why staged uploads rather than handing Shopify the source URL directly:
#
#   1. LoremFlickr answers with a RELATIVE redirect (/cache/resized/...). Shopify's
#      server-side fetch cannot resolve it, so every such file lands FAILED with
#      "... is not a valid URL". Verified, not guessed.
#   2. fileCreate rejects a `filename` whose extension does not match the source URL,
#      and most placeholder services expose no extension. Staging is the only way to
#      control the filename, which is what makes the asset findable and indexable.
#
# The multipart body is built by hand because .NET's MultipartFormDataContent quotes
# the boundary and stamps a Content-Type header on every string part; the Google Cloud
# Storage signed policy rejects both with "Malformed multipart body".

. (Join-Path $PSScriptRoot "gql.ps1")

$script:EmbraeTmp = Join-Path $env:TEMP "embrae-media"
if (-not (Test-Path $script:EmbraeTmp)) { New-Item -ItemType Directory -Path $script:EmbraeTmp | Out-Null }

function New-EmbraeStagedUpload {
  param([Parameter(Mandatory=$true)][string]$Source, [Parameter(Mandatory=$true)][string]$Filename)

  $local = Join-Path $script:EmbraeTmp $Filename
  if ($Source -match '^https?://') { Invoke-WebRequest -Uri $Source -OutFile $local -TimeoutSec 60 -UseBasicParsing }
  else { Copy-Item -Path $Source -Destination $local -Force }
  $bytes = [System.IO.File]::ReadAllBytes($local)
  $mime = if ($Filename -match '\.png$') { "image/png" } elseif ($Filename -match '\.webp$') { "image/webp" } else { "image/jpeg" }

  $q = 'mutation stage($input: [StagedUploadInput!]!) { stagedUploadsCreate(input: $input) { stagedTargets { url resourceUrl parameters { name value } } userErrors { field message } } }'
  $r = Send-GQL $q @{ input = @(@{ filename = $Filename; mimeType = $mime; resource = "IMAGE"; httpMethod = "POST" }) }
  if (@($r.data.stagedUploadsCreate.userErrors).Count -gt 0) { throw ($r.data.stagedUploadsCreate.userErrors | ConvertTo-Json -Compress) }
  $target = $r.data.stagedUploadsCreate.stagedTargets[0]

  $boundary = "EmbraeBoundary" + [System.Guid]::NewGuid().ToString("N")
  $enc = [System.Text.Encoding]::UTF8
  $ms = New-Object System.IO.MemoryStream
  $w = { param($s) $b = $enc.GetBytes($s); $ms.Write($b, 0, $b.Length) }
  foreach ($p in $target.parameters) {
    & $w "--$boundary`r`n"
    & $w ("Content-Disposition: form-data; name=`"" + $p.name + "`"`r`n`r`n")
    & $w ($p.value + "`r`n")
  }
  & $w "--$boundary`r`n"
  & $w ("Content-Disposition: form-data; name=`"file`"; filename=`"" + $Filename + "`"`r`n")
  & $w ("Content-Type: " + $mime + "`r`n`r`n")
  $ms.Write($bytes, 0, $bytes.Length)
  & $w "`r`n--$boundary--`r`n"
  $body = $ms.ToArray(); $ms.Dispose()

  Invoke-RestMethod -Method Post -Uri $target.url -Body $body -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 180 | Out-Null
  Remove-Item $local -Force -ErrorAction SilentlyContinue
  return $target.resourceUrl
}

# Standalone file in Content -> Files. Use for ingredient, concern, article and avatar images.
function Add-EmbraeFile {
  param([Parameter(Mandatory=$true)][string]$Source, [Parameter(Mandatory=$true)][string]$Filename, [Parameter(Mandatory=$true)][string]$Alt)
  $resourceUrl = New-EmbraeStagedUpload -Source $Source -Filename $Filename
  $q = 'mutation reg($files: [FileCreateInput!]!) { fileCreate(files: $files) { files { id fileStatus } userErrors { field message } } }'
  $r = Send-GQL $q @{ files = @(@{ originalSource = $resourceUrl; filename = $Filename; contentType = "IMAGE"; alt = $Alt }) }
  if (@($r.data.fileCreate.userErrors).Count -gt 0) { throw ($r.data.fileCreate.userErrors | ConvertTo-Json -Compress) }
  return $r.data.fileCreate.files[0].id
}

# Attaches straight to a product. Deliberately does NOT also create a standalone file,
# so Content -> Files stays a list of things that need managing, not a pile of duplicates.
function Add-EmbraeProductMedia {
  param([Parameter(Mandatory=$true)][string]$ProductId, [Parameter(Mandatory=$true)][string]$Source, [Parameter(Mandatory=$true)][string]$Filename, [Parameter(Mandatory=$true)][string]$Alt)
  $resourceUrl = New-EmbraeStagedUpload -Source $Source -Filename $Filename
  $q = 'mutation addMedia($id: ID!, $media: [CreateMediaInput!]!) { productCreateMedia(productId: $id, media: $media) { media { ... on MediaImage { id } } mediaUserErrors { field message } } }'
  $r = Send-GQL $q @{ id = $ProductId; media = @(@{ originalSource = $resourceUrl; alt = $Alt; mediaContentType = "IMAGE" }) }
  if (@($r.data.productCreateMedia.mediaUserErrors).Count -gt 0) { throw ($r.data.productCreateMedia.mediaUserErrors | ConvertTo-Json -Compress) }
  return $r.data.productCreateMedia.media[0].id
}
