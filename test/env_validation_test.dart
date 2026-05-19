import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/config/env.dart';

void main() {
  group('Env.assertValid', () {
    test('throws StateError when SUPABASE_URL is empty', () {
      // По умолчанию тесты запускаются без --dart-define=SUPABASE_URL,
      // поэтому Env.supabaseUrl пустой и assertValid должен упасть.
      expect(Env.supabaseUrl, isEmpty);
      expect(
        Env.assertValid,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('SUPABASE_URL'),
          ),
        ),
      );
    });

    test('isProduction defaults to false', () {
      expect(Env.isProduction, isFalse);
      expect(Env.environment, 'development');
    });
  });
}
