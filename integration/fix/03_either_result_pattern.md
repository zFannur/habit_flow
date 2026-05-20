# Шаг 03 — W22: репозитории возвращают `Either<Failure, T>` вместо `throw`

**Severity:** 🟠 HIGH · **Время:** 6–10 часов (по 1 репо за подход) · **Риск:** каскадные правки в UI.

## Проблема

Все публичные методы Repository кидают исключения (например
[AuthRepository.signInWithTelegram](../../lib/features/auth/data/auth_repository.dart#L39) кидает `AuthException`).
По правилу W22 публичные `Future` на Repository/UseCase обязаны возвращать
`Future<Either<Failure, T>>` (или sealed `Result<T,F>`), а не бросать.

Это даёт:
- Compile-time напоминание обработать ошибку (нельзя «забыть» try/catch).
- Единый тип ошибки → проще маппинг в UI.

## Целевое решение

Использовать `fpdart` (рекомендация WATCHDOG — не путать с `dartz`,
которая запрещена W06).

## План — строго по порядку

### Шаг 03.1 — добавить зависимость

**Файл:** `app/pubspec.yaml`

В блок `dependencies:` добавить:

```yaml
  fpdart: ^1.1.0
```

Запустить:
```powershell
flutter pub get
```

Коммит:
```
chore(deps): add fpdart for typed Either<Failure, T> (W22)
```

### Шаг 03.2 — sealed `Failure` + helper

**Новый файл:** `app/lib/core/errors/failure.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({String? message}) = NetworkFailure;
  const factory Failure.auth({String? message}) = AuthFailureF;
  const factory Failure.server({required int status, String? message}) = ServerFailure;
  const factory Failure.notFound({String? message}) = NotFoundFailure;
  const factory Failure.parse({String? message}) = ParseFailure;
  const factory Failure.unknown({String? message}) = UnknownFailure;
}
```

**Новый файл:** `app/lib/core/errors/result.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'failure.dart';

/// Единый алиас для типизированного результата.
typedef AppResult<T> = Either<Failure, T>;
typedef AppTask<T>   = TaskEither<Failure, T>;
```

Прогнать билдер для freezed:
```powershell
dart run build_runner build --delete-conflicting-outputs
```

Коммит:
```
feat(core): introduce Failure sealed + AppResult typedef (W22)
```

### Шаг 03.3 — рефакторить репозитории по одному

Порядок (от меньшего к большему):

| № | Repository | Файл |
|---|---|---|
| a | OpenRouterKeyRepository | `lib/features/ai/data/openrouter_key_repository.dart` |
| b | OpenRouterModelsRepository | `lib/features/ai/data/openrouter_models_repository.dart` |
| c | OpenRouterClient | `lib/features/ai/data/openrouter_client.dart` |
| d | AuthRepository | `lib/features/auth/data/auth_repository.dart` |
| e | JournalRepository | `lib/features/journal/data/journal_repository.dart` |
| f | AiStyleRepository | `lib/features/ai/data/ai_style_repository.dart` |
| g | ChatProviders (repository-часть) | `lib/features/ai/data/chat_providers.dart` |

Для **каждого** репо в одном коммите:

1. Изменить сигнатуру публичных методов:
   ```dart
   // было
   Future<Authenticated> signInWithTelegram(String initData) async { ... throw ... }

   // стало
   AppTask<Authenticated> signInWithTelegram(String initData) {
     return TaskEither.tryCatch(
       () async { ... },
       (e, st) => _mapError(e),  // приватный маппер DioException/SocketException/... → Failure
     );
   }
   ```
2. Добавить приватный `Failure _mapError(Object e)` — централизованный маппинг.
3. Обновить всех консьюмеров (Notifier/StateNotifier/Provider) — заменить
   `try { repo.x(); } catch (e) { state = Failed(e); }` на:
   ```dart
   final res = await repo.signInWithTelegram(initData).run();
   res.match(
     (f) => state = Failed(f),
     (ok) => state = ok,
   );
   ```
4. `flutter test` (тесты репо нужно тоже поправить: `when().thenReturn(TaskEither.right(...))`).

### Шаг 03.4 — заменить `AuthState.Failed(Object)` на `Failed(Failure)`

**Файл:** `app/lib/features/auth/domain/auth_state.dart`

```dart
// было
const factory AuthState.failed(Object error) = Failed;

// стало
const factory AuthState.failed(Failure failure) = Failed;
```

Это catch-all для UI: дальше выводим `failure.when(...)`.

## Валидация

- `flutter analyze` — без ошибок.
- `flutter test` — все зелёные (включая обновлённые моки).
- Ручной smoke: ошибка сети (DevTools → Offline) → UI показывает понятное
  сообщение из `NetworkFailure`, а не raw exception.

## Откат

Каждый репозиторий — отдельный коммит, можно откатить по одному.
Запретить мерж PR частично выполненного — состояние «половина репо на Either,
половина — на throw» хуже исходного.
