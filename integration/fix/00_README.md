# План фиксов по WATCHDOG-отчёту (`flutter-ai-dev`)

Базовый аудит — в чате (выше). Здесь — пошаговое применение по файлам.
Каждый шаг = отдельный документ, выполняй **по номеру**, после каждого:

```powershell
cd app
flutter analyze
flutter test
```

Только зелёный analyze → переходи к следующему шагу. Один шаг = один коммит
(удобно откатить, удобно ревьюить).

## Порядок (от срочного к косметике)

| № | Severity | Правило | Файл инструкции | Скоуп |
|---|---|---|---|---|
| 01 | 🔴 CRITICAL | W32 | [01_gitignore_secrets.md](01_gitignore_secrets.md) | `app/.gitignore` (1 файл) |
| 02 | 🟠 HIGH | W10 | [02_text_style_theme.md](02_text_style_theme.md) | ~30 экранов + 2 новых файла темы |
| 03 | 🟠 HIGH | W22 | [03_either_result_pattern.md](03_either_result_pattern.md) | pubspec + все repository |
| 04 | 🟡 MEDIUM | W11 | [04_todo_unimplemented.md](04_todo_unimplemented.md) | 4 файла с `UnimplementedError` + 9 TODO |
| 05 | 🟡 MEDIUM | W9 | [05_chart_colors_tokens.md](05_chart_colors_tokens.md) | `analytics_screen.dart` + `tokens.dart` |
| 06 | 🟡 MEDIUM | W23 | [06_navigator_to_gorouter.md](06_navigator_to_gorouter.md) | `summaries_screen.dart` |
| 07 | 🟢 LOW | W7 | [07_hardcoded_urls_env.md](07_hardcoded_urls_env.md) | `env.dart` + 3 файла |
| 08 | 🟢 LOW | W26 | [08_mounted_after_await.md](08_mounted_after_await.md) | 6 экранов (точечно) |

## Рекомендуемая стратегия по веткам

- **Шаги 01, 05, 06, 07, 08** — одна ветка `chore/watchdog-quickfix`, один PR.
- **Шаг 02 (TextStyle → Theme.textTheme)** — отдельная ветка `refactor/text-theme`,
  применять по feature-папкам (мелкими коммитами).
- **Шаг 03 (Either/Result)** — отдельная ветка `refactor/either`,
  по одному repository за коммит. Долго; делать с новыми фичами.

## Что НЕ трогаем

Свежедобавленный код таймзоны (`lib/core/utils/timezone*.dart` и патч в
`auth_repository._syncTimeZone`) — прошёл аудит чисто. В этих фиксах его
не касаемся.

## После всех шагов

1. `flutter analyze` — 0 issues (или максимум 1 info из dev-зависимости).
2. `flutter test` — все зелёные.
3. `flutter build web --release --dart-define=ENV=production ...` — собралось.
4. Прогон по [MANUAL_QA.md](../../MANUAL_QA.md) — пройден.
5. Git tag (`v1.0.1-watchdog` или похоже) — фиксируем чистое состояние.
