-- Quiz and Certificate System Tables for CIMA Learn
-- Add these tables to your existing Supabase database

-- =============================================================================
-- QUIZZES TABLE - Store quiz definitions
-- =============================================================================

CREATE TABLE IF NOT EXISTS quizzes (
    id TEXT PRIMARY KEY,
    course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    questions JSONB NOT NULL DEFAULT '[]', -- Store questions as JSON
    time_limit INTEGER DEFAULT 30, -- in minutes
    passing_score INTEGER DEFAULT 70, -- percentage
    is_required BOOLEAN DEFAULT FALSE,
    max_attempts INTEGER DEFAULT 3,
    available_from TIMESTAMPTZ,
    available_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    
    -- Indexes for performance
    INDEX idx_quizzes_course_id (course_id),
    INDEX idx_quizzes_available (available_from, available_until),
    INDEX idx_quizzes_created_at (created_at DESC)
);

-- =============================================================================
-- QUIZ ATTEMPTS TABLE - Track user quiz attempts
-- =============================================================================

CREATE TABLE IF NOT EXISTS quiz_attempts (
    id TEXT PRIMARY KEY,
    quiz_id TEXT NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    attempt_number INTEGER NOT NULL DEFAULT 1,
    answers JSONB DEFAULT '{}', -- Store user answers as JSON
    score INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0,
    percentage DECIMAL(5,2) DEFAULT 0.00,
    is_passed BOOLEAN DEFAULT FALSE,
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    time_taken INTEGER, -- in seconds
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(quiz_id, user_id, attempt_number),
    CHECK (percentage >= 0 AND percentage <= 100),
    CHECK (score >= 0),
    CHECK (total_points >= 0),
    
    -- Indexes for performance
    INDEX idx_quiz_attempts_quiz_id (quiz_id),
    INDEX idx_quiz_attempts_user_id (user_id),
    INDEX idx_quiz_attempts_completed (completed_at),
    INDEX idx_quiz_attempts_percentage (percentage DESC)
);

-- =============================================================================
-- CERTIFICATES TABLE - Store issued certificates
-- =============================================================================

CREATE TABLE IF NOT EXISTS certificates (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    certificate_type VARCHAR(50) DEFAULT 'course_completion',
    certificate_number VARCHAR(100) UNIQUE NOT NULL,
    recipient_name VARCHAR(255) NOT NULL,
    course_title VARCHAR(255) NOT NULL,
    instructor_name VARCHAR(255),
    completion_date TIMESTAMPTZ NOT NULL,
    final_score DECIMAL(5,2),
    verification_code VARCHAR(100) UNIQUE NOT NULL,
    template_used VARCHAR(50) DEFAULT 'cima_standard',
    pdf_url TEXT,
    is_verified BOOLEAN DEFAULT TRUE,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    revocation_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(user_id, course_id, certificate_type),
    
    -- Indexes for performance
    INDEX idx_certificates_user_id (user_id),
    INDEX idx_certificates_course_id (course_id),
    INDEX idx_certificates_verification_code (verification_code),
    INDEX idx_certificates_certificate_number (certificate_number),
    INDEX idx_certificates_issued_at (issued_at DESC),
    INDEX idx_certificates_valid_until (valid_until)
);

-- =============================================================================
-- COURSE MODULES ENHANCEMENT - Add quiz support
-- =============================================================================

-- Add quiz_id to course modules to link modules with quizzes
ALTER TABLE course_modules ADD COLUMN IF NOT EXISTS quiz_id TEXT REFERENCES quizzes(id) ON DELETE SET NULL;
ALTER TABLE course_modules ADD COLUMN IF NOT EXISTS is_quiz_required BOOLEAN DEFAULT FALSE;
ALTER TABLE course_modules ADD COLUMN IF NOT EXISTS completion_criteria JSONB DEFAULT '{}';

-- =============================================================================
-- USER PROGRESS ENHANCEMENT - Track detailed progress
-- =============================================================================

CREATE TABLE IF NOT EXISTS user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    module_id TEXT REFERENCES course_modules(id) ON DELETE CASCADE,
    lesson_id TEXT,
    progress_type VARCHAR(50) NOT NULL, -- 'lesson', 'quiz', 'assignment', 'video'
    status VARCHAR(20) DEFAULT 'not_started', -- 'not_started', 'in_progress', 'completed', 'failed'
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    time_spent INTEGER DEFAULT 0, -- in seconds
    last_accessed TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    data JSONB DEFAULT '{}', -- Store additional progress data
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(user_id, course_id, module_id, lesson_id, progress_type),
    CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    
    -- Indexes for performance
    INDEX idx_user_progress_user_course (user_id, course_id),
    INDEX idx_user_progress_module (module_id),
    INDEX idx_user_progress_status (status),
    INDEX idx_user_progress_last_accessed (last_accessed DESC)
);

