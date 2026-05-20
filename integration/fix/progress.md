# Прогресс интеграции исправлений по WATCHDOG-отчёту

| Шаг | Правило | Описание | Статус |
|---|---|---|---|
| 01 | W32 | Защитить секреты в `.gitignore` | ✅ Выполнено |
| 02 | W10 | Inline `TextStyle()` → `Theme.textTheme` | ✅ Выполнено |
| 03 | W22 | Репозитории возвращают `Either<Failure, T>` | ✅ Выполнено |
| 04 | W11 | Убрать `UnimplementedError` и TODO | ✅ Выполнено |
| 05 | W9 | Палитра графиков в `tokens.dart` | ✅ Выполнено |
| 06 | W23 | `Navigator.push` → `context.push` (go_router) | ✅ Выполнено |
| 07 | W7 | Вынести хардкод-URL в `Env` | ⏳ Ожидание |
| 08 | W26 | `mounted` после `await` перед `context` | ⏳ Ожидание |
