import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedLocalizationService extends ChangeNotifier {
  static final EnhancedLocalizationService _instance = EnhancedLocalizationService._internal();
  factory EnhancedLocalizationService() => _instance;
  EnhancedLocalizationService._internal();

  Locale _currentLocale = const Locale('en', 'US');
  bool _isLoading = true;

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  bool get isLoading => _isLoading;

  // Supported languages for CIMA Learn
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English (US)
    Locale('en', 'GB'), // English (UK)
    Locale('fr', 'FR'), // French
    Locale('es', 'ES'), // Spanish
    Locale('pt', 'BR'), // Portuguese (Brazil)
    Locale('ar', 'AE'), // Arabic (UAE)
    Locale('zh', 'CN'), // Chinese (Simplified)
    Locale('de', 'DE'), // German
    Locale('ru', 'RU'), // Russian
    Locale('ja', 'JP'), // Japanese
  ];

  // Comprehensive translations map
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'CIMA Learn',
      'app_subtitle': 'Dispute Resolution Training',
      'welcome_message': 'Welcome to CIMA Learn Hub!',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'sign_out': 'Sign Out',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'forgot_password': 'Forgot Password?',
      'create_account': 'Create Account',
      'already_have_account': 'Already have an account?',
      'dont_have_account': 'Don\'t have an account?',
      'my_profile': 'My Profile',
      'learning_progress': 'Learning Progress',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'courses': 'Courses',
      'enrolled_courses': 'Enrolled Courses',
      'search_all_courses': 'Search all courses, instructors, topics...',
      'search_enrolled_courses': 'Search for courses enrolled...',
      'filter_courses': 'Filter Courses',
      'level': 'Level',
      'category': 'Category',
      'delivery_mode': 'Delivery Mode',
      'price_range': 'Price Range',
      'duration': 'Duration',
      'foundational_only': 'Foundational Only',
      'clear_filters': 'Clear Filters',
      'apply_filters': 'Apply Filters',
      'enroll_now': 'Enroll Now',
      'continue_learning': 'Continue Learning',
      'course_completed': 'Course Completed',
      'modules': 'Modules',
      'hours': 'Hours',
      'rating': 'Rating',
      'instructor': 'Instructor',
      'level_associate': 'Associate (ACIMArb)',
      'level_member': 'Member (MCIMArb)',
      'level_fellow': 'Fellow (FCIMArb)',
      'category_adr': 'Alternative Dispute Resolution',
      'category_arbitration': 'International Arbitration',
      'category_mediation': 'Mediation',
      'category_construction': 'Construction Disputes',
      'category_commercial': 'Commercial Law',
      'category_maritime': 'Maritime Arbitration',
      'category_investment': 'Investment Disputes',
      'category_sports': 'Sports Arbitration',
      'category_technology': 'Technology & IP',
      'delivery_virtual': 'Virtual',
      'delivery_in_person': 'In-Person',
      'delivery_hybrid': 'Hybrid',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'profession': 'Profession',
      'organization': 'Organization',
      'phone_number': 'Phone Number',
      'country': 'Country',
      'learning_preferences': 'Learning Preferences',
      'bio': 'Bio',
      'profile_updated': 'Profile updated successfully!',
      'enrollment_successful': 'Successfully enrolled in course!',
      'video_player': 'Video Player',
      'play': 'Play',
      'pause': 'Pause',
      'fullscreen': 'Fullscreen',
      'volume': 'Volume',
      'progress': 'Progress',
      'completed': 'Completed',
      'in_progress': 'In Progress',
      'not_started': 'Not Started',
      'quiz': 'Quiz',
      'assignment': 'Assignment',
      'discussion': 'Discussion',
      'certificate': 'Certificate',
      'watch_video': 'Watch Video',
      'download_material': 'Download Material',
      'next_module': 'Next Module',
      'previous_module': 'Previous Module',
      'course_overview': 'Course Overview',
      'learning_outcomes': 'Learning Outcomes',
      'course_materials': 'Course Materials',
      'course_content': 'Course Content',
    },
    'fr': {
      'app_title': 'CIMA Apprendre',
      'app_subtitle': 'Formation en Résolution de Conflits',
      'welcome_message': 'Bienvenue sur CIMA Learn Hub!',
      'sign_in': 'Se Connecter',
      'sign_up': 'S\'inscrire',
      'sign_out': 'Se Déconnecter',
      'email': 'E-mail',
      'password': 'Mot de Passe',
      'full_name': 'Nom Complet',
      'forgot_password': 'Mot de passe oublié?',
      'create_account': 'Créer un Compte',
      'already_have_account': 'Vous avez déjà un compte?',
      'dont_have_account': 'Vous n\'avez pas de compte?',
      'my_profile': 'Mon Profil',
      'learning_progress': 'Progrès d\'Apprentissage',
      'privacy_policy': 'Politique de Confidentialité',
      'terms_of_service': 'Conditions de Service',
      'settings': 'Paramètres',
      'language': 'Langue',
      'theme': 'Thème',
      'light': 'Clair',
      'dark': 'Sombre',
      'system': 'Système',
      'courses': 'Cours',
      'enrolled_courses': 'Cours Inscrits',
      'search_all_courses': 'Rechercher tous les cours, instructeurs, sujets...',
      'search_enrolled_courses': 'Rechercher les cours inscrits...',
      'enroll_now': 'S\'inscrire Maintenant',
      'continue_learning': 'Continuer l\'Apprentissage',
      'course_completed': 'Cours Terminé',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'cancel': 'Annuler',
      'save': 'Sauvegarder',
      'modules': 'Modules',
      'hours': 'Heures',
      'rating': 'Note',
      'instructor': 'Instructeur',
      'watch_video': 'Regarder la Vidéo',
      'download_material': 'Télécharger le Matériel',
      'next_module': 'Module Suivant',
      'previous_module': 'Module Précédent',
      'course_overview': 'Aperçu du Cours',
      'learning_outcomes': 'Résultats d\'Apprentissage',
      'course_materials': 'Matériels de Cours',
      'course_content': 'Contenu du Cours',
    },
    'es': {
      'app_title': 'CIMA Aprender',
      'app_subtitle': 'Formación en Resolución de Disputas',
      'welcome_message': '¡Bienvenido a CIMA Learn Hub!',
      'sign_in': 'Iniciar Sesión',
      'sign_up': 'Registrarse',
      'sign_out': 'Cerrar Sesión',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'full_name': 'Nombre Completo',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'create_account': 'Crear Cuenta',
      'already_have_account': '¿Ya tienes una cuenta?',
      'dont_have_account': '¿No tienes una cuenta?',
      'my_profile': 'Mi Perfil',
      'learning_progress': 'Progreso de Aprendizaje',
      'courses': 'Cursos',
      'enrolled_courses': 'Cursos Inscritos',
      'search_all_courses': 'Buscar todos los cursos, instructores, temas...',
      'search_enrolled_courses': 'Buscar cursos inscritos...',
      'enroll_now': 'Inscribirse Ahora',
      'continue_learning': 'Continuar Aprendiendo',
      'course_completed': 'Curso Completado',
      'loading': 'Cargando...',
      'error': 'Error',
      'success': 'Éxito',
      'save': 'Guardar',
      'modules': 'Módulos',
      'hours': 'Horas',
      'rating': 'Calificación',
      'instructor': 'Instructor',
      'watch_video': 'Ver Video',
      'download_material': 'Descargar Material',
      'next_module': 'Siguiente Módulo',
      'previous_module': 'Módulo Anterior',
      'course_overview': 'Resumen del Curso',
      'learning_outcomes': 'Resultados de Aprendizaje',
      'course_materials': 'Materiales del Curso',
      'course_content': 'Contenido del Curso',
    },
    'ar': {
      'app_title': 'سيما للتعلم',
      'app_subtitle': 'تدريب حل النزاعات',
      'welcome_message': 'مرحباً بكم في مركز سيما للتعلم!',
      'sign_in': 'تسجيل الدخول',
      'sign_up': 'إنشاء حساب',
      'sign_out': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'full_name': 'الاسم الكامل',
      'forgot_password': 'نسيت كلمة المرور؟',
      'my_profile': 'ملفي الشخصي',
      'learning_progress': 'تقدم التعلم',
      'courses': 'الدورات',
      'enrolled_courses': 'الدورات المسجلة',
      'search_all_courses': 'البحث في جميع الدورات والمدربين والمواضيع...',
      'search_enrolled_courses': 'البحث في الدورات المسجلة...',
      'enroll_now': 'سجل الآن',
      'continue_learning': 'متابعة التعلم',
      'course_completed': 'تم إنجاز الدورة',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'save': 'حفظ',
      'modules': 'الوحدات',
      'hours': 'ساعات',
      'rating': 'التقييم',
      'instructor': 'المدرب',
      'watch_video': 'مشاهدة الفيديو',
      'download_material': 'تحميل المادة',
      'next_module': 'الوحدة التالية',
      'previous_module': 'الوحدة السابقة',
      'course_overview': 'نظرة عامة على الدورة',
      'learning_outcomes': 'نتائج التعلم',
      'course_materials': 'مواد الدورة',
      'course_content': 'محتوى الدورة',
    },
  };

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('selected_language');
      
      if (savedLanguage != null) {
        final locale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == savedLanguage,
          orElse: () => const Locale('en', 'US'),
        );
        _currentLocale = locale;
      }
    } catch (e) {
      _currentLocale = const Locale('en', 'US');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', locale.languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  static String t(String key) {
    final languageCode = _instance._currentLocale.languageCode;
    final translations = _translations[languageCode] ?? _translations['en']!;
    return translations[key] ?? key;
  }

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en': return 'English';
      case 'fr': return 'Français';
      case 'es': return 'Español';
      case 'pt': return 'Português';
      case 'ar': return 'العربية';
      case 'zh': return '中文';
      case 'de': return 'Deutsch';
      case 'ru': return 'Русский';
      case 'ja': return '日本語';
      default: return languageCode.toUpperCase();
    }
  }

  static String getCountryFlag(String languageCode) {
    switch (languageCode) {
      case 'en': return '🇺🇸';
      case 'fr': return '🇫🇷';
      case 'es': return '🇪🇸';
      case 'pt': return '🇧🇷';
      case 'ar': return '🇦🇪';
      case 'zh': return '🇨🇳';
      case 'de': return '🇩🇪';
      case 'ru': return '🇷🇺';
      case 'ja': return '🇯🇵';
      default: return '🌐';
    }
  }

  bool isRTL() {
    return _currentLocale.languageCode == 'ar';
  }
}