-- =============================================================================
-- ROW LEVEL SECURITY POLICIES
-- =============================================================================

-- Enable RLS on new tables
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- Quizzes: Public read access, instructors can manage
CREATE POLICY "Public can view quizzes" ON quizzes
    FOR SELECT TO authenticated, anon USING (TRUE);

CREATE POLICY "Instructors can manage quizzes" ON quizzes
    FOR ALL TO authenticated USING (auth.uid() = created_by);

-- Quiz attempts: Users can only access their own attempts
CREATE POLICY "Users can view own quiz attempts" ON quiz_attempts
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can create own quiz attempts" ON quiz_attempts
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own quiz attempts" ON quiz_attempts
    FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Certificates: Users can view their own, public verification
CREATE POLICY "Users can view own certificates" ON certificates
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Public can verify certificates" ON certificates
    FOR SELECT TO anon, authenticated USING (is_verified = TRUE);

CREATE POLICY "System can issue certificates" ON certificates
    FOR INSERT TO service_role WITH CHECK (TRUE);

CREATE POLICY "System can update certificates" ON certificates
    FOR UPDATE TO service_role USING (TRUE);

-- User progress: Users can only access their own progress
CREATE POLICY "Users can view own progress" ON user_progress
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own progress" ON user_progress
    FOR ALL TO authenticated USING (auth.uid() = user_id);

-- =============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =============================================================================

-- Update timestamps
CREATE TRIGGER update_quizzes_updated_at 
    BEFORE UPDATE ON quizzes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quiz_attempts_updated_at 
    BEFORE UPDATE ON quiz_attempts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_certificates_updated_at 
    BEFORE UPDATE ON certificates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_progress_updated_at 
    BEFORE UPDATE ON user_progress 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- USEFUL FUNCTIONS
-- =============================================================================

-- Calculate course completion percentage
CREATE OR REPLACE FUNCTION calculate_course_completion(user_uuid UUID, course_uuid TEXT)
RETURNS DECIMAL(5,2)
LANGUAGE sql SECURITY DEFINER
AS $$
    WITH progress_summary AS (
        SELECT 
            COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed,
            COUNT(*) as total
        FROM user_progress 
        WHERE user_id = user_uuid 
        AND course_id = course_uuid
        AND progress_type IN ('lesson', 'quiz')
    )
    SELECT 
        CASE 
            WHEN total = 0 THEN 0.00
            ELSE ROUND((completed::DECIMAL / total::DECIMAL) * 100, 2)
        END
    FROM progress_summary;
$$;

-- Check if user meets certificate requirements
CREATE OR REPLACE FUNCTION meets_certificate_requirements(user_uuid UUID, course_uuid TEXT)
RETURNS BOOLEAN
LANGUAGE sql SECURITY DEFINER
AS $$
    SELECT 
        -- Course must be 100% complete
        calculate_course_completion(user_uuid, course_uuid) >= 100.00
        AND
        -- All required quizzes must be passed
        NOT EXISTS (
            SELECT 1 FROM quizzes q
            WHERE q.course_id = course_uuid
            AND q.is_required = TRUE
            AND NOT EXISTS (
                SELECT 1 FROM quiz_attempts qa
                WHERE qa.quiz_id = q.id
                AND qa.user_id = user_uuid
                AND qa.is_passed = TRUE
            )
        );
$$;

-- =============================================================================
-- SAMPLE DATA FUNCTIONS
-- =============================================================================

-- Function to create sample quiz for a course
CREATE OR REPLACE FUNCTION create_sample_quiz(
    course_uuid TEXT,
    quiz_title TEXT DEFAULT 'Course Assessment Quiz'
)
RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
    quiz_uuid TEXT;
    sample_questions JSONB;
