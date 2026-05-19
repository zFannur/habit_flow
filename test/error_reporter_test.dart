import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/services/error_reporter.dart';

void main() {
  setUp(() => ErrorReporter.instance.clear());

  test('captureException stores reports in buffer', () {
    ErrorReporter.instance.captureException(
      Exception('boom'),
      StackTrace.current,
      context: 'test',
    );
    expect(ErrorReporter.instance.buffer, hasLength(1));
    expect(ErrorReporter.instance.buffer.single.message, contains('boom'));
    expect(ErrorReporter.instance.buffer.single.context, 'test');
  });

  test('exportText returns formatted text with all entries', () {
    ErrorReporter.instance.captureException(Exception('a'), null);
    ErrorReporter.instance.captureException(Exception('b'), null);
    final text = ErrorReporter.instance.exportText();
    expect(text, contains('a'));
    expect(text, contains('b'));
  });

  test('buffer is bounded — old entries get dropped', () {
    for (var i = 0; i < 250; i++) {
      ErrorReporter.instance.captureException(Exception('e$i'), null);
    }
    expect(ErrorReporter.instance.buffer.length, 200);
    expect(ErrorReporter.instance.buffer.first.message, contains('e50'));
    expect(ErrorReporter.instance.buffer.last.message, contains('e249'));
  });
}
