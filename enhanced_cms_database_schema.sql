-- Enhanced CIMA Learn Hub CMS Database Schema
-- This extends the existing schema with comprehensive content management capabilities

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Course modules table
CREATE TABLE course_modules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  duration_minutes INTEGER DEFAULT 0,
  is_free BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT fk_course_modules_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Course content table (videos, documents, quizzes, etc.)
CREATE TABLE course_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  module_id UUID NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('video', 'text', 'quiz', 'assignment', 'pdf', 'image')),
  title TEXT NOT NULL,
  content_url TEXT,
  content_data JSONB, -- For storing quiz questions, text content, etc.
  order_index INTEGER NOT NULL DEFAULT 0,
  duration_minutes INTEGER DEFAULT 0,
  is_required BOOLEAN DEFAULT true,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  published_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT fk_course_content_module FOREIGN KEY (module_id) REFERENCES course_modules(id) ON DELETE CASCADE
);

-- User progress tracking
CREATE TABLE user_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  content_id UUID NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  last_position INTEGER DEFAULT 0, -- For video position tracking (seconds)
  attempt_count INTEGER DEFAULT 0,
  score DECIMAL(5,2), -- For quiz scores
  time_spent_minutes INTEGER DEFAULT 0,
  last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT fk_user_progress_content FOREIGN KEY (content_id) REFERENCES course_content(id) ON DELETE CASCADE,
  UNIQUE(user_id, content_id)
);

-- Course completion tracking
CREATE TABLE course_completions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  course_id UUID NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  completion_percentage DECIMAL(5,2) DEFAULT 0.00,
  total_time_minutes INTEGER DEFAULT 0,
  certificate_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT fk_course_completions_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  UNIQUE(user_id, course_id)
);

-- Quiz attempts and submissions
CREATE TABLE quiz_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  content_id UUID NOT NULL,
  attempt_number INTEGER NOT NULL,
  answers JSONB NOT NULL, -- Store user's answers
  score DECIMAL(5,2) DEFAULT 0.00,
  max_score DECIMAL(5,2) NOT NULL,
  time_spent_seconds INTEGER DEFAULT 0,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  submitted_at TIMESTAMP WITH TIME ZONE,
  auto_graded BOOLEAN DEFAULT true,
  graded_by UUID, -- For manual grading
  feedback TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT fk_quiz_attempts_content FOREIGN KEY (content_id) REFERENCES course_content(id) ON DELETE CASCADE
);

-- Content analytics
CREATE TABLE content_analytics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content_id UUID NOT NULL,
  user_id UUID,
  event_type TEXT NOT NULL CHECK (event_type IN ('view', 'start', 'pause', 'resume', 'complete', 'skip')),
  event_data JSONB,
  session_id UUID,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT fk_content_analytics_content FOREIGN KEY (content_id) REFERENCES course_content(id) ON DELETE CASCADE
);

-- File storage tracking
CREATE TABLE content_files (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content_id UUID NOT NULL,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_size BIGINT NOT NULL,
  mime_type TEXT NOT NULL,
  storage_provider TEXT DEFAULT 'supabase' CHECK (storage_provider IN ('supabase', 'aws', 'gcp', 'azure')),
  bucket_name TEXT,
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT fk_content_files_content FOREIGN KEY (content_id) REFERENCES course_content(id) ON DELETE CASCADE
);

-- Content reviews and feedback
CREATE TABLE content_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content_id UUID NOT NULL,
  user_id UUID NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  is_helpful_count INTEGER DEFAULT 0,
  is_reported BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT fk_content_reviews_content FOREIGN KEY (content_id) REFERENCES course_content(id) ON DELETE CASCADE,
  UNIQUE(content_id, user_id)
);

-- Instructor permissions and roles
CREATE TABLE instructor_permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  course_id UUID NOT NULL,
  permission_level TEXT DEFAULT 'editor' CHECK (permission_level IN ('viewer', 'editor', 'admin', 'owner')),
  granted_by UUID NOT NULL,
  granted_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  revoked_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT fk_instructor_permissions_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  UNIQUE(user_id, course_id)
);

