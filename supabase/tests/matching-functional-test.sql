-- マッチング機能の DB 層機能テスト（11ケース）
--
-- 実行方法（ローカル検証用。リモートには流さないこと）:
--   docker run -d --name vq-test -e POSTGRES_PASSWORD=postgres public.ecr.aws/supabase/postgres:17.6.1.134
--   for f in supabase/migrations/*.sql; do docker exec -i vq-test psql -U postgres -v ON_ERROR_STOP=1 < "$f"; done
--   docker exec -i vq-test psql -U postgres < supabase/tests/matching-functional-test.sql
--   docker rm -f vq-test
--
-- 注意: auth.uid() が読む GUC は環境で異なる。
--   supabase/postgres イメージ = request.jwt.claim.sub（このファイルはこちら）
--   本番 Supabase = request.jwt.claims (JSON) だが、本番では PostgREST が設定するため気にしなくてよい。
\set ON_ERROR_STOP on

-- テストユーザー作成
INSERT INTO auth.users (id, email) VALUES
  ('00000000-0000-0000-0000-00000000000a', 'a@test.local'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.local'),
  ('00000000-0000-0000-0000-00000000000c', 'c@test.local');

-- プロファイル作成（A と B は似た価値観、C はマッチング無効）
INSERT INTO values_profiles (user_id, vector, answered_count, excited_count, nickname, bio, is_matching_enabled) VALUES
  ('00000000-0000-0000-0000-00000000000a',
   ARRAY[0.8,0.7,0.6,0.5,0.9,0.6,0.7,0.4,0.8,0.6,0.5,0.7,0.3, 0.7,0.6,0.5,0.8,0.6,0.5,0.4,0.9,0.5,0.6,0.5,0.5,0.5,0.5]::double precision[],
   60, 40, 'Aさん', '創作が好き', TRUE),
  ('00000000-0000-0000-0000-00000000000b',
   ARRAY[0.7,0.8,0.6,0.5,0.8,0.7,0.6,0.5,0.9,0.5,0.6,0.6,0.4, 0.6,0.7,0.4,0.9,0.5,0.6,0.3,0.8,0.6,0.5,0.5,0.5,0.5,0.5]::double precision[],
   80, 50, 'Bさん', '学びが好き', TRUE),
  ('00000000-0000-0000-0000-00000000000c',
   ARRAY[0.1,0.2,0.1,0.2,0.1,0.2,0.1,0.2,0.1,0.2,0.1,0.2,0.1, 0.2,0.1,0.2,0.1,0.2,0.1,0.2,0.1,0.2,0.1,0.2,0.1,0.2,0.1]::double precision[],
   55, 10, 'Cさん', NULL, FALSE);

-- コサイン類似度: 同一ベクトルは 1.0
SELECT 'TEST cosine_identity',
  CASE WHEN abs(vector_cosine_similarity(ARRAY[0.5,0.5]::double precision[], ARRAY[0.5,0.5]::double precision[]) - 1.0) < 1e-9
  THEN 'PASS' ELSE 'FAIL' END;

-- === A として操作 ===
SET ROLE authenticated;
SET "request.jwt.claim.sub" = '00000000-0000-0000-0000-00000000000a';

-- 候補取得: B のみ返る（C は無効なので出ない、自分も出ない）
SELECT 'TEST candidates_for_A',
  CASE WHEN (SELECT count(*) FROM get_match_candidates(10)) = 1
    AND (SELECT nickname FROM get_match_candidates(10) LIMIT 1) = 'Bさん'
    AND (SELECT similarity FROM get_match_candidates(10) LIMIT 1) > 0.9
  THEN 'PASS' ELSE 'FAIL' END;

-- A が B を Like → まだマッチしない（NULL）
SELECT 'TEST like_no_mutual',
  CASE WHEN decide_match('00000000-0000-0000-0000-00000000000b', TRUE) IS NULL
  THEN 'PASS' ELSE 'FAIL' END;

-- === B として操作 ===
SET "request.jwt.claim.sub" = '00000000-0000-0000-0000-00000000000b';

-- B が A を Like → マッチ成立（match_id が返る）
SELECT 'TEST mutual_match',
  CASE WHEN decide_match('00000000-0000-0000-0000-00000000000a', TRUE) IS NOT NULL
  THEN 'PASS' ELSE 'FAIL' END;

-- B のマッチ一覧に A がいる
SELECT 'TEST matches_for_B',
  CASE WHEN (SELECT count(*) FROM get_my_matches()) = 1
    AND (SELECT partner_nickname FROM get_my_matches() LIMIT 1) = 'Aさん'
  THEN 'PASS' ELSE 'FAIL' END;

-- B がメッセージ送信
INSERT INTO messages (match_id, sender_id, content)
SELECT match_id, '00000000-0000-0000-0000-00000000000b', 'はじめまして！'
FROM get_my_matches() LIMIT 1;

-- === A として: メッセージが見える ===
SET "request.jwt.claim.sub" = '00000000-0000-0000-0000-00000000000a';
SELECT 'TEST message_visible_to_A',
  CASE WHEN (SELECT count(*) FROM messages) = 1 THEN 'PASS' ELSE 'FAIL' END;

-- === C として: RLS で何も見えない・できない ===
SET "request.jwt.claim.sub" = '00000000-0000-0000-0000-00000000000c';
SELECT 'TEST rls_C_sees_no_matches',
  CASE WHEN (SELECT count(*) FROM matches) = 0 THEN 'PASS' ELSE 'FAIL' END;
SELECT 'TEST rls_C_sees_no_messages',
  CASE WHEN (SELECT count(*) FROM messages) = 0 THEN 'PASS' ELSE 'FAIL' END;
-- C から見える values_profiles は自分の行だけ（他人の行は不可視）
SELECT 'TEST rls_C_sees_only_own_profile',
  CASE WHEN (SELECT count(*) FROM values_profiles) = 1
    AND (SELECT nickname FROM values_profiles LIMIT 1) = 'Cさん'
  THEN 'PASS' ELSE 'FAIL' END;

-- C（マッチング無効）が候補取得しようとするとエラーになる
DO $$
BEGIN
  PERFORM get_match_candidates(10);
  RAISE NOTICE 'TEST candidates_for_disabled: FAIL';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'TEST candidates_for_disabled: PASS';
END;
$$;

-- C が他人のマッチにメッセージを送れない（RLS violation）
DO $$
BEGIN
  INSERT INTO messages (match_id, sender_id, content)
  VALUES ((SELECT id FROM public.matches LIMIT 1), '00000000-0000-0000-0000-00000000000c', '侵入');
  RAISE NOTICE 'TEST rls_C_cannot_message: FAIL';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'TEST rls_C_cannot_message: PASS';
END;
$$;

RESET ROLE;
