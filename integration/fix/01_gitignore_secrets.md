# Шаг 01 — W32: защитить секреты в `.gitignore`

**Severity:** 🔴 CRITICAL · **Время:** 1 минута · **Риск:** нулевой.

## Проблема

`app/.gitignore` не игнорирует `.env`, `*.env`, `key.properties`, `*.jks`.
Если кто-то положит `app/.env` (как уже сделано в `bot/.env` с `BOT_TOKEN`),
файл уйдёт в публичный репо `zFannur/habit_flow` при следующем `git add .`.

## Что менять

### Файл: `app/.gitignore`

В конец (перед или после блока `# Local dev artifacts`) дописать:

```gitignore
# Secrets — никогда не коммитим
.env
.env.*
!.env.example
key.properties
*.jks
*.keystore
*.p12
*.mobileprovision
```

Замечания:
- `.env.*` ловит `.env.local`, `.env.production` и т.п.
- `!.env.example` оставляет шаблон в репо (полезно для онбординга).
- `.jks`/`.keystore`/`.p12` — на случай если когда-нибудь соберёшь нативные
  Android/iOS варианты Mini App.

## Валидация

```powershell
cd app

# 1. Создай тестовый .env и убедись, что git его не видит
echo "FAKE=value" | Out-File .env
git status --short | Select-String '.env'   # должно быть пусто
git check-ignore -v .env                    # должно показать .gitignore:LINE

# 2. Проверь, что .env.example не игнорируется (если положишь его)
echo "FAKE=" | Out-File .env.example
git status --short | Select-String '.env.example'  # должно показать как untracked

# 3. Удали тестовые
del .env, .env.example
```

## Коммит

```powershell
git add .gitignore
git commit -m "chore(app): ignore .env / *.jks / key.properties (W32)"
```
