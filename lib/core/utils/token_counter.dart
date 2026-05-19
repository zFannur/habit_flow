/// Грубая эвристика для подсчёта токенов LLM-моделей.
///
/// Точный счёт требует tokenizer-а (tiktoken / SentencePiece), что для
/// клиента-Flutter невыгодно по размеру бандла. Нам нужна только защита
/// от переполнения context-окна в `PromptBuilder`, поэтому достаточно
/// простой средней оценки:
///
/// - английский текст: ~ 1 токен / 4 символа
/// - русский (кириллица занимает 2+ BPE-токена на букву): ~ 1 токен / 2 символа
/// - смешанный: компромисс ~ 1 токен / 3 символа
///
/// Реализация: считаем долю кириллицы и интерполируем между двумя
/// крайностями. Это всё ещё эвристика, но она различает RU и EN, как
/// и просит SPEC §7.4.
class TokenCounter {
  const TokenCounter._();

  /// Минимальный делитель, ниже которого мы не опускаемся (защита от
  /// деления на ноль на пустых строках).
  static const double _minCharsPerToken = 1.5;

  /// Возвращает оценку количества токенов в [text].
  ///
  /// Возвращает 0 для пустой / null-строки.
  static int count(String? text) {
    if (text == null || text.isEmpty) return 0;

    final ratio = _cyrillicRatio(text);
    // RU: 2 chars/token, EN: 4 chars/token. Линейная интерполяция.
    final charsPerToken = 4.0 - 2.0 * ratio;
    final divisor = charsPerToken < _minCharsPerToken
        ? _minCharsPerToken
        : charsPerToken;
    final tokens = text.length / divisor;
    return tokens.ceil();
  }

  /// Сумма токенов по списку строк.
  static int countAll(Iterable<String?> parts) {
    var total = 0;
    for (final p in parts) {
      total += count(p);
    }
    return total;
  }

  /// Доля кириллических букв среди буквенно-цифровых символов.
  /// Знаки пунктуации/пробелы игнорируются — они присутствуют в обоих
  /// языках в близких пропорциях.
  static double _cyrillicRatio(String text) {
    var letters = 0;
    var cyrillic = 0;
    for (final code in text.codeUnits) {
      // Базовые латинские буквы.
      final isLatin =
          (code >= 0x0041 && code <= 0x005A) ||
          (code >= 0x0061 && code <= 0x007A);
      // Cyrillic + Cyrillic Supplement (U+0400..U+04FF, U+0500..U+052F).
      final isCyrillic = code >= 0x0400 && code <= 0x052F;
      if (isLatin) {
        letters++;
      } else if (isCyrillic) {
        letters++;
        cyrillic++;
      }
    }
    if (letters == 0) return 0.0;
    return cyrillic / letters;
  }
}
