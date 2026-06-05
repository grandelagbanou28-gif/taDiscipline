-- taDiscipline — Données de démo pour le développement local
-- Exécuter après la migration : supabase db reset

-- Créer un utilisateur de test (email: test@tadiscipline.app, password: Test1234!)
INSERT INTO auth.users (
  id, instance_id, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'test@tadiscipline.app',
  '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890123456789012345678901',
  now(),
  '{"provider":"email"}',
  '{"display_name":"Alex"}',
  now(),
  now()
) ON CONFLICT DO NOTHING;

-- Profil
INSERT INTO public.profiles (id, display_name, timezone)
VALUES ('00000000-0000-0000-0000-000000000001', 'Alex', 'Europe/Paris')
ON CONFLICT DO NOTHING;

-- Objectifs de démo
INSERT INTO public.goals (id, user_id, title, description, category, deadline, progress, status)
VALUES
  ('g1000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
   'Courir un semi-marathon', 'Se préparer pour le semi-marathon de Paris', 'fitness',
   '2026-09-15', 35, 'inProgress'),
  ('g1000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001',
   'Lire 12 livres', 'Un livre par mois cette année', 'learning',
   '2026-12-31', 25, 'inProgress'),
  ('g1000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001',
   'Économiser 5000€', 'Pour le voyage au Japon', 'finance',
   '2026-06-30', 60, 'inProgress')
ON CONFLICT DO NOTHING;

-- Sous-tâches
INSERT INTO public.subtasks (goal_id, title, completed, "order")
VALUES
  ('g1000000-0000-0000-0000-000000000001', 'Acheter des chaussures de running', true, 1),
  ('g1000000-0000-0000-0000-000000000001', 'Suivre un plan d''entraînement 3x/semaine', true, 2),
  ('g1000000-0000-0000-0000-000000000001', 'Courir 10km en moins d''1h', false, 3),
  ('g1000000-0000-0000-0000-000000000002', 'Choisir ma liste de lecture', true, 1),
  ('g1000000-0000-0000-0000-000000000002', 'Lire 30min par jour', false, 2);

-- Habitudes de démo
INSERT INTO public.habits (id, user_id, name, frequency, target, color, icon)
VALUES
  ('h1000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
   'Méditation matinale', 'daily', 1, '#7C3AED', '🧘'),
  ('h1000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001',
   'Lecture', 'daily', 1, '#10B981', '📚'),
  ('h1000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001',
   'Sport', 'daily', 1, '#F59E0B', '💪');

-- Logs habitudes (30 derniers jours)
INSERT INTO public.habit_logs (habit_id, date, completed)
SELECT 'h1000000-0000-0000-0000-000000000001', g::date, random() > 0.3
FROM generate_series(
  current_date - 30, current_date - 1, '1 day'::interval
) AS g;

-- Réglages
INSERT INTO public.user_settings (user_id, theme, notifications, lock_timeout, language)
VALUES ('00000000-0000-0000-0000-000000000001', 'dark', true, 2, 'fr')
ON CONFLICT DO NOTHING;
