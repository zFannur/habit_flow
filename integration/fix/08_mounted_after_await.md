# Шаг 08 — W26: `mounted` после `await` перед обращением к `context`

**Severity:** 🟢 LOW · **Время:** 20 минут (по 6 файлам, точечно).

## Проблема

Если StatefulWidget после `await` дёргает `context.X` (Navigator/Theme/
ScaffoldMessenger/...) **без проверки `mounted`** — а виджет уже размонтирован
(пользователь ушёл с экрана) — Flutter в дебаге кидает assert, в проде —
может тихо упасть или утечь.

Grep нашёл 6 экранов с паттерном `await ... context.X`:

1. [reflection_template_screen.dart](../../lib/features/profile/presentation/reflection_template_screen.dart)
2. [contact_screen.dart](../../lib/features/profile/presentation/contact_screen.dart)
3. [habit_detail_screen.dart](../../lib/features/habits/presentation/habit_detail_screen.dart) — **уже есть `mounted`-чеки** (4 на 3 await), проверь только новый код.
4. [about_screen.dart](../../lib/features/profile/presentation/about_screen.dart)
5. [onboarding_screen.dart](../../lib/features/onboarding/presentation/onboarding_screen.dart)
6. [splash_screen.dart](../../lib/features/auth/presentation/splash_screen.dart)

## Алгоритм для каждого файла

1. Открыть файл, найти каждый `await` (`Ctrl+F`).
2. Для каждого `await` посмотреть, что идёт **после** него.
3. Если после await встречается **любое** из:
   - `context.X` (`context.push`, `context.go`, `context.read`, `context.findAncestor...`)
   - `Navigator.of(context)`
   - `Theme.of(context)`
   - `ScaffoldMessenger.of(context).showSnackBar(...)`
   - `Provider.of<...>(context)`
   - `ref.read(...)` если `ref` приходит из BuildContext (в StatefulWidget — это не наш случай, ConsumerStatefulWidget хранит `ref` сам, без context — там mounted-чек не обязателен для самого ref, но всё равно — для context-зависимых вызовов нужен)

   → **перед** этим вызовом обязательна проверка:

   ```dart
   await someAsyncCall();
   if (!mounted) return;       // для State<...>
   // или (Flutter 3.7+):
   if (!context.mounted) return; // для любого BuildContext (включая вложенные builder'ы)
   context.go('/foo');
   ```

4. Если в файле уже есть `if (!mounted) return;` после части await — это
   ОК, просто убедись, что **все** await покрыты.

## Конкретные подсказки по файлам

### `splash_screen.dart`

Скорее всего — самое критичное место: после `bootstrap()` / `signIn()` идёт
`context.go('/today')` или `context.go('/onboarding')`. Если splash дёрнули
и пользователь успел закрыть Mini App до завершения auth_telegram —
context уже мёртвый.

Шаблон:
```dart
await ref.read(authStateProvider.notifier).bootstrap();
if (!mounted) return;
final state = ref.read(authStateProvider);
context.go(state is Authenticated ? '/today' : '/onboarding');
```

### `onboarding_screen.dart`

После сохранения настроек/`onboardingService.complete()` — `context.go('/today')`.
Тот же шаблон.

### `contact_screen.dart`, `about_screen.dart`

Вероятно `TelegramService.openLink(...)` (без context) + потом
`Navigator.pop(context)`/snackbar. После `openLink` нужно `if (!mounted) return;`
перед `pop`.

### `reflection_template_screen.dart`

Сохранение шаблона в `users.reflection_template` (PATCH через Supabase)
→ snackbar «Сохранено» → pop. После save — `if (!mounted) return;`.

### `habit_detail_screen.dart`

Уже видны 4 `mounted`-чека на 3 await — должен быть в норме. Просто открой
и убедись, что не пропустил вновь добавленных за время правок.

## Валидация

```powershell
flutter analyze   # включает linter use_build_context_synchronously
flutter test
```

В `analysis_options.yaml` хорошо включить явно (если не включено) —
linter из `flutter_lints` обычно его уже даёт:

```yaml
linter:
  rules:
    use_build_context_synchronously: true
```

После правок:
```powershell
flutter analyze --no-pub 2>&1 | Select-String 'synchronously'
# должно быть 0 строк
```

## Коммит

```
fix(ui): mounted-guard после await перед context.X (W26)
```
