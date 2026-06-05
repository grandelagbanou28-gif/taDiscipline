# ============================================
# taDiscipline — Génération des icônes d'application
# ============================================
# Usage : pwsh scripts/generate-icons.ps1
#
# Génère les icônes Android (mipmap) et iOS (xcassets)
# à partir d'un fichier source 1024x1024 PNG.
#
# Prérequis : ImageMagick (convert) ou Python (Pillow)
#   - ImageMagick : winget install ImageMagick
#   - Python Pillow : pip install Pillow
# ============================================

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

# Source icon (doit être un PNG 1024x1024)
$SourceIcon = Join-Path $ProjectRoot "assets\icons\icon-1024.png"
$AndroidRes = Join-Path $ProjectRoot "android\app\src\main\res"
$IosAssets = Join-Path $ProjectRoot "ios\Runner\Assets.xcassets\AppIcon.appiconset"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   taDiscipline — Génération des icônes      ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

if (-not (Test-Path $SourceIcon)) {
  Write-Host "  ⚠️  Source icon non trouvée : $SourceIcon" -ForegroundColor Yellow
  Write-Host "  -> Place un fichier icon-1024.png (1024x1024) dans assets/icons/" -ForegroundColor Gray
  Write-Host "  -> Ou crée des icônes manuellement avec https://icon.kitchen" -ForegroundColor Gray
  Write-Host ""
  Write-Host "  📝 Tailles Android requises :" -ForegroundColor Cyan
  Write-Host "    mipmap-mdpi     : 48x48" -ForegroundColor White
  Write-Host "    mipmap-hdpi     : 72x72" -ForegroundColor White
  Write-Host "    mipmap-xhdpi    : 96x96" -ForegroundColor White
  Write-Host "    mipmap-xxhdpi   : 144x144" -ForegroundColor White
  Write-Host "    mipmap-xxxhdpi  : 192x192" -ForegroundColor White
  Write-Host ""
  Write-Host "  📝 iOS : 1024x1024 (AppIcon.appiconset)" -ForegroundColor Cyan
  exit 0
}

# Vérifier ImageMagick
$hasMagick = $null -ne (Get-Command "convert" -ErrorAction SilentlyContinue)
$hasPython = $null -ne (Get-Command "python" -ErrorAction SilentlyContinue)

if (-not $hasMagick -and -not $hasPython) {
  Write-Host "  ❌ Ni ImageMagick ni Python trouvé." -ForegroundColor Red
  Write-Host "  Installe l'un des deux :" -ForegroundColor Yellow
  Write-Host "    ImageMagick : winget install ImageMagick" -ForegroundColor Gray
  Write-Host "    Python      : winget install Python.Python" -ForegroundColor Gray
  exit 1
}

# Tailles Android (mipmap)
$androidSizes = @(
  @{dir="mipmap-mdpi"; size=48},
  @{dir="mipmap-hdpi"; size=72},
  @{dir="mipmap-xhdpi"; size=96},
  @{dir="mipmap-xxhdpi"; size=144},
  @{dir="mipmap-xxxhdpi"; size=192}
)

Write-Host "  🖼️  Génération des icônes Android..." -ForegroundColor Cyan
foreach ($size in $androidSizes) {
  $outputDir = Join-Path $AndroidRes $size.dir
  New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
  $outputFile = Join-Path $outputDir "ic_launcher.png"

  if ($hasMagick) {
    convert $SourceIcon -resize "$($size.size)x$($size.size)" $outputFile 2>&1 | Out-Null
  } else {
    python -c @"
from PIL import Image
img = Image.open(r'$SourceIcon')
img = img.resize(($($size.size), $($size.size)), Image.LANCZOS)
img.save(r'$outputFile')
"@ 2>&1 | Out-Null
  }
  Write-Host "    ✅ ${size.size}x${size.size} → $($size.dir)" -ForegroundColor Green
}

# Icône iOS (1024x1024)
Write-Host "  🖼️  Génération de l'icône iOS..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $IosAssets -Force | Out-Null
$iosOutput = Join-Path $IosAssets "icon-1024.png"
Copy-Item -LiteralPath $SourceIcon -Destination $iosOutput -Force
Write-Host "    ✅ 1024x1024 → AppIcon.appiconset" -ForegroundColor Green

# Icônes web (PWA)
Write-Host "  🖼️  Génération des icônes Web..." -ForegroundColor Cyan
$webIcons = Join-Path $ProjectRoot "web\icons"
New-Item -ItemType Directory -Path $webIcons -Force | Out-Null
$webSizes = @(192, 512)
foreach ($size in $webSizes) {
  $outputFile = Join-Path $webIcons "icon-$size.png"
  if ($hasMagick) {
    convert $SourceIcon -resize "$($size)x$($size)" $outputFile 2>&1 | Out-Null
  } else {
    python -c @"
from PIL import Image
img = Image.open(r'$SourceIcon')
img = img.resize(($size, $size), Image.LANCZOS)
img.save(r'$outputFile')
"@ 2>&1 | Out-Null
  }
  Write-Host "    ✅ ${size}x${size}" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Icônes générées avec succès !" -ForegroundColor Green
