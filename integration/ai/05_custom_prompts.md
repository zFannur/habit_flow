# Шаг 05 — Пользовательские промпты (добавление/удаление)

**Severity:** 🔴 HIGH · **Время:** 50 мин · **Риск:** высокий

## Проблема

В `prompts_grid_screen.dart` все 14 промптов зашиты в код как статический список `_prompts`. 
Пользователь не может:
1. Добавить свои собственные промпты.
2. Удалить или отредактировать их.
3. Категории и описания также статичны и не локализованы.

## План

### 1. Создать таблицу `ai_prompts` в Supabase (или использовать локальную базу через SharedPreferences/SQLite, если мы хотим сэкономить сетевые запросы)
Для простоты и надежности (а также облачной синхронизации между девайсами) создадим таблицу в Supabase:
```sql
create table public.ai_prompts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  emoji text not null,
  title text not null,
  description text not null,
  category text not null, -- 'analysis', 'emotions', 'growth', 'relapse'
  is_system boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS правила
alter table public.ai_prompts enable row level security;

create policy "Users can view own or system prompts" on public.ai_prompts
  for select using (auth.uid() = user_id or is_system = true);

create policy "Users can insert own prompts" on public.ai_prompts
  for insert with check (auth.uid() = user_id);

create policy "Users can update own prompts" on public.ai_prompts
  for update using (auth.uid() = user_id);

create policy "Users can delete own prompts" on public.ai_prompts
  for delete using (auth.uid() = user_id);
```

### 2. Реализовать репозиторий `AiPromptsRepository`
Создать `lib/features/ai/data/ai_prompts_repository.dart` для работы с таблицей `ai_prompts`.
Пользовательские промпты загружаются из сети, а системные промпты (14 штук) остаются статическими, но сливаются с пользовательскими при выводе в UI. 

### 3. Добавить кнопку «Создать промпт» в `prompts_grid_screen.dart`
- Добавить FloatingActionButton (FAB) на экран промптов.
- При нажатии открывать диалог `CreatePromptDialog` с полями:
  - Emoji (выбор через простой список или emoji picker)
  - Название
  - Описание
  - Категория (выпадающий список)
- Сохранять в репозиторий.

### 4. Добавить удаление промптов
- Обернуть карточки пользовательских промптов в `Dismissible` или добавить иконку корзины на саму карточку.
- Системные промпты защитить от удаления (скрыть иконку удаления).

## Файлы

- **[NEW]** `lib/features/ai/data/ai_prompts_repository.dart`
- **[MODIFY]** `lib/features/ai/presentation/prompts_grid_screen.dart`

## Коммит

```
git commit -m "feat(ai): add custom user prompts support with database sync"
```
