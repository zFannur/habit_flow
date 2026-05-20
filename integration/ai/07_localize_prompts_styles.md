# Шаг 07 — Локализация промптов и стилей

**Severity:** 🟡 MEDIUM · **Время:** 35 мин · **Риск:** низкий

## Проблема

Множество строк в модуле ИИ захардкожены на русском языке:
1. Быстрые промпты в `chat_screen.dart` (`Проанализируй мою неделю` и т.д.).
2. Карточки промптов в `prompts_grid_screen.dart` (названия, описания).
3. Названия, описания и превью стилей в `ai_settings_screen.dart`.
4. Инструкция для ИИ в `prompt_builder.dart` (инструкция по identity statements захардкожена на русском).

Поскольку приложение двуязычное (RU/EN), при переключении языка интерфейса эти части остаются на русском языке.

## План

### 1. Перенести строки быстрых промптов в ARB-файлы
Добавить ключи `aiQuickPrompt1` .. `aiQuickPrompt5` в `app_ru.arb` и `app_en.arb`.

### 2. Перенести 14 системных промптов в ARB-файлы
Создать локализованные версии для каждого промпта. Ключи вида:
- `aiPromptPatternTitle`, `aiPromptPatternDesc`
- `aiPromptBlindSpotTitle`, `aiPromptBlindSpotDesc`
- и так далее.

В `prompts_grid_screen.dart` заменить хардкод на чтение через `l.aiPrompt...`.

### 3. Перенести описания стилей в ARB-файлы
В `ai_settings_screen.dart` перенести в локализацию:
- Имя стиля
- Описание
- Пример сообщения (preview bubble)

Использовать ключи:
- `aiStyleCoachTitle`, `aiStyleCoachDesc`, `aiStyleCoachPreview`
- и так далее для всех 5 стилей.

### 4. Локализовать промпты в `prompt_builder.dart`
Заменить жестко прописанную инструкцию:
```dart
'Если пользователь упоминает прогресс, напомни ему identity statement'
```
на соответствующую языку пользователя (через `user.language`).

## Файлы

- **[MODIFY]** `lib/core/localization/app_en.arb`
- **[MODIFY]** `lib/core/localization/app_ru.arb`
- **[MODIFY]** `lib/features/ai/presentation/chat_screen.dart`
- **[MODIFY]** `lib/features/ai/presentation/prompts_grid_screen.dart`
- **[MODIFY]** `lib/features/profile/presentation/ai_settings_screen.dart`
- **[MODIFY]** `lib/features/ai/data/prompt_builder.dart`

## Коммит

```
git commit -m "intl(ai): localize all system prompts, personality styles and instructions"
```
