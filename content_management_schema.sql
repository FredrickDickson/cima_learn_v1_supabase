-- Extended database schema for video content and multi-language support

-- Course Modules Table (for detailed course content)
CREATE TABLE IF NOT EXISTS course_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL,
  module_type VARCHAR(50) DEFAULT 'video' CHECK (module_type IN ('video', 'document', 'quiz', 'live_session', 'assignment')),
  estimated_duration_minutes INTEGER DEFAULT 30,
  is_required BOOLEAN DEFAULT TRUE,
  prerequisites TEXT[], -- Array of prerequisite module IDs
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Multi-language Content Table
CREATE TABLE IF NOT EXISTS module_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
  language_code VARCHAR(10) NOT NULL, -- 'en', 'fr', 'es', 'ar', etc.
  content_type VARCHAR(50) NOT NULL, -- 'video_url', 'document_url', 'text_content', 'quiz_data'
  content_url TEXT, -- URL for videos, documents, etc.
  content_data JSONB, -- JSON data for quizzes, text content, etc.
  subtitle_url TEXT, -- URL for subtitle files
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(module_id, language_code, content_type)
);

-- Course Content Metadata
CREATE TABLE IF NOT EXISTS course_content_metadata (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id VARCHAR(255) NOT NULL,
  language_code VARCHAR(10) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  learning_outcomes TEXT[],
  requirements TEXT[],
  target_audience TEXT,
  certification_info TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(course_id, language_code)
);

-- User Video Progress Table (detailed tracking)
CREATE TABLE IF NOT EXISTS user_video_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_id UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
  watch_time_seconds INTEGER DEFAULT 0,
  total_duration_seconds INTEGER DEFAULT 0,
  completion_percentage DECIMAL(5,2) DEFAULT 0.00,
  is_completed BOOLEAN DEFAULT FALSE,
  last_position_seconds INTEGER DEFAULT 0,
  playback_speed DECIMAL(3,2) DEFAULT 1.00,
  language_watched VARCHAR(10) DEFAULT 'en',
  completed_at TIMESTAMPTZ,
  last_watched_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, module_id)
);

-- Quiz Attempts Table
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_id UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
  attempt_number INTEGER DEFAULT 1,
  score DECIMAL(5,2),
  max_score DECIMAL(5,2),
  answers JSONB, -- User's answers
  is_passed BOOLEAN DEFAULT FALSE,
  time_taken_seconds INTEGER,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Language Preferences
CREATE TABLE IF NOT EXISTS user_language_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  preferred_language VARCHAR(10) DEFAULT 'en',
  fallback_languages VARCHAR(10)[] DEFAULT ARRAY['en'],
  subtitle_language VARCHAR(10),
  interface_language VARCHAR(10) DEFAULT 'en',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content Ratings and Reviews (multi-language)
CREATE TABLE IF NOT EXISTS content_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id VARCHAR(255) NOT NULL,
  module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  review_text TEXT,
  language_code VARCHAR(10) DEFAULT 'en',
  is_verified BOOLEAN DEFAULT FALSE,
  helpful_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Live Session Schedule
CREATE TABLE IF NOT EXISTS live_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  instructor_name VARCHAR(255),
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  max_participants INTEGER,
  meeting_url TEXT,
  language_code VARCHAR(10) DEFAULT 'en',
  is_recorded BOOLEAN DEFAULT TRUE,
  recording_url TEXT,
  status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'live', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Live Session Attendance
CREATE TABLE IF NOT EXISTS live_session_attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES live_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ,
  left_at TIMESTAMPTZ,
  attendance_duration_minutes INTEGER DEFAULT 0,
  participation_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(session_id, user_id)
);

