# HabitFlow Android — Implementation Playbook

> Этот файл — пошаговая инструкция для агента-исполнителя. Каждая операция содержит:
> цель, файлы, сигнатуры/схему, acceptance criteria, команды проверки.
>
> ТЗ-уровень (зачем и почему): [PLAN.md](PLAN.md) + [ARCHITECTURE.md](ARCHITECTURE.md).
> Парный план для бота: [../../../bot/integration/androidApp/PLAN.md](../../../bot/integration/androidApp/PLAN.md).

---

## 0. Утверждённые решения (не пересматривать)

| Решение | Значение |
|---|---|
| Auth-flow | Вариант A: login-via-bot + deep link + poll. |
| Android `applicationId` | `com.habitflow.app` |
| `minSdk` | `24` (Android 7.0) |
| `targetSdk` / `compileSdk` | `35` (Android 15, 16 KB-page-aligned) |
| Уведомления | Через Telegram-бота. Никаких FCM/Firebase. |
| JWT signing | HS256, общий `_shared/auth_utils.ts` для `auth_telegram` и `auth_device_link`. |
| Token entropy | 32 байта `crypto.getRandomValues` → base64url. |
| TTL токена | `pending`: 5 минут; `linked`: ещё 60 сек на выдачу JWT. |
| Poll interval | 2 сек, max 90 раз (3 мин), затем UI говорит «попробуйте снова». |
| BOT_USERNAME | `habit_flow_app_bot` — один и тот же бот на prod и dev. Передаётся через `--dart-define=BOT_USERNAME=habit_flow_app_bot` и через `supabase secrets set BOT_USERNAME=habit_flow_app_bot`. |
| App display name (Android) | `Habit Flow` — отображается на launcher-иконке и в системных диалогах. Подставляется в `android:label` в `AndroidManifest.xml`. |
| Distribution | **TBD** — sideload .apk на старте, Google Play позже. Не блокер для имплементации. |

---

## 1. Инварианты, которые нельзя сломать

1. **Web Mini App работает как раньше.** Любое изменение в `auth_telegram` — только refactor (вынос общего кода), без смены контракта `POST {initData} → {jwt, user}`.
2. **JWT — HS256, тем же ключом.** См. memory `project_jwt_hs256_constraint.md`. `auth_device_link` использует те же env-переменные (`SUPABASE_JWT_SECRET` → `SUPABASE_INTERNAL_JWT_SECRET` → `JWT_SECRET`).
3. **asyncpg jsonb-codec уже зарегистрирован** в `bot/src/services/db.py`. См. memory `project_asyncpg_jsonb_codec.md`. UPDATE с `user_json::jsonb` опирается на это.
4. **Бот деплоится отдельным репо** `zFannur/habit_flow_bot`. См. memory `project_bot_deploy_path.md`. Изменения в `bot/` нужно будет вручную скопировать или запушить в синхронизированный репозиторий.
5. **Никогда** не логируем полный `link_token`, никогда не логируем raw `initData`. Маска: первые 6 символов.
6. **Никаких** Riverpod ↔ BLoC миксов (W30). Сейчас в проекте Riverpod — оставляем Riverpod.

---

## 2. Порядок этапов (зависимости)

```
[1] Supabase migration ──┬──► [2] _shared/auth_utils refactor ──► [3] auth_device_link Edge fn
                          │
                          └──► [4] Bot: services/device_link + start.py
                                            │
                                            ▼
                                  Все три выкачены и проверены
                                            │
                                            ▼
                                  [5] Flutter env/pubspec
                                            │
                                            ▼
                                  [6] Flutter Android config
                                            │
                                            ▼
                                  [7] TelegramService extension
                                            │
                                            ▼
                                  [8] Auth feature: DeviceLink*
                                            │
                                            ▼
                                  [9] Splash + router
                                            │
                                            ▼
                                  [10] Локализация (ARB)
                                            │
                                            ▼
                                  [11] Тесты + manual QA
```

Бэкенд (1–4) можно выкатить независимо: новая Edge Function не имеет вызывающих, новая ветка `/start link_<...>` не срабатывает без payload. Web-юзеры не заметят.

---

# ЭТАП 1 — Supabase: миграция `0016_device_link_tokens.sql`

**Агент:** `supabase-schema`.
**Skill активирован:** `supabase` (см. system reminders).

### 1.1. Цель
Создать служебную таблицу для одноразовых linking-токенов + pg_cron-чистку просрочки.

### 1.2. Файлы
- Создать: `supabase/migrations/0016_device_link_tokens.sql`.

### 1.3. Содержимое (схема)
```sql
-- 0016_device_link_tokens.sql
-- Цель: одноразовые токены для привязки нативного устройства к Telegram-аккаунту.
-- Заполняет Edge Function auth_device_link (action=create);
-- помечает linked бот (handlers/start.py: /start link_<token>);
-- помечает consumed снова Edge Function (action=poll).

create table if not exists public.device_link_tokens (
  token             text primary key,
  status            text not null default 'pending'
                          check (status in ('pending','linked','consumed','expired')),
  telegram_user_id  bigint,
  user_json         jsonb,
  created_at        timestamptz not null default now(),
  linked_at         timestamptz,
  consumed_at       timestamptz,
  expires_at        timestamptz not null
);

create index if not exists device_link_tokens_expires_idx
  on public.device_link_tokens (expires_at)
  where status in ('pending','linked');

alter table public.device_link_tokens enable row level security;
-- service-only: никаких политик не создаём, к таблице ходят только
-- service_role (Edge Functions) и бот через прямой Postgres-конн.

-- Чистка: убираем строки, мёртвые больше часа.
-- Запускаем каждые 10 минут — не нагружает, индекс по expires_at режет диапазон.
select cron.schedule(
  'cleanup_device_link_tokens',
  '*/10 * * * *',
  $$ delete from public.device_link_tokens
      where expires_at < now() - interval '1 hour' $$
);
```

### 1.4. Acceptance
- `supabase db reset` локально проходит без ошибок (миграция идемпотентна).
- `supabase db push` к удалённому проекту — успешно (см. `supabase/CLAUDE.md`).
- `select * from cron.job where jobname='cleanup_device_link_tokens';` возвращает 1 строку.
- RLS-проверка: `set role anon; select * from public.device_link_tokens;` возвращает 0 строк (даже если в таблице данные есть). `set role service_role;` — даёт доступ.

### 1.5. Команды
```powershell
cd supabase
supabase db reset
# Если ОК:
supabase db push
```

---

# ЭТАП 2 — Supabase: рефакторинг общего auth-кода в `_shared/auth_utils.ts`

**Агент:** `supabase-schema`.

### 2.1. Цель
Вынести из `supabase/functions/auth_telegram/index.ts` функции, которые понадобятся новой `auth_device_link`. **Никаких изменений контракта.** Это чистый refactor.

### 2.2. Файлы
- Создать: `supabase/functions/_shared/auth_utils.ts`.
- Править: `supabase/functions/auth_telegram/index.ts` (импорты из нового модуля).

