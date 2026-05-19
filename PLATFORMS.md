# Platform Support Matrix — HabitFlow v1.0

Поведение на 5 платформах. Запуск Mini App только из Telegram (initData нужен).

## Матрица

| Платформа | Auth | Notifications | Stars | Темы | Известные баги |
|---|---|---|---|---|---|
| Telegram iOS | ✅ | ✅ через бот | ✅ | TG `themeParams` | safe-area iPhone X+ — учтено через `SafeArea` |
| Telegram Android | ✅ | ✅ через бот | ✅ | TG `themeParams` | back-gesture закрывает Mini App |
| Telegram Desktop | ✅ | ✅ через бот | ✅ | TG `themeParams` | размер окна 1024×768 default — layout testing |
| Telegram Web (web.telegram.org) | ✅ | ✅ через бот | ✅ | TG `themeParams` | клавиатура браузера может перекрывать input |
| Standalone web (Chrome без TG) | ❌ | — | — | system | initData отсутствует — показывается заглушка |

## Тестирование

Прогнать `MANUAL_QA.md` на каждой строке.

## Known issues

(заполнить после прогона QA)

- [ ] iOS: ...
- [ ] Android: ...
- [ ] Desktop: ...
- [ ] Web: ...

## Минимальные версии

| Клиент | Минимальная версия |
|---|---|
| Telegram iOS | 9.0+ |
| Telegram Android | 9.0+ |
| Telegram Desktop | 4.10+ |
| Telegram Web | актуальная (Chrome 100+, Safari 15+) |

## Bot side

Бот работает с любым клиентом Telegram. WebApp deep links поддерживаются на всех клиентах ≥ Bot API 6.4 (Mini Apps).
