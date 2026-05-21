<div align="center">

# HabitFlow — Mini App

**Habit tracker · reflection journal · analytics · AI chat — a Flutter Web Telegram Mini App.**

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-0553B1.svg)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[![Try it in Telegram](https://img.shields.io/badge/Try%20it-%40habit__flow__app__bot-26A5E4.svg?logo=telegram&logoColor=white)](https://t.me/habit_flow_app_bot)

**English** · [Русский](README.ru.md)

🤖 **Live bot → [@habit_flow_app_bot](https://t.me/habit_flow_app_bot)**

</div>

> Flutter Web Mini App that runs inside Telegram. It authenticates with `initData`,
> talks to Supabase over PostgREST, and renders the full HabitFlow experience —
> Today, Habits, Journal, Analytics, AI, and Profile. Also ships an Android build
> (login via bot deep-link) from the same codebase. The companion notification bot
> lives in **[habit_flow_bot](https://github.com/zFannur/habit_flow_bot)**.

<!--
📸 Add Mini App screenshots in screenshots/ and uncomment this block.

<p align="center">
  <img src="screenshots/01-today.png"        width="240" alt="Today tab" />
  <img src="screenshots/03-habit-detail.png" width="240" alt="Habit detail with heatmap" />
  <img src="screenshots/05-analytics.png"    width="240" alt="Analytics charts" />
</p>
-->

> 📸 **Screenshots coming soon.**

---

## ✨ What's inside

- **Today** — only habits due now, one-tap done/skip, all-done celebration
- **Habits** — CRUD with emoji / Telegram-photo icons, colors, schedules, swipe-to-archive/delete
- **Habit detail** — calendar heatmap, history, streaks & recovery, anti-habit "days since"
- **Journal** — reflection entries with optional templates
- **Analytics** — completion rate, trends, activity heatmap (`fl_chart` + `table_calendar`)
- **AI** — chat, periodic summaries, and ready-made prompt buttons (OpenRouter, bring your own key)
- **Profile** — settings, AI key, donations (Telegram Stars), about/contact
- **Bilingual** RU + EN, **Material 3** theme overridden from `Telegram.WebApp.themeParams`

---

## 🚀 Getting started

```bash
flutter pub get

flutter run -d chrome --web-port=5173 \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx
```

Release web build:

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=ENV=production
```

Common dev commands:

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # freezed / json / riverpod
flutter gen-l10n                                            # after editing .arb files
```

---

## ⚙️ Environment (`--dart-define`)

`Env.assertValid()` runs in `main.dart` before `runApp` and fails fast with a clear
`StateError` if a required value is missing.

| Key | Required | Default | Purpose |
|---|:--:|---|---|
| `SUPABASE_URL` | ✅ | — | Supabase project URL |
| `SUPABASE_ANON_KEY` | ✅ | — | Supabase public anon key |
| `OPENROUTER_BASE_URL` | — | `https://openrouter.ai/api/v1` | OpenRouter base URL |
| `OPENROUTER_DEFAULT_MODEL` | — | `openai/gpt-oss-120b:free` | default AI model |
| `ENV` | — | `development` | `production` enables strict modes (`Env.isProduction`) |
| `APP_BASE_URL` | — | `https://habitflow.app` | canonical Mini App URL (HTTP-Referer) |
| `BOT_PUBLIC_CHANNEL` | — | `https://t.me/habitflow_dev` | public Telegram channel/chat |
| `OPENROUTER_KEYS_URL` | — | `https://openrouter.ai/keys` | OpenRouter keys dashboard |

> 🔒 The OpenRouter API key is the **user's own**, stored in `flutter_secure_storage`
> (WebCrypto on Web). `BOT_TOKEN` and `SUPABASE_SERVICE_ROLE_KEY` never live here.

---

## 🏗 Architecture

Feature-first. Each feature owns `data/` (models + repository), `domain/` (pure
functions), and `presentation/` (screens + widgets).

```
lib/
├── main.dart, app.dart
├── core/
│   ├── config/        # env, theme
│   ├── routing/       # go_router
│   ├── services/      # supabase, telegram, openrouter, notifications
│   ├── localization/  # .arb + generated
│   └── utils/
├── features/
│   ├── auth/          # splash + initData → JWT
│   ├── habits/        # CRUD, Today, Habits
│   ├── journal/       # reflection journal
│   ├── analytics/     # Analytics tab
│   ├── ai/            # chat, summaries, prompts
│   ├── profile/       # settings, donations
│   └── onboarding/
└── shared/widgets/
```

---

## 📐 Conventions

- **State** — Riverpod, preferably `@riverpod` codegen.
- **Models** — `freezed` + `json_serializable`.
- **Routing** — `go_router`. Deep links `?screen=...&id=...` are required for the bot.
- **Theme** — Material 3, overridden by `Telegram.WebApp.themeParams` via `TelegramService`.
- **Localization** — `AppLocalizations.of(context)!.<key>`. **No hard-coded UI strings.**
- **Telegram Mini App limits** — no background API; habit timers are frontend, resumed from `last_active_at`.
- **Comments** — only "why", never "what the code does".
- **Design** — mockups arrive separately and are copied **1:1**, never interpreted.

---

## 🔐 Security

- `BOT_TOKEN`, `SUPABASE_SERVICE_ROLE_KEY` — **never** on the client.
- `initData` is logged masked only.
- Authorization is server-side `initData` validation. `tg.initDataUnsafe` is for UI
  params (name, avatar) only — never for auth.

---

## 📚 More docs

- **[CLAUDE.md](CLAUDE.md)** — agent guide for this package
- **[PLATFORMS.md](PLATFORMS.md)** · **[PERF.md](PERF.md)** · **[RATE_LIMITS.md](RATE_LIMITS.md)** · **[MANUAL_QA.md](MANUAL_QA.md)**
- **Companion bot** — [habit_flow_bot](https://github.com/zFannur/habit_flow_bot)

---

## 📄 License

[MIT](LICENSE) © 2026 zFannur.
