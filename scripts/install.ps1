# Setup cnb-rs for GitHub Actions (Windows)
#
# Expected environment variables:
#   CNB_RS_VERSION  - version to install (e.g. v1.0.0-alpha.1)
#   CNB_RS_SOURCE   - download source: cnb (default) or github
#   CNB_RS_BIN_DIR  - directory to install the binary to

$ErrorActionPreference = 'Stop'

$Version = $env:CNB_RS_VERSION
$Source = if ($env:CNB_RS_SOURCE) { $env:CNB_RS_SOURCE } else { 'cnb' }
$BinDir = $env:CNB_RS_BIN_DIR
$CnbEndpoint = if ($env:CNB_RS_CNB_ENDPOINT) { $env:CNB_RS_CNB_ENDPOINT } else { 'https://cnb.cool' }

if (-not $Version) {
  Write-Host '::error::CNB_RS_VERSION is required'
  exit 1
}
if (-not $BinDir) {
  Write-Host '::error::CNB_RS_BIN_DIR is required'
  exit 1
}

# ── Normalize version ───────────────────────────────────────────
if (-not $Version.StartsWith('v')) {
  $Version = "v$Version"
}

# ── Detect architecture ─────────────────────────────────────────
$Arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
$Target = switch ($Arch) {
  'x64'   { 'x86_64-pc-windows-msvc' }
  'arm64' { 'aarch64-pc-windows-msvc' }
  default {
    Write-Host "::error::Unsupported Windows architecture: $Arch"
    exit 1
  }
}

# ── Build download URL ──────────────────────────────────────────
$CnbRepoSlug = 'wwvo/cnb-rs/cnb-rs'
$GitHubRepoSlug = 'wwvo/cnb-rs'

$BaseUrl = switch ($Source) {
  'cnb' {
    "$CnbEndpoint/$CnbRepoSlug/-/releases/download/$Version"
  }
  'github' {
    "https://github.com/$GitHubRepoSlug/releases/download/$Version"
  }
  default {
    Write-Host "::error::Unsupported download source: $Source (expected: cnb or github)"
    exit 1
  }
}

$AssetName = "cnb-rs-$Version-$Target.zip"
$ArchiveUrl = "$BaseUrl/$AssetName"
$ChecksumUrl = "$BaseUrl/sha256sum.txt"

# ── Download ────────────────────────────────────────────────────
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "cnb-rs-setup-$([System.Guid]::NewGuid().ToString('N').Substring(0, 8))"
New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null

try {
  Write-Host "::group::Download cnb-rs $Version ($Target)"

  $ArchivePath = Join-Path $TmpDir $AssetName
  $ChecksumPath = Join-Path $TmpDir 'sha256sum.txt'

  Write-Host "Downloading $ArchiveUrl"
  Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ArchivePath -UseBasicParsing

  Write-Host "Downloading sha256sum.txt"
  Invoke-WebRequest -Uri $ChecksumUrl -OutFile $ChecksumPath -UseBasicParsing

  # ── Verify checksum ─────────────────────────────────────────
  $Checksums = Get-Content $ChecksumPath -Raw
  $Pattern = "(?m)^(\S+)\s+$([regex]::Escape($AssetName))$"
  $Match = [regex]::Match($Checksums, $Pattern)

  if ($Match.Success) {
    $Expected = $Match.Groups[1].Value.ToLower()
    $Actual = (Get-FileHash -Path $ArchivePath -Algorithm SHA256).Hash.ToLower()

    if ($Actual -ne $Expected) {
      Write-Host "::error::SHA-256 checksum mismatch for $AssetName"
      Write-Host "  expected: $Expected"
      Write-Host "  actual:   $Actual"
      exit 1
    }
    Write-Host 'Verified SHA-256 checksum'
  } else {
    Write-Host "::warning::No checksum entry found for $AssetName in sha256sum.txt"
  }

  # ── Extract and install ─────────────────────────────────────
  $ExtractDir = Join-Path $TmpDir 'extract'
  Expand-Archive -Path $ArchivePath -DestinationPath $ExtractDir -Force

  $BinaryFile = Get-ChildItem -Path $ExtractDir -Recurse -Filter 'cnb-rs.exe' |
    Select-Object -First 1

  if (-not $BinaryFile) {
    Write-Host '::error::Failed to locate cnb-rs.exe in the extracted archive'
    exit 1
  }

  New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
  Copy-Item -Path $BinaryFile.FullName -Destination (Join-Path $BinDir 'cnb-rs.exe') -Force

  Write-Host '::endgroup::'
} finally {
  Remove-Item -Path $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
}
