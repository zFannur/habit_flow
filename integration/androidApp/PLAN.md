# HabitFlow Android — авторизация через Telegram + уведомления

> Документ-ТЗ. Кода ещё нет — нужно явное одобрение до старта имплементации.
> Сопутствующие файлы:
> - [ARCHITECTURE.md](ARCHITECTURE.md) — диаграммы и потоки.
> - [../../../bot/integration/androidApp/PLAN.md](../../../bot/integration/androidApp/PLAN.md) — изменения в боте.
> - Source of truth для всего проекта: [SPEC.md](../../../SPEC.md), [CLAUDE.md](../../../CLAUDE.md).

---

## 1. Цель и не-цели

### Цель
Дать пользователю на Android (Flutter native APK) ровно тот же опыт, что в Mini App:
- войти **через Telegram** без отдельного пароля/email;
- получать **уведомления** про привычки / дневник / weekly review из существующего бота;
- работать с теми же данными в Supabase под тем же `auth.uid()`.

### Не-цели (out of scope первой итерации)
- iOS — отдельный этап (тот же flow, нужны лишь Universal Links и подпись).
- Полноценный pull-based push внутри приложения через FCM / OneSignal. **Уведомления остаются в Telegram-боте.**
- In-app Telegram Stars (Stars работают только из Mini App).
- Background-сервисы / WorkManager для отслеживания таймеров.

---

## 2. Почему именно так (выбор архитектуры)

Текущий Web-flow опирается на `Telegram.WebApp.initData` — JS-объект, который Telegram кладёт только в WebView Mini App. **В нативном Android этого объекта нет.** Варианты:

| Вариант | Решение | Вердикт |
|---|---|---|
| A. **Login via Bot + deep link + poll** | Android генерирует одноразовый `link_token`, открывает `tg://resolve?domain=BOT&start=link_<token>`, бот ловит `/start link_<token>`, фиксирует `telegram_id`, Android опрашивает Edge Function и получает JWT. | ✅ **Берём.** Нет внешних доменов, нет WebView, переиспользует существующий бот и существующий HS256 JWT contract. |
| B. Telegram Login Widget в WebView | `oauth.telegram.org` через домен, привязанный к боту через BotFather. | Требует домен с DNS-валидацией, WebView + cookie на Android капризен. Лишний путь. |
| C. Свой OAuth-like с email/пароль | — | Нарушает принцип SPEC «никаких отдельных аккаунтов». |
| D. WebView внутри APK, грузим Mini App | Загружаем тот же Web-бандл, JS-мост к `Telegram.WebApp` подделать нельзя. | Не работает — Telegram сам инжектит initData, в чужом WebView его нет. |

Вариант A — это та же модель, что у `@BotFather`, GitHub `gh auth login`, `wrangler login`: «открыли внешний клиент, дождались подтверждения, опросили сервер». Минимум новой инфры.

---

## 3. Высокоуровневая схема

```
Android app                Supabase                       Telegram Bot (aiogram 3)
-----------                --------                       -----------------------
[1] gen link_token (32 B)
[2] POST auth_device_link
        action=create     → INSERT device_link_tokens
                            (token, status='pending',
                             expires_at = now()+5 min)
        ← { token, deep_link: "https://t.me/BOT?start=link_<token>" }

[3] launchUrl(deep_link)
     (открывается Telegram,
      пользователь жмёт START)
                                                          [4] /start link_<token>
                                                              upsert_user(...)
                                                              UPDATE device_link_tokens
                                                                SET status='linked',
                                                                    telegram_user_id=...,
                                                                    user_json=...
                                                              reply: «Готово,
                                                                     вернитесь в HabitFlow»

[5] poll каждые 2 сек:
    POST auth_device_link
         action=poll, token
                          → SELECT device_link_tokens
                            if linked:
                              upsertUser() [та же логика, что в auth_telegram]
                              jwt = signJwt(HS256)
                              UPDATE status='consumed'
                            else if expired: 410
                            else: 202 (ещё ждём)
    ← { jwt, user }

[6] cache jwt + apply session ────► ровно те же RLS-правила, что в Web
```

---

## 4. Архетип проекта (по скилу flutter-ai-dev)

