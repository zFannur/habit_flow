# Шаг 04 — W11: убрать `UnimplementedError` и инвентаризировать TODO

**Severity:** 🟡 MEDIUM · **Время:** 30 минут на UnimplementedError + аудит TODO.

## Часть А — `UnimplementedError` в провайдер-плейсхолдерах

Паттерн «провайдер кидает `UnimplementedError`, в `main()` ставим `override`»
рабочий, но по W11 не должен использовать `UnimplementedError` (это
«семантика заглушки» — а у нас это намеренный «забыл переопределить»).
Заменяем на `StateError` с понятным сообщением.

### Файл: `app/lib/core/services/locale_service.dart`

Строки 31 и 35:

```dart
// строка ~31 — sharedPreferencesProvider
final sharedPreferencesProvider = Provider<SharedPreferences>(
  // было
  (ref) => throw UnimplementedError('Override in main()'),
  // стало
  (ref) => throw StateError(
    'sharedPreferencesProvider must be overridden in main() '
    'with ProviderScope(overrides: [...]).',
  ),
);

// строка ~35 — localeNotifierProvider
final localeNotifierProvider = ... (
  // было
  (ref) => throw UnimplementedError('Override in main() with LocaleNotifier.create'),
  // стало
  (ref) => throw StateError(
    'localeNotifierProvider must be overridden in main() '
    'after `await LocaleNotifier.create(prefs)`.',
  ),
);
```

### Файл: `app/lib/core/services/theme_service.dart`

Строки 48 и 88 — те же замены, но для `themeNotifierProvider` и
`accentColorNotifierProvider`. Сообщения формулируй конкретно
(«override … with ThemeNotifier.create»).

После правки:

```powershell
flutter analyze
flutter test
```

Коммит:
```
chore: StateError вместо UnimplementedError в Riverpod-overrides (W11)
```

## Часть B — TODO-комментарии (9 штук)

Не удаляем огульно — каждый TODO решает или принимает явно.

| Файл | Строка | TODO | Рекомендация |
|---|---|---|---|
| [onboarding_screen.dart](../../lib/features/onboarding/presentation/onboarding_screen.dart#L720) | 720 | `TODO(l10n): add key onboardingS3TemplatesSub` | Добавить ключ в `app_ru.arb`/`app_en.arb` (используй скил `arb-translate`). |
| [analytics_screen.dart](../../lib/features/analytics/presentation/analytics_screen.dart#L837) | 837 | `TODO(real-data): compute delta vs previous week/month` | Завести issue, оставить плейсхолдер `—` с локализованной подписью «Недостаточно данных». |
| [habit_create_screen.dart](../../lib/features/habits/presentation/habit_create_screen.dart#L17) | 17, 62, 1133 | `TODO(l10n)`: категории/типы повторения/«Каждые N дней» | Перенести списки в `.arb` + локализовать. |
| [habits_list_screen.dart](../../lib/features/habits/presentation/habits_list_screen.dart#L110) | 110, 827 | `TODO(real-data)`: completion-rate из логов; локализация расписания | Использовать `streakProvider`/новый `completionRateProvider`; локализация — `.arb`. |
| [ai_settings_screen.dart](../../lib/features/profile/presentation/ai_settings_screen.dart#L37) | 37 | `TODO(07-04): users.is_supporter` | Уже доступен через `userRowProvider.isSupporter` — заменить заглушку. |
| [donate_screen.dart](../../lib/features/profile/presentation/donate_screen.dart#L13) | 13, 34, 81 | `TODO(real-data)/(l10n)` | Использовать `userRowProvider`; вынести пресеты в `.arb`. |
| [profile_screen.dart](../../lib/features/profile/presentation/profile_screen.dart#L167) | 167 | `TODO: вызов Edge Function delete_account` | Поднять отдельную задачу (Edge Function требует разработки на бэке). |

Действие в этом шаге — **не реализация**, а решение для каждого TODO:
- **fix-now** → закрыть в этом же PR;
- **schedule** → завести issue в репо `zFannur/habit_flow` и заменить TODO
  на `// см. issue #NN`.

После принятия решений по списку, либо убираем TODO (с фиксом), либо
переписываем в ссылку на issue. `grep -nE "TODO\("` после этого должно
вернуть только закомментированные ссылки на issue.

## Валидация

```powershell
flutter analyze
flutter test
Select-String -Path lib\**\*.dart -Pattern 'UnimplementedError\('  # должно быть пусто
```

## Коммиты

Один коммит на UnimplementedError, дальше — по 1 коммиту на TODO,
если фиксим прямо здесь.