### 2.3. Что выносим в `_shared/auth_utils.ts`
- `hmacSha256(keyBytes, data)`
- `toHex(bytes)`
- `timingSafeEqual(a, b)`
- `signJwt(userId, telegramUserId, jwtSecret)`
- `findAuthUserIdByEmail(supabaseUrl, serviceRoleKey, email)`
- `upsertUser(supabaseUrl, serviceRoleKey, tgUser)` (включая интерфейс `TelegramUser`)
- Хелпер `readJwtSecret(): string` — единое место для трёх env-fallback'ов (`SUPABASE_JWT_SECRET` → `SUPABASE_INTERNAL_JWT_SECRET` → `JWT_SECRET`). Возвращает строку или бросает `Error('jwt_secret_missing')`.

### 2.4. Изменения в `auth_telegram/index.ts`
- Удалить вышеперечисленные функции.
- Импортировать их из `../_shared/auth_utils.ts`.
- `validateInitData(initData, botToken)` остаётся в `auth_telegram/index.ts` — это специфика Mini App, переиспользования нет.

### 2.5. Acceptance
- Существующий `supabase/functions/auth_telegram/test.ts` проходит без правок: `deno test --allow-env --allow-net supabase/functions/auth_telegram/test.ts`.
- В файле `auth_telegram/index.ts` не осталось определений вынесенных функций (только импорты).
- Дев-логин из Mini App в локальном `supabase functions serve auth_telegram` отдаёт `200 { jwt, user }`.

### 2.6. Деплой
```powershell
cd supabase
supabase functions deploy auth_telegram --project-ref <ref>
```

---

# ЭТАП 3 — Supabase: Edge Function `auth_device_link`

**Агент:** `supabase-schema`.

### 3.1. Цель
Реализовать `create` (выдать токен) и `poll` (вернуть JWT когда бот подтвердил).

### 3.2. Файлы
- Создать: `supabase/functions/auth_device_link/index.ts`.
- Создать: `supabase/functions/auth_device_link/test.ts`.

### 3.3. Контракт

`POST /functions/v1/auth_device_link`

#### action=create
Запрос:
```json
{ "action": "create" }
```
Ответ 200:
```json
{
  "token": "u8s5...",
  "deep_link": "https://t.me/<BOT_USERNAME>?start=link_u8s5...",
  "expires_at": "2026-05-20T12:05:00Z"
}
```

#### action=poll
Запрос:
```json
{ "action": "poll", "token": "u8s5..." }
```
Возможные ответы:
- `200 { "status": "pending" }`
- `200 { "status": "linked", "jwt": "...", "user": {...} }` — одноразовый ответ, после него токен `consumed`.
- `401 { "status": "consumed" }` — повторный poll после успешного poll.
- `404 { "status": "not_found" }`
- `410 { "status": "expired" }`
- `429 { "error": "rate_limited" }`

### 3.4. Конкретные требования к коду

1. **Env-переменные** (читаем в начале хендлера):
   - `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` — обязательны.
   - `BOT_USERNAME` — обязательна, без `@`. Используется в `deep_link`.
   - `SUPABASE_JWT_SECRET` (или fallback’и) — обязателен. Берём через `readJwtSecret()`.
   - Любое отсутствие — `500 { error: 'server_misconfigured' }`. **Не** логируем имя env.

2. **Генерация токена** (`action=create`):
   ```ts
   const bytes = new Uint8Array(32);
   crypto.getRandomValues(bytes);
   const token = base64UrlEncode(bytes); // без padding
   const expiresAt = new Date(Date.now() + 5 * 60_000).toISOString();
   ```
   INSERT в `device_link_tokens`:
   ```sql
   insert into device_link_tokens (token, status, expires_at)
     values ($1, 'pending', $2::timestamptz);
   ```
   В ответ возвращаем `deep_link = `https://t.me/${BOT_USERNAME}?start=link_${token}`.

3. **Poll** (`action=poll`):
   - Lookup `select token, status, telegram_user_id, user_json, expires_at from device_link_tokens where token=$1`.
   - Если row нет → `404 { status: 'not_found' }`.
   - Если `status='consumed'` → `401 { status: 'consumed' }`.
   - Если `status='expired'` ИЛИ `expires_at < now()` → если не `expired` — UPDATE на `expired`, затем `410 { status: 'expired' }`.
   - Если `status='pending'` → `200 { status: 'pending' }`.
   - Если `status='linked'`:
     1. Распарсить `user_json` как `TelegramUser`.
     2. Вызвать `upsertUser(...)` из `_shared/auth_utils.ts` — он вернёт строку `dbUser`.
     3. `jwt = await signJwt(dbUser.id, tgUser.id, jwtSecret)`.
     4. UPDATE атомарно: `UPDATE ... SET status='consumed', consumed_at=now() WHERE token=$1 AND status='linked' RETURNING token`. Если UPDATE вернул 0 строк (race — два параллельных poll) → 401 `{status:'consumed'}`.
     5. Вернуть `200 { status: 'linked', jwt, user: dbUser }`.

4. **Rate-limit (minimal):**
   Простейшее in-memory ограничение: `Map<token, {count, windowStart}>`, max 30 запросов за 60 сек на токен. На `429` отвечаем без подсчёта пинов в БД (так как Edge Function instances — короткоживущие, но в рамках одного instance защита есть). Если этого мало — позже добавим persisted-таблицу.

5. **Логи:**
   - На create: `console.log("device-link create", { token_prefix: token.slice(0,6) })`.
   - На poll linked: `console.log("device-link poll linked", { token_prefix, telegram_user_id })`.
   - На все ошибки: `console.warn(...)` без stack-trace в ответ пользователю.

6. **CORS:** используем существующий `corsHeaders` / `handleCors` из `_shared/cors.ts`.

7. **Никаких `Authorization: Bearer apikey` от клиента не требуем** — клиент пройдёт через стандартный CORS Supabase, как и `auth_telegram`. Anon-ключ передаётся клиентом в `apikey` header.

### 3.5. Тесты (`test.ts`)
Минимальный набор (`deno test`):

| # | Сценарий | Ожидаемый ответ |
|---|---|---|
| T1 | POST `{action:'create'}` | 200, token >= 43 символа, deep_link начинается с `https://t.me/` |
| T2 | POST `{action:'poll', token:'<свежий из T1>'}` | 200 `{status:'pending'}` |
| T3 | INSERT-руками `linked`, затем poll | 200 `{status:'linked', jwt, user}` |
| T4 | Повторный poll после T3 | 401 `{status:'consumed'}` |
| T5 | UPDATE `expires_at = now() - 1min`, poll | 410 `{status:'expired'}` |
| T6 | poll с неизвестным токеном | 404 `{status:'not_found'}` |
| T7 | 31 poll за 60 сек одного токена | 429 на 31-ом |
| T8 | Невалидный JSON в body | 400 `{error:'invalid_json'}` |
| T9 | `{action:'unknown'}` | 400 `{error:'bad_request'}` |
| T10 | Метод GET | 405 |