- **Тип:** существующий Flutter Mini App + добавление **второй платформы (Android)** к уже отлаженной кодовой базе.
- **Состояние:** Riverpod (уже выбран). Без переключения на BLoC — это W30.
- **Сеть:** Dio (уже есть). Без http.
- **Локальное хранилище:** `flutter_secure_storage` (уже есть, JWT хранится там). **Это критично** — на Android оно автоматически использует EncryptedSharedPreferences/Keystore (W13 OK).
- **Архитектура:** feature-first, репозиторий → провайдер → экран (без новых слоёв).
- **Уведомления:** через Telegram-бота. Никаких FCM/OneSignal — **нет** новых пакетов, **нет** Firebase-проекта, **нет** google-services.json.

---

## 5. Что меняем в `app/` (Flutter)

### 5.1. pubspec.yaml — добавить
```yaml
url_launcher: ^6.3.1   # открыть tg:// и https://t.me deep link
device_info_plus: ^11.2.0   # для diagnostics (необязательный nice-to-have, можно отложить)
```
**Не добавляем:** firebase_*, flutter_local_notifications, awesome_notifications — уведомления остаются в Telegram-клиенте.

### 5.2. Android-конфигурация (`app/android/`)
- `compileSdk = 35`, `targetSdk = 35`, `minSdk = 24`. (Android 15 — 16 KB page alignment OK, см. предупреждение flutter-ai-dev.)
- `applicationId = "com.habitflow.app"` (зафиксировать с пользователем).
- Подпись релиза: `key.properties` + `habitflow-release.jks`, **обоих в `.gitignore`** (W32). Сейчас в `.gitignore` уже есть `.env` — добавить `key.properties`, `*.jks`, `*.keystore`.
- `AndroidManifest.xml`: **никаких новых intent-filter не нужно** — мы открываем Telegram, не наоборот. `INTERNET` уже есть by default.
- `<queries>` нужно расширить, чтобы `url_launcher` мог проверить наличие Telegram:
  ```xml
  <queries>
    <intent>
      <action android:name="android.intent.action.VIEW"/>
      <data android:scheme="tg"/>
    </intent>
    <intent>
      <action android:name="android.intent.action.VIEW"/>
      <data android:scheme="https" android:host="t.me"/>
    </intent>
  </queries>
  ```
- Proguard-rules: для Dio/secure_storage обычно ничего не нужно, но добавим `keep` для kotlinx-serialization если используется.

### 5.3. Код — новый sub-tree в `lib/features/auth/`

Добавляем строго **внутри существующей feature `auth/`** — это «второй способ входа», не отдельная feature.

```
lib/features/auth/
├── data/
│   ├── auth_repository.dart          ← уже есть, дополняется методом signInWithDeviceLink()
│   ├── auth_providers.dart           ← уже есть, добавляется deviceLinkControllerProvider
│   └── device_link_repository.dart   ← НОВЫЙ: HTTP-обёртка над auth_device_link
├── domain/
│   ├── auth_state.dart               ← уже есть, без правок
│   └── device_link_state.dart        ← НОВЫЙ: sealed класс (Idle / Pending / Linked / Expired / Failed)
└── presentation/
    ├── splash_screen.dart            ← правится: на non-Web рендерит DeviceLinkScreen вместо «outside Telegram» заглушки
    └── device_link_screen.dart       ← НОВЫЙ: CTA «Войти через Telegram» + индикатор ожидания
```

### 5.4. `TelegramService` — расширить
Текущая структура (`telegram_service.dart` + `*_web.dart` + `*_stub.dart`) уже разделена через conditional import. Добавляем:
- На Web: оставляем как есть (`getInitData()` возвращает initData).
- На non-Web: новый метод `openBotDeepLink(String token)` → `url_launcher` запускает `https://t.me/<bot_username>?start=link_<token>`. Telegram-клиент перехватывает.
- Если Telegram не установлен — `canLaunchUrl` вернёт false → показываем диалог с inline-кнопкой «Установить Telegram» (`market://details?id=org.telegram.messenger`).

Имя бота читается из `Env.botUsername` — добавляем новый `--dart-define=BOT_USERNAME=habitflow_bot`.

### 5.5. Новый env-ключ
| Ключ | Обязателен на Android | Default | Назначение |
|---|---|---|---|
| `BOT_USERNAME` | да | — | username бота без `@`, для построения `https://t.me/<x>` |

Добавить в `Env.assertValid()` чек только когда `!kIsWeb` — Web этим ключом не пользуется.

### 5.6. Router (`app_router.dart`) — minimal patch
- На splash: если `!kIsWeb` и нет сохранённой сессии → редирект на `/auth/device-link` (новый GoRoute вне ShellRoute).
- На Web: поведение не меняется — initData есть → старый путь работает.

### 5.7. WATCHDOG-аудит для предстоящих изменений
Прогон ключевых правил из `flutter-ai-dev` skill:

