# CIMA Learn - Flutter Web Application

## Overview
A comprehensive dispute resolution training platform using Flutter web and Supabase backend. The platform features course browsing, user authentication, Paystack payment processing, video content delivery, multi-language support (9 languages including Arabic RTL), professional branding with CIMA's red color scheme, and modular course structure with video learning capabilities.

## Project Architecture
- **Frontend**: Flutter Web application with responsive design
- **Backend**: Supabase (PostgreSQL database with authentication)
- **Payment Processing**: Paystack integration for course purchases
- **Assessment**: Quiz system with automatic scoring and feedback
- **Certificates**: Automated certificate generation for course completion
- **Build System**: Flutter build system with Dart SDK
- **Deployment**: Static web hosting (currently serving with Python HTTP server)

## Current State
✅ **Production Ready MVP** - Complete learning management system
- Flutter environment configured with Dart support
- Supabase integration configured with environment variables
- Web build successfully compiled and serving on port 5000
- Authentication system with enhanced user profiles
- Payment integration with Paystack for course enrollment
- Quiz system with multiple question types and automatic scoring
- Certificate generation system for course completions
- Enrollment management and access control

## Key Features
### 🎓 Learning Management
- Course browsing and filtering by categories (Arbitration, Mediation, Commercial Law, etc.)
- Modular course structure with lessons and assessments
- Video content delivery system
- Progress tracking and completion analytics
- Multi-language support (English, Arabic, French, Spanish, etc.)

### 👤 User Management  
- Enhanced authentication system (email/password, Google OAuth)
- Comprehensive user profiles with CIMA membership levels
- Professional profile management (profession, organization, experience)
- User dashboard with learning analytics

### 💳 Payment & Enrollment
- Paystack payment integration for Nigerian market
- Secure course purchase and enrollment system
- Payment history and receipt management
- Multiple payment methods (cards, bank transfer, USSD, etc.)
- Automatic enrollment activation after successful payment

### 📝 Assessment & Certification
- Comprehensive quiz system with multiple question types
- Automatic scoring with detailed feedback
- Time-limited assessments with attempt tracking
- Certificate generation for course completions
- Certificate verification system with unique codes
- PDF certificate downloads

## Project Structure
```
lib/
├── config/           # Configuration files (themes, routes, constants)
├── src/
│   ├── models/       # Data models (Course)
│   ├── screens/      # UI screens (HomePage, LoginPage, etc.)
│   ├── services/     # Business logic (CourseService)
│   ├── utils/        # Utility functions
│   └── widgets/      # Reusable UI components
└── main.dart         # Application entry point
```

## Environment Configuration
- **SUPABASE_KEY**: Required environment variable for database access
- **Supabase URL**: https://pgmtaemwcueobaexthaq.supabase.co
- **PAYSTACK_PUBLIC_KEY**: Public key for Paystack payment integration
- **PAYSTACK_SECRET_KEY**: Secret key for Paystack API calls (server-side)

## Recent Changes (Sep 5, 2025)
### Critical Security & Bug Fixes ✅
1. **Security Vulnerability Fixed**: Completely removed hardcoded API keys from AppConfig - all sensitive credentials now come strictly from environment variables with no fallback defaults
2. **Payment Security Enhanced**: Fixed payment reference generation bug that could cause crashes with short user IDs
3. **Routing System Fixed**: Resolved conflicts between MaterialApp home and routes properties, consolidated all routing in single location
4. **Missing Widget Added**: Created comprehensive responsive layout system with breakpoint utilities and adaptive sizing helpers
5. **Build System Stabilized**: Successfully compiled Flutter web application with full environment variable integration