Используем моки `SUPABASE_URL` через локальный stub или ходим в `supabase start` стек.

### 3.6. Деплой
```powershell
cd supabase
supabase secrets set BOT_USERNAME=<значение>   # на dev и prod проектах
supabase functions deploy auth_device_link --project-ref <ref>
```

### 3.7. Acceptance
- `deno test --allow-env --allow-net supabase/functions/auth_device_link/test.ts` — все ≥ 10 кейсов зелёные.
- В `supabase functions list` присутствует `auth_device_link`.
- Постман-смок: POST `{action:'create'}` к prod URL даёт 200 с deep_link на правильного бота.
- В Postgres: `select count(*) from device_link_tokens where status='pending'` растёт после create.

---

# ЭТАП 4 — Bot: `services/device_link.py` + `handlers/start.py`

**Агент:** `telegram-bot-dev`.
**Skill активирован:** `telegram-bot-dev` (см. system reminders).

### 4.1. Цель
Реализовать ветку `/start link_<token>` и сервис, который атомарно помечает токен `linked` в БД, плюс шлёт пользователю осмысленный ответ.

### 4.2. Файлы
- Создать: `bot/src/services/device_link.py`.
- Править: `bot/src/handlers/start.py` (добавить второй хендлер, не трогать существующий).
- Править: `bot/src/templates.py` (добавить тексты на ru/en).
- Создать: `bot/tests/test_device_link.py`.

### 4.3. `services/device_link.py` — структура

```python
# Pseudocode signature
from enum import Enum

class DeviceLinkOutcome(str, Enum):
    LINKED_NOW = "linked_now"
    ALREADY_LINKED = "already_linked"
    CONSUMED = "consumed"
    EXPIRED = "expired"
    NOT_FOUND = "not_found"
    INVALID_FORMAT = "invalid_format"


_TOKEN_RE = re.compile(r"^[A-Za-z0-9_-]{32,128}$")


def validate_token(token: str) -> bool:
    return bool(_TOKEN_RE.fullmatch(token))


async def confirm_link(
    pool: asyncpg.Pool,
    *,
    token: str,
    telegram_user_id: int,
    tg_user_snapshot: dict[str, Any],
) -> DeviceLinkOutcome:
    """Атомарно перевести pending токен в linked.

    Возвращает один из DeviceLinkOutcome. Никаких исключений наружу
    (кроме случаев catastrophic-фейла connectionа пула — пусть hendler
    их ловит и логирует).
    """
```

Реализация — единый CTE-запрос из `bot/integration/androidApp/PLAN.md` §4.2:

```sql
WITH upd AS (
  UPDATE device_link_tokens
     SET status='linked',
         telegram_user_id=$1,
         user_json=$2::jsonb,
         linked_at=now()
   WHERE token=$3
     AND status='pending'
     AND expires_at > now()
  RETURNING token
), miss AS (
  SELECT status, expires_at FROM device_link_tokens WHERE token=$3
)
SELECT
  CASE
    WHEN exists(SELECT 1 FROM upd) THEN 'linked_now'
    WHEN NOT exists(SELECT 1 FROM miss) THEN 'not_found'
    WHEN (SELECT expires_at FROM miss) < now() THEN 'expired'
    WHEN (SELECT status FROM miss) = 'linked' THEN 'already_linked'
    WHEN (SELECT status FROM miss) = 'consumed' THEN 'consumed'
    ELSE 'not_found'
  END AS outcome;
```

`pool.fetchval(sql, telegram_user_id, json.dumps(tg_user_snapshot), token)` → строка `outcome` → `DeviceLinkOutcome(outcome)`.

### 4.4. `handlers/start.py` — патч

Не удаляем существующий `cmd_start`. Добавляем второй хендлер **выше** общего:

```python
from aiogram import F
from aiogram.filters import CommandStart, CommandObject

# Pseudocode
@router.message(CommandStart(deep_link=True, magic=F.args.startswith("link_")))
async def cmd_start_with_link(
    message: Message,
    command: CommandObject,
) -> None:
    ...
```

Внутри:
1. Извлечь `token = command.args[len('link_'):]`.
2. `if not validate_token(token):` → ответить «invalid format» текстом, log.warning без полного токена.
3. `upsert_user(...)` — как в существующем `cmd_start`. **Делаем ДО** `confirm_link`: если БД уронит upsert, мы не пометим токен linked (что лучше, чем пометить linked без users-строки).
4. `tg_user_snapshot = {"id": ..., "first_name": ..., "last_name": ..., "username": ..., "language_code": ...}`.
5. `outcome = await confirm_link(pool, token=token, telegram_user_id=tg_user.id, tg_user_snapshot=tg_user_snapshot)`.
6. По `outcome` выбрать текст из `templates.py`:
   - `LINKED_NOW` → «Вход подтверждён. Возвращайтесь в HabitFlow Android — приложение откроется автоматически.»
   - `ALREADY_LINKED` → «Вход уже подтверждён. Если приложение зависло — откройте его заново.»
   - `CONSUMED` → «Эта ссылка уже использована. Откройте приложение — вы уже внутри.»
   - `EXPIRED` → «Срок жизни ссылки истёк (5 минут). Нажмите «Войти через Telegram» в приложении ещё раз.»
   - `NOT_FOUND` → «Ссылка устарела или повреждена. Откройте приложение и нажмите «Войти ещё раз.»
   - `INVALID_FORMAT` → то же что NOT_FOUND (не выдаём probing-инфу).
7. Логировать `log.info("device-link outcome", extra={"outcome": outcome.value, "tg_user_id": tg_user.id, "token_prefix": token[:6]})`.

### 4.5. `templates.py` — новые тексты

Добавить словари вида:
```python
DEVICE_LINK_TEXTS: dict[str, dict[str, str]] = {
    "linked_now":      {"ru": "...", "en": "..."},
    "already_linked":  {"ru": "...", "en": "..."},
    "consumed":        {"ru": "...", "en": "..."},
    "expired":         {"ru": "...", "en": "..."},
    "not_found":       {"ru": "...", "en": "..."},
}
```
Получение текста: `DEVICE_LINK_TEXTS[outcome.value].get(lang, DEVICE_LINK_TEXTS[outcome.value]["en"])`.

### 4.6. Тесты `bot/tests/test_device_link.py`

`pytest-asyncio`. Тесты опираются на in-memory SQLite-эмуляцию? Нет — это не подойдёт для jsonb. Лучше — **pytest fixture с testcontainers-postgres** или против локального `supabase start`. Если нет docker — `unittest.mock` для `asyncpg.Pool` и проверка SQL-параметров.

Минимум (моковый pool):