| # | Правило | Как соблюдаем |
|---|---|---|
| W07 | Нет hardcoded URL | `https://t.me/<bot>` строится из `Env.botUsername`. |
| W08 | Нет секретов | `BOT_TOKEN` остаётся серверным, в APK его нет. |
| W11 | Нет TODO/UnimplementedError | План пишется так, чтобы каждый артефакт был полным. |
| W13 | Токены не в SharedPreferences | JWT остаётся в `flutter_secure_storage` (EncryptedSharedPreferences на Android). |
| W15/W16 | Dispose контроллеров / отписки от опроса | Polling реализуется через `Timer.periodic` в `DeviceLinkController` с `dispose()`. Поллинг останавливается при unmount и при terminal-статусе. |
| W22 | Repository → Either/Result | `DeviceLinkRepository.poll()` возвращает sealed `DeviceLinkPollResult` (Pending/Linked/Expired/Failed). |
| W23 | Только `context.go` / `context.push` | Используем go_router как и сейчас. |
| W25 | 4 состояния экрана | `DeviceLinkScreen`: idle / opening / waiting / failed. |
| W26 | `mounted` после await | Поллер хранит `bool _disposed` и проверяет до `state =`. |
| W27 | jsonDecode в try/catch | Все ответы Edge Function декодируются с маппингом в `DeviceLinkFailure`. |
| W30 | Не смешиваем Riverpod и BLoC | Только Riverpod. |

---

## 6. UX-сценарий на Android

```
1. Установил APK → запустил.
2. Splash определяет: !kIsWeb && нет сессии → переход на /auth/device-link.
3. Экран DeviceLinkScreen:
     [Лого HabitFlow]
     «Вход через Telegram»
     «Откроется Telegram. Подтвердите вход, и приложение
      само продолжит работу.»
     [ Войти через Telegram ]   ← primary button
4. Тап → device_link_repository.createToken()
       → telegramService.openBotDeepLink(token)
       → Telegram открылся, /start link_<token>.
5. Экран меняется на «Ожидаем подтверждения от бота…»
     с тонким прогрессом и кнопкой «Открыть Telegram ещё раз».
6. Через ~2-3 сек poll вернёт linked → applySession(jwt) → /today.
7. Failed/Expired: показываем причину + «Попробовать снова» (новый токен).
```

Тексты — двуязычные (RU/EN), новые ключи добавятся в `app_ru.arb` и `app_en.arb` через skill **arb-translate**.

---

## 7. Уведомления на Android — без новой инфры

Текущая схема:
```
pg_cron (минутно) → notification_queue → send_notifications Edge Function
   → POST {bot}:8080/send_due/<secret>
   → bot читает notification_queue + users по user_id
   → bot.send_message(chat_id=users.telegram_user_id)
```

После привязки Android-устройства строка пользователя в `public.users` идентична Web — у неё есть `telegram_user_id`. Бот шлёт сообщение в Telegram → **Telegram сам пушит его** на устройстве (потому что у юзера установлен Telegram-клиент, который мы только что использовали для логина).

То есть:
- **никакого FCM не надо**;
- **никакого фонового сервиса** в нашем APK не надо;
- inline-кнопки `Done` / `Skip` в habit_reminder продолжают работать через `callback_query` (это пока Telegram, не HabitFlow APK);
- кнопка `Открыть приложение` в существующих уведомлениях сейчас рендерится через `WebAppInfo` — она запускает Mini App. Для Android-устройств **она не открывает APK**, она по-прежнему даст веб-Mini App. Это допустимо для первой итерации; deep-link в APK (`habitflow://habit?id=...`) — отдельная задача §10.4.

---

## 8. Edge Function `auth_device_link` (новый)

Лежит рядом с `auth_telegram`: `supabase/functions/auth_device_link/index.ts`.

### 8.1. Контракт

`POST /functions/v1/auth_device_link`

**Создание токена:**
```json
{ "action": "create" }
```
→ `200`
```json
{
  "token": "u8s5...",        // 32 байта base64url
  "deep_link": "https://t.me/habitflow_bot?start=link_u8s5...",
  "expires_at": "2026-05-20T12:05:00Z"
}
```

**Опрос:**
```json
{ "action": "poll", "token": "u8s5..." }
```
→ варианты:
- `200 { "status": "pending" }` — ждём бота.
- `200 { "status": "linked", "jwt": "...", "user": {...} }` — успех, после первой выдачи токен помечается `consumed`.
- `410 { "status": "expired" }` — TTL вышел.
- `404 { "status": "not_found" }` — токен не существует.
- `429` — превышен rate-limit.
- `401 { "status": "consumed" }` — токен уже использован.