-- Content Analytics
CREATE TABLE IF NOT EXISTS content_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id VARCHAR(255) NOT NULL,
  module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type VARCHAR(50) NOT NULL, -- 'video_start', 'video_pause', 'video_complete', 'quiz_start', etc.
  event_data JSONB,
  language_code VARCHAR(10) DEFAULT 'en',
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  session_id VARCHAR(255), -- To group events by user session
  ip_address INET,
  user_agent TEXT
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_course_modules_course_id ON course_modules(course_id);
CREATE INDEX IF NOT EXISTS idx_course_modules_order ON course_modules(course_id, order_index);
CREATE INDEX IF NOT EXISTS idx_module_content_module_id ON module_content(module_id);
CREATE INDEX IF NOT EXISTS idx_module_content_language ON module_content(language_code);
CREATE INDEX IF NOT EXISTS idx_user_video_progress_user_id ON user_video_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_video_progress_module_id ON user_video_progress(module_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user_module ON quiz_attempts(user_id, module_id);
CREATE INDEX IF NOT EXISTS idx_content_reviews_course_id ON content_reviews(course_id);
CREATE INDEX IF NOT EXISTS idx_live_sessions_scheduled_at ON live_sessions(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_content_analytics_timestamp ON content_analytics(timestamp);
CREATE INDEX IF NOT EXISTS idx_content_analytics_course_module ON content_analytics(course_id, module_id);

-- Row Level Security Policies
ALTER TABLE course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE module_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_video_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_language_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_session_attendance ENABLE ROW LEVEL SECURITY;

-- Course modules are public (readable by all authenticated users)
CREATE POLICY "Course modules are viewable by authenticated users" ON course_modules
  FOR SELECT USING (auth.role() = 'authenticated');

-- Module content is public (readable by all authenticated users)
CREATE POLICY "Module content is viewable by authenticated users" ON module_content
  FOR SELECT USING (auth.role() = 'authenticated');

-- Users can only access their own video progress
CREATE POLICY "Users can manage their own video progress" ON user_video_progress
  FOR ALL USING (auth.uid() = user_id);

-- Users can only access their own quiz attempts
CREATE POLICY "Users can manage their own quiz attempts" ON quiz_attempts
  FOR ALL USING (auth.uid() = user_id);

-- Users can manage their own language preferences
CREATE POLICY "Users can manage their own language preferences" ON user_language_preferences
  FOR ALL USING (auth.uid() = user_id);

-- Users can create reviews, but only edit their own
CREATE POLICY "Users can view all reviews" ON content_reviews
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can create reviews" ON content_reviews
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews" ON content_reviews
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can view their own attendance records
CREATE POLICY "Users can view their own attendance" ON live_session_attendance
  FOR SELECT USING (auth.uid() = user_id);

-- Triggers for updated_at columns
CREATE TRIGGER update_course_modules_updated_at 
  BEFORE UPDATE ON course_modules 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_module_content_updated_at 
  BEFORE UPDATE ON module_content 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_video_progress_updated_at 
  BEFORE UPDATE ON user_video_progress 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_language_preferences_updated_at 
  BEFORE UPDATE ON user_language_preferences 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_content_reviews_updated_at 
  BEFORE UPDATE ON content_reviews 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data for testing
INSERT INTO course_modules (course_id, title, description, order_index, module_type, estimated_duration_minutes) VALUES
('cima-001', 'Introduction to International Arbitration', 'Overview of international arbitration principles and history', 1, 'video', 45),
('cima-001', 'UNCITRAL Model Law Fundamentals', 'Deep dive into UNCITRAL Model Law provisions', 2, 'video', 60),
('cima-001', 'Arbitration Agreement Drafting', 'Best practices for drafting arbitration clauses', 3, 'document', 30),
('cima-001', 'Module 1 Assessment', 'Test your knowledge of arbitration fundamentals', 4, 'quiz', 20);

-- Multi-language content for the first module
INSERT INTO module_content (module_id, language_code, content_type, content_url) VALUES
((SELECT id FROM course_modules WHERE course_id = 'cima-001' AND order_index = 1), 'en', 'video_url', 'https://example.com/videos/intro-arbitration-en.mp4'),
((SELECT id FROM course_modules WHERE course_id = 'cima-001' AND order_index = 1), 'fr', 'video_url', 'https://example.com/videos/intro-arbitration-fr.mp4'),
((SELECT id FROM course_modules WHERE course_id = 'cima-001' AND order_index = 1), 'es', 'video_url', 'https://example.com/videos/intro-arbitration-es.mp4'),
((SELECT id FROM course_modules WHERE course_id = 'cima-001' AND order_index = 1), 'ar', 'video_url', 'https://example.com/videos/intro-arbitration-ar.mp4');

-- Multi-language course metadata
INSERT INTO course_content_metadata (course_id, language_code, title, description, learning_outcomes, target_audience) VALUES
('cima-001', 'en', 'Law, Practice & Procedure in Domestic and International Arbitration', 
 'Our flagship foundational course delivering in-depth training on legal principles, processes, and procedures that underpin domestic and international arbitration.',
 ARRAY['Understand fundamental principles of arbitration', 'Navigate procedural frameworks effectively', 'Apply key legislation including UNCITRAL Model Law'],
 'Aspiring and seasoned legal professionals'),
('cima-001', 'fr', 'Droit, Pratique et Procédure en Arbitrage National et International',
 'Notre cours phare offrant une formation approfondie sur les principes juridiques, processus et procédures qui sous-tendent l''arbitrage national et international.',
 ARRAY['Comprendre les principes fondamentaux de l''arbitrage', 'Naviguer efficacement dans les cadres procéduraux', 'Appliquer la législation clé incluant la Loi Modèle CNUDCI'],
 'Professionnels juridiques aspirants et expérimentés');