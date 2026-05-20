# Шаг 01 — Полноценный Markdown-рендеринг в чате

**Severity:** 🔴 HIGH · **Время:** 30 мин · **Риск:** низкий

## Проблема

Виджет `_Markdown` в `chat_screen.dart` (строки 868-962) поддерживает только:
- `**bold**`
- `` `inline code` ``

ИИ отправляет ответы с заголовками, списками, курсивом, блоками кода — всё это показывается как plain text.

В то же время `summary_detail_screen.dart` (строки 217-506) содержит виджет `_MarkdownBody`, который уже поддерживает H1-H6, bullet/numbered списки, параграфы, bold, italic, inline code.

## План

### 1. Создать `lib/shared/widgets/hf_markdown.dart`

Извлечь `_MarkdownBody` и все вспомогательные виджеты из `summary_detail_screen.dart` в shared-виджет `HfMarkdown`:

```dart
class HfMarkdown extends StatelessWidget {
  const HfMarkdown({super.key, required this.text, this.textColor});
  final String text;
  final Color? textColor; // для возможности overriding цвета (streaming cursor)
  // ...
}
```

### 2. Заменить `_Markdown` в `chat_screen.dart`

```dart
// Было:
child: _Markdown(text: message.content),

// Стало:
child: HfMarkdown(text: message.content),
```

### 3. Обновить `_StreamingMessageRow`

```dart
// Было:
child: _Markdown(text: '$text▋'),

// Стало:
child: HfMarkdown(text: '$text▋'),
```

### 4. Обновить `summary_detail_screen.dart`

Заменить внутренний `_MarkdownBody` на импорт `HfMarkdown`.

### 5. Удалить старый `_Markdown` из `chat_screen.dart`

## Файлы

- **[NEW]** `lib/shared/widgets/hf_markdown.dart`
- **[MODIFY]** `lib/features/ai/presentation/chat_screen.dart`
- **[MODIFY]** `lib/features/ai/presentation/summary_detail_screen.dart`

## Коммит

```
git commit -m "feat(ai): extract shared HfMarkdown widget for rich chat rendering"
```
