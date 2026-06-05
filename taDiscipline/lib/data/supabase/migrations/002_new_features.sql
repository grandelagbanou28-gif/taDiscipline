-- taDiscipline - Migration 002 : Stories, Defis, Recherche

-- 12. PROFILES : ajout champ is_verified
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;

-- 13. STORIES
CREATE TABLE IF NOT EXISTS stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  caption TEXT DEFAULT '',
  mood TEXT DEFAULT 'neutral',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT now() + interval '24 hours'
);

ALTER TABLE stories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view stories" ON stories;
CREATE POLICY "Users can view stories"
  ON stories FOR SELECT
  USING (auth.uid() = user_id OR user_id IN (
    SELECT p2.user_id FROM challenge_participants p1
    JOIN challenge_participants p2 ON p1.challenge_id = p2.challenge_id
    WHERE p1.user_id = auth.uid() AND p2.user_id != auth.uid()
  ));

DROP POLICY IF EXISTS "Users can insert own stories" ON stories;
CREATE POLICY "Users can insert own stories"
  ON stories FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own stories" ON stories;
CREATE POLICY "Users can delete own stories"
  ON stories FOR DELETE
  USING (auth.uid() = user_id);

-- 14. CHALLENGES
CREATE TABLE IF NOT EXISTS challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  category TEXT DEFAULT 'other',
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  goal_type TEXT DEFAULT 'streak',
  goal_target INT DEFAULT 7,
  is_public BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'open',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view public challenges" ON challenges;
CREATE POLICY "Anyone can view public challenges"
  ON challenges FOR SELECT
  USING (is_public = true OR creator_id = auth.uid() OR auth.uid() IN (
    SELECT user_id FROM challenge_participants WHERE challenge_id = challenges.id
  ));

DROP POLICY IF EXISTS "Users can create challenges" ON challenges;
CREATE POLICY "Users can create challenges"
  ON challenges FOR INSERT
  WITH CHECK (auth.uid() = creator_id);

DROP POLICY IF EXISTS "Creator can update challenge" ON challenges;
CREATE POLICY "Creator can update challenge"
  ON challenges FOR UPDATE
  USING (auth.uid() = creator_id);

-- 15. CHALLENGE_PARTICIPANTS
CREATE TABLE IF NOT EXISTS challenge_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  progress REAL DEFAULT 0,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(challenge_id, user_id)
);

ALTER TABLE challenge_participants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Participants can view" ON challenge_participants;
CREATE POLICY "Participants can view"
  ON challenge_participants FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() IN (
    SELECT creator_id FROM challenges WHERE id = challenge_participants.challenge_id
  ));

DROP POLICY IF EXISTS "Users can join challenges" ON challenge_participants;
CREATE POLICY "Users can join challenges"
  ON challenge_participants FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own progress" ON challenge_participants;
CREATE POLICY "Users can update own progress"
  ON challenge_participants FOR UPDATE
  USING (auth.uid() = user_id);

-- 16. CHALLENGE_MESSAGES (chat du defi)
CREATE TABLE IF NOT EXISTS challenge_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE challenge_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Participants can view messages" ON challenge_messages;
CREATE POLICY "Participants can view messages"
  ON challenge_messages FOR SELECT
  USING (auth.uid() IN (
    SELECT user_id FROM challenge_participants WHERE challenge_id = challenge_messages.challenge_id
  ) OR auth.uid() IN (
    SELECT creator_id FROM challenges WHERE id = challenge_messages.challenge_id
  ));

DROP POLICY IF EXISTS "Participants can send messages" ON challenge_messages;
CREATE POLICY "Participants can send messages"
  ON challenge_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id AND auth.uid() IN (
    SELECT user_id FROM challenge_participants WHERE challenge_id = challenge_messages.challenge_id
  ));

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_stories_user_id ON stories(user_id);
CREATE INDEX IF NOT EXISTS idx_stories_expires_at ON stories(expires_at);
CREATE INDEX IF NOT EXISTS idx_challenges_status ON challenges(status);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_challenge ON challenge_participants(challenge_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_user ON challenge_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_messages_challenge ON challenge_messages(challenge_id);

-- TRIGGER: updated_at pour challenges
DROP TRIGGER IF EXISTS update_challenges_updated_at ON challenges;
CREATE TRIGGER update_challenges_updated_at
  BEFORE UPDATE ON challenges FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Fonction pour nettoyer les stories expirees (appelee par Edge Function cron)
CREATE OR REPLACE FUNCTION cleanup_expired_stories()
RETURNS void AS $$
BEGIN
  DELETE FROM stories WHERE expires_at < now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
