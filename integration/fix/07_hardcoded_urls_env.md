# Шаг 07 — W7: вынести 3 хардкод-URL в `Env`

**Severity:** 🟢 LOW · **Время:** 15 минут · **Риск:** низкий.

## Проблема

Три incidental hardcoded URL не лежат в `env.dart`:

| Файл | Строка | URL | Назначение |
|---|---|---|---|
| [openrouter_client.dart](../../lib/features/ai/data/openrouter_client.dart#L76) | 76 | `'https://habitflow.app'` | HTTP-Referer для OpenRouter rankings |
| [analytics_screen.dart](../../lib/features/analytics/presentation/analytics_screen.dart#L79) | 79 | `'https://t.me/habitflow_dev'` | Share-intent: ссылка на канал |
| [analytics_screen.dart](../../lib/features/analytics/presentation/analytics_screen.dart#L81) | 81 | `'https://t.me/share/url?...'` | Telegram share URL (системный — оставляем) |
| [ai_settings_screen.dart](../../lib/features/profile/presentation/ai_settings_screen.dart#L324) | 324 | `'https://openrouter.ai/keys'` | Кнопка «Открыть дашборд OpenRouter» |

Системный `https://t.me/share/url` оставляем — это **протокольная** константа Telegram,
не наш домен. Остальные три — переносим в `Env`.

## Что менять

### Файл: `app/lib/core/config/env.dart`

В класс `Env` добавить три статических геттера (с `--dart-define`-перекрытием
и разумным дефолтом):

```dart
class Env {
  // ... существующие поля ...

  /// Канонический URL Mini App (используется как HTTP-Referer для
  /// OpenRouter rankings, чтобы статистика по приложению агрегировалась).
  static const String appBaseUrl = String.fromEnvironment(
    'APP_BASE_URL',
    defaultValue: 'https://habitflow.app',
  );

  /// Публичный канал/чат проекта в Telegram — кнопка «Поделиться».
  static const String botPublicChannel = String.fromEnvironment(
    'BOT_PUBLIC_CHANNEL',
    defaultValue: 'https://t.me/habitflow_dev',
  );

  /// Дашборд ключей OpenRouter — куда отправляем пользователя за BYO-key.
  static const String openRouterKeysUrl = String.fromEnvironment(
    'OPENROUTER_KEYS_URL',
    defaultValue: 'https://openrouter.ai/keys',
  );
}
```

В таблицу env-переменных в [app/CLAUDE.md](../../CLAUDE.md) (раздел
«Env-переменные») добавь три новых ключа с дефолтами и отметкой «не обязателен».

### Файл: `app/lib/features/ai/data/openrouter_client.dart`

Строка 76:

```dart
// было
'HTTP-Referer': 'https://habitflow.app',

// стало
'HTTP-Referer': Env.appBaseUrl,
```

Импорт `env.dart` уже должен быть; если нет — добавь.

### Файл: `app/lib/features/analytics/presentation/analytics_screen.dart`

Район строк 79–81:

```dart
// было
final url = Uri.encodeComponent('https://t.me/habitflow_dev');
final shareUrl =
    'https://t.me/share/url?url=$url&text=${Uri.encodeComponent(text)}';

// стало
final url = Uri.encodeComponent(Env.botPublicChannel);
final shareUrl =
    'https://t.me/share/url?url=$url&text=${Uri.encodeComponent(text)}';
// (системный t.me/share/url — это API Telegram, не наш домен, оставляем)
```

### Файл: `app/lib/features/profile/presentation/ai_settings_screen.dart`

Строка 324:

```dart
// было
.openLink('https://openrouter.ai/keys'),

// стало
.openLink(Env.openRouterKeysUrl),
```

## Валидация

```powershell
flutter analyze

# Grep — что хардкод убран в правленых местах
Select-String -Path lib\features\ai\data\openrouter_client.dart `
  -Pattern "habitflow\.app"
Select-String -Path lib\features\analytics\presentation\analytics_screen.dart `
  -Pattern "habitflow_dev"
Select-String -Path lib\features\profile\presentation\ai_settings_screen.dart `
  -Pattern "openrouter\.ai/keys"
# все три — пусто

# Сборка с прод-флагами
flutter build web --release `
  --dart-define=SUPABASE_URL=... `
  --dart-define=SUPABASE_ANON_KEY=... `
  --dart-define=ENV=production
```

## Коммит

```
refactor(env): app_base_url / bot_public_channel / openrouter_keys в Env (W7)
```
