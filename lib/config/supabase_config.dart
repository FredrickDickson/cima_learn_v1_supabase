// Simplified Supabase configuration following Flutter docs pattern
// Direct access to Supabase client through main.dart global instance

import 'package:supabase_flutter/supabase_flutter.dart';

// Global Supabase client - use this throughout the app
final supabase = Supabase.instance.client;

// Configuration constants
const String supabaseUrl = 'https://pgmtaemwcueobaexthaq.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbXRhZW13Y3Vlb2JhZXh0aGFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0NTk3NzcsImV4cCI6MjA0MTAzNTc3N30.Sfa7Z1UjmTkz5-rnUz4u_xTJ8oFI1EH45lJGaXqg_iY';

// Helper to check if Supabase is ready
bool get isSupabaseReady => Supabase.instance.isInitialized;