# Шаг 04 — Иконка привычки: `icon_telegram_file_id` не используется, фото не грузится

**Severity:** 🟠 HIGH · **Время:** 1–2 часа · **Риск:** средний.

## Проблема

В модели `HabitModel` существует поле `iconTelegramFileId` (строка 36), но **нигде в приложении оно не используется**:

1. **`HabitEmojiIcon`** — отображает только текстовый эмодзи, без поддержки Telegram-фото.
2. **`HabitDraft`** — не содержит поля для фото-иконки, только `emoji`.
3. **`habit_create_screen.dart`** — предлагает только эмодзи-выбор, нет кнопки загрузки фото.
4. **Карточки привычек** (`binary_habit_card.dart`, `countable_habit_card.dart`, etc.) — передают только `emoji`, не учитывают `iconTelegramFileId`.

В результате если бот создал привычку с фото-иконкой через Telegram — в приложении она просто не отображается.

## Архитектура решения

### Вариант A: Поддержка Telegram file_id (рекомендуется)

Telegram `file_id` — это уникальный идентификатор файла в инфраструктуре Telegram. Для отображения в Flutter нужно:

1. Создать Edge Function `get_telegram_photo` (или эндпоинт в боте), который по `file_id` вернёт URL для скачивания.
2. Кэшировать URL локально (file_id → URL маппинг стабилен в рамках бота).
3. Отображать через `CachedNetworkImage`.

### Вариант B: Загрузка фото из галереи (альтернативный)

Позволить пользователю загружать фото из галереи устройства:

1. Добавить `image_picker` в зависимости.
2. Загружать в Supabase Storage (`habit-icons/<user_id>/<habit_id>.jpg`).
3. Хранить URL в новом поле `icon_url` в `habits`.

### Что менять (Вариант A — минимальный MVP)

#### Файл: `lib/features/habits/presentation/widgets/habit_emoji_icon.dart`

Расширить виджет для поддержки фото:

```dart
class HabitEmojiIcon extends StatelessWidget {
  const HabitEmojiIcon({
    super.key,
    required this.emoji,
    this.photoUrl,       // ← новый параметр
    this.tint,
    this.size = 44,
    this.fontSize = 22,
  });

  final String emoji;
  final String? photoUrl;
  final Color? tint;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    
    // Если есть фото — показать его
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(HFTokens.rMd),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.network(
            photoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _emojiWidget(c),
          ),
        ),
      );
    }
    
    return _emojiWidget(c);
  }
  
  Widget _emojiWidget(HFColors c) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint ?? c.bgSecondary,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: ...),
    );
  }
}
```

#### Файл: Все карточки привычек

Прокинуть `iconTelegramFileId` или `photoUrl` через карточки:

- `binary_habit_card.dart`
- `countable_habit_card.dart`
- `timed_habit_card.dart`
- `anti_habit_card.dart`

#### Файл: `today_screen.dart`

В `_HabitCardRouter` передавать `habit.iconTelegramFileId` в карточки.

## Валидация

```powershell
cd app
flutter analyze

# Ручная проверка:
# 1. Привычка с эмодзи — отображается эмодзи (как раньше).
# 2. Привычка с фото (через бота) — отображается фото.
# 3. Фото не загрузилось — fallback на эмодзи.
```

## Коммит

```powershell
git add .
git commit -m "feat(habits): поддержка фото-иконок в карточках привычек"
```
