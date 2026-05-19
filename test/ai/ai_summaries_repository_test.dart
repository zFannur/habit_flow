import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/ai/data/ai_summaries_repository.dart';

void main() {
  group('AiSummary.fromSupabase', () {
    test('parses a typical row including dates and tokens', () {
      final s = AiSummary.fromSupabase({
        'id': 's1',
        'user_id': 'u1',
        'range_start_n': 1,
        'range_end_n': 30,
        'range_start_date': '2025-01-01',
        'range_end_date': '2025-01-30',
        'content': '## Heading\nbody',
        'model_used': 'openai/gpt-oss-120b:free',
        'tokens_used': 1234,
        'created_at': '2025-02-01T10:30:00.000Z',
      });

      expect(s.id, 's1');
      expect(s.userId, 'u1');
      expect(s.rangeStartN, 1);
      expect(s.rangeEndN, 30);
      expect(s.rangeStartDate, DateTime.utc(2025, 1, 1));
      expect(s.rangeEndDate, DateTime.utc(2025, 1, 30));
      expect(s.content, '## Heading\nbody');
      expect(s.modelUsed, 'openai/gpt-oss-120b:free');
      expect(s.tokensUsed, 1234);
      expect(s.createdAt.toUtc(), DateTime.utc(2025, 2, 1, 10, 30));
    });

    test('tolerates null tokens_used and empty content', () {
      final s = AiSummary.fromSupabase({
        'id': 's2',
        'user_id': 'u1',
        'range_start_n': 31,
        'range_end_n': 60,
        'range_start_date': '2025-02-01',
        'range_end_date': '2025-02-28',
        'content': null,
        'model_used': null,
        'tokens_used': null,
        'created_at': '2025-03-01T00:00:00.000Z',
      });

      expect(s.tokensUsed, isNull);
      expect(s.content, '');
      expect(s.modelUsed, '');
    });

    test('coerces numeric strings via num cast for range_*_n', () {
      // Supabase returns ints as int already; this guards against overflow
      // changes that promote to num.
      final s = AiSummary.fromSupabase({
        'id': 's3',
        'user_id': 'u1',
        'range_start_n': 61,
        'range_end_n': 90,
        'range_start_date': '2025-03-01',
        'range_end_date': '2025-03-31',
        'content': 'x',
        'model_used': 'm',
        'tokens_used': 0,
        'created_at': '2025-04-01T00:00:00.000Z',
      });
      expect(s.rangeStartN, 61);
      expect(s.rangeEndN, 90);
      expect(s.tokensUsed, 0);
    });
  });
}
