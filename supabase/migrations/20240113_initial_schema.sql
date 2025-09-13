-- Create questions table
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  category TEXT NOT NULL,
  growth_score DECIMAL(3,2) NOT NULL CHECK (growth_score >= 0 AND growth_score <= 1),
  tags TEXT[] DEFAULT '{}',
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create user_responses table
CREATE TABLE IF NOT EXISTS user_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  is_excited BOOLEAN NOT NULL,
  responded_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, question_id)
);

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  ideal_self TEXT,
  values JSONB DEFAULT '{}',
  personality_traits JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create habits table
CREATE TABLE IF NOT EXISTS habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  frequency TEXT CHECK (frequency IN ('daily', 'weekly', 'monthly')),
  streak_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create avoid_list table
CREATE TABLE IF NOT EXISTS avoid_list (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  reason TEXT,
  category TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_questions_category ON questions(category);
CREATE INDEX idx_questions_growth_score ON questions(growth_score);
CREATE INDEX idx_user_responses_user_id ON user_responses(user_id);
CREATE INDEX idx_user_responses_question_id ON user_responses(question_id);
CREATE INDEX idx_habits_user_id ON habits(user_id);
CREATE INDEX idx_avoid_list_user_id ON avoid_list(user_id);

-- Enable Row Level Security
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE avoid_list ENABLE ROW LEVEL SECURITY;

-- Create policies for questions (everyone can read)
CREATE POLICY "Questions are viewable by everyone"
  ON questions FOR SELECT
  USING (true);

-- Create policies for user_responses (users can only access their own)
CREATE POLICY "Users can view own responses"
  ON user_responses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own responses"
  ON user_responses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own responses"
  ON user_responses FOR UPDATE
  USING (auth.uid() = user_id);

-- Create policies for user_profiles
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- Create policies for habits
CREATE POLICY "Users can view own habits"
  ON habits FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own habits"
  ON habits FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits"
  ON habits FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits"
  ON habits FOR DELETE
  USING (auth.uid() = user_id);

-- Create policies for avoid_list
CREATE POLICY "Users can view own avoid list"
  ON avoid_list FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert to own avoid list"
  ON avoid_list FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete from own avoid list"
  ON avoid_list FOR DELETE
  USING (auth.uid() = user_id);