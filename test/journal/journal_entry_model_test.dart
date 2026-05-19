import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/journal/data/journal_entry_model.dart';

void main() {
  group('JournalEntryModel', () {
    final base = JournalEntryModel(
      id: '11111111-1111-1111-1111-111111111111',
      userId: '22222222-2222-2222-2222-222222222222',
      date: DateTime.utc(2026, 5, 7),
      text: 'Hello world',
      mood: 8,
      energy: 6,
      answers: const {'q1': 'A', 'q2': 'B'},
      linkedHabitLogIds: const ['log-1', 'log-2'],
      createdAt: DateTime.utc(2026, 5, 7, 12, 0),
      updatedAt: DateTime.utc(2026, 5, 7, 12, 5),
    );

    test('round-trips through JSON', () {
      final json = base.toJson();
      final restored = JournalEntryModel.fromJson(json);
      expect(restored, equals(base));
    });

    test('fromSupabase parses a typical row', () {
      final row = <String, dynamic>{
        'id': base.id,
        'user_id': base.userId,
        'entry_date': '2026-05-07',
        'free_text': 'Hello world',
        'mood': 8,
        'energy': 6,
        'answers': {'q1': 'A', 'q2': 'B'},
        'created_at': '2026-05-07T12:00:00Z',
        'updated_at': '2026-05-07T12:05:00Z',
      };
      final entry = JournalEntryModel.fromSupabase(row);
      expect(entry.id, base.id);
      expect(entry.userId, base.userId);
      expect(entry.date, DateTime.utc(2026, 5, 7));
      expect(entry.text, 'Hello world');
      expect(entry.mood, 8);
      expect(entry.energy, 6);
      expect(entry.answers, {'q1': 'A', 'q2': 'B'});
      expect(entry.linkedHabitLogIds, isEmpty);
    });

    test('fromSupabase tolerates nullable fields', () {
      final row = <String, dynamic>{
        'id': base.id,
        'user_id': base.userId,
        'entry_date': '2026-05-07',
        'free_text': null,
        'mood': null,
        'energy': null,
        'answers': null,
        'created_at': '2026-05-07T12:00:00Z',
        'updated_at': '2026-05-07T12:05:00Z',
      };
      final entry = JournalEntryModel.fromSupabase(row);
      expect(entry.text, '');
      expect(entry.mood, isNull);
      expect(entry.energy, isNull);
      expect(entry.answers, isNull);
    });

    test('toSupabase strips runtime-only fields and formats date', () {
      final payload = base.toSupabase();
      expect(payload['entry_date'], '2026-05-07');
      expect(payload['free_text'], 'Hello world');
      expect(payload['mood'], 8);
      expect(payload.containsKey('linked_habit_log_ids'), isFalse);
      expect(payload.containsKey('created_at'), isFalse);
      expect(payload.containsKey('updated_at'), isFalse);
    });

    test('isLowMood / isHighMood helpers', () {
      expect(base.copyWith(mood: 3).isLowMood, isTrue);
      expect(base.copyWith(mood: 4).isLowMood, isTrue);
      expect(base.copyWith(mood: 5).isLowMood, isFalse);
      expect(base.copyWith(mood: 7).isHighMood, isTrue);
      expect(base.copyWith(mood: 6).isHighMood, isFalse);
      expect(base.copyWith(mood: null).isLowMood, isFalse);
      expect(base.copyWith(mood: null).isHighMood, isFalse);
    });
  });
}
