# ============================================
# Télécharge les polices pour taDiscipline
# ============================================
# Les polices sont utilisées via google_fonts (runtime)
# mais on les bundle aussi en offline.
# ============================================

param([switch]$Force)

$AssetsDir = Join-Path $PSScriptRoot ".." "assets" "fonts"
New-Item -ItemType Directory -Path $AssetsDir -Force | Out-Null

$fonts = @(
  @{
    Name     = "SpaceGrotesk-Variable.ttf"
    Url      = "https://raw.githubusercontent.com/google/fonts/main/ofl/spacegrotesk/SpaceGrotesk%5Bwght%5D.ttf"
    Fallback = "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/spacegrotesk/SpaceGrotesk%5Bwght%5D.ttf"
  }
  @{
    Name     = "Inter-Variable.ttf"
    Url      = "https://raw.githubusercontent.com/google/fonts/main/ofl/inter/Inter%5Bslnt%2Cwght%5D.ttf"
    Fallback = $null
  }
  @{
    Name     = "JetBrainsMono-Variable.ttf"
    Url      = "https://raw.githubusercontent.com/google/fonts/main/ofl/jetbrainsmono/JetBrainsMono%5Bwght%5D.ttf"
    Fallback = "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/jetbrainsmono/JetBrainsMono%5Bwght%5D.ttf"
  }
)

$success = 0
$failed = 0

foreach ($font in $fonts) {
  $filepath = Join-Path $AssetsDir $font.Name
  if ((-not $Force) -and (Test-Path $filepath)) {
    Write-Host "  ✅ $($font.Name) déjà présent" -ForegroundColor Gray
    $success++
    continue
  }

  $urls = @($font.Url)
  if ($font.Fallback) { $urls += $font.Fallback }

  $downloaded = $false
  foreach ($url in $urls) {
    if ($downloaded) { break }
    Write-Host "  ⏳ $($font.Name)..." -NoNewline
    try {
      Invoke-WebRequest -Uri $url -OutFile $filepath -UseBasicParsing -ErrorAction Stop
      $size = (Get-Item $filepath).Length / 1KB -as [int]
      Write-Host " ✅ $size KB" -ForegroundColor Green
      $downloaded = $true
      $success++
    } catch {
      Write-Host " ❌" -ForegroundColor Red
    }
  }

  if (-not $downloaded) {
    $failed++
    Write-Host "  ⚠️  $($font.Name) : toutes les sources ont échoué" -ForegroundColor Yellow
    Write-Host "     -> google_fonts servira cette police à l'exécution" -ForegroundColor Gray
  }
}

Write-Host ""
Write-Host "=== Résultat : $success téléchargées, $failed échouées ===" -ForegroundColor Cyan
Write-Host "📁 Contenu :" -ForegroundColor Cyan
Get-ChildItem $AssetsDir -Filter "*.ttf" | ForEach-Object {
  "  • $($_.Name) ($($_.Length / 1KB -as [int]) KB)"
}

if ($failed -gt 0) {
  Write-Host ""
  Write-Host "💡 Les polices non téléchargées seront chargées automatiquement" -ForegroundColor Yellow
  Write-Host "   par le package google_fonts au premier lancement de l'app." -ForegroundColor Yellow
  Write-Host "   Aucune action requise." -ForegroundColor Yellow
}
