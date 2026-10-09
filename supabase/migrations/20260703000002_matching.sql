-- 価値観マッチング（Phase 4: 候補提示・相互Like・チャット）
--
-- 設計方針:
-- - 他ユーザーのプロファイルへの直接 SELECT は許可しない。
--   候補取得・マッチ判定は SECURITY DEFINER の RPC 経由に限定し、
--   公開してよい列（nickname / bio / 類似度 / 回答数）だけを返す。
-- - マッチ成立（相互Like判定 → matches 行作成）も RPC 内で行い、
--   クライアントの競合や不正 INSERT を防ぐ。

-- ============================================================
-- コサイン類似度（Flutter 側 ValuesProfileBuilder.cosineSimilarity と同一ロジック）
-- ============================================================
CREATE OR REPLACE FUNCTION vector_cosine_similarity(a DOUBLE PRECISION[], b DOUBLE PRECISION[])
RETURNS DOUBLE PRECISION
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE
    WHEN s.norm_a = 0 OR s.norm_b = 0 THEN 0
    ELSE s.dot / (sqrt(s.norm_a) * sqrt(s.norm_b))
  END
  FROM (
    SELECT
      COALESCE(SUM(x * y), 0) AS dot,
      COALESCE(SUM(x * x), 0) AS norm_a,
      COALESCE(SUM(y * y), 0) AS norm_b
    FROM unnest(a, b) AS t(x, y)
  ) s;
$$;

-- ============================================================
-- Like / Skip の記録
-- ============================================================
CREATE TABLE IF NOT EXISTS match_decisions (
  decider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  target_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  is_like BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (decider_id, target_id),
  CHECK (decider_id <> target_id)
);

CREATE INDEX IF NOT EXISTS idx_match_decisions_target
  ON match_decisions(target_id) WHERE is_like;

ALTER TABLE match_decisions ENABLE ROW LEVEL SECURITY;

-- 自分の決定のみ閲覧可。INSERT は RPC（decide_match）経由のみ。
-- 「誰が自分をLikeしたか」を直接見せない（相互成立まで秘匿）。
DROP POLICY IF EXISTS "Users can view own decisions" ON match_decisions;
CREATE POLICY "Users can view own decisions"
  ON match_decisions FOR SELECT
  USING (auth.uid() = decider_id);

-- ============================================================
-- マッチ（相互Like成立ペア）: user_a < user_b の正規化ペア
-- ============================================================
CREATE TABLE IF NOT EXISTS matches (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_a UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_b UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_a, user_b),
  CHECK (user_a < user_b)
);

CREATE INDEX IF NOT EXISTS idx_matches_user_a ON matches(user_a);
CREATE INDEX IF NOT EXISTS idx_matches_user_b ON matches(user_b);

ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Participants can view own matches" ON matches;
CREATE POLICY "Participants can view own matches"
  ON matches FOR SELECT
  USING (auth.uid() = user_a OR auth.uid() = user_b);

-- ============================================================
-- メッセージ（マッチ成立ペアのみ）
-- ============================================================
CREATE TABLE IF NOT EXISTS messages (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  match_id BIGINT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL CHECK (char_length(content) BETWEEN 1 AND 2000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_match_id ON messages(match_id, created_at);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Participants can view match messages" ON messages;
CREATE POLICY "Participants can view match messages"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM matches m
      WHERE m.id = match_id
        AND (m.user_a = auth.uid() OR m.user_b = auth.uid())
    )
  );

DROP POLICY IF EXISTS "Participants can send match messages" ON messages;
CREATE POLICY "Participants can send match messages"
  ON messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM matches m
      WHERE m.id = match_id
        AND (m.user_a = auth.uid() OR m.user_b = auth.uid())
    )
  );

