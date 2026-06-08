/// Разбор deep link из bot-уведомлений.
///
/// Бот открывает Mini App ссылками вида `{mini_app_url}?screen=habit&id=...`,
/// `?screen=journal`, `?screen=summary&id=...`, `?screen=analytics&review=1`
/// (см. `bot/src/services/notifications.py`). На Flutter Web с hash-роутингом
/// эти query-параметры лежат в `Uri.base` (search-часть), а НЕ в маршруте
/// go_router — поэтому читаем их отсюда напрямую.
///
/// Снимок query делается один раз при первом обращении: последующая навигация
/// меняет только hash-фрагмент, поэтому search-часть остаётся валидной, но мы
/// фиксируем её, чтобы быть устойчивыми к смене URL-стратегии в будущем.
library;

final Map<String, String> _launchQuery = Uri.base.queryParameters;

/// Целевой маршрут из deep link запуска, либо `null`, если deep link
/// отсутствует или `screen` не распознан.
///
/// Маппинг повторяет контракт бота 1:1:
/// * `habit` + `id`      → `/habits/{id}`
/// * `journal`           → `/journal`
/// * `summary` + `id`    → `/summary/{id}`
/// * `analytics`(+review)→ `/analytics` (`?review=1` при наличии флага)
String? deepLinkInitialRoute() {
  final screen = _launchQuery['screen'];
  if (screen == null || screen.isEmpty) return null;

  final id = _launchQuery['id'];
  final hasId = id != null && id.isNotEmpty;

  switch (screen) {
    case 'habit':
      return hasId ? '/habits/$id' : null;
    case 'journal':
      return '/journal';
    case 'summary':
      return hasId ? '/summary/$id' : null;
    case 'analytics':
      return _launchQuery['review'] == '1' ? '/analytics?review=1' : '/analytics';
    default:
      return null;
  }
}
