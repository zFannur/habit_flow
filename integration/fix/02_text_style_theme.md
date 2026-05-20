# Шаг 02 — W10: inline `TextStyle()` → `Theme.textTheme`

**Severity:** 🟠 HIGH · **Время:** ~4–6 часов (по фичам) · **Риск:** визуальные регрессии.

## Проблема

В ~30 экранах используется literal `TextStyle(fontSize: …, fontWeight: …)`
прямо в `build()`. Пример [today_screen.dart:284-298](../../lib/features/habits/presentation/today_screen.dart#L284-L298):

```dart
style: TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.w800,
  color: c.textPrimary,
)
```

Цвета вынесены в [tokens.dart](../../lib/core/config/tokens.dart) (правильно),
а **типографика** — нет. Это нарушает W10 и затрудняет смену шрифта/масштаба.

## Целевое решение

1. Единый `TextTheme` (Material 3 имена: `displayLarge`, `headlineMedium`,
   `titleLarge`, `bodyMedium`, `labelSmall`, …) — задаётся в `MaterialApp.theme`.
2. Доступ через `Theme.of(context).textTheme.titleLarge` или короткий
   helper `context.tt.titleLarge`.
3. Цвет всё ещё применяется через `.copyWith(color: c.textPrimary)`.

## План по файлам — в указанном порядке

### Шаг 02.1 — создать `text_theme.dart`

**Новый файл:** `app/lib/core/config/text_theme.dart`

```dart
import 'package:flutter/material.dart';

/// Единый источник правды для типографики HabitFlow.
/// Названия — Material 3, чтобы любой существующий виджет, который смотрит
/// в Theme.of(context).textTheme, сразу подхватил наш стиль.
const _kFontFamily = null; // системный/SF Pro/Roboto — оставим OS-дефолт

final TextTheme hfTextTheme = const TextTheme(
  // Display — крупные числа на дашборде
  displayLarge:  TextStyle(fontSize: 36, fontWeight: FontWeight.w800, height: 1.1, fontFamily: _kFontFamily),
  displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, fontFamily: _kFontFamily),

  // Headlines — заголовки экранов
  headlineLarge:  TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2, fontFamily: _kFontFamily),
  headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2, fontFamily: _kFontFamily),
  headlineSmall:  TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.25, fontFamily: _kFontFamily),

  // Titles — карточки, секции
  titleLarge:  TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3, fontFamily: _kFontFamily),
  titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3, fontFamily: _kFontFamily),
  titleSmall:  TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3, fontFamily: _kFontFamily),

  // Body — основной текст
  bodyLarge:  TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, fontFamily: _kFontFamily),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.45, fontFamily: _kFontFamily),
  bodySmall:  TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.4, fontFamily: _kFontFamily),

  // Labels — кнопки, подписи
  labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2, fontFamily: _kFontFamily),
  labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, fontFamily: _kFontFamily),
  labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2, fontFamily: _kFontFamily),
);
```

### Шаг 02.2 — подключить в `MaterialApp`

**Файл:** `app/lib/app.dart` (или где собирается `ThemeData`)

Найти `ThemeData(...)` и добавить `textTheme: hfTextTheme,`. Аналогично для
dark-темы (если есть отдельная). Не забудь импорт `text_theme.dart`.

### Шаг 02.3 — таблица замен

Прежде чем менять файлы, выпиши **существующие комбинации** `fontSize`+`fontWeight`
в одну таблицу — это даст карту "literal → имя стиля". Команда:

```powershell
cd app
Select-String -Path lib\features\**\presentation\**\*.dart `
  -Pattern 'fontSize:\s*\d+' -Context 0,2 | `
  ForEach-Object { $_.Line + " | " + $_.Context.PostContext[0] } | `
  Sort-Object -Unique | Out-File integration\fix\_textstyle_audit.txt
```

Просмотри `_textstyle_audit.txt` → сопоставь каждую комбинацию с именем
из `hfTextTheme` (`titleLarge`/`bodyMedium`/…). Это карта для подмены.

### Шаг 02.4 — заменять по фича-папкам, по одному коммиту

Порядок (от меньшего к большему — чтобы заметить ошибки раньше):

1. `lib/shared/widgets/` (4 файла: hf_header_bar, hf_input, hf_skeleton, hf_error_state)
2. `lib/features/auth/presentation/splash_screen.dart`
3. `lib/features/onboarding/presentation/` (2 экрана)
4. `lib/features/profile/presentation/` (8 файлов)
5. `lib/features/journal/presentation/` (2 файла)
6. `lib/features/ai/presentation/` (5 файлов)
7. `lib/features/analytics/presentation/` (analytics_screen + widgets/weekly_review_checklist)
8. `lib/features/habits/presentation/` (4 экрана + widgets/ — самая большая папка)

В каждом файле:
- `TextStyle(fontSize: X, fontWeight: Y, color: c.foo)` →
  `Theme.of(context).textTheme.<имя>.copyWith(color: c.foo)`
- Если есть `letterSpacing`/`height`/`fontStyle` — переноси в `copyWith`.

После каждой папки:
```powershell
flutter analyze
flutter test
```

### Шаг 02.5 — guard от регресса

В `analysis_options.yaml` (необязательно, но хорошо) включи lint, который
запретит inline-стили в `build()`. Готового lint для этого нет, поэтому
вариант — **custom_lint** + правило `avoid_text_style_in_build`. Опционально
(не блокер).

## Валидация

- `flutter analyze` — 0 ошибок.
- Открой каждый экран — типографика **на глаз** не должна измениться
  (это и есть смысл единой темы — никакого визуального дрейфа).
- Скриншоты до/после критичных экранов (Today, Profile, Chat) — приложи к PR.

## Откат

Если визуально что-то поплыло — `git revert` нужного по-файлового коммита.
Поэтому делать **по одному файлу = по одному коммиту**.
