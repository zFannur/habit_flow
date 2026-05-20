# Шаг 02 — Disclaimer «Твой ключ — твои данные» один раз

**Severity:** 🟡 MEDIUM · **Время:** 15 мин · **Риск:** низкий

## Проблема

Предупреждение о конфиденциальности в чате (`_Disclaimer` widget) показывается каждый раз при входе в чат, потому что `_disclaimerVisible = true` сбрасывается при каждой перестройке `ChatScreen`.

При этом `DisclaimerService` уже сохраняет флаг в `SharedPreferences`, но используется только для модального диалога в `ai_screen.dart`, а не для inline-баннера.

## План

### 1. В `_ChatScreenState.initState()`:

```dart
@override
void initState() {
  super.initState();
  // Проверяем, видел ли пользователь disclaimer
  _loadDisclaimerState();
  // ...
}

Future<void> _loadDisclaimerState() async {
  final seen = await ref.read(disclaimerServiceProvider).hasSeen();
  if (mounted && seen) {
    setState(() => _disclaimerVisible = false);
  }
}
```

### 2. В `_Disclaimer.onDismiss`:

```dart
onDismiss: () {
  setState(() => _disclaimerVisible = false);
  ref.read(disclaimerServiceProvider).markSeen();
},
```

### 3. Убрать дублирующий модальный диалог в `ai_screen.dart`

Удалить `_maybeShowDisclaimer()` и связанный вызов — оставить inline-баннер как единственную точку показа.

## Файлы

- **[MODIFY]** `lib/features/ai/presentation/chat_screen.dart`
- **[MODIFY]** `lib/features/ai/presentation/ai_screen.dart`

## Коммит

```
git commit -m "fix(ai): show privacy disclaimer only once, remove duplicate modal"
```