| # | Тест | Что проверяем |
|---|---|---|
| t1 | `validate_token` accepts 32–128 base64url chars | unit |
| t2 | `validate_token` rejects `!@#`, пустую строку, длиннее 128 | unit |
| t3 | `confirm_link` маппит `'linked_now'` → enum LINKED_NOW | unit с моком `fetchval` |
| t4 | …то же для остальных 5 outcome | unit |
| t5 | handler `cmd_start_with_link` с валидным токеном, замокан `confirm_link → LINKED_NOW` → message.answer вызван с текстом из DEVICE_LINK_TEXTS["linked_now"]["ru"] (если user.language_code=='ru') | unit |
| t6 | handler с invalid_format → ответ NOT_FOUND-текстом, `confirm_link` НЕ вызван | unit |
| t7 | handler с language_code='it' → fallback на 'en' | unit |
| t8 | handler НЕ пишет полный токен в logging.LogRecord — только prefix 6 chars | unit (через `caplog`) |

### 4.7. Acceptance
- `cd bot && pytest tests/test_device_link.py -v` — все зелёные.
- `ruff check src/` и `mypy src/` — без новых ошибок.
- Локальный smoke: запустить бот в polling-режиме, в любом тестовом чате выдать `/start link_AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA` (32 A) — должен ответить «Ссылка устарела или повреждена» (NOT_FOUND, потому что в БД нет такого токена).

### 4.8. Деплой
Зеркальный репо: `zFannur/habit_flow_bot` (см. memory `project_bot_deploy_path.md`). Изменения в `bot/` нужно перенести туда (вручную копированием или скриптом синхронизации) и запушить — Railway autodeploy подхватит. Проверить `Railway → logs → "device-link"`.

---

# ЭТАП 5 — Flutter: env-переменные и пакеты

**Skill активирован:** `flutter-ai-dev`.

### 5.1. Цель
Добавить `BOT_USERNAME` в env-контракт, подключить `url_launcher`, обновить `Env.assertValid()`.

### 5.2. Файлы
- Править: `app/pubspec.yaml`.
- Править: `app/lib/core/config/env.dart`.
- Править: `app/CLAUDE.md` (раздел Env-переменные).

### 5.3. `pubspec.yaml` patch
В блок `dependencies` (после `flutter_secure_storage`):
```yaml
  url_launcher: ^6.3.1
```
Никаких других новых пакетов на этом этапе.

После правки:
```powershell
cd app
flutter pub get
```

### 5.4. `env.dart` patch
Добавить:
- `static const String botUsername = String.fromEnvironment('BOT_USERNAME', defaultValue: '');`
- В `assertValid()` добавить проверку:
  ```dart
  if (!kIsWeb && botUsername.isEmpty) {
    throw StateError('BOT_USERNAME --dart-define is required on non-web platforms');
  }
  ```
  (Импортировать `package:flutter/foundation.dart` для `kIsWeb`, если ещё не импортирован.)

### 5.5. `app/CLAUDE.md` — добавить строку в таблицу env-переменных
| `BOT_USERNAME` | да на mobile | — | username бота без `@`, для построения `https://t.me/<x>?start=link_...` |

### 5.6. Acceptance
- `flutter pub get` без ошибок.
- `flutter analyze` без новых warning.
- Команда `flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` (без BOT_USERNAME) на web — поднимается (т.к. assertValid не требует его на web).
- `flutter run -d <android-emulator>` без `BOT_USERNAME` — падает с понятным `StateError`.

---

# ЭТАП 6 — Flutter Android конфигурация

**Skill активирован:** `flutter-ai-dev`.

### 6.1. Цель
Установить `applicationId`, sdk-уровни, расширить `<queries>`, подготовить `key.properties.example`.

### 6.2. Файлы

#### 6.2.1. `app/android/app/build.gradle.kts` (или `build.gradle` — какой реально лежит)
- `defaultConfig.applicationId = "com.habitflow.app"`.
- `compileSdk = 35`.
- `defaultConfig.minSdk = 24`.
- `defaultConfig.targetSdk = 35`.
- `defaultConfig.versionCode` оставить как было; `versionName` — синхронизировать с `pubspec.yaml` version.
- Подключить `signingConfigs.release` из `key.properties` (см. шаблон ниже). `buildTypes.release.signingConfig = signingConfigs.release`.
- `buildTypes.release.minifyEnabled = true`, `shrinkResources = true` — оставить дефолты Flutter, не выключать.

#### 6.2.2. `app/android/app/src/main/AndroidManifest.xml`

Шаг A. Поменять `android:label` на `<application>`:
```xml
<application
    android:label="Habit Flow"     <!-- было: "habit_flow" -->
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```
Это меняет имя на иконке launcher и в системных списках. **Не трогаем** `pubspec.yaml name: habit_flow` — это идентификатор пакета Dart, не пользовательское имя.

Шаг B. В блок `<queries>` (он уже есть, с PROCESS_TEXT) **добавить** (не заменять существующее):
```xml
<intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="tg"/>
</intent>
<intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="https" android:host="t.me"/>
</intent>
```
Никаких `<intent-filter>` в `<activity>` **не добавляем** — мы не принимаем deep link в APK на этом этапе.

#### 6.2.3. `app/android/key.properties.example`
```properties
# Скопируйте в key.properties и заполните реальными значениями.
# key.properties и *.jks НЕ должны попадать в git.
storeFile=habitflow-release.jks
storePassword=CHANGE_ME
keyAlias=habitflow
keyPassword=CHANGE_ME
```

#### 6.2.4. `app/.gitignore` (или `app/android/.gitignore` — какой релевантен)
Убедиться, что есть строки:
```
android/key.properties
*.jks
*.keystore
```

#### 6.2.5. `app/android/app/build.gradle.kts` — загрузка key.properties
В верхушке файла (выше `android { }` блока):
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystoreFile = rootProject.file("key.properties")
if (keystoreFile.exists()) {
    keystoreProperties.load(FileInputStream(keystoreFile))
}
```
В `android { signingConfigs { create("release") { ... } } }` — стандартный шаблон Flutter docs.

### 6.3. Acceptance
- `flutter build apk --debug --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=BOT_USERNAME=habit_flow_app_bot` — собирается.
- `aapt dump badging build/app/outputs/flutter-apk/app-debug.apk | grep package` показывает `name='com.habitflow.app'`.
- `aapt dump badging ... | grep application-label` показывает `application-label:'Habit Flow'`.
- Без `key.properties` `flutter build apk --release` падает понятной ошибкой про отсутствующий keystore (не молча подменяет debug-подписью — это намеренно).

---

# ЭТАП 7 — Flutter: `TelegramService` extension

**Skill активирован:** `flutter-ai-dev`.

### 7.1. Цель
Добавить кросс-платформенный метод `openBotDeepLink(String token)`. На Web — открыть через существующий `openLinkWeb`; на Mobile — через `url_launcher`.

### 7.2. Файлы
- Править: `app/lib/core/services/telegram_service.dart`.
- Создать: `app/lib/core/services/telegram_service_mobile.dart`.
- Править: `app/lib/core/services/telegram_service_stub.dart`.

### 7.3. Conditional import
Текущая схема:
```dart
import 'telegram_service_web.dart'
    if (dart.library.io) 'telegram_service_stub.dart';
