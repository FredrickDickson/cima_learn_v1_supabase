import 'package:flutter_dotenv/flutter_dotenv.dart';

const String supabaseUrl = 'https://pgmtaemwcueobaexthaq.supabase.co';
String get supabaseAnonKey => dotenv.env['SUPABASE_KEY'] ?? '';

// Add a flag to check if we're in offline/demo mode  
bool get isOfflineMode => supabaseAnonKey.isEmpty;