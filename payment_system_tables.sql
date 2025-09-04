-- Payment System Tables for CIMA Learn Paystack Integration
-- Add these tables to your existing Supabase database

-- =============================================================================
-- PAYMENTS TABLE - Track all payment transactions
-- =============================================================================

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference VARCHAR(255) UNIQUE NOT NULL, -- Paystack reference
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'NGN',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'abandoned', 'cancelled')),
    payment_method VARCHAR(50) DEFAULT 'paystack',
    paystack_data JSONB, -- Store full Paystack response
    gateway_response TEXT,
    authorization_code TEXT, -- For future recurring payments
    customer_code TEXT, -- Paystack customer code
    channel VARCHAR(50), -- card, bank, ussd, qr, etc.
    fees DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours'), -- Payment link expiry
    
    -- Indexes for performance
    INDEX idx_payments_reference (reference),
    INDEX idx_payments_user_id (user_id),
    INDEX idx_payments_course_id (course_id),
    INDEX idx_payments_status (status),
    INDEX idx_payments_created_at (created_at DESC)
);

-- =============================================================================
-- ENROLLMENTS TABLE ENHANCEMENT - Link payments to enrollments
-- =============================================================================

-- Add payment reference to existing enrollments table
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS payment_reference VARCHAR(255);
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS amount_paid DECIMAL(10,2);
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'NGN';
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS enrollment_status VARCHAR(20) DEFAULT 'active' 
    CHECK (enrollment_status IN ('active', 'suspended', 'completed', 'refunded'));
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS access_expires_at TIMESTAMPTZ;
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS completion_percentage DECIMAL(5,2) DEFAULT 0.00;
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS certificate_issued BOOLEAN DEFAULT FALSE;
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS certificate_url TEXT;

-- Add foreign key constraint for payment reference
ALTER TABLE enrollments 
ADD CONSTRAINT fk_enrollments_payment_reference 
FOREIGN KEY (payment_reference) 
REFERENCES payments(reference) ON DELETE SET NULL;

-- =============================================================================
-- PAYMENT SUBSCRIPTIONS - For future membership features
-- =============================================================================

CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    subscription_code VARCHAR(255) UNIQUE NOT NULL, -- Paystack subscription code
    customer_code VARCHAR(255) NOT NULL, -- Paystack customer code
    plan_code VARCHAR(255) NOT NULL, -- Paystack plan code
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'non-renewing', 'cancelled', 'attention')),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'NGN',
    interval VARCHAR(20) NOT NULL, -- monthly, yearly
    next_payment_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    cancelled_at TIMESTAMPTZ,
    
    INDEX idx_subscriptions_user_id (user_id),
    INDEX idx_subscriptions_status (status),
    INDEX idx_subscriptions_next_payment (next_payment_date)
);

-- =============================================================================
-- PAYMENT WEBHOOKS - Track webhook events from Paystack
-- =============================================================================

CREATE TABLE IF NOT EXISTS payment_webhooks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(100) NOT NULL, -- charge.success, subscription.create, etc.
    reference VARCHAR(255), -- Payment/subscription reference
    data JSONB NOT NULL, -- Full webhook payload
    processed BOOLEAN DEFAULT FALSE,
    processed_at TIMESTAMPTZ,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    INDEX idx_webhooks_event_type (event_type),
    INDEX idx_webhooks_reference (reference),
    INDEX idx_webhooks_processed (processed),
    INDEX idx_webhooks_created_at (created_at DESC)
);

-- =============================================================================
-- PAYMENT DISPUTES - Handle chargebacks and disputes
-- =============================================================================

CREATE TABLE IF NOT EXISTS payment_disputes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID REFERENCES payments(id) ON DELETE CASCADE,
    dispute_id VARCHAR(255) UNIQUE NOT NULL, -- Paystack dispute ID
    reason VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'resolved', 'lost')),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'NGN',
    evidence JSONB, -- Evidence submitted
    resolution_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    
    INDEX idx_disputes_payment_id (payment_id),
    INDEX idx_disputes_status (status)
);

-- =============================================================================
-- ROW LEVEL SECURITY POLICIES
-- =============================================================================

-- Enable RLS on all payment tables
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_webhooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_disputes ENABLE ROW LEVEL SECURITY;

