# 🎓 CIMA Learn - Professional Dispute Resolution Training Platform

> **Comprehensive Learning Management System for International Arbitration, Mediation & Commercial Law**

A cutting-edge Flutter web application delivering world-class training in dispute resolution. Built for professionals seeking CIMA certification and expertise in arbitration, mediation, commercial law, and compliance.

[![Flutter](https://img.shields.io/badge/Flutter-3.32.0-blue.svg)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com/)
[![Paystack](https://img.shields.io/badge/Paystack-Payments-orange.svg)](https://paystack.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Production](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg)](#)

---

## 🌟 Key Features

### 🎯 **Complete Learning Management System**
- **📚 Comprehensive Course Catalog** - Arbitration, mediation, commercial law, maritime disputes, sports arbitration
- **🏆 CIMA Certification Paths** - Associate (ACIMArb), Member (MCIMArb), Fellow (FCIMArb) level courses
- **🎥 Interactive Video Learning** - High-quality video content with progress tracking
- **📝 Assessment & Testing** - Comprehensive quiz system with automatic scoring and feedback
- **🏅 Certificate Generation** - Automated digital certificates with verification codes
- **📊 Progress Analytics** - Detailed learning analytics and completion tracking

### 👥 **Role-Based User Management**
- **🔐 Advanced Authentication** - Email/password, Google OAuth, enhanced security
- **👨‍🎓 Student Portal** - Course browsing, enrollment, progress tracking, shopping cart
- **👨‍🏫 Instructor Dashboard** - Course creation, student management, analytics, revenue tracking
- **⚙️ Admin Panel** - User management, course approval, platform analytics, instructor applications
- **📋 Professional Profiles** - CIMA membership levels, professional credentials, learning preferences

### 💳 **Payment & Commerce**
- **🏦 Paystack Integration** - Cards, bank transfer, USSD, mobile money (MTN, Airtel, 9mobile)
- **🛒 Shopping Cart System** - Bulk course purchases with discounts
- **💰 Flexible Pricing** - Free courses, tiered pricing, membership-based discounts
- **🧾 Payment Management** - Transaction history, receipts, enrollment automation
- **🔄 Subscription Support** - Recurring payments for premium content

### 🌍 **Multi-Language & Accessibility**
- **🗣️ 9 Language Support** - English, Arabic (RTL), French, Spanish, Portuguese, Chinese, Japanese, Korean, Russian
- **📱 Responsive Design** - Mobile-first approach with tablet and desktop optimization
- **♿ WCAG Compliance** - Accessibility features for inclusive learning
- **🎨 Professional Branding** - CIMA's signature red color scheme and modern UI

---

## 🏗️ Technical Architecture

### **Frontend Framework**
- **Flutter Web 3.32.0** - Modern cross-platform framework with Material 3 design
- **Responsive UI System** - Adaptive layouts for all screen sizes
- **Provider State Management** - Efficient state handling across the application
- **Progressive Web App** - Offline capability and native-like experience

### **Backend Infrastructure**
- **Supabase PostgreSQL** - Scalable database with real-time capabilities
- **Row Level Security** - Fine-grained access control and data protection
- **Supabase Auth** - Secure authentication with social login support
- **File Storage** - Course materials, certificates, and user-generated content

### **Payment Processing**
- **Paystack Gateway** - Nigerian-focused payment processing with global support
- **Webhook Integration** - Automatic enrollment and subscription management
- **PCI Compliance** - Secure payment handling and data protection
- **Multi-Currency Support** - Local and international payment options

### **Deployment & Hosting**
- **Replit Platform** - Development and staging environment
- **Flutter Web Build** - Optimized static web deployment
- **CDN Ready** - Prepared for content delivery network deployment
- **Autoscale Deployment** - Production-ready scaling configuration

---

## 🚀 Quick Start Guide

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.32.0 or higher
- [Dart](https://dart.dev/get-dart) 3.8.0 or higher
- Web browser (Chrome, Firefox, Safari, Edge)

### Environment Setup

1. **Clone the Repository**
```bash
git clone https://github.com/your-repo/cima-learn.git
cd cima-learn
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Configure Environment Variables**
Create a `.env` file in the root directory:
```bash
# Supabase Configuration
SUPABASE_URL=https://pgmtaemwcueobaexthaq.supabase.co
SUPABASE_KEY=your_supabase_anon_key

# Paystack Payment Integration
PAYSTACK_PUBLIC_KEY=pk_test_your_public_key
PAYSTACK_SECRET_KEY=sk_test_your_secret_key
```

4. **Database Setup**
Run these SQL commands in your Supabase SQL Editor:
```sql
-- Add missing columns to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS learning_preferences text[];
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS profession text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS organization text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_number text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS country text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS bio text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role text DEFAULT 'student';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS cima_membership_level text DEFAULT 'associate';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS display_name text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id);

-- Update existing records
UPDATE profiles SET 
  role = COALESCE(role, 'student'),
  cima_membership_level = COALESCE(cima_membership_level, 'associate'),
  learning_preferences = COALESCE(learning_preferences, '{}');
```

5. **Run the Application**
```bash
# Development server
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000

# Production build
flutter build web --dart-define=SUPABASE_KEY=$SUPABASE_KEY --release
```

6. **Access the Platform**
Open your browser to `http://localhost:5000`

---

## 📁 Project Structure

```
lib/
├── config/                     # Application configuration
│   ├── app_theme.dart         # Material 3 theme and styling
│   ├── app_routes.dart        # Route definitions and navigation
│   └── supabase_config.dart   # Database configuration
│
├── src/
│   ├── models/                # Data models and structures
│   │   ├── course.dart        # Course data model
│   │   ├── cima_course.dart   # CIMA-specific course extensions
│   │   ├── user_profile.dart  # User profile and preferences
│   │   ├── course_module.dart # Course content structure
│   │   └── quiz_models.dart   # Assessment and quiz models
│   │
│   ├── screens/               # Main application screens
│   │   ├── home_page.dart              # Landing page and course discovery
│   │   ├── course_detail_page.dart     # Individual course information
│   │   ├── login_page.dart             # Authentication interface
│   │   ├── profile_page.dart           # User profile management
│   │   ├── instructor_dashboard.dart   # Instructor course management
│   │   ├── admin_dashboard.dart        # Platform administration
│   │   ├── cart_page.dart              # Shopping cart and checkout
│   │   └── learning_progress_page.dart # Progress tracking
│   │
│   ├── widgets/               # Reusable UI components
│   │   ├── header.dart                 # Navigation header with role-based menus
│   │   ├── course_card.dart            # Course display cards
│   │   ├── enrollment_button.dart      # Payment and enrollment integration
│   │   ├── quiz_widget.dart            # Assessment interface
│   │   ├── video_player_widget.dart    # Course content delivery
│   │   └── responsive_layout.dart      # Responsive design utilities
│   │
│   ├── services/              # Business logic and API integration
│   │   ├── enhanced_auth_service.dart      # Authentication and user management
│   │   ├── course_service.dart             # Course data management
│   │   ├── instructor_service.dart         # Instructor-specific functionality
│   │   ├── admin_service.dart              # Administrative operations
│   │   ├── paystack_service.dart           # Payment processing
│   │   ├── cart_service.dart               # Shopping cart management
│   │   ├── quiz_service.dart               # Assessment and testing
│   │   └── enhanced_localization_service.dart # Multi-language support
│   │
│   └── utils/                 # Helper functions and utilities
│       ├── constants.dart     # Application constants
│       ├── responsive.dart    # Responsive design helpers
│       └── validators.dart    # Form validation utilities
│
├── assets/                    # Static assets
│   ├── images/               # Course images and branding
│   ├── videos/               # Course content videos
│   └── documents/            # PDF materials and certificates
│
└── main.dart                 # Application entry point
```

---

## 🎯 User Workflows

### **Student Journey**
1. **Registration** → Email verification and profile completion
2. **Course Discovery** → Browse catalog with advanced filtering
3. **Free Trial** → Access introductory course content
4. **Purchase** → Secure payment via Paystack integration
5. **Learning** → Video content, quizzes, and progress tracking
6. **Assessment** → Comprehensive testing with instant feedback
7. **Certification** → Automated certificate generation and verification

### **Instructor Journey**
1. **Application** → Apply for instructor status with qualifications
2. **Approval** → Admin review and verification process
3. **Course Creation** → Comprehensive course builder with content upload
4. **Student Management** → Track enrollments and engagement
5. **Analytics** → Revenue tracking and performance metrics
6. **Content Updates** → Ongoing course maintenance and improvements

### **Admin Journey**
1. **User Management** → Oversee all platform users and roles
2. **Instructor Approval** → Review and approve instructor applications
3. **Course Oversight** → Approve and manage all course content
4. **Platform Analytics** → Monitor usage, revenue, and growth metrics
5. **System Configuration** → Manage platform settings and features

---

## 🛠️ Development & Deployment

### **Local Development**
```bash
# Install dependencies
flutter pub get

# Run development server
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000

# Run tests
flutter test

# Code formatting
dart format lib/

# Static analysis
flutter analyze
```

### **Production Deployment**
```bash
# Create optimized build
flutter build web --dart-define=SUPABASE_KEY=$SUPABASE_KEY --release

# Deploy static files from build/web/
# Compatible with: Vercel, Netlify, Firebase Hosting, GitHub Pages
```

### **Replit Configuration**
The project includes Replit-specific configuration:
- **Deployment Target**: Autoscale (stateless web application)
- **Build Command**: `flutter build web --dart-define=SUPABASE_KEY=$SUPABASE_KEY`
- **Run Command**: `python3 flutter_server.py` (serves on port 5000)

---

## 🔧 Configuration & Environment Variables

### **Required Environment Variables**
```bash
# Database Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key

# Payment Processing
PAYSTACK_PUBLIC_KEY=pk_test_your_public_key
PAYSTACK_SECRET_KEY=sk_test_your_secret_key

# Optional Analytics
GOOGLE_ANALYTICS_ID=your_google_analytics_id
```

### **Database Schema**
The application uses PostgreSQL with these key tables:
- **`profiles`** - User profiles with CIMA membership levels
- **`courses`** - Course catalog with metadata and content
- **`enrollments`** - Student course enrollments and progress
- **`payments`** - Payment transactions and history
- **`quizzes`** - Assessment questions and results
- **`certificates`** - Generated certificates with verification

---

## 🤝 Contributing

We welcome contributions from the educational technology and dispute resolution communities!

### **How to Contribute**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Guidelines**
- Follow Dart and Flutter best practices
- Maintain responsive design across all devices
- Write comprehensive tests for new features
- Update documentation for significant changes
- Ensure payment integration security
- Test multi-language support

---

## 📄 License & Legal

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### **Third-Party Acknowledgments**
- **Flutter Framework** - Google's UI toolkit
- **Supabase** - Backend-as-a-service platform
- **Paystack** - Payment processing for African markets
- **Material Design** - Google's design system

---

## 👨‍💻 Author & Support

**Developer**: Professional Flutter developer specializing in educational technology
**Support**: For technical support and collaboration opportunities
**Community**: Join our developer community for updates and discussions

### **Professional Services**
- Custom e-learning platform development
- Flutter web application consulting
- Payment integration implementation
- Multi-language platform localization

---

## 📊 Project Metrics

- **Languages**: Dart (95%), JavaScript (3%), HTML/CSS (2%)
- **Framework**: Flutter 3.32.0 with Material 3
- **Database**: PostgreSQL with Supabase
- **Payment Gateway**: Paystack for African markets
- **Deployment**: Web-first with mobile responsive design
- **Status**: Production-ready with active development
- **License**: MIT (open source)

---

## 🎯 Roadmap & Future Features

### **Phase 1 - Current** ✅
- Complete learning management system
- Role-based user management
- Payment processing integration
- Multi-language support

### **Phase 2 - In Development** 🔄
- Native mobile applications (iOS/Android)
- Advanced analytics dashboard
- Live virtual classroom integration
- AI-powered course recommendations

### **Phase 3 - Planned** 📋
- Blockchain certificate verification
- VR/AR training modules
- Advanced proctoring system
- Global payment gateway expansion

---

*Built with ❤️ for the global dispute resolution and legal education community*

**Ready to transform legal education? Start learning today!**