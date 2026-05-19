import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/ai/domain/style_prompts.dart';

void main() {
  group('AiStyle.fromWire', () {
    test('round-trips every enum value', () {
      for (final s in AiStyle.values) {
        expect(AiStyle.fromWire(s.wireName), s);
      }
    });

    test('falls back to coach for unknown / null', () {
      expect(AiStyle.fromWire(null), AiStyle.coach);
      expect(AiStyle.fromWire(''), AiStyle.coach);
      expect(AiStyle.fromWire('mentor'), AiStyle.coach);
      expect(AiStyle.fromWire('FRIEND'), AiStyle.coach);
    });

    test('only Poet requires supporter', () {
      for (final s in AiStyle.values) {
        expect(s.requiresSupporter, s == AiStyle.poet);
      }
    });
  });

  group('StylePrompts.systemPrompt', () {
    test('every style × {ru, en} returns a non-empty prompt', () {
      const langs = ['ru', 'en'];
      for (final lang in langs) {
        for (final style in AiStyle.values) {
          final prompt = StylePrompts.systemPrompt(style, lang);
          expect(prompt.trim().isNotEmpty, true,
              reason: '${style.wireName}/$lang must be non-empty');
          // Sanity: at least 5 lines, per task spec ("5-15 lines each").
          expect(prompt.split('\n').length, greaterThanOrEqualTo(5),
              reason: '${style.wireName}/$lang too short');
        }
      }
    });

    test('appends the privacy/topic suffix in the right language', () {
      final ru = StylePrompts.systemPrompt(AiStyle.coach, 'ru');
      expect(ru, contains('ВАЖНО'));
      expect(ru, contains('русском'));

      final en = StylePrompts.systemPrompt(AiStyle.coach, 'en');
      expect(en, contains('IMPORTANT'));
      expect(en, contains('English'));
    });

    test('unknown language falls back to English', () {
      final fr = StylePrompts.systemPrompt(AiStyle.buddy, 'fr');
      expect(fr, contains('IMPORTANT'));
      expect(fr, contains('English'));
    });

    test('different styles produce different prompts', () {
      final coach = StylePrompts.systemPrompt(AiStyle.coach, 'en');
      final sergeant = StylePrompts.systemPrompt(AiStyle.sergeant, 'en');
      final buddy = StylePrompts.systemPrompt(AiStyle.buddy, 'en');
      final sage = StylePrompts.systemPrompt(AiStyle.sage, 'en');
      final poet = StylePrompts.systemPrompt(AiStyle.poet, 'en');

      final all = {coach, sergeant, buddy, sage, poet};
      expect(all.length, 5, reason: 'all five styles must be unique');
    });
  });
}
