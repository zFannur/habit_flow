# Шаг 05 — Swipe-to-archive / swipe-to-delete в списке привычек

**Severity:** 🟡 MEDIUM · **Время:** 30 мин · **Риск:** низкий.

## Проблема

На экране «Привычки» (`habits_list_screen.dart`) нет возможности архивировать или удалить
привычку прямо из списка. Пользователю нужно:

1. Тапнуть на привычку → попасть на Detail Screen.
2. Нажать ⋯ → выбрать «Архивировать» / «Удалить».

Это 3 касания для базовой операции. Стандарт UX для списков — **swipe-действия**.

## Что менять

### Файл: `lib/features/habits/presentation/habits_list_screen.dart`

Обернуть каждую карточку привычки в `Dismissible`:

```dart
Dismissible(
  key: Key(habit.id),
  direction: DismissDirection.horizontal,
  
  // Свайп влево → удалить (красный фон)
  background: Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(left: 24),
    decoration: BoxDecoration(
      color: c.warning,
      borderRadius: BorderRadius.circular(HFTokens.rLg),
    ),
    child: Icon(LucideIcons.archive, color: Colors.white),
  ),
  
  // Свайп вправо → архивировать (оранжевый фон)
  secondaryBackground: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    decoration: BoxDecoration(
      color: c.danger,
      borderRadius: BorderRadius.circular(HFTokens.rLg),
    ),
    child: Icon(LucideIcons.trash2, color: Colors.white),
  ),
  
  confirmDismiss: (direction) async {
    if (direction == DismissDirection.startToEnd) {
      // Архивировать — без подтверждения, с undo через SnackBar
      return true;
    } else {
      // Удалить — показать диалог подтверждения
      return await _confirmDelete(context, habit);
    }
  },
  
  onDismissed: (direction) async {
    final repo = ref.read(habitsRepositoryProvider);
    if (direction == DismissDirection.startToEnd) {
      await repo.archive(habit.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.habitDetailArchivedToast)),
      );
    } else {
      await repo.delete(habit.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.habitDetailDeletedToast)),
      );
    }
  },
  
  child: _HabitCard(habit: habit, ...),
)
```

## Валидация

```powershell
cd app
flutter analyze

# Ручная проверка:
# 1. Свайп влево → архивация, SnackBar «Привычка в архиве».
# 2. Свайп вправо → диалог подтверждения → удаление.
# 3. Привычка исчезает из списка после действия.
```

## Коммит

```powershell
git add lib/features/habits/presentation/habits_list_screen.dart
git commit -m "feat(habits): swipe-to-archive и swipe-to-delete в списке привычек"
```
