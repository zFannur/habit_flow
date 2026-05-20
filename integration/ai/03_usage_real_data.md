# Шаг 03 — Реальные данные usage (счётчик сообщений)

**Severity:** 🟡 MEDIUM · **Время:** 25 мин · **Риск:** средний

## Проблема

1. В `_InputBar` (chat_screen.dart) хардкод:
   - `_requestsLimit = 200`
   - Модель `'gpt-oss-120b:free'` в `aiChatTokenCounter`
   - `isNearLimit` порог `> 160`

2. В `ai_settings_screen.dart` Usage-секция — полностью мок:
   - `today = 23` запроса
   - `limit = 200`
   - `month = '412 запросов'`
   - `spent = '$0.00'`

## План

### 1. Динамическая модель в InputBar

```dart
// Вместо хардкода
final selectedModel = ref.watch(preferredModelControllerProvider).value;
final modelName = _shortModelName(selectedModel ?? Env.defaultModel);

// В aiChatTokenCounter:
aiChatTokenCounter(modelName, requestsUsed, requestsLimit)
```

### 2. Динамический лимит

Лимит зависит от модели (free модели = 200/день, платные = без лимита от нас).
Пока оставить 200 как дефолт, но вынести в провайдер для будущего расширения.

### 3. Реальные данные в AI Settings

```dart
// Usage section:
final todayCount = ref.watch(dailyMessageCountProvider);
// Показывать реальное значение
```

### 4. Скрыть моковые поля

Месячную статистику и расход `$0.00` — скрыть или показать «—» до появления бэкенда.

## Файлы

- **[MODIFY]** `lib/features/ai/presentation/chat_screen.dart`
- **[MODIFY]** `lib/features/profile/presentation/ai_settings_screen.dart`

## Коммит

```
git commit -m "fix(ai): use real message count and selected model in usage display"
```
