/// Конфигурация окружения. Значения подставляются через --dart-define
/// при сборке (см. CLAUDE.md → "Сборка и запуск").
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const openRouterBaseUrl = String.fromEnvironment(
    'OPENROUTER_BASE_URL',
    defaultValue: 'https://openrouter.ai/api/v1',
  );
  static const defaultModel = String.fromEnvironment(
    'OPENROUTER_DEFAULT_MODEL',
    defaultValue: 'openai/gpt-oss-120b:free',
  );

  /// Окружение: `development` (по умолчанию) или `production`.
  /// Влияет на строгость валидации и поведение error reporting.
  static const environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';

  /// Проверяет, что обязательные env-переменные заданы.
  /// Бросает [StateError] с понятным сообщением, если что-то не передано
  /// через `--dart-define`. Вызывать до `runApp` в `main.dart`.
  static void assertValid() {
    if (supabaseUrl.isEmpty) {
      throw StateError(
        'SUPABASE_URL is required. '
        'Pass --dart-define=SUPABASE_URL=... at build/run time.',
      );
    }
    if (supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY is required. '
        'Pass --dart-define=SUPABASE_ANON_KEY=... at build/run time.',
      );
    }
  }
}
