-- Enhanced User Profiles Table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  profile_image VARCHAR(500),
  profession VARCHAR(100),
  organization VARCHAR(255),
  phone_number VARCHAR(20),
  country VARCHAR(100),
  learning_preferences TEXT[], -- Array of learning preferences
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Course Progress Tracking Table
CREATE TABLE IF NOT EXISTS course_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id VARCHAR(255) NOT NULL,
  course_title VARCHAR(255) NOT NULL,
  progress_percentage DECIMAL(5,2) DEFAULT 0.0,
  completed_modules INTEGER DEFAULT 0,
  total_modules INTEGER DEFAULT 10,
  enrollment_date TIMESTAMPTZ DEFAULT NOW(),
  completion_date TIMESTAMPTZ,
  last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
  module_progress JSONB DEFAULT '[]'::jsonb, -- Array of module progress objects
  overall_score DECIMAL(5,2),
  status VARCHAR(20) DEFAULT 'enrolled' CHECK (status IN ('enrolled', 'in_progress', 'completed', 'paused')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- Course Modules Table (for detailed progress tracking)
CREATE TABLE IF NOT EXISTS course_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id VARCHAR(255) NOT NULL,
  module_id VARCHAR(255) NOT NULL,
  module_title VARCHAR(255) NOT NULL,
  module_order INTEGER NOT NULL,
  estimated_duration_minutes INTEGER DEFAULT 30,
  module_type VARCHAR(50) DEFAULT 'video' CHECK (module_type IN ('video', 'reading', 'quiz', 'assignment', 'discussion')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(course_id, module_id)
);

-- User Module Progress Table
CREATE TABLE IF NOT EXISTS user_module_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id VARCHAR(255) NOT NULL,
  module_id VARCHAR(255) NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  score DECIMAL(5,2),
  time_spent_seconds INTEGER DEFAULT 0,
  completed_at TIMESTAMPTZ,
  last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, course_id, module_id)
);

-- Learning Statistics Table (for analytics)
CREATE TABLE IF NOT EXISTS learning_statistics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  total_study_time_minutes INTEGER DEFAULT 0,
  modules_completed INTEGER DEFAULT 0,
  courses_accessed INTEGER DEFAULT 0,
  quiz_scores JSONB DEFAULT '[]'::jsonb,
  streaks INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_course_progress_user_id ON course_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_course_progress_course_id ON course_progress(course_id);
CREATE INDEX IF NOT EXISTS idx_course_progress_status ON course_progress(status);
CREATE INDEX IF NOT EXISTS idx_user_module_progress_user_id ON user_module_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_module_progress_course_id ON user_module_progress(course_id);
CREATE INDEX IF NOT EXISTS idx_learning_statistics_user_id ON learning_statistics(user_id);
CREATE INDEX IF NOT EXISTS idx_learning_statistics_date ON learning_statistics(date);

-- Row Level Security (RLS) Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_module_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_statistics ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Course progress policies
CREATE POLICY "Users can view their own course progress" ON course_progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own course progress" ON course_progress
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own course progress" ON course_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User module progress policies
CREATE POLICY "Users can view their own module progress" ON user_module_progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own module progress" ON user_module_progress
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own module progress" ON user_module_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Learning statistics policies
CREATE POLICY "Users can view their own learning statistics" ON learning_statistics
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own learning statistics" ON learning_statistics
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own learning statistics" ON learning_statistics
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at columns
CREATE TRIGGER update_profiles_updated_at 
  BEFORE UPDATE ON profiles 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_course_progress_updated_at 
  BEFORE UPDATE ON course_progress 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_module_progress_updated_at 
  BEFORE UPDATE ON user_module_progress 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_learning_statistics_updated_at 
  BEFORE UPDATE ON learning_statistics 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();