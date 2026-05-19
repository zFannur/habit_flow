# app/ — Flutter Mini App

Это Flutter-фронт HabitFlow. Полный контекст проекта — `../CLAUDE.md` и `../SPEC.md`.

## Команды

```powershell
flutter pub get
flutter analyze
flutter test

# Запуск
flutter run -d chrome --web-port=5173 `
  --dart-define=SUPABASE_URL=... `
  --dart-define=SUPABASE_ANON_KEY=...

# Генерация freezed/json/riverpod
dart run build_runner build --delete-conflicting-outputs

# Локализация (после правки .arb)
flutter gen-l10n
```

### Env-переменные (`--dart-define`)

`Env.assertValid()` вызывается в `main.dart` до `runApp` и валит запуск с
понятным `StateError`, если обязательные значения пустые.

| Ключ | Обязателен | Default | Назначение |
|---|---|---|---|
| `SUPABASE_URL` | да | — | URL Supabase-проекта |
| `SUPABASE_ANON_KEY` | да | — | публичный anon-ключ Supabase |
| `OPENROUTER_BASE_URL` | нет | `https://openrouter.ai/api/v1` | базовый URL OpenRouter |
| `OPENROUTER_DEFAULT_MODEL` | нет | `openai/gpt-oss-120b:free` | модель по умолчанию |
| `ENV` | нет | `development` | `production` включает строгие режимы (см. `Env.isProduction`) |

Релизная сборка:

```powershell
flutter build web --release `
  --dart-define=SUPABASE_URL=https://xxx.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=xxx `
  --dart-define=ENV=production
```

## Архитектура

Feature-first. См. `lib/`:

```
lib/
├── main.dart, app.dart
├── core/
│   ├── config/    (env, theme)
│   ├── routing/   (go_router)
│   ├── services/  (supabase, telegram, openrouter, notifications)
│   ├── localization/ (arb)
│   └── utils/
├── features/
│   ├── auth/        (splash + initData → JWT)
│   ├── habits/      (CRUD, Сегодня, Привычки)
│   ├── journal/     (дневник)
│   ├── analytics/   (Tab Аналитика)
│   ├── ai/          (чат, сводки, промпты)
│   ├── profile/     (настройки, донаты)
│   └── onboarding/
└── shared/widgets/
```

В каждой feature: `data/` (модели + репозиторий), `domain/` (чистые функции), `presentation/` (экраны и виджеты).

## Соглашения

- **Состояние** — Riverpod, предпочтительно codegen `@riverpod`.
- **Модели** — `freezed` + `json_serializable`.
- **Навигация** — `go_router`. Глубокие ссылки `?screen=...&id=...` нужны для бота.
- **Тема** — Material 3, перекрывается `Telegram.WebApp.themeParams` через `TelegramService`.
- **Локализация** — `AppLocalizations.of(context)!.<key>`. Никаких хардкоженных строк UI.
- **Лимиты Telegram Mini App**: нет background API (таймер привычки — frontend, продолжается из last_active_at).

## Дизайн

Дизайн получаем от пользователя отдельно. **Копируем 1:1**, не интерпретируем.
Используй скил `design-import` или агент `flutter-ui-builder`.

## Безопасность

- `BOT_TOKEN`, `SUPABASE_SERVICE_ROLE_KEY` — никогда на клиенте.
- `initData` логируем только маскированно.
- Авторизация — только через серверную валидацию initData. `tg.initDataUnsafe` — для UI-параметров (имя, аватар), не для auth.
