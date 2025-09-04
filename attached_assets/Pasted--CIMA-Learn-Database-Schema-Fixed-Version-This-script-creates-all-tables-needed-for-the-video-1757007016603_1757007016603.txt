-- CIMA Learn Database Schema - Fixed Version
-- This script creates all tables needed for the video learning system

-- =====================================================================================
-- STEP 1: BACKUP EXISTING DATA AND UPDATE COURSES TABLE
-- =====================================================================================

-- Backup existing courses
CREATE TABLE IF NOT EXISTS courses_backup AS SELECT * FROM courses;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Allow public read access to courses" ON courses;
DROP POLICY IF EXISTS "Public can view courses" ON courses;
DROP POLICY IF EXISTS "Public can view course modules" ON course_modules;
DROP POLICY IF EXISTS "Public can view module content" ON module_content;
DROP POLICY IF EXISTS "Public can view live sessions" ON live_sessions;
DROP POLICY IF EXISTS "Users can manage their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can manage their own enrollments" ON enrollments;
DROP POLICY IF EXISTS "Users manage own progress" ON user_video_progress;
DROP POLICY IF EXISTS "Users manage own quiz attempts" ON quiz_attempts;
DROP POLICY IF EXISTS "Users manage own language preferences" ON user_language_preferences;
DROP POLICY IF EXISTS "Users manage own profiles" ON profiles;
DROP POLICY IF EXISTS "Users manage own enrollments" ON enrollments;

-- Enhanced courses table to match CIMACourse model
ALTER TABLE courses ADD COLUMN IF NOT EXISTS description TEXT DEFAULT '';
ALTER TABLE courses ADD COLUMN IF NOT EXISTS skills TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE courses ADD COLUMN IF NOT EXISTS language VARCHAR(10) DEFAULT 'en';
ALTER TABLE courses ADD COLUMN IF NOT EXISTS video_url TEXT;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS modules TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE courses ADD COLUMN IF NOT EXISTS level VARCHAR(20) DEFAULT 'member';
ALTER TABLE courses ADD COLUMN IF NOT EXISTS prerequisites TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE courses ADD COLUMN IF NOT EXISTS session_count INTEGER DEFAULT 4;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS delivery_mode VARCHAR(20) DEFAULT 'virtual';
ALTER TABLE courses ADD COLUMN IF NOT EXISTS learning_outcomes TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE courses ADD COLUMN IF NOT EXISTS certification_offered VARCHAR(255) DEFAULT 'Certificate of Completion';
ALTER TABLE courses ADD COLUMN IF NOT EXISTS is_foundational BOOLEAN DEFAULT FALSE;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS practical_hours DECIMAL(5,2) DEFAULT 0.00;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS theory_hours DECIMAL(5,2) DEFAULT 0.00;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE courses ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Update data types to match our models - FIXED VERSION
ALTER TABLE courses ALTER COLUMN duration TYPE INTEGER USING 
  CASE 
    WHEN duration::TEXT ~ '^[0-9]+' THEN REGEXP_REPLACE(duration::TEXT, '[^0-9]', '', 'g')::INTEGER
    ELSE 8
  END;

-- =====================================================================================
-- STEP 2: COURSE MODULES SYSTEM (matches CourseModule model)
-- =====================================================================================

CREATE TABLE IF NOT EXISTS course_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT DEFAULT '',
    order_index INTEGER NOT NULL,
    module_type VARCHAR(20) DEFAULT 'video' CHECK (module_type IN ('video', 'document', 'quiz', 'live_session')),
    content JSONB DEFAULT '{}'::jsonb, -- language code -> content URL mapping
    estimated_duration_minutes INTEGER DEFAULT 30,
    prerequisites TEXT[] DEFAULT ARRAY[]::TEXT[],
    is_required BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(course_id, order_index)
);

-- =====================================================================================
-- STEP 3: MULTI-LANGUAGE CONTENT (matches what EnhancedLocalizationService expects)
-- =====================================================================================

CREATE TABLE IF NOT EXISTS module_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
    language_code VARCHAR(10) NOT NULL, -- 'en', 'fr', 'es', 'pt', 'ar', 'zh', 'de', 'ru', 'ja'
    content_type VARCHAR(50) NOT NULL, -- 'video_url', 'document_url', 'quiz_data'
    content_url TEXT,
    content_data JSONB,
    subtitle_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(module_id, language_code, content_type)
);

-- =====================================================================================
-- STEP 4: USER PROGRESS TRACKING (matches ModuleService expectations)
-- =====================================================================================

CREATE TABLE IF NOT EXISTS user_video_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    module_id UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
    watch_time_seconds INTEGER DEFAULT 0,
    completion_percentage DECIMAL(5,2) DEFAULT 0.00,
    is_completed BOOLEAN DEFAULT FALSE,
    last_position_seconds INTEGER DEFAULT 0,
    language_watched VARCHAR(10) DEFAULT 'en',
    completed_at TIMESTAMPTZ,
    last_watched_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, module_id)
);

