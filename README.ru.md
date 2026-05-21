<div align="center">

# HabitFlow — Mini App

**Трекер привычек · дневник рефлексии · аналитика · ИИ-чат — Flutter Web Telegram Mini App.**

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-0553B1.svg)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[![Попробовать в Telegram](https://img.shields.io/badge/Попробовать-%40habit__flow__app__bot-26A5E4.svg?logo=telegram&logoColor=white)](https://t.me/habit_flow_app_bot)

[English](README.md) · **Русский**

🤖 **Живой бот → [@habit_flow_app_bot](https://t.me/habit_flow_app_bot)**

</div>

> Flutter Web Mini App, работающее внутри Telegram. Авторизуется через `initData`,
> общается с Supabase по PostgREST и рендерит весь опыт HabitFlow — Сегодня,
> Привычки, Дневник, Аналитика, ИИ и Профиль. Также есть Android-сборка
> (логин через deep-link бота) на той же кодовой базе. Бот-компаньон с уведомлениями
> живёт в **[habit_flow_bot](https://github.com/zFannur/habit_flow_bot)**.

<!--
📸 Добавьте скриншоты Mini App в screenshots/ и раскомментируйте этот блок.

<p align="center">
  <img src="screenshots/01-today.png"        width="240" alt="Вкладка Сегодня" />
  <img src="screenshots/03-habit-detail.png" width="240" alt="Детали привычки с тепловой картой" />
  <img src="screenshots/05-analytics.png"    width="240" alt="Графики аналитики" />
</p>
-->

> 📸 **Скриншоты скоро будут.**

---

## ✨ Что внутри

- **Сегодня** — только привычки, что пора сделать, отметка в один тап, празднование по завершении
- **Привычки** — CRUD с иконками-эмодзи / фото из Telegram, цвета, расписания, свайп-в-архив/удалить
- **Детали привычки** — тепловая карта-календарь, история, серии и восстановление, «дней без» для анти-привычек
- **Дневник** — записи рефлексии с опциональными шаблонами
- **Аналитика** — процент выполнения, тренды, тепловая карта активности (`fl_chart` + `table_calendar`)
- **ИИ** — чат, периодические сводки и готовые кнопки-промпты (OpenRouter, на своём ключе)
- **Профиль** — настройки, ключ ИИ, донаты (Telegram Stars), о приложении/контакты
- **Двуязычность** RU + EN, тема **Material 3** перекрывается из `Telegram.WebApp.themeParams`

---

## 🚀 Запуск

```bash
flutter pub get

flutter run -d chrome --web-port=5173 \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx
```

Релизная web-сборка:

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=ENV=production
```

Частые команды разработки:

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # freezed / json / riverpod
flutter gen-l10n                                            # после правки .arb
```

---

## ⚙️ Окружение (`--dart-define`)

`Env.assertValid()` вызывается в `main.dart` до `runApp` и валит запуск с понятным
`StateError`, если обязательное значение пустое.

| Ключ | Обязателен | Default | Назначение |
|---|:--:|---|---|
| `SUPABASE_URL` | ✅ | — | URL Supabase-проекта |
| `SUPABASE_ANON_KEY` | ✅ | — | публичный anon-ключ Supabase |
| `OPENROUTER_BASE_URL` | — | `https://openrouter.ai/api/v1` | базовый URL OpenRouter |
| `OPENROUTER_DEFAULT_MODEL` | — | `openai/gpt-oss-120b:free` | модель ИИ по умолчанию |
| `ENV` | — | `development` | `production` включает строгие режимы (`Env.isProduction`) |
| `APP_BASE_URL` | — | `https://habitflow.app` | канонический URL Mini App (HTTP-Referer) |
| `BOT_PUBLIC_CHANNEL` | — | `https://t.me/habitflow_dev` | публичный канал/чат в Telegram |
| `OPENROUTER_KEYS_URL` | — | `https://openrouter.ai/keys` | дашборд ключей OpenRouter |

> 🔒 Ключ OpenRouter — **собственный ключ пользователя**, хранится в `flutter_secure_storage`
> (на Web — поверх WebCrypto). `BOT_TOKEN` и `SUPABASE_SERVICE_ROLE_KEY` здесь не живут.

---

## 🏗 Архитектура

Feature-first. Каждая feature владеет `data/` (модели + репозиторий), `domain/`
(чистые функции) и `presentation/` (экраны + виджеты).

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
│   ├── habits/        # CRUD, Сегодня, Привычки
│   ├── journal/       # дневник рефлексии
│   ├── analytics/     # вкладка Аналитика
│   ├── ai/            # чат, сводки, промпты
│   ├── profile/       # настройки, донаты
│   └── onboarding/
└── shared/widgets/
```

---

## 📐 Соглашения

- **Состояние** — Riverpod, предпочтительно codegen `@riverpod`.
- **Модели** — `freezed` + `json_serializable`.
- **Навигация** — `go_router`. Глубокие ссылки `?screen=...&id=...` нужны для бота.
- **Тема** — Material 3, перекрывается `Telegram.WebApp.themeParams` через `TelegramService`.
- **Локализация** — `AppLocalizations.of(context)!.<key>`. **Никаких хардкоженных строк UI.**
- **Лимиты Telegram Mini App** — нет background API; таймеры привычек — на фронте, продолжаются из `last_active_at`.
- **Комментарии** — только «почему», никогда «что делает код».
- **Дизайн** — макеты приходят отдельно и копируются **1:1**, без интерпретации.

---

## 🔐 Безопасность

- `BOT_TOKEN`, `SUPABASE_SERVICE_ROLE_KEY` — **никогда** на клиенте.
- `initData` логируется только маскированно.
- Авторизация — серверная валидация `initData`. `tg.initDataUnsafe` — только для
  UI-параметров (имя, аватар), не для auth.

---

## 📚 Ещё документация

- **[CLAUDE.md](CLAUDE.md)** — гид для агента по этому пакету
- **[PLATFORMS.md](PLATFORMS.md)** · **[PERF.md](PERF.md)** · **[RATE_LIMITS.md](RATE_LIMITS.md)** · **[MANUAL_QA.md](MANUAL_QA.md)**
- **Бот-компаньон** — [habit_flow_bot](https://github.com/zFannur/habit_flow_bot)

---

## 📄 Лицензия

[MIT](LICENSE) © 2026 zFannur.
