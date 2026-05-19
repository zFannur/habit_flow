# Performance Budgets — HabitFlow v1.0

Целевые метрики и инструкции замера.

## Бюджеты

| Метрика | Цель | Замер |
|---|---|---|
| web bundle (gzip) | < 1.5 MB | `du -sh build/web/main.dart.js.gz` |
| cold start (Telegram) | < 2.5 s | DevTools Network → load complete |
| первый paint (FP) | < 1.0 s | Lighthouse "First Paint" |
| largest contentful paint (LCP) | < 2.5 s | Lighthouse |
| FPS на скролле `/today` | ≥ 55 | Chrome DevTools → Performance recorder |
| FPS на скролле `/analytics` | ≥ 55 | то же |
| Memory peak | < 150 MB | DevTools Memory → Heap snapshot |

## Замер

```powershell
cd app
flutter build web --release --no-tree-shake-icons `
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=<anon> `
  --dart-define=ENV=production
gzip -k build/web/main.dart.js
ls -lh build/web/main.dart.js.gz
```

Затем загрузить `build/web/` на CDN или localhost:8000 через `python -m http.server` и открыть в Telegram Desktop.

## Текущие замеры (заполнить перед релизом)

| Метрика | Цель | Факт | Дата |
|---|---|---|---|
| web bundle gzip | < 1.5 MB | TBD | TBD |
| cold start | < 2.5 s | TBD | TBD |
| FP | < 1.0 s | TBD | TBD |
| LCP | < 2.5 s | TBD | TBD |
| FPS today | ≥ 55 | TBD | TBD |
| FPS analytics | ≥ 55 | TBD | TBD |
| Memory peak | < 150 MB | TBD | TBD |

## Оптимизации (если бюджет нарушен)

- Tree-shake icons: убрать `--no-tree-shake-icons` если кастомных Lucide icons нет в runtime.
- Lazy-load `/analytics` (graphs library `fl_chart` тяжёлый): GoRoute lazy builder.
- Reduce `flutter_chat_ui` если не используется — заменить на самодельный.
- Skeleton placeholders вместо CircularProgressIndicator (уже сделано в 09-03).
- Compress images (если есть в `assets/`).
