# CIMA Learn - Flutter Web Application

## Overview
A Flutter web application for CIMA Learn, offering dispute resolution training courses. The application provides a platform for users to browse, enroll in, and manage training courses in commercial law, arbitration, mediation, and compliance.

## Project Architecture
- **Frontend**: Flutter Web application
- **Backend**: Supabase (PostgreSQL database with authentication)
- **Build System**: Flutter build system with Dart SDK
- **Deployment**: Static web hosting (currently serving with Python HTTP server)

## Current State
✅ **Setup Complete** - Project is fully configured and running in Replit environment
- Flutter environment configured with Dart support
- Supabase integration configured with environment variables
- Web build successfully compiled and serving on port 5000
- All compilation errors resolved

## Key Features
- Course browsing and filtering by categories
- User authentication (login/signup)
- Course enrollment system
- Responsive web design
- Integration with Supabase backend

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

## Recent Changes (Sep 4, 2025)
1. Fixed Flutter compilation errors in Course model and service
2. Updated Supabase configuration to use dart-define for web compatibility
3. Set up Python HTTP server workflow for production-ready serving
4. Configured deployment settings for autoscale deployment
5. Resolved environment variable access for web builds

## Development Workflow
- **Build Command**: `flutter build web --dart-define=SUPABASE_KEY=$SUPABASE_KEY`
- **Serve Command**: `python3 -m http.server 5000 --directory build/web`
- **Development Port**: 5000 (configured for Replit environment)

## Deployment
- Target: Autoscale (stateless web application)
- Build process includes Flutter web compilation
- Serves static files from build/web directory