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

## Recent Changes (Sep 4, 2025)
### Authentication & User Management ✅
1. Implemented enhanced authentication service with Supabase Auth
2. Created comprehensive user profile system with CIMA membership levels
3. Added social login support (Google OAuth)
4. Built user dashboard with profile management

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

## Development Workflow
- **Build Command**: `flutter build web --dart-define=SUPABASE_KEY=$SUPABASE_KEY`
- **Serve Command**: `python3 -m http.server 5000 --directory build/web`
- **Development Port**: 5000 (configured for Replit environment)

## Deployment
- Target: Autoscale (stateless web application)
- Build process includes Flutter web compilation
- Serves static files from build/web directory