-- Content versioning
CREATE TABLE content_versions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content_id UUID NOT NULL,
  version_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  content_url TEXT,
  content_data JSONB,
  change_summary TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  CONSTRAINT fk_content_versions_content FOREIGN KEY (content_id) REFERENCES course_content(id) ON DELETE CASCADE,
  UNIQUE(content_id, version_number)
);

-- Indexes for performance
CREATE INDEX idx_course_modules_course_id ON course_modules(course_id);
CREATE INDEX idx_course_modules_order ON course_modules(course_id, order_index);
CREATE INDEX idx_course_content_module_id ON course_content(module_id);
CREATE INDEX idx_course_content_order ON course_content(module_id, order_index);
CREATE INDEX idx_course_content_type ON course_content(content_type);
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_content_id ON user_progress(content_id);
CREATE INDEX idx_user_progress_completed ON user_progress(completed_at) WHERE completed_at IS NOT NULL;
CREATE INDEX idx_course_completions_user_id ON course_completions(user_id);
CREATE INDEX idx_course_completions_course_id ON course_completions(course_id);
CREATE INDEX idx_quiz_attempts_user_content ON quiz_attempts(user_id, content_id);
CREATE INDEX idx_content_analytics_content_id ON content_analytics(content_id);
CREATE INDEX idx_content_analytics_created_at ON content_analytics(created_at);
CREATE INDEX idx_content_files_content_id ON content_files(content_id);

-- RLS (Row Level Security) Policies
ALTER TABLE course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE instructor_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_versions ENABLE ROW LEVEL SECURITY;

-- Policies for course modules (instructors and enrolled users can view)
CREATE POLICY "Course modules viewable by instructors and enrolled users" ON course_modules
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM instructor_permissions ip 
      WHERE ip.course_id = course_modules.course_id 
      AND ip.user_id = auth.uid()
    )
    OR 
    EXISTS (
      SELECT 1 FROM enrollments e 
      WHERE e.course_id = course_modules.course_id 
      AND e.user_id = auth.uid()
    )
  );

-- Policies for course content
CREATE POLICY "Course content viewable by instructors and enrolled users" ON course_content
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM course_modules cm 
      JOIN instructor_permissions ip ON ip.course_id = cm.course_id
      WHERE cm.id = course_content.module_id 
      AND ip.user_id = auth.uid()
    )
    OR 
    EXISTS (
      SELECT 1 FROM course_modules cm 
      JOIN enrollments e ON e.course_id = cm.course_id
      WHERE cm.id = course_content.module_id 
      AND e.user_id = auth.uid()
    )
  );

-- Policies for user progress (users can only see their own progress)
CREATE POLICY "Users can view own progress" ON user_progress
  FOR ALL USING (user_id = auth.uid());

-- Policies for course completions
CREATE POLICY "Users can view own completions" ON course_completions
  FOR ALL USING (user_id = auth.uid());

-- Policies for quiz attempts
CREATE POLICY "Users can view own quiz attempts" ON quiz_attempts
  FOR ALL USING (user_id = auth.uid());

-- Functions for analytics and reporting
CREATE OR REPLACE FUNCTION get_course_progress(p_user_id UUID, p_course_id UUID)
RETURNS TABLE (
  content_id UUID,
  content_title TEXT,
  content_type TEXT,
  progress_percentage INTEGER,
  completed_at TIMESTAMP WITH TIME ZONE,
  last_position INTEGER
)
LANGUAGE SQL
AS $$
  SELECT 
    cc.id as content_id,
    cc.title as content_title,
    cc.content_type,
    COALESCE(up.progress_percentage, 0) as progress_percentage,
    up.completed_at,
    COALESCE(up.last_position, 0) as last_position
  FROM course_modules cm
  JOIN course_content cc ON cc.module_id = cm.id
  LEFT JOIN user_progress up ON up.content_id = cc.id AND up.user_id = p_user_id
  WHERE cm.course_id = p_course_id
  ORDER BY cm.order_index, cc.order_index;
$$;

