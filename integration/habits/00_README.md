# План: Расширение и исправление операций над привычками

Аудит фичи `features/habits` выявил ряд багов и недоработок.
Каждый шаг = отдельный документ. Выполняй **по номеру**, после каждого:

```powershell
cd app
flutter analyze
```

Только зелёный analyze → переходи к следующему шагу. Один шаг = один коммит.

## Порядок (от критичного к улучшениям)

| № | Severity | Проблема | Файл инструкции | Скоуп |
|---|---|---|---|---|
| 01 | 🔴 CRITICAL | Дубликат привычки после создания (realtime + invalidate) | [01_duplicate_after_create.md](01_duplicate_after_create.md) | `habits_providers.dart`, `habit_create_screen.dart` |
| 02 | 🔴 CRITICAL | Нет экрана редактирования привычки | [02_habit_edit_screen.md](02_habit_edit_screen.md) | `habit_draft.dart`, `habit_create_screen.dart` → `habit_form_screen.dart`, `app_router.dart` |
| 03 | 🟠 HIGH | `update()` в репозитории отправляет `category_id` = null → ошибка PostgreSQL | [03_repository_update_fix.md](03_repository_update_fix.md) | `habits_repository.dart` |
| 04 | 🟠 HIGH | Иконка привычки: `icon_telegram_file_id` не используется, фото не грузится | [04_habit_icon_photo.md](04_habit_icon_photo.md) | `habit_emoji_icon.dart`, `habit_model.dart`, `habit_create_screen.dart` |
| 05 | 🟡 MEDIUM | Нет swipe-to-archive / swipe-to-delete в списке привычек | [05_swipe_actions.md](05_swipe_actions.md) | `habits_list_screen.dart` |
| 06 | 🟡 MEDIUM | Хардкод русских строк в `habit_draft.dart` и `habit_create_screen.dart` | [06_localize_hardcoded_strings.md](06_localize_hardcoded_strings.md) | `habit_draft.dart`, `habit_create_screen.dart`, `app_*.arb` |
| 07 | 🟢 LOW | Detail screen: `dynamic habit` вместо типизированного `HabitModel` | [07_detail_screen_typing.md](07_detail_screen_typing.md) | `habit_detail_screen.dart` |

## Рекомендуемая стратегия по веткам

- **Шаги 01, 03, 07** — одна ветка `fix/habits-crud-bugs`, один PR.
- **Шаг 02** — отдельная ветка `feat/habits-edit-screen` (большой рефакторинг).
- **Шаг 04** — отдельная ветка `feat/habits-icon-photo`.
- **Шаги 05, 06** — одна ветка `improve/habits-ux`.

## После всех шагов

1. `flutter analyze` — 0 issues.
2. `flutter test test/habits/` — все зелёные.
3. Ручная QA по [MANUAL_QA.md](../../MANUAL_QA.md) — раздел «Привычки».
