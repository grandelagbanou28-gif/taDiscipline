# ============================================
# taDiscipline — Script de configuration complet
# Usage : pwsh scripts/setup.ps1
# ============================================

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║        taDiscipline — Configuration       ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# 1. Installer Flutter si absent
Write-Host "📱 Vérification de Flutter..." -ForegroundColor Cyan
$flutterInstalled = $null
try { $flutterInstalled = flutter --version 2>&1 | Select-String "Flutter" } catch {}

if (-not $flutterInstalled) {
  Write-Host "  ⬇️  Flutter non trouvé. Téléchargement..." -ForegroundColor Yellow
  $url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.0-stable.zip"
  $zip = "$env:TEMP\flutter.zip"
  $extract = "$env:USERPROFILE\flutter"
  Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
  Expand-Archive -Path $zip -DestinationPath $env:USERPROFILE -Force
  $env:Path += ";$extract\bin"
  [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";$extract\bin", "User")
  Write-Host "  ✅ Flutter $($flutterInstalled.Line) installé dans $extract" -ForegroundColor Green
  flutter precache 2>&1 | Out-Null
} else {
  Write-Host "  ✅ $($flutterInstalled.Line)" -ForegroundColor Green
}

# 2. Vérifier Dart
Write-Host "🎯 Vérification de Dart..." -ForegroundColor Cyan
try {
  $dartVer = dart --version 2>&1
  Write-Host "  ✅ $dartVer" -ForegroundColor Green
} catch {
  Write-Host "  ❌ Dart non trouvé" -ForegroundColor Red
  exit 1
}

# 3. Vérifier Python (pour icônes)
Write-Host "🐍 Vérification de Python..." -ForegroundColor Cyan
try {
  $pyVer = python --version 2>&1
  Write-Host "  ✅ $pyVer" -ForegroundColor Green
  pip install Pillow -q 2>&1 | Out-Null
} catch {
  Write-Host "  ⚠️  Python non trouvé. Les icônes ne seront pas générées." -ForegroundColor Yellow
}

# 4. Créer .env si absent
Write-Host "🔑 Configuration des variables d'environnement..." -ForegroundColor Cyan
$envTarget = Join-Path $projectRoot ".env"
if (-not (Test-Path $envTarget)) {
  @"
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre-anon-key
XAI_API_KEY=xai-votre-cle-api
"@ | Set-Content $envTarget -Encoding UTF8
  Write-Host "  ✅ .env créé avec les clés" -ForegroundColor Green
} else {
  Write-Host "  ✅ .env déjà présent" -ForegroundColor Gray
}

# 5. Installer les dépendances Flutter
Write-Host "📦 Installation des dépendances..." -ForegroundColor Cyan
Set-Location $projectRoot
try {
  flutter pub get 2>&1 | Out-Null
  Write-Host "  ✅ flutter pub get OK" -ForegroundColor Green
} catch {
  Write-Host "  ❌ Erreur : $_" -ForegroundColor Red
  exit 1
}

# 6. Télécharger les polices
Write-Host "🔤 Téléchargement des polices..." -ForegroundColor Cyan
& "$PSScriptRoot\download-fonts.ps1" 2>&1 | Out-Null

# 7. Générer les fichiers Riverpod (.g.dart)
Write-Host "⚡ Génération des providers Riverpod..." -ForegroundColor Cyan
try {
  dart run build_runner build --delete-conflicting-outputs 2>&1 | Out-Null
  Write-Host "  ✅ build_runner terminé" -ForegroundColor Green
} catch {
  Write-Host "  ⚠️  build_runner a échoué — les .g.dart manuels sont utilisés" -ForegroundColor Yellow
}

# 8. Générer les icônes
Write-Host "🖼️  Génération des icônes..." -ForegroundColor Cyan
try {
  python "$PSScriptRoot\gen_icons.py" 2>&1 | Out-Null
  Write-Host "  ✅ Icônes générées (Python)" -ForegroundColor Green
} catch {
  try {
    & "$PSScriptRoot\generate-icons.ps1" 2>&1 | Out-Null
    Write-Host "  ✅ Icônes générées" -ForegroundColor Green
  } catch {
    Write-Host "  ⚠️  Icônes non générées" -ForegroundColor Yellow
  }
}

# 9. Générer les plateformes natives
Write-Host "📱 Génération des plateformes natives..." -ForegroundColor Cyan
try {
  & "$PSScriptRoot\generate-platform.ps1" 2>&1 | Out-Null
  Write-Host "  ✅ Plateformes générées" -ForegroundColor Green
} catch {
  Write-Host "  ⚠️  Génération des plateformes échouée" -ForegroundColor Yellow
}

# 10. Build APK Release
Write-Host "🔨 Build APK Release..." -ForegroundColor Cyan
try {
  flutter build apk --release --dart-define-from-file=.env 2>&1 | Out-Null
  $apk = "$projectRoot\build\app\outputs\flutter-apk\app-release.apk"
  if (Test-Path $apk) {
    $size = "{0:N0} KB" -f ((Get-Item $apk).Length / 1KB)
    Write-Host "  ✅ APK généré : $apk ($size)" -ForegroundColor Green
  }
} catch {
  Write-Host "  ❌ Build APK échoué. Détails :" -ForegroundColor Red
  flutter build apk --release --dart-define-from-file=.env 2>&1 | Write-Host
  exit 1
}

# Résumé
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║     ✓  taDiscipline prête !              ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  📱 APK : build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
Write-Host "  🗄️  SQL : lib\data\supabase\migrations\002_new_features.sql" -ForegroundColor Cyan
Write-Host "  🤖 Edge Function : supabase functions deploy delaide-chat" -ForegroundColor Cyan
Write-Host ""

Set-Location $projectRoot
