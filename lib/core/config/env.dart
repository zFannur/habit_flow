import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Конфигурация окружения. Значения подставляются из файла .env.
class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static String get openRouterBaseUrl => dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';
  
  static String get defaultModel => dotenv.env['OPENROUTER_DEFAULT_MODEL'] ?? 'openai/gpt-oss-120b:free';

  /// Окружение: `development` (по умолчанию) или `production`.
  /// Влияет на строгость валидации и поведение error reporting.
  static String get environment => dotenv.env['ENV'] ?? 'development';

  /// Канонический URL Mini App (используется как HTTP-Referer для
  /// OpenRouter rankings, чтобы статистика по приложению агрегировалась).
  static String get appBaseUrl => dotenv.env['APP_BASE_URL'] ?? 'https://habitflow.app';

  /// Публичный канал/чат проекта в Telegram — кнопка «Поделиться».
  static String get botPublicChannel => dotenv.env['BOT_PUBLIC_CHANNEL'] ?? 'https://t.me/habitflow_dev';

  /// Дашборд ключей OpenRouter — куда отправляем пользователя за BYO-key.
  static String get openRouterKeysUrl => dotenv.env['OPENROUTER_KEYS_URL'] ?? 'https://openrouter.ai/keys';

  /// Username Telegram-бота для авторизации по ссылке на мобильных платформах.
  static String get botUsername => dotenv.env['BOT_USERNAME'] ?? '';

  static bool get isProduction => environment == 'production';

  /// Проверяет, что обязательные env-переменные заданы.
  /// Бросает [StateError] с понятным сообщением, если что-то не передано.
  /// Вызывать до `runApp` в `main.dart`.
  static void assertValid() {
    if (supabaseUrl.isEmpty) {
      throw StateError(
        'SUPABASE_URL is required. '
        'Add SUPABASE_URL=... to your .env file.',
      );
    }
    if (supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY is required. '
        'Add SUPABASE_ANON_KEY=... to your .env file.',
      );
    }
    if (!kIsWeb && botUsername.isEmpty) {
      throw StateError(
        'BOT_USERNAME is required on mobile platforms. '
        'Add BOT_USERNAME=... to your .env file.',
      );
    }
  }
}
