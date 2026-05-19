# Manual QA Checklist — HabitFlow v1.0

Прогнать перед релизом. Запускать на iOS, Android, Telegram Desktop, Telegram Web.

## Auth

- [ ] `/splash` → initData → `/today` (валидная авторизация работает)
- [ ] первый запуск ведёт на `/onboarding`
- [ ] просроченный JWT → re-auth → `/today`
- [ ] вне Telegram (Chrome без mock) — заглушка с инструкцией
- [ ] выход (`signOut`) → редирект на `/splash`

## Today

- [ ] header показывает дату и сводку `done из total · Streak N 🔥`
- [ ] карточки 4 типов (binary / countable / timed / anti) рендерятся
- [ ] чек binary меняет статус
- [ ] +1 на countable, прогресс-бар обновляется
- [ ] таймер старт/пауза/стоп
- [ ] anti-habit "Удержался" / "Сорвался" + confirm
- [ ] empty state без привычек
- [ ] confetti при all-done (один раз)
- [ ] stack chain отображается ("После: <emoji> <name>")
- [ ] implementation intentions ("в 7:00 в зале")

## Habits (Tab 2)

- [ ] поиск по name (case-insensitive)
- [ ] фильтры All / Active / Archive / категории
- [ ] сортировка (дата / streak / completion rate)
- [ ] empty state filtered.isEmpty
- [ ] создание через wizard (4 шага), валидация name 1..60
- [ ] detail screen: heatmap 90 дней, edit, archive, delete
- [ ] long-press → bottom-sheet (identity, reward, intention)

## Journal

- [ ] лента с counter (total + streak)
- [ ] фильтры по mood (All / This month / Low / High)
- [ ] empty state
- [ ] создание/редактирование с mood/energy slider 1–10
- [ ] вопросы из шаблона
- [ ] 30-я запись → `notification_queue` summary_ready

## Analytics

- [ ] week / month переключатель
- [ ] BarChart completion by day
- [ ] PieChart by category
- [ ] mood line chart
- [ ] top habits секция
- [ ] correlations card (заглушка)
- [ ] weekly review checklist при `?review=1`

## AI

- [ ] settings → ввод ключа → проверка → статус ✓
- [ ] выбор модели из списка
- [ ] 5 стилей (Poet locked если !supporter)
- [ ] чат стримит ответ
- [ ] история сохраняется в `ai_messages`
- [ ] сводки рендерятся (markdown)
- [ ] промпты-кнопки отправляют сообщение
- [ ] privacy disclaimer на первом запуске после ввода ключа
- [ ] 429 → красный баннер
- [ ] empty state без ключа

## Profile

- [ ] аватар (имя из Telegram)
- [ ] supporter badge (если `is_supporter=true`)
- [ ] 11 пунктов меню кликабельны
- [ ] subscreens работают: account, ai-settings, appearance, notifications, donate, reflection-template, privacy, contact, about

## Stars (Donate)

- [ ] открытие donate → выбор 50/150/500 ⭐
- [ ] tap "Поддержать" → `Telegram.WebApp.openInvoice` вызван
- [ ] после оплаты — toast + supporter badge появляется
- [ ] cancel → ничего не меняется
- [ ] Poet style разблокируется

## Bot

- [ ] `/start` создаёт user в `users`, шлёт приветствие
- [ ] habit_reminder в назначенное время
- [ ] callback "Сделано" пишет лог + edit message
- [ ] callback "Пропустить" → status=skipped
- [ ] evening reflection (с linked habit_logs)
- [ ] summary_ready (после Edge fn `generate_summary`)
- [ ] quiet_hours соблюдается (23:00–07:00 → skipped)
- [ ] recovery rule (yesterday missed → softer текст)
- [ ] chain-risk (vчера missed + сегодня pending → "Не пропусти дважды подряд")
- [ ] weekly review (вс 18:00)

## Тема и локализация

- [ ] light / dark / auto переключаются мгновенно
- [ ] выбор сохраняется между запусками
- [ ] `Telegram.WebApp.themeParams` переопределяет тему
- [ ] RU / EN — все тексты переводятся
- [ ] выбор RU/EN сохраняется

## Безопасность

- [ ] неавторизованный запрос отвергается RLS (попытка чтения чужих habits)
- [ ] невалидный initData → 401 от auth_telegram
- [ ] OpenRouter key хранится в secure-storage (не в localStorage plain)
- [ ] `BOT_TOKEN`, `SUPABASE_SERVICE_ROLE_KEY` отсутствуют в bundle (`grep` по `build/web/`)

## Перформанс

- [ ] cold start < 2.5s в Telegram
- [ ] FPS на скролле today ≥ 55
- [ ] нет видимых фризов при загрузке /analytics

## Definition of Done

- [ ] все пункты ✅ на iOS, Android, Telegram Desktop, Telegram Web
- [ ] баги задокументированы в `app/PLATFORMS.md` как known issues
