# Шаг 06 — W23: `Navigator.of(context).push` → `context.push` (go_router)

**Severity:** 🟡 MEDIUM · **Время:** 10–20 минут (зависит от регистрации маршрута).

## Проблема

[summaries_screen.dart:58](../../lib/features/ai/presentation/summaries_screen.dart#L58)
открывает экран через `Navigator.of(context).push(MaterialPageRoute(...))`.
Это ломает deep-link контракт go_router (см. CLAUDE.md: «Глубокие ссылки
`?screen=...&id=...` обязательны для бота»).

Остальные `Navigator.pop(ctx)` — это закрытие диалогов/sheet'ов
(`showDialog`/`showModalBottomSheet`), что **идиоматично** и не нарушает W23.

## Что менять

### 1. Открыть текущий код и понять цель навигации

**Файл:** `app/lib/features/ai/presentation/summaries_screen.dart` (район строки 58)

Скорее всего там что-то вроде:
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => SummaryDetailScreen(summaryId: id),
  ),
);
```

Цель — экран `SummaryDetailScreen`. Нужно открывать его через `go_router`.

### 2. Проверить регистрацию маршрута

**Файл:** `app/lib/core/routing/...` (имя файла зависит от структуры — найти
по `GoRouter(` или `routes:`).

Должно быть что-то вроде:

```dart
GoRoute(
  path: '/summary/:id',
  name: 'summary',
  builder: (context, state) => SummaryDetailScreen(
    summaryId: state.pathParameters['id']!,
  ),
),
```

**Если такого маршрута нет** — добавь его:
- путь: `/summary/:id` (под общую схему уже существующих deep-link'ов
  типа `/habit/:id`);
- builder читает `state.pathParameters['id']`.

### 3. Заменить вызов

В `summaries_screen.dart:58`:

```dart
// было
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => SummaryDetailScreen(summaryId: id)),
);

// стало
context.push('/summary/$id');
```

Импорт уже должен быть: `import 'package:go_router/go_router.dart';`. Если нет — добавь.

### 4. Не трогать `Navigator.pop`

Все остальные `Navigator.pop(ctx)` в файлах:
- `ai/presentation/chat_screen.dart`
- `habits/presentation/habits_list_screen.dart`
- `habits/presentation/habit_detail_screen.dart`

— это **закрытие диалогов** через `showDialog`/`showModalBottomSheet`.
`Navigator.pop` тут единственный корректный способ вернуть результат
из диалога. **Оставляем как есть** — это не W23.

## Валидация

```powershell
flutter analyze
flutter test
```

Ручная проверка:
1. Открыть Summaries → тапнуть саммари → должен открыться SummaryDetail.
2. В адресной строке браузера URL должен стать `/summary/<id>` (go_router
   синхронизирует URL).
3. Прямой переход по URL `https://<owner>.github.io/<repo>/?screen=summary&id=<id>`
   (или какой формат deep-link у нас принят) — должен открыть тот же экран.

Если deep-link через `?screen=...&id=...`, а не path-параметр — проверь,
какой формат у других экранов (`/habit/:id` vs `/today?screen=...`), и
выбери ту же схему. Бот в [bot/src/services/notifications.py](../../../bot/src/services/notifications.py)
строит ссылки вида `mini_app_url + ?screen=habit&id=...` — значит у проекта
используется query-param деплинк. Тогда:

```dart
context.push('/ai/summary?id=$id');  // или твой реальный путь
```

Сверь с фактическим роутером `lib/core/routing/`.

## Коммит

```
refactor(ai): replace Navigator.push with context.push for summary detail (W23)
```
