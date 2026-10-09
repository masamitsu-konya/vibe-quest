-- 価値観マッチング基盤（Phase 3: 認証 + サーバー同期）
--
-- 現行アプリは質問をアプリ内データで保持する（question_id は '1'〜'1020' の TEXT）。
-- 既存の questions / user_responses / user_profiles はサーバー駆動設計時代の遺物で
-- 現行アプリからは未使用（互換性が無いため流用せず、新テーブルを追加する。
-- 旧テーブルの整理は別マイグレーションで行う）。

-- ============================================================
-- スワイプ回答（ローカル shared_preferences のサーバーレプリカ）
-- ============================================================
CREATE TABLE IF NOT EXISTS swipe_responses (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  question_id TEXT NOT NULL,
  is_excited BOOLEAN NOT NULL,
  answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, question_id)
);

CREATE INDEX IF NOT EXISTS idx_swipe_responses_user_id ON swipe_responses(user_id);

ALTER TABLE swipe_responses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own swipe responses" ON swipe_responses;
CREATE POLICY "Users can view own swipe responses"
  ON swipe_responses FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own swipe responses" ON swipe_responses;
CREATE POLICY "Users can insert own swipe responses"
  ON swipe_responses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own swipe responses" ON swipe_responses;
CREATE POLICY "Users can update own swipe responses"
  ON swipe_responses FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own swipe responses" ON swipe_responses;
CREATE POLICY "Users can delete own swipe responses"
  ON swipe_responses FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- 価値観プロファイル（27次元ベクトル + マッチング用プロフィール）
--
-- vector の次元構成は Flutter 側 ValuesProfile と同一（順序固定）:
--   [0..12]  スコア次元: growth, sdt_autonomy, sdt_competence, sdt_relatedness,
--            ikigai_love, ikigai_good_at, ikigai_world_needs, ikigai_paid_for,
--            big5_openness, big5_conscientiousness, big5_extraversion,
--            big5_agreeableness, big5_neuroticism
--   [13..26] カテゴリ親和度: health, career, hobby, learning, relationship,
--            lifestyle, finance, creativity, sports, travel, adventure,
--            service, mindfulness, entertainment
-- ============================================================
CREATE TABLE IF NOT EXISTS values_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  vector DOUBLE PRECISION[] NOT NULL,
  vector_version INTEGER NOT NULL DEFAULT 1,
  answered_count INTEGER NOT NULL DEFAULT 0,
  excited_count INTEGER NOT NULL DEFAULT 0,
  nickname TEXT CHECK (nickname IS NULL OR char_length(nickname) BETWEEN 1 AND 20),
  bio TEXT CHECK (bio IS NULL OR char_length(bio) <= 500),
  is_matching_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (array_length(vector, 1) = 27)
);

ALTER TABLE values_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own values profile" ON values_profiles;
CREATE POLICY "Users can view own values profile"
  ON values_profiles FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own values profile" ON values_profiles;
CREATE POLICY "Users can insert own values profile"
  ON values_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own values profile" ON values_profiles;
CREATE POLICY "Users can update own values profile"
  ON values_profiles FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 他ユーザーのプロファイル閲覧はマッチング機能（Phase 4）で
-- SECURITY DEFINER な RPC 経由に限定する。直接 SELECT は本人のみ。
