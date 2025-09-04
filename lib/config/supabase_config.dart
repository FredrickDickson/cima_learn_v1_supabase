// Environment-based configuration
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', 
  defaultValue: 'https://pgmtaemwcueobaexthaq.supabase.co');

const String supabaseAnonKey = String.fromEnvironment('SUPABASE_KEY', 
  defaultValue: '');

// Add a flag to check if we're in offline/demo mode  
bool get isOfflineMode => supabaseAnonKey.isEmpty;