### Comprehensive Security Audit & Vulnerability Fixes ✅
1. **Input Validation System**: Created comprehensive validation utilities (`validators.dart`) with security-focused input sanitization, XSS prevention, and SQL injection protection
2. **Authentication Security**: Enhanced auth services with proper input validation, sanitized user data, and configurable redirect URLs for different environments
3. **Payment Security**: Implemented comprehensive validation for payment data, course IDs, amounts, and currency codes with security pattern detection
4. **Configuration Security**: Made all callback URLs and redirect URLs configurable via environment variables instead of hardcoded values
5. **Data Sanitization**: Added systematic sanitization of all user inputs to prevent cross-site scripting and injection attacks
6. **Dependency Security**: Audited all dependencies for known vulnerabilities and ensured proper version management

## Previous Changes (Sep 4, 2025)
### Authentication & User Management ✅
1. Implemented enhanced authentication service with Supabase Auth
2. Created comprehensive user profile system with CIMA membership levels
3. Added social login support (Google OAuth)
4. Built user dashboard with profile management

### Role-Based Architecture ✅
1. **Enhanced Authentication System**: Implemented comprehensive role-based authentication with Student, Instructor, and Admin user types
2. **Role Management**: Added role promotion system with instructor applications and admin approval workflows
3. **Permission System**: Built granular permission checks for course creation, user management, and platform administration
4. **Role-Based Navigation**: Updated header navigation to show role-appropriate menu options dynamically

### Instructor Platform ✅
1. **Instructor Dashboard**: Complete instructor portal with course management, analytics, and student tracking
2. **Course Creation System**: Comprehensive course creation workflow with rich metadata, learning outcomes, and prerequisites
3. **Instructor Analytics**: Revenue tracking, enrollment monitoring, and performance metrics
4. **Course Management**: Full CRUD operations for instructor-owned courses with status management (draft, pending, published)
5. **Student Feedback System**: Integration for collecting and displaying student reviews and ratings

### Admin Panel ✅
1. **Admin Dashboard**: Complete administrative interface with platform oversight and management tools
2. **User Management**: Admin tools for viewing, managing, and moderating all platform users
3. **Instructor Applications**: Review and approval system for instructor role requests with detailed application tracking
4. **Course Approval**: Admin workflow for reviewing and approving instructor-submitted courses
5. **Platform Analytics**: Comprehensive platform-wide analytics including user distribution, revenue tracking, and growth metrics
6. **Role Management**: Admin capability to promote/demote users and manage platform permissions

### Enhanced User Experience ✅
1. **Dynamic Navigation**: Role-based header menu that adapts based on user permissions and authentication status
2. **Access Control**: Proper access restrictions for sensitive areas with user-friendly error handling
3. **Application Workflows**: Streamlined instructor application process with status tracking and email notifications
4. **Professional UI**: Enhanced dashboard interfaces with modern card layouts, analytics visualizations, and intuitive navigation

### Payment Integration ✅  
1. Integrated Paystack payment processing for course purchases
2. Created secure payment workflow with enrollment automation
3. Added payment verification and webhook handling
4. Implemented payment history and receipt management

### Assessment System ✅
1. Built comprehensive quiz system with multiple question types
2. Added automatic scoring and detailed feedback system
3. Implemented time-limited assessments with attempt tracking
4. Created quiz analytics and progress monitoring

### Certificate System ✅
1. Automated certificate generation for course completions
2. Added certificate verification system with unique codes
3. Implemented PDF certificate generation capability
4. Built certificate management and display system

### Database Architecture ✅
1. Enhanced database schema with payment, quiz, and certificate tables
2. Implemented row-level security for data protection
3. Added analytics views for course and user reporting
4. Created helper functions for completion tracking
5. **Added Role Support**: Extended user profiles table with role field and instructor application tracking
6. **Course Management Schema**: Enhanced course tables with instructor ownership and approval status tracking

## Development Workflow
- **Build Command**: `flutter build web --dart-define=SUPABASE_KEY=$SUPABASE_KEY`
- **Serve Command**: `python3 -m http.server 5000 --directory build/web`
- **Development Port**: 5000 (configured for Replit environment)

## Deployment
- Target: Autoscale (stateless web application)
- Build process includes Flutter web compilation
- Serves static files from build/web directory