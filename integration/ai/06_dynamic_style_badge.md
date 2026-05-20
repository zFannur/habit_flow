# Шаг 06 — Динамический бейдж стиля в заголовке чата

**Severity:** 🟡 MEDIUM · **Время:** 15 мин · **Риск:** низкий

## Проблема

В шапке чата (`chat_screen.dart` строка ~414) захардкожен бейдж стиля:
```dart
Container(
  child: Text('🎓 Coach', ...)
)
```

Он не меняется при изменении стиля в настройках. При этом выбранный стиль сохраняется в Supabase через `aiStyleControllerProvider` и применяется при отправке промптов в ИИ.

## План

### 1. Подключить `aiStyleControllerProvider` в `_Header`

Виджет `_Header` сейчас является `StatelessWidget`. Нужно сделать его `ConsumerWidget` (или передавать текущий стиль из родительского `ChatScreen`).

### 2. Сделать отображение динамическим

Получать текущий стиль:
```dart
final currentStyle = ref.watch(aiStyleControllerProvider).valueOrNull ?? AiStyle.coach;
```

Отображать соответствующий emoji и локализованное название стиля в зависимости от выбранного `AiStyle`:
- `coach` → 🎓 Coach (Коуч)
- `sergeant` → 🪖 Sergeant (Сержант)
- `buddy` → 🤝 Buddy (Друг)
- `sage` → 🦉 Sage (Мудрец)
- `poet` → ✍️ Poet (Поэт)

```dart
String getStyleBadgeText(AiStyle style, AppLocalizations l) {
  switch (style) {
    case AiStyle.coach:
      return '🎓 ${l.aiStyleCoachTitle}';
    case AiStyle.sergeant:
      return '🪖 ${l.aiStyleSergeantTitle}';
    case AiStyle.buddy:
      return '🤝 ${l.aiStyleBuddyTitle}';
    case AiStyle.sage:
      return '🦉 ${l.aiStyleSageTitle}';
    case AiStyle.poet:
      return '✍️ ${l.aiStylePoetTitle}';
  }
}
```

## Файлы

- **[MODIFY]** `lib/features/ai/presentation/chat_screen.dart`

## Коммит

```
git commit -m "feat(ai): make chat header style badge dynamic based on active settings"
```