### 8.2. Безопасность

- **Token entropy:** 32 случайных байта через `crypto.getRandomValues`, base64url. Не угадывается.
- **TTL:** 5 минут на linking + ещё 60 сек на `poll` после `linked` (чтобы Android успел забрать JWT).
- **One-shot:** при `linked → 200` сразу `UPDATE status='consumed'` и возвращаем JWT. Повторный poll → 401.
- **Rate-limit:** простейший — `request_log_device_link(ip, ts)`-таблица + проверка ≤ 30 запросов за 60 сек на токен/IP. (Или используем нативный Supabase Edge Functions rate-limit, если у проекта он активирован.)
- **Логи:** никогда не пишем `token` целиком — только префикс 6 символов.
- **Constant-time compare** на сравнениях токена.

### 8.3. JWT
**Critically:** функция выпускает JWT **тем же способом**, что и `auth_telegram` (HS256 + `SUPABASE_JWT_SECRET` с fallback на `JWT_SECRET`). Не вводим новый ключ, не вводим RS256 — иначе сломается весь auth-стек (см. memory `project_jwt_hs256_constraint.md`).

Логику `upsertUser` и `signJwt` **выносим в `_shared/auth_utils.ts`**, чтобы обе Edge Function (`auth_telegram` и `auth_device_link`) использовали один и тот же код. Это и борьба с дрейфом, и снижение риска регрессий.

---

## 9. Миграция БД (новая, `0016_device_link_tokens.sql`)

```sql
create table if not exists device_link_tokens (
  token text primary key,
  status text not null default 'pending'
    check (status in ('pending','linked','consumed','expired')),
  telegram_user_id bigint,
  user_json jsonb,
  created_at timestamptz not null default now(),
  linked_at timestamptz,
  consumed_at timestamptz,
  expires_at timestamptz not null
);

create index if not exists device_link_tokens_expires_idx
  on device_link_tokens (expires_at)
  where status in ('pending','linked');

alter table device_link_tokens enable row level security;
-- Никаких user-facing политик: к таблице ходят только service_role
-- (Edge Functions) и бот через прямой Postgres-конн.

-- pg_cron: чистим раз в 10 минут
select cron.schedule(
  'cleanup_device_link_tokens',
  '*/10 * * * *',
  $$ delete from device_link_tokens where expires_at < now() - interval '1 hour' $$
);
```

RLS остаётся enabled и пустой — это «service-only» таблица, и SPEC §3 это разрешает.

---

## 10. Этапы и зависимости

### 10.1. Этап 0 — подготовка (без кода)
1. Подтвердить ТЗ (этот файл).
2. Зарегистрировать `key.properties` в `.gitignore`.
3. Согласовать `applicationId` (предложено `com.habitflow.app`).
4. Согласовать `BOT_USERNAME` для прода и dev.

### 10.2. Этап 1 — backend (Supabase + бот)
Зависимостей со стороны Flutter нет.

1. Миграция `0016_device_link_tokens.sql`.
2. Вынести `upsertUser` / `signJwt` из `auth_telegram/index.ts` в `_shared/auth_utils.ts`.
3. Edge Function `auth_device_link` с действиями `create` и `poll`.
4. **Бот**: handler `/start link_<token>` (см. `bot/integration/androidApp/PLAN.md`).
5. Юнит-тесты:
   - `auth_device_link/test.ts` — happy-path, expired, double-consume, rate-limit.
   - Бот: pytest на парсинг payload `link_<token>` и обновление row.

### 10.3. Этап 2 — Flutter Android
1. `pubspec.yaml`: `url_launcher` + `flutter pub get`.
2. `android/app/build.gradle`: applicationId, sdk-версии, signingConfigs.
3. `android/key.properties.example` (без секретов).
4. `Env.botUsername` + assertValid на mobile.
5. `TelegramService.openBotDeepLink(token)` на non-Web.
6. `DeviceLinkRepository` + `DeviceLinkController` + `DeviceLinkScreen`.
7. Правка `SplashScreen`: на mobile при отсутствии сессии → `/auth/device-link`.
8. Локализация: новые ARB-ключи через skill `arb-translate`.
9. Тесты: widget-test `DeviceLinkScreen` (idle/waiting/error), unit-test `DeviceLinkController` с моком репозитория.
10. **Manual QA**: установить APK, провести через шаги 1–6 §6, убедиться, что Telegram-уведомление прилетает после привязки.

