const String supabaseUrl = 'https://pgmtaemwcueobaexthaq.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbXRhZW13Y3Vlb2JhZXh0aGFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4NTcwMDcsImV4cCI6MjA3MjQzMzAwN30.UleVbd7A9Fu8ceNgsJdi0Vc226IT0AuhJv7bH-3I4QI';

// Add a flag to check if we're in offline/demo mode
bool get isOfflineMode => supabaseAnonKey.isEmpty;