BEGIN
    quiz_uuid := 'quiz_' || course_uuid || '_' || EXTRACT(EPOCH FROM NOW())::text;
    
    sample_questions := '[
        {
            "id": "q1",
            "question": "What is the primary purpose of alternative dispute resolution (ADR)?",
            "type": "singleChoice",
            "points": 2,
            "options": [
                {"id": "a", "text": "To replace court systems entirely", "isCorrect": false},
                {"id": "b", "text": "To provide faster and more cost-effective dispute resolution", "isCorrect": true},
                {"id": "c", "text": "To eliminate the need for lawyers", "isCorrect": false},
                {"id": "d", "text": "To make legal processes more complex", "isCorrect": false}
            ],
            "correctAnswer": "b",
            "explanation": "ADR aims to provide faster, more cost-effective, and often more flexible dispute resolution compared to traditional litigation."
        },
        {
            "id": "q2",
            "question": "Which of the following are key principles of mediation?",
            "type": "multipleChoice",
            "points": 3,
            "options": [
                {"id": "a", "text": "Voluntary participation", "isCorrect": true},
                {"id": "b", "text": "Confidentiality", "isCorrect": true},
                {"id": "c", "text": "Neutral facilitation", "isCorrect": true},
                {"id": "d", "text": "Binding decisions", "isCorrect": false}
            ],
            "correctAnswers": ["a", "b", "c"],
            "explanation": "Mediation is based on voluntary participation, confidentiality, and neutral facilitation. Unlike arbitration, mediation does not result in binding decisions."
        },
        {
            "id": "q3",
            "question": "Arbitration decisions are legally binding on the parties involved.",
            "type": "trueFalse",
            "points": 1,
            "options": [
                {"id": "true", "text": "True", "isCorrect": true},
                {"id": "false", "text": "False", "isCorrect": false}
            ],
            "correctAnswer": "true",
            "explanation": "Yes, arbitration decisions (awards) are legally binding and enforceable in courts, which is one of the key differences from mediation."
        }
    ]'::JSONB;
    
    INSERT INTO quizzes (
        id, course_id, title, description, questions, 
        time_limit, passing_score, is_required, max_attempts
    ) VALUES (
        quiz_uuid, 
        course_uuid, 
        quiz_title,
        'Test your understanding of the key concepts covered in this course.',
        sample_questions,
        30, -- 30 minutes
        70, -- 70% passing score
        TRUE, -- Required for certificate
        3 -- Max 3 attempts
    );
    
    RETURN quiz_uuid;
END;
$$;

-- =============================================================================
-- VIEWS FOR REPORTING
-- =============================================================================

-- Course completion dashboard
CREATE VIEW course_completion_dashboard AS
SELECT 
    c.id as course_id,
    c.title,
    COUNT(DISTINCT e.user_id) as total_enrolled,
    COUNT(DISTINCT CASE WHEN cert.id IS NOT NULL THEN e.user_id END) as certificates_issued,
    ROUND(AVG(e.completion_percentage), 2) as avg_completion,
    COUNT(DISTINCT qa.user_id) as quiz_participants,
    ROUND(AVG(qa.percentage), 2) as avg_quiz_score
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
LEFT JOIN certificates cert ON c.id = cert.course_id AND e.user_id = cert.user_id
LEFT JOIN quiz_attempts qa ON qa.quiz_id IN (
    SELECT id FROM quizzes WHERE course_id = c.id
) AND qa.user_id = e.user_id AND qa.completed_at IS NOT NULL
GROUP BY c.id, c.title
ORDER BY total_enrolled DESC;

-- User learning analytics
CREATE VIEW user_learning_analytics AS
SELECT 
    u.id as user_id,
    p.full_name,
    COUNT(DISTINCT e.course_id) as courses_enrolled,
    COUNT(DISTINCT cert.course_id) as certificates_earned,
    ROUND(AVG(e.completion_percentage), 2) as avg_course_completion,
    COUNT(DISTINCT qa.quiz_id) as quizzes_taken,
    ROUND(AVG(qa.percentage), 2) as avg_quiz_score,
    SUM(CASE WHEN qa.is_passed THEN 1 ELSE 0 END) as quizzes_passed
FROM auth.users u
JOIN profiles p ON u.id = p.user_id
LEFT JOIN enrollments e ON u.id = e.user_id
LEFT JOIN certificates cert ON u.id = cert.user_id
LEFT JOIN quiz_attempts qa ON u.id = qa.user_id AND qa.completed_at IS NOT NULL
GROUP BY u.id, p.full_name
ORDER BY certificates_earned DESC, avg_course_completion DESC;

-- Success message
SELECT 'Quiz and Certificate system tables created successfully! 
✅ Comprehensive quiz system with multiple question types
✅ Quiz attempt tracking with scoring and time limits
✅ Certificate generation and verification system  
✅ Enhanced user progress tracking
✅ Course completion analytics
✅ Row-level security for data protection
✅ Sample data generation functions
🎯 Ready for assessment and certification features!' as setup_status;