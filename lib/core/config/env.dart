import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Конфигурация окружения. Значения берутся из двух источников:
///   1. На мобильных платформах — из `.env` (bundled asset), загруженного
///      через `flutter_dotenv` до `runApp`.
///   2. На Web (CI билдит через `--dart-define`) — из compile-time констант
///      `String.fromEnvironment`.
/// Dotenv приоритетнее: если значение задано в `.env`, оно перебивает дефайн.
/// Это позволяет одному и тому же бинарю работать в обоих сценариях без
/// смены команды сборки.
class Env {
  static const _defSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _defSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const _defOpenRouterBaseUrl = String.fromEnvironment(
    'OPENROUTER_BASE_URL',
    defaultValue: 'https://openrouter.ai/api/v1',
  );
  static const _defDefaultModel = String.fromEnvironment(
    'OPENROUTER_DEFAULT_MODEL',
    defaultValue: 'openai/gpt-oss-120b:free',
  );
  static const _defEnvironment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );
  static const _defAppBaseUrl = String.fromEnvironment(
    'APP_BASE_URL',
    defaultValue: 'https://habitflow.app',
  );
  static const _defBotPublicChannel = String.fromEnvironment(
    'BOT_PUBLIC_CHANNEL',
    defaultValue: 'https://t.me/habitflow_dev',
  );
  static const _defOpenRouterKeysUrl = String.fromEnvironment(
    'OPENROUTER_KEYS_URL',
    defaultValue: 'https://openrouter.ai/keys',
  );
  static const _defBotUsername = String.fromEnvironment('BOT_USERNAME');

  static String _read(String key, String fallback) {
    if (dotenv.isInitialized) {
      final v = dotenv.maybeGet(key);
      if (v != null && v.isNotEmpty) return v;
    }
    return fallback;
  }

  static String get supabaseUrl => _read('SUPABASE_URL', _defSupabaseUrl);
  static String get supabaseAnonKey =>
      _read('SUPABASE_ANON_KEY', _defSupabaseAnonKey);
  static String get openRouterBaseUrl =>
      _read('OPENROUTER_BASE_URL', _defOpenRouterBaseUrl);
  static String get defaultModel =>
      _read('OPENROUTER_DEFAULT_MODEL', _defDefaultModel);
  static String get environment => _read('ENV', _defEnvironment);
  static String get appBaseUrl => _read('APP_BASE_URL', _defAppBaseUrl);
  static String get botPublicChannel =>
      _read('BOT_PUBLIC_CHANNEL', _defBotPublicChannel);
  static String get openRouterKeysUrl =>
      _read('OPENROUTER_KEYS_URL', _defOpenRouterKeysUrl);
  static String get botUsername => _read('BOT_USERNAME', _defBotUsername);

  static bool get isProduction => environment == 'production';

  /// Загружает `.env` как asset. На Web `.env` обычно пустой/отсутствует —
  /// тогда тихо игнорируем ошибку и работаем на compile-time дефайнах.
  /// На Android/iOS `.env` бандлится локально и заполняет значения.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env может отсутствовать (Web в CI) — это норма.
    }
  }

  /// Проверяет, что обязательные env-переменные заданы.
  /// Бросает [StateError] с понятным сообщением. Вызывать после [load] до `runApp`.
  static void assertValid() {
    if (supabaseUrl.isEmpty) {
      throw StateError(
        'SUPABASE_URL is required. '
        'Для Android/iOS заполни app/.env, для Web — передай --dart-define=SUPABASE_URL=... при сборке.',
      );
    }
    if (supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY is required. '
        'Для Android/iOS заполни app/.env, для Web — передай --dart-define=SUPABASE_ANON_KEY=... при сборке.',
      );
    }
    if (!kIsWeb && botUsername.isEmpty) {
      throw StateError(
        'BOT_USERNAME is required on mobile platforms. '
        'Заполни BOT_USERNAME в app/.env.',
      );
    }
  }
}
