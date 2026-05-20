# Шаг 02 — Полноценный экран редактирования привычки

**Severity:** 🔴 CRITICAL · **Время:** 2–3 часа · **Риск:** средний (крупный рефакторинг).

## Проблема

В меню «⋯» на экране деталей привычки (строка 213) кнопка «Редактировать» показывает
`SnackBar('Edit mode coming soon')` — заглушка. Пользователь **не может** изменить:
- Название, эмодзи, цвет, категорию
- Тип расписания (каждый день → по дням недели)
- Цель (для countable/timed)
- Напоминания
- Поведенческие настройки (identity, reward, implementation)

## Архитектура решения

Вместо дублирования 1955-строчного `HabitCreateScreen` — **рефакторинг в универсальную форму**:

### 1. Переименование и расширение `HabitDraft`

`HabitDraft` уже содержит все поля. Нужно добавить:

```dart
class HabitDraft {
  // Существующие поля...
  
  /// Если не null — мы в режиме редактирования. ID существующей привычки.
  final String? editingId;
  
  bool get isEditing => editingId != null;
```

А также фабричный конструктор для предзаполнения из `HabitModel`:

```dart
  /// Создаёт draft из существующей привычки для редактирования.
  factory HabitDraft.fromModel(HabitModel model) {
    return HabitDraft(
      editingId: model.id,
      type: model.type,
      name: model.name,
      category: model.category ?? 'Здоровье',
      emoji: model.emoji ?? '💪',
      accentColor: model.accentColor != null 
        ? _parseHexColor(model.accentColor!) 
        : null,
      repeatType: _scheduleTypeToRepeatType(model.scheduleType),
      selectedWeekdays: _extractWeekdays(model.schedule),
      selectedMonthDays: _extractMonthDays(model.schedule),
      timesPerWeek: (model.schedule['n'] as num?)?.toInt() ?? 3,
      everyN: (model.schedule['every_n'] as num?)?.toInt() ?? 2,
      goalValue: (model.target ?? 8).toInt(),
      goalUnit: model.unit ?? 'раз',
      reminderTimes: List<String>.from(model.reminderTimes),
      endless: model.endedAt == null,
      implementationWhen: model.implementationWhen ?? '',
      implementationWhere: model.implementationWhere ?? '',
      identityStatement: model.identityStatement ?? '',
      twoMinuteVersion: model.twoMinuteVersion ?? '',
      reward: model.reward ?? '',
    );
  }
```

### 2. Расширение `HabitDraftNotifier`

Добавить метод для инициализации в режиме редактирования:

```dart
  void loadForEdit(HabitModel model) {
    state = HabitDraft.fromModel(model);
  }
```

### 3. Рефакторинг `HabitCreateScreen` → `HabitFormScreen`

- Переименовать файл: `habit_create_screen.dart` → `habit_form_screen.dart`
- Класс: `HabitCreateScreen` → `HabitFormScreen`
- Добавить параметр `habitId`:

```dart
class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});
  
  /// Если не null — режим редактирования.
  final String? habitId;
  
  bool get isEditing => habitId != null;
```

- В `initState`: если `habitId != null` → загрузить привычку из `habitDetailProvider` и вызвать `notifier.loadForEdit(model)`.
- В `_next()` (шаг 4 submit):

```dart
if (finalDraft.isEditing) {
  // Режим редактирования
  final updated = finalDraft.toUpdateModel(userId);
  await repo.update(updated);
} else {
  // Режим создания (как сейчас)
  await repo.create(finalDraft.toModel(userId));
}
```

- Заголовок wizard: динамически показывать «Новая привычка» / «Редактировать привычку».

### 4. Метод `toUpdateModel` в `HabitDraft`

Аналог `toModel`, но **сохраняет** `id` и `createdAt` оригинальной привычки:

```dart
HabitModel toUpdateModel(String userId) {
  assert(editingId != null);
  final now = DateTime.now();
  // ... те же поля, что в toModel, но id = editingId!
  return HabitModel(
    id: editingId!,
    // ...остальные поля
  );
}
```

### 5. Маршрутизация

В `app_router.dart` добавить:

```dart
GoRoute(
  path: '/habits/:id/edit',
  builder: (_, state) =>
      HabitFormScreen(habitId: state.pathParameters['id']!),
),
```

### 6. Обновить кнопку «Редактировать» в detail screen

```diff
 _MenuItem(
   icon: LucideIcons.edit,
   label: l.commonEdit,
   color: c.textPrimary,
   onTap: () {
     Navigator.pop(sheetContext);
-    ScaffoldMessenger.of(context).showSnackBar(
-      const SnackBar(
-        content: Text('Edit mode coming soon'),
-        duration: Duration(seconds: 2),
-      ),
-    );
+    context.push('/habits/$habitId/edit');
   },
```

## Файлы, которые нужно изменить

| Файл | Действие |
|---|---|
| `lib/features/habits/data/habit_draft.dart` | Добавить `editingId`, `fromModel()`, `toUpdateModel()`, `loadForEdit()` |
| `lib/features/habits/presentation/habit_create_screen.dart` | Переименовать → `habit_form_screen.dart`, добавить режим edit |
| `lib/core/routing/app_router.dart` | Добавить роут `/habits/:id/edit` |
| `lib/features/habits/presentation/habit_detail_screen.dart` | Заменить заглушку Edit на `context.push` |
| `lib/core/localization/app_en.arb` | Добавить ключи `habitFormEditTitle` |
| `lib/core/localization/app_ru.arb` | Добавить ключи `habitFormEditTitle` |

## Валидация

```powershell
cd app
flutter analyze

# Ручная проверка:
# 1. Открыть привычку → ⋯ → Редактировать → все поля заполнены из привычки.
# 2. Изменить название, сохранить → название обновилось.
# 3. Изменить расписание → расписание обновилось.
# 4. Создать новую привычку — создание по-прежнему работает.
```

## Коммит

```powershell
git add .
git commit -m "feat(habits): полноценный экран редактирования привычки"
```
