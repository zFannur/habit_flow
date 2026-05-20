# Шаг 07 — Detail screen: `dynamic habit` вместо типизированного `HabitModel`

**Severity:** 🟢 LOW · **Время:** 10 мин · **Риск:** нулевой.

## Проблема

В `habit_detail_screen.dart` (строка 65) виджет `_DetailBody` объявляет:

```dart
class _DetailBody extends ConsumerWidget {
  final dynamic habit;  // ← dynamic!
```

Из-за этого:
- Все обращения к полям привычки вида `habit.name`, `habit.emoji` разрешаются **только в рантайме**.
- Анализатор не видит ошибок при опечатках.
- Требуется `// ignore: avoid_dynamic_calls` (строки 172–184).
- IDE не может автодополнять поля.

`habitDetailProvider` возвращает `AsyncValue<HabitModel?>`, а в `data:` ветке передаётся
уже non-null `HabitModel`. Нет причин использовать `dynamic`.

## Что менять

### Файл: `lib/features/habits/presentation/habit_detail_screen.dart`

```diff
 class _DetailBody extends ConsumerWidget {
-  const _DetailBody({required this.habitId, required this.habit});
+  const _DetailBody({required this.habitId, required this.habit});

   final String habitId;
-  // Using dynamic to avoid importing the full model file reference — actual
-  // type from habitDetailProvider is HabitModel.
-  final dynamic habit;
+  final HabitModel habit;
```

Затем убрать все `// ignore: avoid_dynamic_calls` и все кастинги `as String?` из
`_showMoreSheet`:

```diff
   void _showMoreSheet(BuildContext context, dynamic habit) {
-    // ignore: avoid_dynamic_calls
     showModalBottomSheet<void>(
       context: context,
       backgroundColor: Colors.transparent,
       builder: (sheetContext) => HabitMoreSheet(
-        // ignore: avoid_dynamic_calls
-        identity: habit.identityStatement as String?,
-        // ignore: avoid_dynamic_calls
-        reward: habit.reward as String?,
-        // ignore: avoid_dynamic_calls
-        implementationWhen: habit.implementationWhen as String?,
-        // ignore: avoid_dynamic_calls
-        implementationWhere: habit.implementationWhere as String?,
+        identity: habit.identityStatement,
+        reward: habit.reward,
+        implementationWhen: habit.implementationWhen,
+        implementationWhere: habit.implementationWhere,
       ),
     );
   }
```

Также добавить импорт модели (скорее всего уже есть через `habits_providers.dart`).

## Валидация

```powershell
cd app
flutter analyze
```

## Коммит

```powershell
git add lib/features/habits/presentation/habit_detail_screen.dart
git commit -m "refactor(habits): типизировать habit в DetailBody → HabitModel (убрать dynamic)"
```
