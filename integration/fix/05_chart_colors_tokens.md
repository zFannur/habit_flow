# Шаг 05 — W9: вынести палитру графиков в `tokens.dart`

**Severity:** 🟡 MEDIUM · **Время:** 15 минут · **Риск:** визуальная регрессия в Analytics.

## Проблема

В [analytics_screen.dart:274-298](../../lib/features/analytics/presentation/analytics_screen.dart#L274-L298)
жёстко прописаны 8 hex-цветов для палитры графиков:

```dart
Color(0xFF22C55E), Color(0xFF3B82F6), Color(0xFFA855F7),
Color(0xFF22C55E), Color(0xFF3B82F6), Color(0xFFF59E0B),
Color(0xFFA855F7), Color(0xFFEC4899),
```

Часть из них уже есть в [tokens.dart](../../lib/core/config/tokens.dart) под именами:
- `0xFF22C55E` → `HFTokens.success`
- `0xFF3B82F6` → совпадает с `lAccent`
- `0xFFF59E0B` → `HFTokens.warning`
- `0xFFA855F7` → `HFTokens.premium`
- `0xFFEC4899` — нового нет (pink).

W9 запрещает `Color(0xFF...)` вне theme/tokens файлов.

## Что менять

### Файл: `app/lib/core/config/tokens.dart`

В блок `HFTokens` (рядом с `success`/`warning`/`danger`) добавить:

```dart
  // ---------- Chart palette ----------
  // Используется для категориальных серий (привычки/категории) — порядок
  // фиксированный, чтобы цвет конкретной серии не «прыгал» между сборками.
  static const chartPink = Color(0xFFEC4899); // новый — больше нигде не нужен

  /// Каноничный порядок цветов для линий/баров. Не пересоздавай вручную —
  /// добавляй новый цвет в конец и проверь, что Analytics не «дёрнулась».
  static const chartPalette = <Color>[
    success, // 0 — основной (зелёный)
    lAccent, // 1 — синий (одинаков в light/dark, поэтому берём light)
    premium, // 2 — фиолетовый
    warning, // 3 — оранжевый
    chartPink, // 4 — розовый
    anti,    // 5 — эмеральд (анти-привычки)
    danger,  // 6 — красный
    dAccent, // 7 — небесно-голубой
  ];
```

> Замечание: `lAccent` и `dAccent` различаются между light/dark — для графика
> лучше один и тот же hex в обеих темах, иначе цвет серии «дрогнет» при
> смене темы. Если важно — заведи отдельные `chartBlueLight`/`chartBlueDark`.
> Для первой итерации хватит `lAccent`.

### Файл: `app/lib/features/analytics/presentation/analytics_screen.dart`

В районе строк 274 и 294 (две точки использования палитры):

```dart
// было
final palette1 = [
  Color(0xFF22C55E),
  Color(0xFF3B82F6),
  Color(0xFFA855F7),
];

// стало
final palette1 = HFTokens.chartPalette.take(3).toList();
```

И аналогично для второй палитры (8 цветов) — используем
`HFTokens.chartPalette` целиком или `take(N)`. Если порядок цветов в исходном
коде был **другим**, чем в `chartPalette` (например, оранжевый был в позиции 3,
а у нас он в позиции 4) — либо подправь индексы серий, либо переставь
`chartPalette` так, чтобы существующие серии Analytics остались на тех же
цветах (важно — пользователи привыкли к привязке «синяя линия = серия X»).

Импорт `tokens.dart` в analytics_screen.dart, скорее всего, уже есть (через
`HFColors.of(context)`). Если нет — добавь:

```dart
import '../../../core/config/tokens.dart';
```

## Валидация

```powershell
flutter analyze
flutter test

# Запусти приложение, открой вкладку Аналитика — графики должны
# выглядеть точно так же. Если цвета поменялись — поправь порядок в
# chartPalette до совпадения с предыдущим скриншотом.
```

Grep-проверка, что больше нет хардкода в `analytics_screen.dart`:

```powershell
Select-String -Path lib\features\analytics\presentation\analytics_screen.dart `
  -Pattern 'Color\(0x'
# должно быть 0 строк
```

## Коммит

```
refactor(analytics): chart palette moved to tokens.chartPalette (W9)
```
