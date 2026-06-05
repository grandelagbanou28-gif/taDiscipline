-- taDiscipline - Migration initiale
-- Structure de la base de donnees complete avec RLS

-- 1. PROFILES
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL DEFAULT '',
  avatar_url TEXT,
  pin_hash TEXT,
  pin_salt TEXT,
  biometric_enabled BOOLEAN DEFAULT false,
  timezone TEXT DEFAULT 'Europe/Paris',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- 2. GOALS
CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  category TEXT DEFAULT 'other',
  deadline TIMESTAMPTZ,
  progress REAL DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  status TEXT DEFAULT 'notStarted',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own goals" ON goals;
CREATE POLICY "Users can manage own goals"
  ON goals FOR ALL
  USING (auth.uid() = user_id);

-- 3. SUBTASKS
CREATE TABLE IF NOT EXISTS subtasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  completed BOOLEAN DEFAULT false,
  "order" INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE subtasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage subtasks via goals" ON subtasks;
CREATE POLICY "Users can manage subtasks via goals"
  ON subtasks FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM goals WHERE goals.id = subtasks.goal_id AND goals.user_id = auth.uid()
    )
  );

-- 4. HABITS
CREATE TABLE IF NOT EXISTS habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  frequency TEXT DEFAULT 'daily',
  target INT DEFAULT 1,
  color TEXT DEFAULT '#7C3AED',
  icon TEXT DEFAULT '⭐',
  is_positive BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE habits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own habits" ON habits;
CREATE POLICY "Users can manage own habits"
  ON habits FOR ALL
  USING (auth.uid() = user_id);

-- 5. HABIT_LOGS
CREATE TABLE IF NOT EXISTS habit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  completed BOOLEAN DEFAULT false,
  value REAL DEFAULT 1.0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(habit_id, date)
);

ALTER TABLE habit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage habit logs via habits" ON habit_logs;
CREATE POLICY "Users can manage habit logs via habits"
  ON habit_logs FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM habits WHERE habits.id = habit_logs.habit_id AND habits.user_id = auth.uid()
    )
  );

-- 6. PLANS
CREATE TABLE IF NOT EXISTS plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  tasks JSONB DEFAULT '[]'::jsonb,
  type TEXT DEFAULT 'weekly',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE plans ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own plans" ON plans;
CREATE POLICY "Users can manage own plans"
  ON plans FOR ALL
  USING (auth.uid() = user_id);

-- 7. JOURNAL_ENTRIES
CREATE TABLE IF NOT EXISTS journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  content_encrypted TEXT NOT NULL,
  mood TEXT DEFAULT 'neutral',
  type TEXT DEFAULT 'morning',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own journal entries" ON journal_entries;
CREATE POLICY "Users can manage own journal entries"
  ON journal_entries FOR ALL
  USING (auth.uid() = user_id);

-- 8. POMODORO_SESSIONS
CREATE TABLE IF NOT EXISTS pomodoro_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  duration INT DEFAULT 25,
  completed_at TIMESTAMPTZ,
  task_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE pomodoro_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own pomodoro sessions" ON pomodoro_sessions;
CREATE POLICY "Users can manage own pomodoro sessions"
  ON pomodoro_sessions FOR ALL
  USING (auth.uid() = user_id);

-- 9. CHAT_MESSAGES
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own chat messages" ON chat_messages;
CREATE POLICY "Users can manage own chat messages"
  ON chat_messages FOR ALL
  USING (auth.uid() = user_id);

-- 10. ACHIEVEMENTS
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  badge_id TEXT NOT NULL,
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, badge_id)
);

ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own achievements" ON achievements;
CREATE POLICY "Users can view own achievements"
  ON achievements FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own achievements" ON achievements;
CREATE POLICY "Users can insert own achievements"
  ON achievements FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 11. USER_SETTINGS
CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
  theme TEXT DEFAULT 'dark',
  notifications BOOLEAN DEFAULT true,
  lock_timeout INT DEFAULT 2,
  language TEXT DEFAULT 'fr',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own settings" ON user_settings;
CREATE POLICY "Users can manage own settings"
  ON user_settings FOR ALL
  USING (auth.uid() = user_id);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_logs_habit_id ON habit_logs(habit_id);
CREATE INDEX IF NOT EXISTS idx_habit_logs_date ON habit_logs(date);
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_date ON journal_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_pomodoro_sessions_user_id ON pomodoro_sessions(user_id);

-- TRIGGER: updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_goals_updated_at ON goals;
CREATE TRIGGER update_goals_updated_at
  BEFORE UPDATE ON goals FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_user_settings_updated_at ON user_settings;
CREATE TRIGGER update_user_settings_updated_at
  BEFORE UPDATE ON user_settings FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