CREATE OR REPLACE FUNCTION get_content_analytics(p_content_id UUID)
RETURNS TABLE (
  total_views BIGINT,
  unique_viewers BIGINT,
  average_completion_rate DECIMAL,
  average_time_spent INTEGER
)
LANGUAGE SQL
AS $$
  SELECT 
    COUNT(*) as total_views,
    COUNT(DISTINCT user_id) as unique_viewers,
    AVG(progress_percentage) as average_completion_rate,
    AVG(time_spent_minutes) as average_time_spent
  FROM user_progress 
  WHERE content_id = p_content_id;
$$;

CREATE OR REPLACE FUNCTION get_course_analytics(p_course_id UUID)
RETURNS TABLE (
  total_enrollments BIGINT,
  completed_enrollments BIGINT,
  completion_rate DECIMAL,
  average_rating DECIMAL
)
LANGUAGE SQL
AS $$
  SELECT 
    COUNT(DISTINCT e.user_id) as total_enrollments,
    COUNT(DISTINCT cc.user_id) as completed_enrollments,
    CASE 
      WHEN COUNT(DISTINCT e.user_id) > 0 
      THEN (COUNT(DISTINCT cc.user_id)::DECIMAL / COUNT(DISTINCT e.user_id)) * 100 
      ELSE 0 
    END as completion_rate,
    AVG(c.rating) as average_rating
  FROM enrollments e
  LEFT JOIN course_completions cc ON cc.course_id = e.course_id AND cc.user_id = e.user_id
  LEFT JOIN courses c ON c.id = e.course_id
  WHERE e.course_id = p_course_id
  GROUP BY e.course_id;
$$;

-- Triggers for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_course_modules_updated_at BEFORE UPDATE ON course_modules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_course_content_updated_at BEFORE UPDATE ON course_content FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_content_reviews_updated_at BEFORE UPDATE ON content_reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data for testing
INSERT INTO course_modules (id, course_id, title, description, order_index, duration_minutes, is_free) VALUES
  (uuid_generate_v4(), (SELECT id FROM courses LIMIT 1), 'Introduction to Arbitration', 'Basic concepts and principles of international arbitration', 0, 45, true),
  (uuid_generate_v4(), (SELECT id FROM courses LIMIT 1), 'Arbitration Procedures', 'Step-by-step arbitration process', 1, 60, false),
  (uuid_generate_v4(), (SELECT id FROM courses LIMIT 1), 'Award Writing', 'How to draft effective arbitration awards', 2, 90, false);

INSERT INTO course_content (id, module_id, content_type, title, order_index, duration_minutes, content_data) VALUES
  (uuid_generate_v4(), (SELECT id FROM course_modules ORDER BY order_index LIMIT 1), 'video', 'Welcome to Arbitration', 0, 15, '{"videoUrl": "", "autoplay": false, "showControls": true}'),
  (uuid_generate_v4(), (SELECT id FROM course_modules ORDER BY order_index LIMIT 1), 'text', 'What is Arbitration?', 1, 10, '{"content": "Arbitration is a form of alternative dispute resolution..."}'),
  (uuid_generate_v4(), (SELECT id FROM course_modules ORDER BY order_index LIMIT 1), 'quiz', 'Chapter 1 Quiz', 2, 15, '{"questions": [{"type": "multiple_choice", "question": "What is arbitration?", "options": ["ADR method", "Court proceeding", "Mediation", "Settlement"], "correctAnswer": 0}]}');

-- Grant permissions to authenticated users
GRANT SELECT, INSERT, UPDATE ON course_modules TO authenticated;
GRANT SELECT, INSERT, UPDATE ON course_content TO authenticated;
GRANT ALL ON user_progress TO authenticated;
GRANT ALL ON course_completions TO authenticated;
GRANT ALL ON quiz_attempts TO authenticated;
GRANT SELECT, INSERT ON content_analytics TO authenticated;
GRANT SELECT ON content_files TO authenticated;
GRANT ALL ON content_reviews TO authenticated;
GRANT SELECT ON instructor_permissions TO authenticated;
GRANT SELECT ON content_versions TO authenticated;