-- =====================================================================================
-- STEP 5: USER LANGUAGE PREFERENCES (matches ModuleService)
-- =====================================================================================

CREATE TABLE IF NOT EXISTS user_language_preferences (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    preferred_language VARCHAR(10) DEFAULT 'en',
    subtitle_language VARCHAR(10) DEFAULT 'en',
    interface_language VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================================================
-- STEP 6: ENHANCED PROFILES TABLE
-- =====================================================================================

-- Update profiles table to match our app needs
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS display_name VARCHAR(100);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_number VARCHAR(20);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS country VARCHAR(100);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS profession VARCHAR(100);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS organization VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS profile_image VARCHAR(500);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS cima_membership_level VARCHAR(20) DEFAULT 'associate';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- =====================================================================================
-- STEP 7: QUIZ SYSTEM (for quiz modules)
-- =====================================================================================

CREATE TABLE IF NOT EXISTS quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    module_id UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
    attempt_number INTEGER DEFAULT 1,
    score DECIMAL(5,2),
    max_score DECIMAL(5,2),
    is_passed BOOLEAN DEFAULT FALSE,
    answers JSONB,
    time_taken_seconds INTEGER,
    language_code VARCHAR(10) DEFAULT 'en',
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================================================
-- STEP 8: LIVE SESSIONS (for live_session modules)
-- =====================================================================================

CREATE TABLE IF NOT EXISTS live_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
    course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    instructor_name VARCHAR(255),
    scheduled_at TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    max_participants INTEGER DEFAULT 100,
    meeting_url TEXT,
    language_code VARCHAR(10) DEFAULT 'en',
    is_recorded BOOLEAN DEFAULT TRUE,
    recording_url TEXT,
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'live', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================================================
-- STEP 9: PERFORMANCE INDEXES
-- =====================================================================================

-- Course indexes
CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category);
CREATE INDEX IF NOT EXISTS idx_courses_level ON courses(level);
CREATE INDEX IF NOT EXISTS idx_courses_delivery_mode ON courses(delivery_mode);
CREATE INDEX IF NOT EXISTS idx_courses_rating ON courses(rating DESC);

-- Module indexes
CREATE INDEX IF NOT EXISTS idx_course_modules_course_id ON course_modules(course_id);
CREATE INDEX IF NOT EXISTS idx_course_modules_order ON course_modules(course_id, order_index);
CREATE INDEX IF NOT EXISTS idx_course_modules_type ON course_modules(module_type);

-- Content indexes
CREATE INDEX IF NOT EXISTS idx_module_content_module_id ON module_content(module_id);
CREATE INDEX IF NOT EXISTS idx_module_content_language ON module_content(language_code);

-- Progress indexes
CREATE INDEX IF NOT EXISTS idx_user_video_progress_user_id ON user_video_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_video_progress_module_id ON user_video_progress(module_id);
CREATE INDEX IF NOT EXISTS idx_user_video_progress_completion ON user_video_progress(completion_percentage DESC);

-- Quiz indexes
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user_module ON quiz_attempts(user_id, module_id);

-- =====================================================================================
-- STEP 10: ROW LEVEL SECURITY POLICIES
-- =====================================================================================

-- Enable RLS
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE module_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_video_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_language_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_sessions ENABLE ROW LEVEL SECURITY;

-- Public read policies
CREATE POLICY "Public can view courses" ON courses
    FOR SELECT TO public USING (TRUE);

CREATE POLICY "Public can view course modules" ON course_modules
    FOR SELECT TO public USING (TRUE);

CREATE POLICY "Public can view module content" ON module_content
    FOR SELECT TO public USING (TRUE);

CREATE POLICY "Public can view live sessions" ON live_sessions
    FOR SELECT TO public USING (TRUE);

-- User-specific policies
CREATE POLICY "Users manage own progress" ON user_video_progress
    FOR ALL TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users manage own quiz attempts" ON quiz_attempts
    FOR ALL TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users manage own language preferences" ON user_language_preferences
    FOR ALL TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users manage own profiles" ON profiles
    FOR ALL TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users manage own enrollments" ON enrollments
    FOR ALL TO authenticated USING (auth.uid() = user_id);

-- =====================================================================================
-- STEP 11: AUTOMATIC TIMESTAMP TRIGGERS
-- =====================================================================================

-- Update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers
CREATE TRIGGER update_courses_updated_at 
    BEFORE UPDATE ON courses 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_course_modules_updated_at 
    BEFORE UPDATE ON course_modules 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_module_content_updated_at 
    BEFORE UPDATE ON module_content 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_video_progress_updated_at 
    BEFORE UPDATE ON user_video_progress 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_live_sessions_updated_at 
    BEFORE UPDATE ON live_sessions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Success message
SELECT 'Database schema updated successfully! All syntax errors fixed.' as status;