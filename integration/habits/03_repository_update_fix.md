# Шаг 03 — `update()` отправляет `category_id` = null → ошибка PostgreSQL

**Severity:** 🟠 HIGH · **Время:** 10 мин · **Риск:** низкий.

## Проблема

Метод `HabitsRepository.update()` (строка 91) конвертирует `HabitModel` в JSON и отправляет
все поля. Однако в модели есть поле `category_id`, которое приходит из JOIN с таблицей
`habit_categories` и **не является столбцом** в таблице `habits`:

```dart
// В create() это поле корректно удаляется:
final payload = habit.toJson()
  ..remove('created_at')
  ..remove('updated_at')
  ..remove('category_id'); // ← ✅ удалено в create

// В update() — НЕ удаляется:
final payload = habit.toJson()
  ..remove('created_at')
  ..remove('updated_at')
  ..remove('id');           // ← category_id НЕ удалён!
```

При попытке обновить привычку PostgreSQL выбросит ошибку вида:
`column "category_id" of relation "habits" does not exist`.

## Что менять

### Файл: `lib/features/habits/data/habits_repository.dart`

```diff
   Future<HabitModel> update(HabitModel habit) async {
     try {
       final payload = habit.toJson()
         ..remove('created_at')
         ..remove('updated_at')
-        ..remove('id');
+        ..remove('id')
+        ..remove('category_id');
       final row = await _client
```

## Валидация

```powershell
cd app
flutter analyze
# Unit-тест: обновить привычку через update() — не должно быть ошибки PostgreSQL.
```

## Коммит

```powershell
git add lib/features/habits/data/habits_repository.dart
git commit -m "fix(habits): удалить category_id из payload update() (нет такого столбца)"
```
