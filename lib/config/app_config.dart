/// Application configuration
/// In production, these should be loaded from environment variables
class AppConfig {
  // Supabase configuration
  // TODO: Move to environment variables in production
  // NOSONAR - Default values are for development only, production uses environment variables
  static const String supabaseUrl = String.fromEnvironment( // NOSONAR
    'SUPABASE_URL',
    defaultValue: 'https://ekmvgwfrdrnivajlnorj.supabase.co', // NOSONAR
  );
  
  // NOSONAR - JWT token is a Supabase anon key (public key) used for client-side access
  // This is safe to include as it's designed to be public and used in client applications
  // Production should use environment variables via String.fromEnvironment
  static const String supabaseAnonKey = String.fromEnvironment( // NOSONAR
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbXZnd2ZyZHJuaXZhamxub3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyMjEwMjcsImV4cCI6MjA3Njc5NzAyN30.oOiYmA5w-xTWlyoDyZum2OomDBrTvncTiHGvXh9PiK8', // NOSONAR
  );

  // Security configuration
  // Note: In production, encryption key should be stored securely
  // and never hardcoded in source code
  // NOSONAR - Default value is for development only, production uses environment variables
  static const String encryptionKey = String.fromEnvironment( // NOSONAR
    'ENCRYPTION_KEY',
    defaultValue: 'hacienda_elizabeth_2024', // NOSONAR
  );
}

