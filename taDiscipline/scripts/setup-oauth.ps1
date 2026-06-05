# ============================================
# taDiscipline — Configuration OAuth Supabase
# ============================================
# Usage : pwsh scripts/setup-oauth.ps1
#
# Configure OAuth Google/Apple dans votre projet Supabase
# via l'API Management.
#
# Prérequis :
#   1. Se connecter : supabase login
#   2. Avoir un jeton d'accès Supabase Management API
#      → https://app.supabase.com/account/tokens
# ============================================

param(
  [string]$SupabaseProjectRef = "ivhanceqvpmrsppgvsds",
  [string]$ManagementToken = "",
  [switch]$Interactive
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   taDiscipline — Configuration OAuth         ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Mode interactif
if ($Interactive -or [string]::IsNullOrEmpty($ManagementToken)) {
  Write-Host "🔑 Jeton Management API Supabase" -ForegroundColor Cyan
  Write-Host "  Crée un jeton sur : https://app.supabase.com/account/tokens" -ForegroundColor Gray
  $ManagementToken = Read-Host "  Jeton"
  if ([string]::IsNullOrEmpty($ManagementToken)) {
    Write-Host "  ❌ Jeton requis" -ForegroundColor Red
    Write-Host "  Passe en mode manuel (voir README)" -ForegroundColor Yellow
    exit 1
  }
}

$headers = @{
  "Authorization" = "Bearer $ManagementToken"
  "Content-Type"  = "application/json"
}

$baseUrl = "https://api.supabase.com/v1/projects/$SupabaseProjectRef"

# 1. Vérifier l'accès
Write-Host "📍 Vérification de l'accès au projet..." -ForegroundColor Cyan
try {
  $project = Invoke-RestMethod -Uri "$baseUrl" -Headers $headers -Method Get -UseBasicParsing
  Write-Host "  ✅ Projet : $($project.name) ($SupabaseProjectRef)" -ForegroundColor Green
} catch {
  Write-Host "  ❌ Accès refusé. Vérifie le jeton et le project ref." -ForegroundColor Red
  Write-Host "  Passe en mode manuel (dashboard supabase)." -ForegroundColor Yellow
  exit 1
}

# 2. Configurer Google
Write-Host ""
Write-Host "🔵 Configuration Google OAuth..." -ForegroundColor Cyan
Write-Host "  ℹ️  Tu dois d'abord créer des identifiants Google Cloud :" -ForegroundColor Gray
Write-Host "     1. Va sur https://console.cloud.google.com/apis/credentials" -ForegroundColor Gray
Write-Host "     2. Crée un OAuth 2.0 Client ID (application de bureau)" -ForegroundColor Gray
Write-Host "     3. Ajoute comme URI de redirection :" -ForegroundColor Gray
Write-Host "        https://$SupabaseProjectRef.supabase.co/auth/v1/callback" -ForegroundColor Gray
Write-Host ""

$googleClientId = if ($Interactive) { Read-Host "  Google Client ID (laisser vide pour ignorer)" } else { "" }
$googleSecret = if ($Interactive -and -not [string]::IsNullOrEmpty($googleClientId)) { Read-Host "  Google Client Secret" } else { "" }

if (-not [string]::IsNullOrEmpty($googleClientId) -and -not [string]::IsNullOrEmpty($googleSecret)) {
  try {
    $body = @{
      client_id = $googleClientId
      secret = $googleSecret
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$baseUrl/auth/google" -Headers $headers -Body $body -Method Put -UseBasicParsing | Out-Null
    Write-Host "  ✅ Google OAuth configuré !" -ForegroundColor Green
  } catch {
    Write-Host "  ⚠️  Échec API : $_" -ForegroundColor Yellow
    Write-Host "     Configure manuellement dans le dashboard." -ForegroundColor Gray
  }
} else {
  Write-Host "  ⏭️  Google ignoré (pas de Client ID)" -ForegroundColor Yellow
}

# 3. Configurer Apple
Write-Host ""
Write-Host "🍎 Configuration Apple OAuth..." -ForegroundColor Cyan
Write-Host "  ℹ️  Nécessite un compte développeur Apple (99$/an)." -ForegroundColor Gray
Write-Host "     Voir : https://developer.apple.com/account/resources/" -ForegroundColor Gray

$appleServiceId = if ($Interactive) { Read-Host "  Apple Service ID (laisser vide pour ignorer)" } else { "" }
$appleTeamId = if ($Interactive -and -not [string]::IsNullOrEmpty($appleServiceId)) { Read-Host "  Apple Team ID" } else { "" }
$appleKeyId = if ($Interactive -and -not [string]::IsNullOrEmpty($appleServiceId)) { Read-Host "  Apple Key ID" } else { "" }
$appleKeyPath = ""
if ($Interactive -and -not [string]::IsNullOrEmpty($appleServiceId)) {
  $appleKeyPath = Read-Host "  Chemin fichier .p8"
}

if (-not [string]::IsNullOrEmpty($appleServiceId)) {
  $appleKeyContent = ""
  if (Test-Path $appleKeyPath) {
    $appleKeyContent = Get-Content $appleKeyPath -Raw
  } elseif (-not [string]::IsNullOrEmpty($appleKeyPath)) {
    Write-Host "  ⚠️  Fichier .p8 non trouvé" -ForegroundColor Yellow
  }
  try {
    $body = @{
      client_id = $appleServiceId
      team_id = $appleTeamId
      key_id = $appleKeyId
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$baseUrl/auth/apple" -Headers $headers -Body $body -Method Put -UseBasicParsing | Out-Null
    Write-Host "  ✅ Apple OAuth configuré !" -ForegroundColor Green
  } catch {
    Write-Host "  ⚠️  Échec API : $_" -ForegroundColor Yellow
  }
} else {
  Write-Host "  ⏭️  Apple ignoré" -ForegroundColor Yellow
}

# 4. Résumé
Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   Configuration OAuth terminée               ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "📋 Configuration manuelle si la script échoue :" -ForegroundColor Cyan
Write-Host "  1. Dashboard : https://app.supabase.com/project/$SupabaseProjectRef/auth/providers" -ForegroundColor White
Write-Host "  2. Google : Activer → Client ID + Secret" -ForegroundColor White
Write-Host "  3. Apple  : Activer → Service ID + Team ID + Key ID + .p8" -ForegroundColor White
Write-Host "  4. Redirect URLs à ajouter :" -ForegroundColor White
Write-Host "     → io.supabase.flutter://auth/callback" -ForegroundColor White
Write-Host "     → https://$SupabaseProjectRef.supabase.co/auth/v1/callback" -ForegroundColor White
Write-Host "  5. Déploiement Edge Function :" -ForegroundColor White
Write-Host "     supabase secrets set XAI_API_KEY=xai-..." -ForegroundColor White
Write-Host "     supabase functions deploy delaide-chat" -ForegroundColor White
Write-Host ""
