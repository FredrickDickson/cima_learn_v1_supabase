const String supabaseUrl = 'https://pgmtaemwcueobaexthaq.supabase.co';

// For web builds, we'll need to use a different approach to access environment variables
// This is a placeholder - in production you'd inject this at build time
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_KEY', defaultValue: '');