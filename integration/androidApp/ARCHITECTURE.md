# Архитектура — Android-сборка HabitFlow

Сопровождает [PLAN.md](PLAN.md). Только диаграммы и потоки данных.

---

## 1. Слои на стороне Android

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation (Flutter UI)                                    │
│   SplashScreen ── (mobile && !session) ──► DeviceLinkScreen │
│                                              │               │
│                                              ▼               │
│                                       DeviceLinkController   │
│                                       (Riverpod Notifier)    │
└──────────────────────────────────────────────┬──────────────┘
                                               │
┌──────────────────────────────────────────────▼──────────────┐
│ Data (репозитории + сервисы)                                 │
│   DeviceLinkRepository ──► Dio ──► auth_device_link Edge fn │
│   TelegramService.openBotDeepLink(token) ──► url_launcher    │
│   AuthRepository (существующий, +signInWithDeviceLink)       │
│   FlutterSecureStorage (JWT, user JSON — как сейчас)         │
└──────────────────────────────────────────────────────────────┘
```

Все остальные feature (habits, journal, analytics, ai, profile) **не трогаем** — они работают с RLS по `auth.uid()`, который уже корректен после установки JWT через `SupabaseService.applySession`.

---

## 2. Sequence: первая авторизация на устройстве

```
User    Android App        Edge Function          Postgres            Telegram-бот     Telegram-клиент
 │           │                   │                    │                    │                  │
 │ open app  │                   │                    │                    │                  │
 ├──────────►│                   │                    │                    │                  │
 │           │  splash → no session && !kIsWeb        │                    │                  │
 │           │  → /auth/device-link                   │                    │                  │
 │  tap "Войти через Telegram"   │                    │                    │                  │
 ├──────────►│ POST /auth_device_link {action:create} │                    │                  │
 │           ├──────────────────►│                    │                    │                  │
 │           │                   │ INSERT device_link_tokens (pending,5min)│                  │
 │           │                   ├──────────────────►│                    │                  │
 │           │  { token, deep_link }                  │                    │                  │
 │           │◄──────────────────┤                    │                    │                  │
 │           │ openBotDeepLink → url_launcher         │                    │                  │
 │           ├───────────────────────────────────────────────────────────────────────────────►│
 │           │                                                                                │ открывается Telegram
 │ START     │                                                                                │
 ├──────────────────────────────────────────────────────────────────────────────────────────►│
 │           │                                            /start link_<token>                 │
 │           │                                        ◄───┤                                  │
 │           │                                            │ upsert users + UPDATE token=linked│
 │           │                                            ├──────────────────►│              │
 │           │                                            │ reply «возвращайтесь»            │
 │           │                                            │──────────────────────────────────►│
 │           │ ── poll loop every 2s (≤ 5 min) ──         │                                  │
 │           │ POST /auth_device_link {action:poll}       │                                  │
 │           ├──────────────────►│                       │                                  │
 │           │                   │ SELECT status=linked  │                                  │
 │           │                   ├──────────────────►   │                                  │
 │           │                   │ upsertUser + signJwt (общий код с auth_telegram)         │
 │           │                   │ UPDATE status=consumed                                    │
 │           │                   │                                                            │
 │           │  { jwt, user }    │                                                            │
 │           │◄──────────────────┤                                                            │
 │           │ secure_storage.write(jwt) + supabase.applySession(jwt)                         │
 │           │ → router redirect → /today                                                    │
 │ habits visible                                                                            │
```

---

## 3. Sequence: уведомления остаются в Telegram

```
pg_cron(1m)
   │
   ▼
notification_queue (pending)  ──► send_notifications Edge fn
                                      │
                                      ▼
                              POST {bot}:8080/send_due/<secret>
                                      │
                                      ▼
                              bot.send_message(
                                  chat_id = users.telegram_user_id,
                                  text    = render(...),
                                  reply_markup = inline_keyboard()
                              )
                                      │
                                      ▼
                         Telegram сервера ─► Telegram-клиент на устройстве пользователя
                                                              │
                                                              ▼
                                                      Android system push
```

С точки зрения Android-приложения HabitFlow тут ничего делать **не нужно** — Telegram-клиент уже умеет показывать пуши. Привязка устройства = привязка `telegram_user_id` в `users` (которая делается ровно во время linking-flow выше).

---

## 4. Sequence: повторный запуск с валидным JWT

```
App start
  │
  ▼
AuthController.bootstrap()
  │
  ▼
AuthRepository.restoreSession()
  ├─ читает JWT из secure_storage
  ├─ JWT валиден и не истёк → applySession + return Authenticated
  │
  ▼
