-- 質問テーブルに理論的分析用のフィールドを追加
ALTER TABLE questions
  -- Self-Determination Theory (自己決定理論) の3要素
  ADD COLUMN IF NOT EXISTS sdt_autonomy DECIMAL(3,2) DEFAULT 0.5 CHECK (sdt_autonomy >= 0 AND sdt_autonomy <= 1),
  ADD COLUMN IF NOT EXISTS sdt_competence DECIMAL(3,2) DEFAULT 0.5 CHECK (sdt_competence >= 0 AND sdt_competence <= 1),
  ADD COLUMN IF NOT EXISTS sdt_relatedness DECIMAL(3,2) DEFAULT 0.5 CHECK (sdt_relatedness >= 0 AND sdt_relatedness <= 1),

  -- ikigai（生きがい）の4要素
  ADD COLUMN IF NOT EXISTS ikigai_love DECIMAL(3,2) DEFAULT 0.5 CHECK (ikigai_love >= 0 AND ikigai_love <= 1),
  ADD COLUMN IF NOT EXISTS ikigai_good_at DECIMAL(3,2) DEFAULT 0.5 CHECK (ikigai_good_at >= 0 AND ikigai_good_at <= 1),
  ADD COLUMN IF NOT EXISTS ikigai_world_needs DECIMAL(3,2) DEFAULT 0.5 CHECK (ikigai_world_needs >= 0 AND ikigai_world_needs <= 1),
  ADD COLUMN IF NOT EXISTS ikigai_paid_for DECIMAL(3,2) DEFAULT 0.5 CHECK (ikigai_paid_for >= 0 AND ikigai_paid_for <= 1),

  -- 動機付けタイプ
  ADD COLUMN IF NOT EXISTS motivation_type TEXT DEFAULT 'mixed' CHECK (motivation_type IN ('intrinsic', 'extrinsic', 'mixed')),

  -- Big Five パーソナリティ特性
  ADD COLUMN IF NOT EXISTS big5_openness DECIMAL(3,2) DEFAULT 0.5 CHECK (big5_openness >= 0 AND big5_openness <= 1),
  ADD COLUMN IF NOT EXISTS big5_conscientiousness DECIMAL(3,2) DEFAULT 0.5 CHECK (big5_conscientiousness >= 0 AND big5_conscientiousness <= 1),
  ADD COLUMN IF NOT EXISTS big5_extraversion DECIMAL(3,2) DEFAULT 0.5 CHECK (big5_extraversion >= 0 AND big5_extraversion <= 1),
  ADD COLUMN IF NOT EXISTS big5_agreeableness DECIMAL(3,2) DEFAULT 0.5 CHECK (big5_agreeableness >= 0 AND big5_agreeableness <= 1),
  ADD COLUMN IF NOT EXISTS big5_neuroticism DECIMAL(3,2) DEFAULT 0.5 CHECK (big5_neuroticism >= 0 AND big5_neuroticism <= 1);

-- インデックスを追加（分析時のパフォーマンス向上）
CREATE INDEX IF NOT EXISTS idx_questions_motivation_type ON questions(motivation_type);
CREATE INDEX IF NOT EXISTS idx_questions_sdt_autonomy ON questions(sdt_autonomy);
CREATE INDEX IF NOT EXISTS idx_questions_ikigai_love ON questions(ikigai_love);

-- user_profilesテーブルの拡張（分析結果の保存用）
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS analysis_history JSONB DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS personality_type TEXT,
  ADD COLUMN IF NOT EXISTS last_analysis_at TIMESTAMPTZ;

-- 分析結果の履歴を保存するためのテーブル
CREATE TABLE IF NOT EXISTS analysis_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL,
  response_count INTEGER NOT NULL,

  -- 分析結果
  personality_type TEXT,
  primary_motivation TEXT,
  dominant_values TEXT[],

  -- SDTスコア
  avg_sdt_autonomy DECIMAL(3,2),
  avg_sdt_competence DECIMAL(3,2),
  avg_sdt_relatedness DECIMAL(3,2),

  -- ikigaiスコア
  avg_ikigai_love DECIMAL(3,2),
  avg_ikigai_good_at DECIMAL(3,2),
  avg_ikigai_world_needs DECIMAL(3,2),
  avg_ikigai_paid_for DECIMAL(3,2),

  -- Big Fiveスコア
  avg_big5_openness DECIMAL(3,2),
  avg_big5_conscientiousness DECIMAL(3,2),
  avg_big5_extraversion DECIMAL(3,2),
  avg_big5_agreeableness DECIMAL(3,2),
  avg_big5_neuroticism DECIMAL(3,2),

  -- カテゴリー別の興味
  category_preferences JSONB DEFAULT '{}',

  -- 詳細な分析結果
  detailed_analysis TEXT,
  insights JSONB DEFAULT '[]',
  recommendations JSONB DEFAULT '[]',

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- インデックスを追加
CREATE INDEX IF NOT EXISTS idx_analysis_results_user_id ON analysis_results(user_id);
CREATE INDEX IF NOT EXISTS idx_analysis_results_session_id ON analysis_results(session_id);
CREATE INDEX IF NOT EXISTS idx_analysis_results_created_at ON analysis_results(created_at);

-- RLSポリシーを追加
ALTER TABLE analysis_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own analysis results" ON analysis_results;
CREATE POLICY "Users can view own analysis results"
  ON analysis_results FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own analysis results" ON analysis_results;
CREATE POLICY "Users can insert own analysis results"
  ON analysis_results FOR INSERT
  WITH CHECK (auth.uid() = user_id);