```
Нужно: на Web — `telegram_service_web.dart` (как сейчас), на Android/iOS — новый `telegram_service_mobile.dart`. Для этого:
```dart
import 'telegram_service_web.dart'
    if (dart.library.io) 'telegram_service_mobile.dart';
```
**Внимание:** `telegram_service_stub.dart` уходит. Но раз он сейчас содержит no-op для тестов — мы либо удаляем его, либо оставляем как fallback, если `dart.library.io` недоступен (unit-test host). На практике `dart.library.io` доступен в `flutter test` хосте — мобильная реализация подойдёт, если внутри есть guard для `kIsWeb || Platform.isLinux/Mac/Windows` (но `url_launcher` сам корректно работает на desktop тоже).

Решение: оставить **`telegram_service_stub.dart`** как есть; conditional import переписать так, чтобы mobile-вариант явно жил в `_mobile.dart` и conditional import делегировался корректно. Для совместимости с тестами Web-обвязка остаётся.

Пересмотр conditional import:
```dart
// На web (есть dart.library.html / dart.library.js_interop) → web-реализация.
// На non-web (есть dart.library.io) → mobile-реализация.
// Если ни одного — stub (на практике не сработает в production, но защищает анализатор).
import 'telegram_service_stub.dart'
    if (dart.library.io) 'telegram_service_mobile.dart'
    if (dart.library.js_interop) 'telegram_service_web.dart';
```

### 7.4. Сигнатуры
В каждом из трёх файлов экспортируем функции с одинаковыми именами:

```dart
// Все три файла
String getInitDataWeb();                         // web: реально читает; mobile/stub: ''
void openLinkWeb(String url);                    // web: реальный; mobile: url_launcher; stub: no-op
void openInvoiceWeb(String url, void Function(TgInvoiceStatus) onStatus); // web: реально; иначе onStatus(failed)
Future<bool> openBotDeepLinkPlatform(String url); // НОВОЕ — Future<bool>: можно ли было открыть.
```

И в `telegram_service.dart`:
```dart
Future<bool> openBotDeepLink(String token) async {
  final url = 'https://t.me/${Env.botUsername}?start=link_$token';
  return openBotDeepLinkPlatform(url);
}
```

### 7.5. Реализация в `telegram_service_mobile.dart`
```dart
// Pseudocode — реализуется при кодинге.
// import 'package:url_launcher/url_launcher.dart';

String getInitDataWeb() => '';

