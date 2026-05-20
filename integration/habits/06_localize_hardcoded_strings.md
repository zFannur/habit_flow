# Шаг 06 — Хардкод русских строк в `habit_draft.dart` и `habit_create_screen.dart`

**Severity:** 🟡 MEDIUM · **Время:** 30 мин · **Риск:** низкий.

## Проблема

В коде создания привычек захардкожены русские строки, которые не переводятся при переключении
на английский язык:

### `habit_draft.dart`
```dart
class HabitDraft {
  HabitDraft({
    this.category = 'Здоровье',        // ← хардкод
    this.repeatType = 'Каждый день',   // ← хардкод
    this.goalUnit = 'раз',             // ← хардкод
```

### `habit_create_screen.dart`
```dart
const _categories = <String>[
  'Здоровье', 'Спорт', 'Учёба', 'Работа',  // ← хардкод
  'Отношения', 'Финансы', 'Хобби', 'Ментальное', '+ Новая',
];

const _repeatTypes = [
  'Каждый день', 'По дням недели', 'X раз в неделю',  // ← хардкод
  'Каждые N дней', 'По датам месяца',
];

const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];  // ← хардкод

const _stackingNoHabitsHint = '— Сначала создай другую привычку —';
```

## Что менять

### 1. Добавить ключи в ARB-файлы

**`app_ru.arb`**: добавить ключи для категорий, типов расписания, дней недели.
**`app_en.arb`**: добавить английские переводы.

Примеры ключей:
```json
"habitCatHealth": "Здоровье",
"habitCatSport": "Спорт",
"habitCatStudy": "Учёба",
"habitCatWork": "Работа",
"habitCatRelationships": "Отношения",
"habitCatFinance": "Финансы",
"habitCatHobby": "Хобби",
"habitCatMental": "Ментальное",
"habitCatNew": "+ Новая",

"habitRepeatDaily": "Каждый день",
"habitRepeatWeekdays": "По дням недели",
"habitRepeatNPerWeek": "X раз в неделю",
"habitRepeatEveryN": "Каждые N дней",
"habitRepeatMonthly": "По датам месяца",

"habitWeekMon": "Пн",
"habitWeekTue": "Вт",
...

"habitGoalUnitTimes": "раз",
"habitStackingNoHabits": "— Сначала создай другую привычку —"
```

### 2. Заменить константы на вызовы `l10n`

В `habit_create_screen.dart` категории и типы расписания должны формироваться
из `AppLocalizations` в `build()`:

```dart
List<String> _categories(AppLocalizations l) => [
  l.habitCatHealth, l.habitCatSport, l.habitCatStudy, ...
];
```

### 3. Обновить `HabitDraft` — использовать enum ключи

`repeatType` не должен быть `String` — заменить на `enum RepeatTypeKey`:

```dart
enum RepeatTypeKey { daily, weekdays, nPerWeek, everyNDays, monthlyDates }
```

Это устранит зависимость логики (`_toScheduleType()`, `_buildScheduleConfig()`) от
русскоязычных строк.

### Файлы, которые нужно изменить

| Файл | Действие |
|---|---|
| `app_ru.arb` | Добавить ~20 ключей |
| `app_en.arb` | Добавить ~20 ключей |
| `habit_create_screen.dart` | Заменить `const _categories` и `const _repeatTypes` на функции с l10n |
| `habit_draft.dart` | Заменить `String repeatType` на `RepeatTypeKey`, дефолты без хардкода |

## Валидация

```powershell
cd app
flutter gen-l10n
flutter analyze

# Ручная проверка:
# 1. Переключить язык на EN → все строки в wizard на английском.
# 2. Переключить обратно на RU → всё на русском.
# 3. Создать привычку на EN → привычка корректно сохраняется.
```

## Коммит

```powershell
git add .
git commit -m "refactor(habits): вынести хардкод русских строк в ARB-локализацию"
```
