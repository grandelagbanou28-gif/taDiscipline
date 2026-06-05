# taDiscipline

> Maîtrise ton quotidien, conquiers tes rêves.

Application mobile Flutter de discipline personnelle, gestion d'objectifs, habitudes et plans d'action, avec assistant IA (DelAide IA propulsé par Grok/xAI).

---

## Stack technique

| Couche        | Technologie                                    |
| ------------- | ---------------------------------------------- |
| Frontend      | Flutter 3.2+ / Dart                           |
| State         | Riverpod + riverpod_generator                  |
| Navigation    | GoRouter                                       |
| Backend       | Supabase (Auth, Postgres RLS, Realtime, Storage) |
| IA            | xAI Grok (Edge Function Deno)                  |
| Chiffrement   | AES-256 (encrypt + crypto)                     |
| Biométrie     | local_auth (Face ID / Touch ID / Empreinte)    |
| Charts        | fl_chart                                       |
| Notifications | flutter_local_notifications                    |

---

## ⚡ Installation rapide

### Prérequis

- **Flutter** 3.2+ : [flutter.dev](https://flutter.dev)
- **Supabase CLI** : `npm install -g supabase`
- **Compte xAI** : [console.x.ai](https://console.x.ai) (pour la clé Grok)

### 1. Cloner et configurer

```bash
cd taDiscipline
cp .env.example .env
```

Édite `.env` avec tes informations :

```
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
XAI_API_KEY=xai-...
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Télécharger les polices

```bash
pwsh scripts/download-fonts.ps1
```

Ou télécharge-les manuellement depuis Google Fonts :
- [Space Grotesk](https://fonts.google.com/specimen/Space+Grotesk)
- [Inter](https://fonts.google.com/specimen/Inter)
- [JetBrains Mono](https://fonts.google.com/specimen/JetBrains+Mono)

Place les fichiers `.ttf` dans `assets/fonts/`.

### 4. Générer les providers Riverpod

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Démarrer Supabase local (optionnel)

```bash
supabase start
supabase db push      # Appliquer les migrations
supabase db seed      # Données de démo
```

### 6. Lancer l'application

**Avec --dart-define (recommandé) :**

```bash
flutter run --dart-define-from-file=.env
```

**Ou depuis VS Code :**
- Ouvre le projet
- F5 → choisir "taDiscipline (dev)"
- Modifie `.vscode/launch.json` avec tes clés

---

## 🔐 Configuration Supabase

### Projet distant

1. Crée un projet sur [supabase.com](https://supabase.com)
2. Va dans **Settings → API** et copie :
   - `Project URL` → `SUPABASE_URL`
   - `anon public key` → `SUPABASE_ANON_KEY`
3. Dans **SQL Editor**, colle et exécute `lib/data/supabase/migrations/001_init.sql`

### Local (pour le développement)

```bash
supabase init
supabase start
supabase db push
supabase db seed
```

Les identifiants locaux s'affichent avec `supabase status`.

---

## 🤖 Configuration de DelAide IA (Edge Function)

### Clé xAI / Grok

1. Crée un compte sur [console.x.ai](https://console.x.ai)
2. Génère une clé API
3. Configure-la comme secret Supabase :

```bash
supabase secrets set XAI_API_KEY=xai-votre-cle
```

### Déploiement

```bash
supabase functions deploy delaide-chat
```

L'URL de la fonction sera :  
`https://[projet].supabase.co/functions/v1/delaide-chat`

### Variables d'environnement de la fonction

La fonction lit automatiquement :
- `SUPABASE_URL` — injecté par Supabase
- `SUPABASE_ANON_KEY` — injecté par Supabase
- `XAI_API_KEY` — doit être définie via `supabase secrets set`

---

## 🗄️ Base de données

La migration se trouve dans `lib/data/supabase/migrations/001_init.sql`.

Tables créées :
- `profiles` — Profil utilisateur (PIN hash, biométrie)
- `goals` — Objectifs SMART
- `subtasks` — Sous-tâches des objectifs
- `habits` — Habitudes
- `habit_logs` — Logs quotidiens des habitudes
- `plans` — Plans hebdo/mensuels
- `journal_entries` — Journal chiffré (AES-256)
- `pomodoro_sessions` — Sessions focus
- `chat_messages` — Historique DelAide IA
- `achievements` — Badges débloqués
- `user_settings` — Préférences utilisateur

Toutes les tables ont **RLS (Row Level Security)** activé : un utilisateur ne voit que ses données.

---

## 🔒 Sécurité multi-couches

| Couche          | Implémentation                         |
| --------------- | -------------------------------------- |
| Auth Supabase   | Email/password, validation Zod côté Flutter |
| Code PIN 6 chiffres | Hashé avec SHA-256 + sel, stocké dans profiles |
| Biométrie       | Face ID / Touch ID via local_auth      |
| Auto-lock       | Timer 2min (configurable)              |
| Mode panique    | Double-tap pour masquer les données    |
| Chiffrement     | AES-256-CBC via SubtleCrypto           |
| 2FA (TOTP)      | Optionnel, via `totp_service.dart`     |

---

## 📁 Structure du projet

```
lib/
├── core/
│   ├── theme/          # AppColors, AppTypography, AppTheme, GlassStyles
│   ├── constants/      # AppConstants, GoalCategories (enums)
│   ├── utils/          # Validators, DateFormats, EncryptionService
│   └── router/         # GoRouter (14 routes)
├── data/
│   ├── models/         # 6 modèles avec toJson/fromJson
│   ├── repositories/   # 9 repositories Supabase
│   └── supabase/       # Client + migration SQL
├── features/
│   ├── auth/           # Login, Register, Riverpod provider
│   ├── security/       # PIN, Biométrie, AutoLock, Panic, TOTP
│   ├── dashboard/      # Score, streak, citations, quick actions
│   ├── goals/          # CRUD SMART, sous-tâches, progression
│   ├── habits/         # Grille GitHub, logs, gamification
│   ├── plans/          # Calendrier, drag & drop
│   ├── journal/        # Matin/soir, mood tracker, chiffré
│   ├── pomodoro/       # Timer, breaks, sons d'ambiance
│   ├── statistics/     # Charts fl_chart, export PDF
│   └── chat/           # DelAide IA, streaming, markdown
├── shared/widgets/     # GlassCard, CircularProgress, Particles...
└── main.dart           # Entry point
```

---

## 📝 Commandes utiles

```bash
# Lancer l'application
flutter run --dart-define-from-file=.env

# Générer les fichiers Riverpod
dart run build_runner build --delete-conflicting-outputs

# Regarder les changements (auto-génération)
dart run build_runner watch --delete-conflicting-outputs

# Lancer Supabase local
supabase start
supabase stop

# Déployer l'Edge Function
supabase functions deploy delaide-chat

# Appliquer les migrations
supabase db push

# Exécuter les tests
flutter test

# Analyse statique
flutter analyze

# Créer un build release APK
flutter build apk --dart-define-from-file=.env

# Créer un build release iOS
flutter build ios --dart-define-from-file=.env
```

---

## 🧪 Tests

```bash
flutter test
```

Tests inclus :
- Validateurs (email, mot de passe, PIN, force)
- Modèles (Goal, Habit, SubTask, HabitLog) — sérialisation JSON
- Chiffrement (hash, sel, SHA-256)
- Widgets (GlassCard, GlassButton)
# taDiscipline