-- Users can only view their own payment records
CREATE POLICY "Users can view own payments" ON payments
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "System can insert payments" ON payments
    FOR INSERT TO service_role WITH CHECK (TRUE);

CREATE POLICY "System can update payments" ON payments
    FOR UPDATE TO service_role USING (TRUE);

-- Users can view their own subscriptions
CREATE POLICY "Users can view own subscriptions" ON subscriptions
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

-- Only service role can manage webhooks and disputes (admin/system operations)
CREATE POLICY "Service role manages webhooks" ON payment_webhooks
    FOR ALL TO service_role USING (TRUE);

CREATE POLICY "Service role manages disputes" ON payment_disputes
    FOR ALL TO service_role USING (TRUE);

-- =============================================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =============================================================================

-- Update payments timestamp
CREATE TRIGGER update_payments_updated_at 
    BEFORE UPDATE ON payments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update subscriptions timestamp
CREATE TRIGGER update_subscriptions_updated_at 
    BEFORE UPDATE ON subscriptions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update disputes timestamp
CREATE TRIGGER update_disputes_updated_at 
    BEFORE UPDATE ON payment_disputes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- USEFUL VIEWS FOR REPORTING
-- =============================================================================

-- Revenue summary view
CREATE VIEW revenue_summary AS
SELECT 
    DATE_TRUNC('month', created_at) as month,
    COUNT(*) as total_payments,
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as total_revenue,
    AVG(CASE WHEN status = 'completed' THEN amount ELSE NULL END) as avg_payment,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful_payments,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_payments
FROM payments 
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

-- Course enrollment analytics
CREATE VIEW course_enrollment_analytics AS
SELECT 
    c.id,
    c.title,
    c.price,
    COUNT(e.id) as total_enrollments,
    SUM(CASE WHEN p.status = 'completed' THEN p.amount ELSE 0 END) as total_revenue,
    AVG(e.completion_percentage) as avg_completion,
    COUNT(CASE WHEN e.completion_percentage >= 100 THEN 1 END) as completed_students
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
LEFT JOIN payments p ON e.payment_reference = p.reference
GROUP BY c.id, c.title, c.price
ORDER BY total_revenue DESC;

-- User payment history view
CREATE VIEW user_payment_history AS
SELECT 
    p.user_id,
    p.reference,
    p.amount,
    p.currency,
    p.status,
    p.created_at,
    p.completed_at,
    c.title as course_title,
    c.instructor,
    e.enrollment_status,
    e.completion_percentage
FROM payments p
JOIN courses c ON p.course_id = c.id
LEFT JOIN enrollments e ON p.reference = e.payment_reference
ORDER BY p.created_at DESC;

-- =============================================================================
-- SAMPLE FUNCTIONS
-- =============================================================================

-- Function to get user's active enrollments
CREATE OR REPLACE FUNCTION get_user_active_enrollments(user_uuid UUID)
RETURNS TABLE (
    course_id TEXT,
    course_title VARCHAR(255),
    enrollment_date TIMESTAMPTZ,
    completion_percentage DECIMAL(5,2),
    payment_amount DECIMAL(10,2)
) 
LANGUAGE sql SECURITY DEFINER
AS $$
    SELECT 
        e.course_id,
        c.title,
        e.enrolled_at,
        e.completion_percentage,
        p.amount
    FROM enrollments e
    JOIN courses c ON e.course_id = c.id
    LEFT JOIN payments p ON e.payment_reference = p.reference
    WHERE e.user_id = user_uuid 
    AND e.enrollment_status = 'active'
    ORDER BY e.enrolled_at DESC;
$$;

-- Function to check if payment is valid
CREATE OR REPLACE FUNCTION is_payment_valid(payment_ref VARCHAR(255))
RETURNS BOOLEAN
LANGUAGE sql SECURITY DEFINER
AS $$
    SELECT EXISTS(
        SELECT 1 FROM payments 
        WHERE reference = payment_ref 
        AND status = 'completed'
        AND created_at > NOW() - INTERVAL '30 days'
    );
$$;

-- Success message
SELECT 'Payment system tables created successfully! 
✅ Payments tracking with Paystack integration
✅ Enhanced enrollments with payment references  
✅ Subscription management for future features
✅ Webhook handling for real-time updates
✅ Dispute management system
✅ Revenue reporting views
✅ Row-level security policies
🎯 Ready for Paystack payment processing!' as setup_status;