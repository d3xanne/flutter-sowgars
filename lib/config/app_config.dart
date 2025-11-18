/// Application configuration
/// In production, these should be loaded from environment variables
class AppConfig {
  // Supabase configuration
  // TODO: Move to environment variables in production
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ekmvgwfrdrnivajlnorj.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbXZnd2ZyZHJuaXZhamxub3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyMjEwMjcsImV4cCI6MjA3Njc5NzAyN30.oOiYmA5w-xTWlyoDyZum2OomDBrTvncTiHGvXh9PiK8',
  );

  // Security configuration
  // Note: In production, encryption key should be stored securely
  // and never hardcoded in source code
  static const String encryptionKey = String.fromEnvironment(
    'ENCRYPTION_KEY',
    defaultValue: 'hacienda_elizabeth_2024',
  );
}

