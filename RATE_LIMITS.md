# Rate Limits — HabitFlow v1.0

Лимиты внешних сервисов и наша стратегия их не превышать.

## Лимиты

| Сервис | Limit | Что делаем |
|---|---|---|
| OpenRouter free `gpt-oss-120b:free` | 20 RPM, 200 RPD | 429 → красный баннер с CTA "Подождать / Сменить модель" |
| OpenRouter free других моделей | варьируется | то же поведение, юзер видит баннер |
| Supabase free Edge Functions | 500K invocations/month | один user ~ 5K invocations/мес → 100 active users комфортно |
| Supabase free DB connections | 60 concurrent | подключение через connection pool в Edge Functions |
| pg_cron `send_due_notifications` | 1/min | один INSERT/SELECT за тик |
| Telegram Bot API | 30 msgs/sec broadcast | bot batching ≤ 30 за раз с 100ms между |

## UI handling 429 (OpenRouter)

Реализовано в `06-04 chat`:
- `DioException(response.statusCode == 429)` → `chatState.rateLimited = true`
- `chat_screen.dart` показывает баннер "Лимит на сегодня исчерпан"
- `HFErrorState` (09-02) с `isAiContext: true` показывает CTA "Поменять модель"

## Edge Function backoff

`Retry-After` заголовок от OpenRouter — уважаем, не ретраим внутри Edge Function (только пробрасываем 429 на клиент).

## Bot batching

`bot/src/jobs/send_due.py` обрабатывает batch уведомлений последовательно с `asyncio.sleep(0.05)` между каждым `notify_user` — потолок ~20 msgs/sec, безопасно ниже Telegram лимита 30.

## Тесты

- `app/test/ai/chat_controller_test.dart` — мок 429 → `rateLimited == true`.
- `app/integration_test/ai_flow_test.dart` сценарий 5 — баннер показан.

## Мониторинг

- Sentry events с `tag: rate_limited` → видно если юзеры массово упираются.
- Supabase Dashboard → Functions → invocations chart.
