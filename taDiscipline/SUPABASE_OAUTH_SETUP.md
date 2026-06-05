# Configuration OAuth — taDiscipline

## Projet Supabase
- **URL** : `https://ivhanceqvpmrsppgvsds.supabase.co`
- **Project Ref** : `ivhanceqvpmrsppgvsds`

---

## 1. Configurer Google OAuth

### Étape A — Console Google Cloud
1. Va sur https://console.cloud.google.com/apis/credentials
2. Crée un projet (ou utilise un existant)
3. Va dans **OAuth consent screen** → External → Remplis (nom: `taDiscipline`, email)
4. Va dans **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
5. Application type : **Desktop app** (ou Android si APK signé)
6. **URI de redirection autorisés** :
   ```
   https://ivhanceqvpmrsppgvsds.supabase.co/auth/v1/callback
   io.supabase.flutter://auth/callback
   ```
7. Note le **Client ID** et le **Client Secret**

### Étape B — Dashboard Supabase
1. Va sur https://app.supabase.com/project/ivhanceqvpmrsppgvsds/auth/providers
2. Clique sur **Google** → **Enable**
3. Colle :
   - **Client ID** (depuis Google Cloud)
   - **Client Secret** (depuis Google Cloud)
4. **Redirect URLs** :
   - `io.supabase.flutter://auth/callback`
   - `https://ivhanceqvpmrsppgvsds.supabase.co/auth/v1/callback`
5. Sauvegarde

Ou via script (prérequis : jeton API Management) :
```powershell
pwsh scripts/setup-oauth.ps1 -Interactive
```

---

## 2. Configurer Apple OAuth (iOS)

Nécessite un **compte développeur Apple** (99$/an).

### Étapes
1. Va sur https://developer.apple.com/account/resources/
2. Crée un **Service ID** avec identifier `com.tadiscipline.app`
3. Active **Sign In with Apple** sur ce Service ID
4. **Redirect URLs** :
   ```
   https://ivhanceqvpmrsppgvsds.supabase.co/auth/v1/callback
   ```
5. Télécharge la **Private Key** (.p8) depuis **Keys** → **Add Key**
6. Note la **Key ID**

### Dashboard Supabase
1. Va sur https://app.supabase.com/project/ivhanceqvpmrsppgvsds/auth/providers
2. Apple → **Enable**
3. Remplis : Service ID, Team ID (Apple), Key ID et le contenu du fichier .p8
4. Redirect URL : `io.supabase.flutter://auth/callback`

---

## 3. Deep Links (callback vers l'app)

### Android (déjà configuré)
`android/app/src/main/AndroidManifest.xml` :
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="io.supabase.flutter" android:host="auth/callback" />
</intent-filter>
```

### iOS (déjà configuré)
`ios/Runner/Info.plist` :
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.flutter</string>
    </array>
  </dict>
</array>
```

---

## 4. Vérification

```powershell
# Lister les providers configurés
supabase auth list --project-ref ivhanceqvpmrsppgvsds
```

Ou depuis le dashboard : https://app.supabase.com/project/ivhanceqvpmrsppgvsds/auth/providers

---

## 5. Test

Lance l'app :
```powershell
flutter run --dart-define-from-file=.env
```

Clique sur **Continuer avec Google** → un navigateur s'ouvre → authentifie-toi → redirige vers l'app → session créée → dashboard.