### 10.4. Этап 3 (не сейчас) — deep links обратно в APK
- Зарегистрировать `habitflow://` или App Links на `habitflow.app`.
- В уведомлениях бота заменить `WebAppInfo` на URL, если устройство — APK. Это требует разделения логики (бот пока не знает, на каком устройстве пользователь). Простейший компромисс — две кнопки: «Открыть в браузере» и «Открыть в приложении».

---

## 11. Тестирование

### 11.1. Edge Function
- `deno test` сценарии: create + poll loop, race на double poll, истёкший токен, неизвестный токен.

### 11.2. Бот
- `pytest`: ParseObject в `/start` — проверка регулярки `link_[A-Za-z0-9_-]{32,}`.
- Интеграционно (опционально): запуск aiogram TestBot, отправка фейкового `/start link_TOKEN`.

### 11.3. Android
- `flutter test` для DeviceLinkController с фейковым репозиторием.
- `flutter test --device-id emulator-5554 integration_test/auth_device_link_test.dart`:
  - запуск приложения, тап «Войти через Telegram», подмена `url_launcher` платформенным каналом-фейком, ручная фиксация status=`linked` в БД (или fake-репозиторий), ожидание перехода на `/today`.
- **MANUAL_QA.md** дополнить разделом «Android APK», 7 шагов §6.

### 11.4. Безопасность
- Verify, что `token` не появляется в `logcat` (фильтр `flutter` ни в `info`, ни в `error`).
- Verify, что в release-APK нет строкового литерала `service_role` (Bloaty / `strings`-grep).
- Verify, что polling прекращается при terminal-статусе (нет утечки таймера).

---

## 12. Риски и митигации

| Риск | Митигация |
|---|---|
| Пользователь жмёт «Войти», но Telegram не установлен. | `canLaunchUrl` → диалог «Установите Telegram» с deep-link в Play Store. |
| Пользователь не нажал START в боте. | Token истечёт через 5 мин, экран покажет «Истёкло, попробуйте снова». |
| Race: два устройства параллельно используют один токен. | Token one-shot, `UPDATE ... WHERE status='linked' RETURNING ...`; второй получит 401. |
| JWT signing-key уехал с HS256 на RS256. | План фиксирует «выпускаем тем же `signJwt`, что и `auth_telegram`»; на ревью проверять. (См. memory `project_jwt_hs256_constraint.md`.) |
| `flutter_secure_storage` падает на старых Android (<6). | `minSdk = 24` решает (Android 7.0 минимум). |
| Telegram-уведомления отключены у пользователя в системе. | Не наш контроль; в Profile добавить подсказку «Включите уведомления для Telegram в настройках Android». |
| Брутфорс `poll` на неизвестный токен. | Не страшно: пространство токенов 2^256, плюс rate-limit, плюс TTL. |
| Подмена `auth_device_link` чужим клиентом. | Сама функция доверяет только боту (UPDATE из бота через сервис-роль). Клиент Android никак не может проставить `status=linked`. |

---

## 13. Что НЕ меняется (важно зафиксировать)

- **Web Mini App** работает ровно как сейчас. Тот же `auth_telegram`, тот же splash-flow.
- **Бот** для Web-пользователей работает без изменений; новый branch `/start link_<token>` срабатывает только при наличии payload.
- **JWT-контракт** идентичен: `sub`, `telegram_user_id`, `role`, `aud`, `iat`, `exp`. Никакой клиент-код по RLS трогать не нужно.
- **Структура БД пользователей** не меняется. Новая таблица — служебная, изолированная.

---

## 14. Зафиксированные ответы

| Вопрос | Решение |
|---|---|
| `applicationId` Android-сборки | `com.habitflow.app` ✅ |
| App display name | `Habit Flow` ✅ |
| `BOT_USERNAME` | `habit_flow_app_bot` — один бот на prod и dev ✅ |
| `minSdk` | 24 (Android 7+) ✅ — выбран по умолчанию |
| Стиль ожидания после deep-link | Автоматический poll, 2 сек × 90 попыток (3 мин) ✅ |
| Telegram не установлен — куда вести | Play Store через market://details?id=org.telegram.messenger ✅ |

### Ещё не закрыто (не блокирует имплементацию)

- **Распространение APK**: sideload .apk на старте, Google Play позже — этот выбор финализируем после сборки первого release-APK и ручного QA.

После имплементации Этапа 1 (бэкенд) — продолжаем по `IMPLEMENTATION.md`.
