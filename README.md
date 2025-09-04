# 🎓 CIMA Learn Hub

> **Professional Dispute Resolution Training Platform**

A comprehensive Flutter web application providing world-class training in International Arbitration, Mediation, Commercial Law, and Compliance. Built for the Chartered Institute of Arbitrators (CIMA) to deliver structured learning paths, interactive assessments, and professional certification.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com/)
[![Paystack](https://img.shields.io/badge/Paystack-Payments-orange.svg)](https://paystack.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🌟 Features

### 🎯 **Core Learning Management**
- **📚 Comprehensive Course Catalog** - Browse arbitration, mediation, commercial law, and compliance courses
- **🛤️ Structured Learning Paths** - Organized by CIMA membership levels (Associate, Member, Fellow)
- **🆓 Free Introductory Course** - 30-minute introduction to dispute resolution
- **🎥 Video Content Delivery** - Interactive video learning with progress tracking
- **📝 Assessment System** - Quizzes, assignments, and knowledge checks
- **🏆 Certification Management** - Automated certificate generation and verification

### 🔍 **Advanced Discovery & Search**
- **🔎 Intelligent Search** - Main search bar with real-time filtering
- **⚡ Advanced Filters** - Price ranges, languages, quality ratings (4.5+ stars)
- **🏷️ Category Navigation** - Browse by subject areas and specializations
- **⭐ Quality Indicators** - Highest rated, most popular, recently updated

### 👤 **User Management & Authentication**
- **🔐 Secure Authentication** - Email/password and Google OAuth integration
- **📋 Enhanced User Profiles** - Professional information, CIMA membership levels
- **📊 Progress Dashboard** - Learning analytics and achievement tracking
- **💼 Professional Networking** - Connect with industry professionals

### 💳 **Payment & Enrollment**
- **🏦 Paystack Integration** - Support for cards and mobile money (MTN, Airtel, 9mobile)
- **💰 Flexible Pricing** - Free courses, tiered pricing, and membership discounts
- **📜 Enrollment Management** - Automatic course access after payment
- **🧾 Payment History** - Transaction records and receipt management

### 🌍 **Multi-Language & Accessibility**
- **🗣️ 9 Language Support** - Including Arabic RTL support
- **📱 Responsive Design** - Optimized for mobile, tablet, and desktop
- **♿ Accessibility** - WCAG compliant design principles
- **🎨 Professional Branding** - CIMA's signature red color scheme

---

## 🏗️ Architecture

### **Frontend**
- **Flutter Web** - Cross-platform framework with Material 3 design
- **Responsive UI** - Adaptive layouts for all screen sizes
- **State Management** - Provider pattern for efficient state handling

### **Backend**
- **Supabase** - PostgreSQL database with real-time capabilities
- **Authentication** - Supabase Auth with social login support
- **Row Level Security** - Secure data access controls
- **File Storage** - Course materials and user-generated content

### **Payment Processing**
- **Paystack** - Nigerian payment gateway with comprehensive options
- **Webhook Integration** - Automatic enrollment after successful payment
- **Security** - PCI compliant payment processing

### **Deployment**
- **Replit Hosting** - Development and staging environment
- **Flutter Web Build** - Optimized static web deployment
- **CDN Ready** - Optimized for content delivery networks

---

## 🚀 Quick Start

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or higher)
- [Dart](https://dart.dev/get-dart) (3.x or higher)
- [Git](https://git-scm.com/) for version control

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/FredrickDickson/cima_learn_hub.git
cd cima_learn_hub
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Set up environment variables**
Create a `.env` file in the root directory:
```bash
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
PAYSTACK_PUBLIC_KEY=your_paystack_public_key
PAYSTACK_SECRET_KEY=your_paystack_secret_key
```

4. **Run the application**
```bash
# Development mode
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000

# Production build
flutter build web --dart-define=SUPABASE_KEY=$SUPABASE_KEY
```

5. **Access the application**
Open your browser to `http://localhost:5000`

---

## 📁 Project Structure

```
lib/
├── config/                 # Configuration files
│   ├── app_theme.dart     # Material 3 theme configuration
│   ├── app_routes.dart    # Route definitions
│   └── supabase_config.dart # Database configuration
│
├── src/
│   ├── models/            # Data models
│   │   ├── course.dart    # Course data structure
│   │   ├── user.dart      # User profile model
│   │   └── enrollment.dart # Enrollment tracking
│   │
│   ├── screens/           # Main application screens
│   │   ├── home_page.dart           # Homepage with course discovery
│   │   ├── learning_paths_page.dart # Learning path selection
│   │   ├── free_intro_course_page.dart # Free introductory course
│   │   ├── course_detail_page.dart  # Individual course details
│   │   ├── login_page.dart         # Authentication
│   │   └── profile_page.dart       # User profile management
│   │
│   ├── widgets/           # Reusable UI components
│   │   ├── hero_section.dart       # Homepage hero banner
│   │   ├── course_card.dart        # Course display cards
│   │   ├── search_bar_widget.dart  # Main search functionality
│   │   ├── course_filters_widget.dart # Advanced filtering
│   │   ├── enrollment_button.dart  # Payment integration
│   │   └── header.dart            # Navigation header
│   │
│   ├── services/          # Business logic and API calls
│   │   ├── course_service.dart     # Course data management
│   │   ├── auth_service.dart       # User authentication
│   │   ├── paystack_service.dart   # Payment processing
│   │   └── localization_service.dart # Multi-language support
│   │
│   └── utils/             # Helper functions and utilities
│       ├── responsive.dart        # Responsive design utilities
│       └── constants.dart         # App-wide constants
│
└── main.dart              # Application entry point
```

---

## 🔧 Configuration

### Environment Setup

The application requires several environment variables for full functionality:

```bash
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-public-key

# Paystack Payment Integration
PAYSTACK_PUBLIC_KEY=pk_test_your-public-key
PAYSTACK_SECRET_KEY=sk_test_your-secret-key

# Optional: Analytics and Monitoring
GOOGLE_ANALYTICS_ID=your-ga-id
```

### Database Setup

The application uses Supabase PostgreSQL with the following key tables:
- `courses` - Course information and metadata
- `users` - User profiles and authentication
- `enrollments` - Course enrollment tracking
- `payments` - Payment transaction records
- `progress` - Learning progress and completion

---

## 💻 Development

### Running Locally

```bash
# Start development server
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000

# Run tests
flutter test

# Generate build files
flutter build web --release
```

### Code Standards

- **Dart Style Guide** - Follow official Dart style conventions
- **Widget Organization** - Separate widgets into reusable components
- **State Management** - Use Provider for state management
- **Error Handling** - Implement comprehensive error handling
- **Security** - Never commit API keys or sensitive data

---

## 🌐 Deployment

### Production Build

```bash
# Create optimized build
flutter build web --dart-define=SUPABASE_KEY=$SUPABASE_KEY --release

# Deploy to static hosting
# Files will be in build/web/
```

### Supported Platforms

- ✅ **Web Browsers** - Chrome, Firefox, Safari, Edge
- ✅ **Mobile Web** - iOS Safari, Android Chrome
- ✅ **Desktop** - Windows, macOS, Linux (via web)
- 🔄 **Native Mobile** - iOS/Android (planned)

---

## 🎯 User Journey

1. **Discovery** → Landing page with hero section and course preview
2. **Free Trial** → "Start Learning Today" leads to free introductory course
3. **Path Selection** → "Explore Courses" leads to structured learning paths
4. **Course Selection** → Advanced search and filtering for course discovery
5. **Enrollment** → Secure Paystack payment with mobile money support
6. **Learning** → Interactive video content with progress tracking
7. **Assessment** → Quizzes and assignments with automated scoring
8. **Certification** → Automated certificate generation upon completion

---

## 🤝 Contributing

We welcome contributions from the community! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow Dart and Flutter best practices
- Write tests for new functionality
- Update documentation for significant changes
- Ensure responsive design across all devices
- Test payment integration thoroughly

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Fredrick Kwesi Poku Dickson**
- 🌐 [GitHub](https://github.com/FredrickDickson)
- 💼 Full-Stack Engineer specializing in Flutter and educational technology
- 📧 Contact for collaboration opportunities

---

## 🙏 Acknowledgments

- **CIMA (Chartered Institute of Arbitrators)** - For educational content and professional guidance
- **Flutter Team** - For the excellent cross-platform framework
- **Supabase** - For backend-as-a-service infrastructure
- **Paystack** - For seamless payment processing in African markets
- **Open Source Community** - For the amazing packages and tools

---

## 📊 Project Stats

- **Languages**: Dart, JavaScript, HTML, CSS
- **Framework**: Flutter 3.x
- **Database**: PostgreSQL (via Supabase)
- **Payment Gateway**: Paystack
- **Deployment**: Web (Replit)
- **License**: MIT
- **Status**: Production Ready

---

*Built with ❤️ for the global dispute resolution community*