-- ============================================================
-- RPC: マッチング候補の取得
--
-- 呼び出し元と価値観が近い順に、未決定のマッチング参加ユーザーを返す。
-- SECURITY DEFINER で values_profiles の RLS を越えるが、
-- 返すのは公開してよい列だけに限定する。
-- ============================================================
CREATE OR REPLACE FUNCTION get_match_candidates(limit_count INTEGER DEFAULT 20)
RETURNS TABLE (
  user_id UUID,
  nickname TEXT,
  bio TEXT,
  similarity DOUBLE PRECISION,
  answered_count INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  me UUID := auth.uid();
  my_vector DOUBLE PRECISION[];
BEGIN
  IF me IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  SELECT vp.vector INTO my_vector
  FROM values_profiles vp
  WHERE vp.user_id = me AND vp.is_matching_enabled;

  IF my_vector IS NULL THEN
    RAISE EXCEPTION 'matching not enabled for caller';
  END IF;

  RETURN QUERY
  SELECT
    vp.user_id,
    vp.nickname,
    vp.bio,
    vector_cosine_similarity(my_vector, vp.vector) AS similarity,
    vp.answered_count
  FROM values_profiles vp
  WHERE vp.user_id <> me
    AND vp.is_matching_enabled
    AND vp.nickname IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM match_decisions d
      WHERE d.decider_id = me AND d.target_id = vp.user_id
    )
  ORDER BY similarity DESC
  LIMIT LEAST(limit_count, 50);
END;
$$;

-- ============================================================
-- RPC: Like / Skip の決定（相互Likeならマッチ成立まで行う）
--
-- 戻り値: マッチが成立したら match_id、しなければ NULL
-- ============================================================
CREATE OR REPLACE FUNCTION decide_match(target UUID, is_like BOOLEAN)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  me UUID := auth.uid();
  mutual BOOLEAN;
  new_match_id BIGINT;
BEGIN
  IF me IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;
  IF target = me THEN
    RAISE EXCEPTION 'cannot decide on self';
  END IF;

  INSERT INTO match_decisions (decider_id, target_id, is_like)
  VALUES (me, target, is_like)
  ON CONFLICT (decider_id, target_id) DO UPDATE SET
    is_like = EXCLUDED.is_like,
    created_at = NOW();

  IF NOT is_like THEN
    RETURN NULL;
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM match_decisions d
    WHERE d.decider_id = target AND d.target_id = me AND d.is_like
  ) INTO mutual;

  IF NOT mutual THEN
    RETURN NULL;
  END IF;

  INSERT INTO matches (user_a, user_b)
  VALUES (LEAST(me, target), GREATEST(me, target))
  ON CONFLICT (user_a, user_b) DO NOTHING;

  SELECT m.id INTO new_match_id
  FROM matches m
  WHERE m.user_a = LEAST(me, target) AND m.user_b = GREATEST(me, target);

  RETURN new_match_id;
END;
$$;

-- ============================================================
-- RPC: 自分のマッチ一覧（相手の公開プロフィール付き）
-- ============================================================
CREATE OR REPLACE FUNCTION get_my_matches()
RETURNS TABLE (
  match_id BIGINT,
  partner_id UUID,
  partner_nickname TEXT,
  partner_bio TEXT,
  similarity DOUBLE PRECISION,
  matched_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  me UUID := auth.uid();
  my_vector DOUBLE PRECISION[];
BEGIN
  IF me IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  SELECT vp.vector INTO my_vector FROM values_profiles vp WHERE vp.user_id = me;

  RETURN QUERY
  SELECT
    m.id AS match_id,
    p.user_id AS partner_id,
    p.nickname AS partner_nickname,
    p.bio AS partner_bio,
    CASE
      WHEN my_vector IS NULL THEN 0
      ELSE vector_cosine_similarity(my_vector, p.vector)
    END AS similarity,
    m.created_at AS matched_at
  FROM matches m
  JOIN values_profiles p
    ON p.user_id = CASE WHEN m.user_a = me THEN m.user_b ELSE m.user_a END
  WHERE m.user_a = me OR m.user_b = me
  ORDER BY m.created_at DESC;
END;
$$;

-- ============================================================
-- Realtime: メッセージとマッチの購読を有効化
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE messages;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'matches'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE matches;
  END IF;
END;
$$;