void openLinkWeb(String url) {
  // На mobile делегируем url_launcher с external app preference.
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

void openInvoiceWeb(String url, void Function(TgInvoiceStatus) onStatus) {
  // Stars работают только из Mini App — на mobile нет смысла; сразу failed.
  onStatus(TgInvoiceStatus.failed);
}

Future<bool> openBotDeepLinkPlatform(String url) async {
  final uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) {
    return false; // нет Telegram-приложения, нет браузера
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
```

### 7.6. WATCHDOG-проверки
- `W07`: URL `https://t.me/${Env.botUsername}` строится из env — ✅ не hardcoded.
- `W15`: нет контроллеров — N/A.
- `W22`: `Future<bool>` — это простой тип, не Either, но это **service layer**, не repository. Repository (`DeviceLinkRepository`, см. этап 8) использует Either/sealed result. Здесь Future<bool> приемлемо.

### 7.7. Acceptance
- `flutter analyze` без ошибок.
- Существующий тест `flutter_test test/widget_test.dart` (если есть) проходит.
- На web — поведение не изменилось (тот же `getInitDataWeb`, тот же `openInvoice`).
- На Android emulator: вызов `TelegramService().openBotDeepLink('FAKE')` открывает Telegram-клиент с экраном бота (или Play Store, если Telegram нет).

---

# ЭТАП 8 — Flutter: `auth` feature, новые компоненты

**Skill активирован:** `flutter-ai-dev`.

### 8.1. Цель
Реализовать `DeviceLinkRepository` (HTTP-обёртка), `DeviceLinkController` (Riverpod state), `DeviceLinkScreen` (UI), плюс точечно расширить `AuthRepository` для приёма уже-готового JWT (выданного `auth_device_link`).

### 8.2. Файлы
- Создать: `app/lib/features/auth/data/device_link_repository.dart`.
- Создать: `app/lib/features/auth/domain/device_link_state.dart`.
- Создать: `app/lib/features/auth/presentation/device_link_screen.dart`.
- Править: `app/lib/features/auth/data/auth_repository.dart`.
- Править: `app/lib/features/auth/data/auth_providers.dart`.

### 8.3. `device_link_state.dart` — sealed класс

```dart
// Pseudocode — реализуется при кодинге.
sealed class DeviceLinkState {
  const DeviceLinkState();
}
final class DeviceLinkIdle    extends DeviceLinkState { const DeviceLinkIdle(); }
final class DeviceLinkOpening extends DeviceLinkState { const DeviceLinkOpening(); }
final class DeviceLinkWaiting extends DeviceLinkState {
  const DeviceLinkWaiting({required this.attempt, required this.maxAttempts});
  final int attempt;
  final int maxAttempts;
}
final class DeviceLinkSuccess extends DeviceLinkState { const DeviceLinkSuccess(); }
final class DeviceLinkFailed  extends DeviceLinkState {
  const DeviceLinkFailed(this.reason);
  final DeviceLinkFailReason reason;
}

enum DeviceLinkFailReason {
  noTelegramInstalled,
  expired,
  consumed,
  notFound,
  network,
  unknown,
}
```

### 8.4. `device_link_repository.dart`

API:

```dart
class DeviceLinkRepository {
  DeviceLinkRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<DeviceLinkCreateResult> create();
  Future<DeviceLinkPollResult> poll(String token);
}

sealed class DeviceLinkCreateResult { const DeviceLinkCreateResult(); }
final class DeviceLinkCreated extends DeviceLinkCreateResult {
  const DeviceLinkCreated({required this.token, required this.deepLink, required this.expiresAt});
  final String token;
  final String deepLink;
  final DateTime expiresAt;
}
final class DeviceLinkCreateError extends DeviceLinkCreateResult {
  const DeviceLinkCreateError(this.reason);
  final DeviceLinkFailReason reason;
}

sealed class DeviceLinkPollResult { const DeviceLinkPollResult(); }
final class DeviceLinkPending  extends DeviceLinkPollResult { const DeviceLinkPending(); }
final class DeviceLinkLinked   extends DeviceLinkPollResult {
  const DeviceLinkLinked({required this.jwt, required this.user});
  final String jwt;
  final AuthUser user;
}
final class DeviceLinkExpired  extends DeviceLinkPollResult { const DeviceLinkExpired(); }
final class DeviceLinkConsumed extends DeviceLinkPollResult { const DeviceLinkConsumed(); }
final class DeviceLinkNotFound extends DeviceLinkPollResult { const DeviceLinkNotFound(); }
final class DeviceLinkPollError extends DeviceLinkPollResult {
  const DeviceLinkPollError(this.reason);
  final DeviceLinkFailReason reason;
}
```

URL endpoint: `'${Env.supabaseUrl}/functions/v1/auth_device_link'`. Headers: `apikey: anonKey`, `Authorization: Bearer anonKey`, `Content-Type: application/json` — копируем подход из `AuthRepository.signInWithTelegram`.

JSON-декодирование — в `try/catch`, mapping в `DeviceLinkFailReason.network` или `.unknown`. **W27.**

### 8.5. `auth_repository.dart` patch
Добавить метод:

```dart
Future<Authenticated> applyDeviceLinkJwt({
  required String jwt,
  required AuthUser user,
}) async {
  await _persist(jwt: jwt, user: user);
  await _supabase.applySession(jwt);
  await _syncTimeZone(user.id);
  return Authenticated(jwt: jwt, user: user);
}
```

Никаких изменений в `signInWithTelegram` / `restoreSession`.

### 8.6. `auth_providers.dart` patch
Добавить:

```dart
final deviceLinkRepositoryProvider = Provider<DeviceLinkRepository>((_) {
  return DeviceLinkRepository();
});

class DeviceLinkController extends StateNotifier<DeviceLinkState> {
  DeviceLinkController({
    required DeviceLinkRepository repo,
    required AuthRepository authRepo,
    required TelegramService telegramService,
    required AuthController auth,
  })  : _repo = repo,
        _authRepo = authRepo,
        _tg = telegramService,
        _auth = auth,
        super(const DeviceLinkIdle());

  final DeviceLinkRepository _repo;
  final AuthRepository _authRepo;
  final TelegramService _tg;
  final AuthController _auth;

  Timer? _pollTimer;
  String? _activeToken;
  int _attempt = 0;
  static const _kMaxAttempts = 90;     // 90 * 2 sec = 3 min
  static const _kPollInterval = Duration(seconds: 2);

  Future<void> start() async {
    _cancel();
    state = const DeviceLinkOpening();

    final created = await _repo.create();
    if (created is DeviceLinkCreateError) {
      state = DeviceLinkFailed(created.reason);
      return;
    }
    final c = created as DeviceLinkCreated;
    _activeToken = c.token;

    final opened = await _tg.openBotDeepLink(c.token);
    if (!opened) {
      state = const DeviceLinkFailed(DeviceLinkFailReason.noTelegramInstalled);
      return;
    }

    _attempt = 0;
    state = DeviceLinkWaiting(attempt: 0, maxAttempts: _kMaxAttempts);
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    if (_activeToken == null) return;
    if (_attempt >= _kMaxAttempts) {
      _cancel();
      state = const DeviceLinkFailed(DeviceLinkFailReason.expired);
      return;
    }
    _attempt++;
    state = DeviceLinkWaiting(attempt: _attempt, maxAttempts: _kMaxAttempts);

    final result = await _repo.poll(_activeToken!);
    switch (result) {
      case DeviceLinkPending():
        return; // продолжаем
      case DeviceLinkLinked(:final jwt, :final user):
        _cancel();
        await _authRepo.applyDeviceLinkJwt(jwt: jwt, user: user);
        _auth.markAuthenticated(jwt: jwt, user: user); // см. ниже
        state = const DeviceLinkSuccess();
      case DeviceLinkExpired():
        _cancel();
        state = const DeviceLinkFailed(DeviceLinkFailReason.expired);
      case DeviceLinkConsumed():
        _cancel();
        state = const DeviceLinkFailed(DeviceLinkFailReason.consumed);
      case DeviceLinkNotFound():
        _cancel();
        state = const DeviceLinkFailed(DeviceLinkFailReason.notFound);
      case DeviceLinkPollError(:final reason):
        _cancel();
        state = DeviceLinkFailed(reason);
    }
  }

  void _cancel() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void reset() {
    _cancel();
    _activeToken = null;
    _attempt = 0;
    state = const DeviceLinkIdle();
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}

final deviceLinkControllerProvider =
    StateNotifierProvider<DeviceLinkController, DeviceLinkState>((ref) {
  return DeviceLinkController(
    repo: ref.watch(deviceLinkRepositoryProvider),
    authRepo: ref.watch(authRepositoryProvider),
    telegramService: ref.watch(telegramServiceProvider),
    auth: ref.read(authStateProvider.notifier),
  );
});
```

В `AuthController` добавить `markAuthenticated({required String jwt, required AuthUser user})`:
```dart
void markAuthenticated({required String jwt, required AuthUser user}) {
  state = Authenticated(jwt: jwt, user: user);
}
```
(Без него `DeviceLinkController` не смог бы переключить `authStateProvider` без повторного `signInWithTelegram`.)

### 8.7. WATCHDOG аудит для этого этапа

| # | Правило | Реализация |
|---|---|---|
| W15 | Контроллеры dispose'ятся | `_pollTimer.cancel()` в `dispose()` + при terminal-стейтах. |
| W16 | StreamSubscription отписываются | мы используем Timer, не Stream — не релевантно. |
| W22 | Repository → Either/sealed Result | `DeviceLinkRepository.create/poll` возвращают sealed classes. |
| W25 | 4 состояния экрана | `DeviceLinkScreen`: Idle, Opening, Waiting, Failed (+ Success — но он сразу редиректит). |
| W26 | mounted check после await | Timer внутри Controller, не в widget — но Controller проверяет `_activeToken != null` (был ли cancel'нут). |
| W27 | jsonDecode в try/catch | `DeviceLinkRepository.poll/create` оборачивают парсинг в try/catch с маппингом в `network`/`unknown`. |
| W11 | Нет TODO | Sigil-комменты для будущего рефакторинга — допустимы только как `// Why: ...`. |
| W30 | Riverpod, без BLoC | соблюдено. |

### 8.8. Acceptance
- `flutter analyze` чистый.
- Юнит-тест на `DeviceLinkController` с моком `DeviceLinkRepository`:
  - create → openBotDeepLink false → state == Failed(noTelegramInstalled).
  - create OK + openBotDeepLink OK + poll pending(x3) + linked → state == Success, markAuthenticated вызван.
  - timeout: 90 pending → state == Failed(expired).
  - dispose() во время waiting → Timer останавливается (можно проверить через fake_async).

---

# ЭТАП 9 — Flutter: `DeviceLinkScreen` + splash + router

**Skill активирован:** `flutter-ai-dev`.

### 9.1. Цель
UI-экран с 4 состояниями + интеграция в роутинг.

### 9.2. Файлы
- Создать: `app/lib/features/auth/presentation/device_link_screen.dart`.
- Править: `app/lib/features/auth/presentation/splash_screen.dart`.
- Править: `app/lib/core/routing/app_router.dart`.

### 9.3. `device_link_screen.dart` — структура

```dart
// Pseudocode — реализуется при кодинге.
class DeviceLinkScreen extends ConsumerWidget {
  const DeviceLinkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceLinkControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (state) {
            DeviceLinkIdle()    => _Idle(onPressed: () => ref.read(deviceLinkControllerProvider.notifier).start()),
            DeviceLinkOpening() => _Opening(),
            DeviceLinkWaiting(:final attempt, :final maxAttempts) => _Waiting(progress: attempt / maxAttempts),
            DeviceLinkFailed(:final reason) => _Failed(
              reason: reason,
              onRetry: () => ref.read(deviceLinkControllerProvider.notifier).start(),
              onOpenTelegramAgain: () { /* re-open same token if waiting */ },
            ),
            DeviceLinkSuccess() => _Success(),  // эту страницу редко увидим — router сразу уведёт
          },
        ),
      ),
    );
  }
}
```

UI-стиль — следовать существующей дизайн-системе (`shared/widgets/hf_*`). Полноразмерная primary-кнопка `HfButton` с текстом из l10n, под ней — подпись. На `_Waiting` — `CircularProgressIndicator(value: progress)` + текст «Ожидаем подтверждения от бота…». На `_Failed` — иконка `Icons.error_outline` + текст ошибки + 2 действия (Retry / Open Telegram again).

### 9.4. `splash_screen.dart` patch
Добавить ветку:
```dart
@override
Widget build(BuildContext context) {
  if (!kIsWeb) {
    // Mobile: initData недоступен — отправляем в device-link только если
    // ещё нет сессии. Если есть — restoreSession сам перекинет на /today.
    final authState = ref.watch(authStateProvider);
    if (authState is Unauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/auth/device-link');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Authenticated / Failed — обрабатывается ниже стандартной логикой.
  }
  // ... остальной существующий код без правок
}
```

В `_bootstrap()` на mobile не пытаемся `getInitData()` — он вернёт '' и логика правильно зависнет на splash без редиректа. **Не нужно** добавлять отдельный bootstrap для mobile — DeviceLinkController сам управляет своим жизненным циклом.

### 9.5. `app_router.dart` patch
Добавить GoRoute **вне** ShellRoute, рядом с `/splash` и `/onboarding`:
```dart
GoRoute(
  path: '/auth/device-link',
  builder: (_, _) => const DeviceLinkScreen(),
),
```

В `redirect` уже есть «not authenticated && not splash/onboarding → splash». Добавить:
```dart
if (!authState is Authenticated) {
  final onSplash = location == '/splash';
  final onOnboarding = location == '/onboarding';
  final onDeviceLink = location == '/auth/device-link';
  if (!onSplash && !onOnboarding && !onDeviceLink) return '/splash';
  return null;
}
```

И на splash для mobile — после bootstrap → если Unauthenticated → `/auth/device-link`; если Authenticated → стандартно `/today`.

### 9.6. Acceptance
- На Web: поведение splash не изменилось.
- На Android emulator при первом запуске: splash → /auth/device-link → видим idle-state с кнопкой.
- Тап «Войти через Telegram» (если Telegram не установлен в эмуляторе) → переход в Failed(noTelegramInstalled) с текстом про установку.

---

# ЭТАП 10 — Локализация (ARB)

**Skill активирован:** `arb-translate`.

### 10.1. Цель
Добавить новые ключи перевода для `DeviceLinkScreen` + текстов бота на стороне приложения (на стороне бота тексты в `templates.py`, см. этап 4).

### 10.2. Файлы
- Править: `app/lib/core/localization/app_ru.arb`.
- Править: `app/lib/core/localization/app_en.arb`.

### 10.3. Ключи (предлагаемый набор — финальные тексты редактируем после ревью копирайтинга)

| key | ru | en |
|---|---|---|
| `deviceLinkTitle` | Войдите через Telegram | Sign in with Telegram |
| `deviceLinkSubtitle` | Откроется Telegram. Подтвердите вход, и приложение продолжит работу автоматически. | Telegram will open. Confirm sign-in there, and the app will continue automatically. |
| `deviceLinkCta` | Войти через Telegram | Sign in with Telegram |
| `deviceLinkOpeningTitle` | Открываем Telegram… | Opening Telegram… |
| `deviceLinkWaitingTitle` | Ждём подтверждения | Waiting for confirmation |
| `deviceLinkWaitingSubtitle` | Нажмите СТАРТ в боте, и приложение само войдёт. | Tap START in the bot, and the app will sign you in. |
| `deviceLinkOpenAgain` | Открыть Telegram ещё раз | Open Telegram again |
| `deviceLinkRetry` | Попробовать снова | Try again |
| `deviceLinkExpiredTitle` | Время вышло | Time expired |
| `deviceLinkExpiredSubtitle` | Ссылка живёт 5 минут. Начнём заново? | The link is valid for 5 minutes. Start over? |
| `deviceLinkNoTelegramTitle` | Telegram не установлен | Telegram is not installed |
| `deviceLinkNoTelegramSubtitle` | Установите Telegram из Play Store и попробуйте снова. | Install Telegram from Play Store and try again. |
| `deviceLinkInstallTelegram` | Установить Telegram | Install Telegram |
| `deviceLinkUnknownErrorTitle` | Не удалось войти | Sign-in failed |
| `deviceLinkUnknownErrorSubtitle` | Проверьте подключение и попробуйте снова. | Check your connection and try again. |

После правки:
```powershell
cd app
flutter gen-l10n
flutter analyze
```

### 10.4. Acceptance
- `flutter gen-l10n` без ошибок.
- `AppLocalizations.of(context).deviceLinkTitle` доступно на обоих языках.
- Build APK не падает с missing-locale.

---

# ЭТАП 11 — Тесты и Manual QA

### 11.1. Автотесты
- **Supabase Edge Function:** `deno test --allow-env --allow-net supabase/functions/auth_device_link/test.ts` — 10+ кейсов из §3.5.
- **Bot:** `cd bot && pytest tests/test_device_link.py -v` — 8 кейсов из §4.6.
- **Flutter unit:** новые тесты на `DeviceLinkController`, `DeviceLinkRepository` (моки Dio).
- **Flutter widget:** `DeviceLinkScreen` рендерит 4 состояния под разные `DeviceLinkState`-овые входы (через override провайдера).
- **Flutter analyze:** `cd app && flutter analyze` — без warnings.
- **Существующие тесты:** `cd app && flutter test` — все зелёные (auth_telegram/Web-flow не тронут).

### 11.2. Manual QA — `app/MANUAL_QA.md` дополнить разделом

```
## Android APK — device-link auth

Предусловия: APK подписан release-keystore, BOT_USERNAME=<prod-bot>,
эмулятор/устройство Android 7+ с установленным Telegram.

1. Установить APK, открыть. → Splash → Device Link Screen.
2. Тап «Войти через Telegram». → Открывается Telegram, бот, кнопка СТАРТ.
3. Жмём СТАРТ. → Бот отвечает «Вход подтверждён, возвращайтесь в HabitFlow».
4. Возвращаемся в APK. → В течение 2-4 сек экран переключается на /today.
5. Закрываем приложение, открываем снова. → Прямо в /today, без повторного входа.
6. Сценарий expired: жмём «Войти через Telegram», ждём 6 минут не нажимая
   СТАРТ → state = Failed(expired), CTA «Попробовать снова».
7. Сценарий no telegram: удаляем Telegram, жмём «Войти через Telegram» →
   state = Failed(noTelegramInstalled), CTA ведёт в Play Store.
8. Сценарий уведомления: создаём в Mini App привычку с напоминанием
   через 2 мин. Через 2 мин в Telegram-клиенте приходит habit_reminder
   с inline-кнопками. Жмём «Готово» → callback_query прилетает боту,
   привычка отмечается в БД. (Проверка, что Android-устройство получило
   уведомление через Telegram-канал, БЕЗ FCM.)
```

### 11.3. Smoke на prod
- Postman: `POST {prod-supabase}/functions/v1/auth_device_link {action:create}` → 200 с deep_link.
- Открыть deep_link на устройстве с Telegram, нажать СТАРТ → бот отвечает.
- Postman: `POST {action:poll, token}` → 200 `{status:linked, jwt, user}`.
- Декодировать JWT (jwt.io) → `alg=HS256`, `sub` = UUID, `telegram_user_id` = твой ID.

---

# ЭТАП 12 — Деплой и выкат

### 12.1. Очерёдность
1. **Supabase migration** `0016` → запушить через `supabase db push`. Безопасно — новая таблица, никого не задевает.
2. **`auth_telegram` refactor** → `supabase functions deploy auth_telegram`. Контракт не меняется, но проверить smoke (логин из Mini App).
3. **`auth_device_link`** → `supabase secrets set BOT_USERNAME=habit_flow_app_bot` + `supabase functions deploy auth_device_link`.
4. **Bot** → push в `zFannur/habit_flow_bot`. Railway autodeploy. Проверить в логах, что бот стартует и реагирует на `/start` (без payload).
5. **Flutter Android** → собрать debug APK, прогнать §11.2 шаги 1–5 на эмуляторе. Если ОК — собрать release APK с реальным keystore.
6. Распространение APK — отдельное решение пользователя.

### 12.2. Rollback-план
- Edge Function: `supabase functions deploy auth_device_link --no-verify-jwt` НЕ выкатываем заново, просто прекращаем вызовы со стороны клиента (старая Web-версия её не использует, новый APK можно не публиковать).
- Bot patch: rollback — revert commit на `handlers/start.py` и `services/device_link.py`. Раз ветка `link_<...>` — единственное новшество, существующие хендлеры продолжают работать.
- Миграция `0016`: down-миграция не требуется (новая таблица + cron job изолированы). Если очень нужно — `drop table public.device_link_tokens; select cron.unschedule('cleanup_device_link_tokens');` отдельной миграцией `0017_drop_device_link_tokens.sql`.

### 12.3. Мониторинг после выката
- Postgres: `select status, count(*) from device_link_tokens group by status;` — должно быть >0 в `pending`/`linked`/`consumed` после первых тестов.
- Логи бота: запросы `device-link outcome` с outcome=linked_now.
- Логи Edge Function: запросы `device-link poll linked`.
- Не должно быть всплеска ошибок `jwt_secret_missing` или `server_misconfigured` — это значит, что env-переменные не выставлены.

---

# ПРИЛОЖЕНИЕ A — Контракты в одном месте

### A.1. Edge Function REST

```
POST /functions/v1/auth_device_link
Headers: apikey, Authorization: Bearer anon, Content-Type: application/json

Body (create):  { "action": "create" }
Body (poll):    { "action": "poll", "token": "<base64url, 32B>" }
```

### A.2. Database row

```sql
device_link_tokens(
  token            text primary key,
  status           text in ('pending','linked','consumed','expired'),
  telegram_user_id bigint,
  user_json        jsonb,
  created_at       timestamptz,
  linked_at        timestamptz,
  consumed_at      timestamptz,
  expires_at       timestamptz
)
```

### A.3. Bot deep-link

```
https://t.me/<BOT_USERNAME>?start=link_<token>
```

### A.4. Env-переменные

| Где | Ключ | Назначение |
|---|---|---|
| Edge Function | `BOT_USERNAME` | для построения `deep_link` |
| Edge Function | `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | upsertUser |
| Edge Function | `SUPABASE_JWT_SECRET` / `JWT_SECRET` | signJwt — **тот же**, что для `auth_telegram` |
| Bot | `SUPABASE_DB_URL` | прямой Postgres-конн (уже есть) |
| Flutter | `SUPABASE_URL`, `SUPABASE_ANON_KEY` | как сейчас |
| Flutter (mobile only) | `BOT_USERNAME` | через `--dart-define=BOT_USERNAME=...` |

---

# ПРИЛОЖЕНИЕ B — Чек-лист для финального ревью

Перед мерджем убедиться, что:

- [ ] `auth_telegram/index.ts` импортирует из `_shared/auth_utils.ts`, **тесты test.ts не сломаны**.
- [ ] `auth_device_link/index.ts` — все 10+ deno-тестов зелёные.
- [ ] Миграция `0016` идемпотентна (повторный `supabase db push` без ошибок).
- [ ] pg_cron job `cleanup_device_link_tokens` присутствует в `cron.job`.
- [ ] Бот: `/start` без payload работает как раньше (existing tests).
- [ ] Бот: новый pytest на device-link зелёный, ruff и mypy чистые.
- [ ] Бот: `token` нигде не логируется целиком (grep по `log.*token` без `[:6]`).
- [ ] Flutter: `pubspec.yaml` содержит `url_launcher`, `flutter pub get` чистый.
- [ ] Flutter: `Env.botUsername` есть, `assertValid` падает без него на mobile.
- [ ] Flutter: `android/app/build.gradle` — applicationId=com.habitflow.app, sdks 24/35/35.
- [ ] Flutter: `AndroidManifest.xml` — `<queries>` расширен на `tg://` и `https://t.me`.
- [ ] Flutter: `key.properties` и `*.jks` в `.gitignore`.
- [ ] Flutter: `TelegramService.openBotDeepLink` на mobile запускает url_launcher.
- [ ] Flutter: `DeviceLinkController` правильно отписывает Timer (W15).
- [ ] Flutter: `DeviceLinkRepository.poll` возвращает sealed result (W22).
- [ ] Flutter: 4 состояния `DeviceLinkScreen` (W25), все ARB-ключи есть на ru+en.
- [ ] Flutter: `flutter analyze` и `flutter test` чистые.
- [ ] Manual QA §11.2 пройден на реальном устройстве/эмуляторе.
- [ ] Memory обновлена: статус задачи фиксируется отдельным memo, если выкат прошёл успешно.

---

# Когда ВСЁ это сделано

1. Уведомить пользователя, что APK готов и описать sideload-инструкцию для тестового запуска.
2. Запросить решение по distribution (Play Store / GitHub Releases / прямая ссылка на signed APK).

Полностью имплементация Этапа 1 (Android-сборка с авторизацией и уведомлениями) — заканчивается тут. Дальнейшие этапы (deep-link обратно в APK, in-app push, iOS) — отдельные ТЗ.
