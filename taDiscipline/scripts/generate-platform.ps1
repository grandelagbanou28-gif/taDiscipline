# ============================================
# taDiscipline — Génération des plateformes natives
# ============================================
# Usage : pwsh scripts/generate-platform.ps1
#
# Génère les dossiers android/ et ios/ manquants
# avec flutter create dans un dossier temporaire,
# puis copie les fichiers spécifiques taDiscipline.
# ============================================

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$TempDir = Join-Path $env:TEMP "tadiscipline_platform_$(Get-Random)"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   taDiscipline — Génération des plateformes  ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# 1. Vérifier Flutter
try {
  $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
  if (-not $flutterVersion) { throw "Flutter non détecté" }
  Write-Host "  ✅ Flutter : $($flutterVersion.Line.Trim())" -ForegroundColor Green
} catch {
  Write-Host "  ❌ Flutter non trouvé. Installe-le depuis https://flutter.dev" -ForegroundColor Red
  exit 1
}

# 2. Créer un projet Flutter temporaire
Write-Host "  📁 Création d'un projet temporaire..." -ForegroundColor Cyan
try {
  Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue
  flutter create --project-name ta_discipline --org com.tadiscipline --platforms android,ios,web $TempDir 2>&1 | Out-Null
  Write-Host "  ✅ Projet temporaire créé" -ForegroundColor Green
} catch {
  Write-Host "  ❌ Erreur création projet temporaire : $_" -ForegroundColor Red
  exit 1
}

# 3. Copier les dossiers dans le projet
$folders = @("android", "ios", "web")

foreach ($folder in $folders) {
  $source = Join-Path $TempDir $folder
  $target = Join-Path $ProjectRoot $folder

  if (Test-Path $target) {
    Write-Host "  ⚠️  $folder/ existe déjà. Sauvegarde des fichiers personnalisés..." -ForegroundColor Yellow

    # Pour Android : on garde nos fichiers personnalisés
    if ($folder -eq "android") {
      # Sauvegarder nos fichiers personnalisés
      $backup = Join-Path $env:TEMP "tadiscipline_android_backup_$(Get-Random)"
      Copy-Item -LiteralPath $target -Destination $backup -Recurse -Force
      Remove-Item -LiteralPath $target -Recurse -Force
      Copy-Item -LiteralPath $source -Destination $target -Recurse -Force

      # Restaurer nos personnalisations
      $customFiles = @(
        "app\build.gradle.kts",
        "app\src\main\AndroidManifest.xml",
        "app\src\main\kotlin\com\tadiscipline\app\MainActivity.kt",
        "app\src\debug\AndroidManifest.xml"
      )
      foreach ($file in $customFiles) {
        $backupFile = Join-Path $backup $file
        $targetFile = Join-Path $target $file
        if (Test-Path $backupFile) {
          $targetDir = Split-Path $targetFile -Parent
          New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
          Copy-Item -LiteralPath $backupFile -Destination $targetFile -Force
          Write-Host "    → restauré : $file" -ForegroundColor Gray
        }
      }
      Remove-Item -LiteralPath $backup -Recurse -Force
    }

    # Pour iOS : on garde notre Info.plist
    if ($folder -eq "ios") {
      $backup = Join-Path $env:TEMP "tadiscipline_ios_backup_$(Get-Random)"
      # Sauvegarder Info.plist si existant
      $ourPlist = Join-Path $target "Runner\Info.plist"
      if (Test-Path $ourPlist) {
        $plistDir = Split-Path $ourPlist -Parent
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
        Copy-Item -LiteralPath $ourPlist -Destination (Join-Path $backup "Info.plist") -Force
      }

      Remove-Item -LiteralPath $target -Recurse -Force
      Copy-Item -LiteralPath $source -Destination $target -Recurse -Force

      if (Test-Path (Join-Path $backup "Info.plist")) {
        Copy-Item -LiteralPath (Join-Path $backup "Info.plist") -Destination $ourPlist -Force
        Write-Host "    → restauré : Runner/Info.plist" -ForegroundColor Gray
      }
      Remove-Item -LiteralPath $backup -Recurse -Force
    }
  } else {
    Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
    Write-Host "  ✅ $folder/ généré" -ForegroundColor Green
  }
}

# 4. Nettoyage
Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue

# 5. Installer les dépendances iOS (Pods)
if (Test-Path (Join-Path $ProjectRoot "ios")) {
  Write-Host "  📦 Installation des Pods iOS..." -ForegroundColor Cyan
  try {
    Push-Location (Join-Path $ProjectRoot "ios")
    pod install 2>&1 | Out-Null
    Write-Host "  ✅ Pods installés" -ForegroundColor Green
    Pop-Location
  } catch {
    Write-Host "  ⚠️  pod install a échoué. Lance-le manuellement :" -ForegroundColor Yellow
    Write-Host "     cd ios && pod install" -ForegroundColor Gray
    Pop-Location
  }
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   Plateformes générées avec succès !         ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "📱 Commandes de build :" -ForegroundColor Cyan
Write-Host "  APK debug  : flutter build apk --debug" -ForegroundColor White
Write-Host "  APK release: flutter build apk --release" -ForegroundColor White
Write-Host "  App bundle : flutter build appbundle --release" -ForegroundColor White
Write-Host "  iOS        : flutter build ios --release" -ForegroundColor White
Write-Host ""
Write-Host "🔐 OAuth configuré avec :" -ForegroundColor Cyan
Write-Host "  Android : io.supabase.flutter://auth/callback (AndroidManifest.xml)" -ForegroundColor White
Write-Host "  iOS     : io.supabase.flutter://auth/callback (Info.plist)" -ForegroundColor White
Write-Host ""
