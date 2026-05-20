# Шаг 01 — Дубликат привычки после создания

**Severity:** 🔴 CRITICAL · **Время:** 15 мин · **Риск:** низкий.

## Проблема

После создания привычки на экране «Сегодня» и «Список привычек» **кратковременно** отображаются 2 одинаковых карточки. После перезагрузки страницы (или через несколько секунд) остаётся только 1.

### Корневая причина

В `habit_create_screen.dart` (строки 149–154) после `repo.create()` вызываются:
```dart
ref.invalidate(habitsStreamProvider);   // ← форсирует re-fetch
ref.invalidate(todayHabitsProvider);    // ← форсирует re-fetch
```

Однако `habitsStreamProvider` — это **realtime stream** через Supabase `.stream(primaryKey: ['id'])`. Supabase Realtime **также** публикует INSERT-событие на канале `habits`. В результате:

1. `invalidate` провоцирует свежий `SELECT *` из БД → привычка появляется (корректно).
2. Через ~100–500 мс приходит realtime-событие INSERT → stream эмитит **новый** список, который _мержит_ новую строку поверх уже добавленной через invalidate.
3. Если timing неудачный, слушатель `todayHabitsProvider` получает **оба** эмита подряд, и Flutter рисует дубликат на 1 кадр.

### Дополнительный фактор

В `todayHabitsProvider` (строка 59) есть `ref.watch(habitsStreamProvider)`, то есть каждый эмит stream триггерит пересчёт `todayHabitsProvider`. Два быстрых эмита → два пересчёта.

## Что менять

### Файл: `lib/features/habits/presentation/habit_create_screen.dart`

**Удалить `ref.invalidate(habitsStreamProvider)`**, оставив только invalidate логов.
Realtime-стрим сам доставит новую строку. `todayHabitsProvider` пересчитается автоматически.

```diff
       await repo.create(finalDraft.toModel(userId));
       ref.read(habitDraftProvider.notifier).reset();
-      // Realtime publication on `habits` is best-effort and can lag; force a
-      // refresh so today/habits screens see the new row immediately.
-      ref.invalidate(habitsStreamProvider);
-      ref.invalidate(todayHabitsProvider);
+      // Logs for today need a refresh so the new habit's empty log slot
+      // appears. The habits list itself is updated by realtime stream.
+      ref.invalidate(todayLogsProvider);
```

### Файл: `lib/features/habits/data/habits_providers.dart`

Добавить `distinctBy(id)` дедупликацию в `todayHabitsProvider` как страховку:

```diff
   final combined = combineHabitsWithLogs(
     habits: habits,
     logsForDay: logs,
     day: today,
   );
-  return AsyncValue.data(combined);
+  // Deduplicate — insurance against overlapping realtime + invalidate events.
+  final seen = <String>{};
+  final deduped = combined.where((h) => seen.add(h.habit.id)).toList();
+  return AsyncValue.data(deduped);
```

## Валидация

```powershell
cd app
flutter analyze
# Ручная проверка:
# 1. Создать привычку.
# 2. Убедиться, что на экране «Сегодня» появляется ровно 1 карточка.
# 3. Повторить 3–5 раз для разных типов.
```

## Коммит

```powershell
git add lib/features/habits/presentation/habit_create_screen.dart lib/features/habits/data/habits_providers.dart
git commit -m "fix(habits): устранить дубликат привычки после создания (realtime race)"
```