Router redirect → /today
```

То есть после первой привязки device-link-flow **не запускается** — никакого повторного открытия Telegram. Это важно для UX.

---

## 5. Sequence: JWT истёк / refresh

JWT живёт 7 дней (`signJwt(..., 7d)`). После истечения:
- `restoreSession()` видит просрочку → `_clearStorage()` → `Unauthenticated`.
- Splash на mobile → `/auth/device-link` снова.
- Пользователь жмёт «Войти через Telegram», получает новый JWT.

**Альтернатива (не делаем в первой итерации):** refresh-токен. Это удвоит ширину контракта и поломает аналог Web-flow. 7 дней + auto-relogin через 1 тап — приемлемо.

---

## 6. Файловая карта изменений

```
app/
├── android/
│   ├── app/
│   │   ├── build.gradle               ← правка: applicationId, sdks, signingConfigs
│   │   └── src/main/AndroidManifest.xml   ← правка: <queries> для tg://, https://t.me
│   └── key.properties.example         ← НОВЫЙ (шаблон без секретов)
├── lib/
│   ├── core/
│   │   ├── config/env.dart            ← правка: + botUsername + assertValid на mobile
│   │   └── services/
│   │       ├── telegram_service.dart        ← правка: + openBotDeepLink
│   │       ├── telegram_service_mobile.dart ← НОВЫЙ (url_launcher)
│   │       └── telegram_service_stub.dart   ← правка: добавить no-op
│   └── features/auth/
│       ├── data/
│       │   ├── auth_repository.dart            ← правка: + signInWithDeviceLink
│       │   ├── auth_providers.dart             ← правка: + deviceLinkProviders
│       │   └── device_link_repository.dart     ← НОВЫЙ
│       ├── domain/
│       │   └── device_link_state.dart          ← НОВЫЙ (sealed)
│       └── presentation/
│           ├── splash_screen.dart              ← правка: branch для mobile
│           └── device_link_screen.dart         ← НОВЫЙ
├── pubspec.yaml                       ← правка: + url_launcher
└── integration/androidApp/
    ├── PLAN.md
    ├── ARCHITECTURE.md
    └── IMPLEMENTATION.md

bot/
├── src/handlers/start.py              ← правка: парсинг payload link_<token>
└── integration/androidApp/
    └── PLAN.md

supabase/
├── migrations/0016_device_link_tokens.sql     ← НОВЫЙ
└── functions/
    ├── _shared/auth_utils.ts                  ← НОВЫЙ (вынос upsertUser + signJwt)
    ├── auth_telegram/index.ts                 ← правка: импорт из _shared
    └── auth_device_link/
        ├── index.ts                            ← НОВЫЙ
        └── test.ts                             ← НОВЫЙ
```

---

## 7. Контракт Edge Function `auth_device_link`

Тип-сигнатуры (на пальцах, до имплементации):

```ts
type CreateRequest = { action: 'create' };
type PollRequest   = { action: 'poll'; token: string };

type CreateResponse = {
  token: string;          // base64url, 32 B
  deep_link: string;      // https://t.me/<bot>?start=link_<token>
  expires_at: string;     // ISO-8601
};

type PollResponse =
  | { status: 'pending' }
  | { status: 'linked'; jwt: string; user: UserRow }
  | { status: 'expired' }
  | { status: 'consumed' }
  | { status: 'not_found' };
```

Маппинг HTTP-кодов из PLAN §8.1.

---

## 8. Контракт Postgres-таблицы `device_link_tokens`

| Колонка | Тип | Заполняется кем | Когда |
|---|---|---|---|
| `token` | text PK | Edge Fn (`create`) | при создании, ≥ 43 chars (32 B base64url) |
| `status` | text | Edge Fn / бот | `pending` → `linked` (бот) → `consumed` (Edge Fn poll) |
| `telegram_user_id` | bigint | бот | при `/start link_<token>` |
| `user_json` | jsonb | бот | snapshot `tg_user` для аудита и для последующего `upsertUser` |
| `created_at` | timestamptz | default `now()` | создание |
| `linked_at` | timestamptz | бот | момент привязки |
| `consumed_at` | timestamptz | Edge Fn (`poll`) | момент выдачи JWT |
| `expires_at` | timestamptz | Edge Fn (`create`) | `now() + interval '5 minutes'` |

Не индексируем `status` — мощность маленькая, индекс по `expires_at` достаточен для cleanup.

---

## 9. Принципы безопасности

| # | Принцип | Реализация |
|---|---|---|
| 1 | Токен — единственный «pre-auth» секрет, не угадывается. | 32 B `crypto.getRandomValues` → base64url. |
| 2 | Токен одноразовый. | `UPDATE ... WHERE status='linked' RETURNING ...` атомарно. |
| 3 | Токен короткоживущий. | `expires_at = now()+5m`; `poll` > expires_at → 410. |
| 4 | Только бот может пометить `linked`. | Бот пишет напрямую в Postgres под сервис-ролью (asyncpg pool); RLS не позволяет анонимным записать. |
| 5 | Только владелец токена может забрать JWT. | Для забора нужен сам `token` — он у того, кто его создал. |
| 6 | Не логируем токен. | Маска: `token[:6] + '…'`. |
| 7 | Сравнение токенов в БД — PK lookup, в коде не сравниваем строки. | — |
| 8 | JWT signing идентичен `auth_telegram`. | Общий модуль `_shared/auth_utils.ts`. |
| 9 | Никакого `BOT_TOKEN` / `SERVICE_ROLE_KEY` в APK. | Они лежат только в Edge Fn и в боте. |
| 10 | Rate-limit. | По 1 токен — макс 30 poll за 60 сек; для `action:create` — 5/мин на IP (нативно или через таблицу-журнал). |

---

## 10. Что мы НЕ строим (важные не-цели)

- **FCM/APNs.** Никаких google-services.json, никаких mobile-push капабилити.
- **Background fetch в Android.** Все вычисления streak/quiet-hours остаются в Postgres + боте.
- **Свой WebView-логин.** Не катим Telegram Login Widget.
- **Биометрия.** JWT хранится в EncryptedSharedPreferences/Keystore, биометрия не нужна — Telegram уже верифицирует личность.
- **Refresh-токены.** 7-дневный JWT + 1 тап перелогина при истечении.
