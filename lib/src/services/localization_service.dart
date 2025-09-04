import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  static String _currentLanguage = 'en';

  static String get currentLanguage => _currentLanguage;

  // Initialize language from stored preference
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'en';
  }

  // Change language and save preference
  static Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _currentLanguage = languageCode;
  }

  // Get supported languages
  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
      {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
      {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
      {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
    ];
  }

  // Translations map
  static Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'CIMA Learn',
      'search_courses': 'Search courses...',
      'all_categories': 'All Categories',
      'commercial_law': 'Commercial Law',
      'arbitration': 'Arbitration',
      'mediation': 'Mediation',
      'compliance': 'Compliance',
      'enroll_now': 'Enroll Now',
      'view_course': 'View Course',
      'my_courses': 'My Courses',
      'profile': 'Profile',
      'settings': 'Settings',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'sign_out': 'Sign Out',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'course_enrolled': 'Successfully enrolled in course!',
      'payment_failed': 'Payment failed. Please try again.',
      'already_enrolled': 'You are already enrolled in this course.',
    },
    'es': {
      'app_title': 'CIMA Aprender',
      'search_courses': 'Buscar cursos...',
      'all_categories': 'Todas las Categorías',
      'commercial_law': 'Derecho Comercial',
      'arbitration': 'Arbitraje',
      'mediation': 'Mediación',
      'compliance': 'Cumplimiento',
      'enroll_now': 'Inscribirse Ahora',
      'view_course': 'Ver Curso',
      'my_courses': 'Mis Cursos',
      'profile': 'Perfil',
      'settings': 'Configuraciones',
      'sign_in': 'Iniciar Sesión',
      'sign_up': 'Registrarse',
      'sign_out': 'Cerrar Sesión',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'full_name': 'Nombre Completo',
      'course_enrolled': '¡Inscrito exitosamente en el curso!',
      'payment_failed': 'El pago falló. Por favor, inténtalo de nuevo.',
      'already_enrolled': 'Ya estás inscrito en este curso.',
    },
    'fr': {
      'app_title': 'CIMA Apprendre',
      'search_courses': 'Rechercher des cours...',
      'all_categories': 'Toutes les Catégories',
      'commercial_law': 'Droit Commercial',
      'arbitration': 'Arbitrage',
      'mediation': 'Médiation',
      'compliance': 'Conformité',
      'enroll_now': 'S\'inscrire Maintenant',
      'view_course': 'Voir le Cours',
      'my_courses': 'Mes Cours',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'sign_in': 'Se Connecter',
      'sign_up': 'S\'inscrire',
      'sign_out': 'Se Déconnecter',
      'email': 'E-mail',
      'password': 'Mot de Passe',
      'full_name': 'Nom Complet',
      'course_enrolled': 'Inscription réussie au cours!',
      'payment_failed': 'Le paiement a échoué. Veuillez réessayer.',
      'already_enrolled': 'Vous êtes déjà inscrit à ce cours.',
    },
    'ar': {
      'app_title': 'تعلم سيما',
      'search_courses': 'البحث عن الدورات...',
      'all_categories': 'جميع الفئات',
      'commercial_law': 'القانون التجاري',
      'arbitration': 'التحكيم',
      'mediation': 'الوساطة',
      'compliance': 'الامتثال',
      'enroll_now': 'التسجيل الآن',
      'view_course': 'عرض الدورة',
      'my_courses': 'دوراتي',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'sign_in': 'تسجيل الدخول',
      'sign_up': 'إنشاء حساب',
      'sign_out': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'full_name': 'الاسم الكامل',
      'course_enrolled': 'تم التسجيل في الدورة بنجاح!',
      'payment_failed': 'فشل الدفع. يرجى المحاولة مرة أخرى.',
      'already_enrolled': 'أنت مسجل بالفعل في هذه الدورة.',
    },
    'de': {
      'app_title': 'CIMA Lernen',
      'search_courses': 'Kurse suchen...',
      'all_categories': 'Alle Kategorien',
      'commercial_law': 'Handelsrecht',
      'arbitration': 'Schiedsverfahren',
      'mediation': 'Mediation',
      'compliance': 'Compliance',
      'enroll_now': 'Jetzt Einschreiben',
      'view_course': 'Kurs Anzeigen',
      'my_courses': 'Meine Kurse',
      'profile': 'Profil',
      'settings': 'Einstellungen',
      'sign_in': 'Anmelden',
      'sign_up': 'Registrieren',
      'sign_out': 'Abmelden',
      'email': 'E-Mail',
      'password': 'Passwort',
      'full_name': 'Vollständiger Name',
      'course_enrolled': 'Erfolgreich für den Kurs eingeschrieben!',
      'payment_failed': 'Zahlung fehlgeschlagen. Bitte versuchen Sie es erneut.',
      'already_enrolled': 'Sie sind bereits für diesen Kurs eingeschrieben.',
    },
  };

  // Get translated text
  static String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? 
           _translations['en']?[key] ?? 
           key;
  }

  // Short form for translation
  static String t(String key) => translate(key);
}