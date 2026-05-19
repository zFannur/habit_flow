import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/utils/token_counter.dart';

void main() {
  group('TokenCounter.count', () {
    test('returns 0 for null and empty', () {
      expect(TokenCounter.count(null), 0);
      expect(TokenCounter.count(''), 0);
    });

    test('English text is roughly 1 token per 4 chars', () {
      // 40 chars of latin text → ~10 tokens.
      const text = 'The quick brown fox jumps over the lazy.';
      final tokens = TokenCounter.count(text);
      expect(tokens, greaterThanOrEqualTo(9));
      expect(tokens, lessThanOrEqualTo(12));
    });

    test('Russian text is denser — roughly 1 token per 2 chars', () {
      // 40 cyrillic chars → ~20 tokens.
      const text = 'Привет, как дела сегодня у тебя дружище!';
      final tokens = TokenCounter.count(text);
      expect(tokens, greaterThanOrEqualTo(18));
      expect(tokens, lessThanOrEqualTo(22));
    });

    test('Russian costs ~2x more tokens than English of same length', () {
      // Same length, different alphabet.
      final ru = 'абвгдежзий' * 5; // 50 chars
      final en = 'abcdefghij' * 5; // 50 chars
      expect(TokenCounter.count(ru), greaterThan(TokenCounter.count(en)));
      // Не строгий 2x, но как минимум полуторакратно дороже.
      expect(
        TokenCounter.count(ru),
        greaterThan((TokenCounter.count(en) * 1.5).floor()),
      );
    });

    test('countAll sums parts and skips nulls', () {
      expect(
        TokenCounter.countAll(['hello world', null, 'foo']),
        TokenCounter.count('hello world') + TokenCounter.count('foo'),
      );
    });
  });
}
