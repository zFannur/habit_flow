# Шаг 04 — Ручной вызов сводки + «Спросить про сводку»

**Severity:** 🔴 HIGH · **Время:** 30 мин · **Риск:** средний

## Проблема

В `summary_detail_screen.dart` обе кнопки действий не работают:
- **«Ask about this summary»** → `onTap: () {}` (пустой)
- **«Regenerate»** → `onTap: () {}` (пустой)

Пользователь не может ни обсудить сводку с ИИ, ни перегенерировать её.

## План

### 1. «Ask about this summary» (строка ~558)

При нажатии:
1. Сформировать промпт: `"Разбери эту сводку подробнее:\n\n${summary.content}"`
2. Записать в `pendingPromptProvider`
3. Переключить `aiActiveTabProvider` на 0 (чат)
4. Навигировать назад на вкладку AI: `context.go('/ai')`

```dart
onTap: () {
  final prompt = '${l.aiSummaryChatPrompt}:\n\n${summary.content}';
  ref.read(pendingPromptProvider.notifier).state = prompt;
  ref.read(aiActiveTabProvider.notifier).state = 0;
  context.go('/ai');
},
```

### 2. «Regenerate» (строка ~588)

При нажатии:
1. Показать confirm-диалог: «Текущая сводка будет заменена новой»
2. Вызвать Edge Function `generate_summary` через Dio с данными текущей сводки
3. Показать лоадер (CircularProgressIndicator в кнопке)
4. По завершению — `ref.invalidate(aiSummaryByIdProvider(summaryId))`

Нужно добавить метод `regenerateSummary` в `AiSummariesRepository` или вызывать Edge Function напрямую.

### 3. Кнопка «Создать сводку сейчас» на SummariesScreen (опционально)

Если у пользователя достаточно записей (≥30), показать кнопку рядом с GhostCard.

## Файлы

- **[MODIFY]** `lib/features/ai/presentation/summary_detail_screen.dart`
- **[MODIFY]** `lib/features/ai/data/ai_summaries_repository.dart` (добавить `regenerate`)
- **[MODIFY]** `lib/features/ai/presentation/summaries_screen.dart` (опционально)

## Коммит

```
git commit -m "feat(ai): implement 'ask about summary' and 'regenerate' actions"
```
