import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/ai/data/openrouter_client.dart';
import 'package:habit_flow/features/ai/data/prompt_builder.dart';
import 'package:habit_flow/features/habits/data/habit_log_model.dart';
import 'package:habit_flow/features/habits/data/habit_model.dart';
import 'package:habit_flow/features/habits/domain/habit_log_status.dart';
import 'package:habit_flow/features/habits/domain/habit_type.dart';
import 'package:habit_flow/features/habits/domain/schedule_type.dart';
import 'package:habit_flow/features/journal/data/journal_entry_model.dart';

class _FakeClient extends OpenRouterClient {
  _FakeClient({this.summary = 'compressed summary'})
      : super(apiKey: 'test-key');

  final String summary;
  int calls = 0;

  @override
  Stream<String> chatCompletion({
    required List<OpenRouterMessage> messages,
    String? model,
    bool stream = true,
  }) {
    calls++;
    final controller = StreamController<String>();
    controller.add(summary);
    controller.close();
    return controller.stream;
  }
}

HabitModel _habit({
  required String id,
  String name = 'Read',
  String? identityStatement,
  String? stackAfterHabitId,
}) {
  final now = DateTime.utc(2025, 1, 1);
  return HabitModel(
    id: id,
    userId: 'u1',
    name: name,
    type: HabitType.binary,
    scheduleType: ScheduleType.daily,
    startedAt: now,
    createdAt: now,
    updatedAt: now,
    identityStatement: identityStatement,
    stackAfterHabitId: stackAfterHabitId,
  );
}

HabitLogModel _log({
  required String id,
  required String habitId,
  required DateTime date,
}) {
  return HabitLogModel(
    id: id,
    userId: 'u1',
    habitId: habitId,
    date: date,
    status: HabitLogStatus.done,
    createdAt: date,
  );
}

JournalEntryModel _journal({
  required String id,
  required DateTime date,
  required String text,
}) {
  return JournalEntryModel(
    id: id,
    userId: 'u1',
    date: date,
    text: text,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  group('PromptBuilder.build', () {
    test('builds a minimal prompt for empty history and context', () async {
      final client = _FakeClient();
      final builder = PromptBuilder(client: client);
      const user = PromptUser(id: 'u1', name: 'Nova', language: 'en');

      final messages = await builder.build(
        user: user,
        context: const PromptContext(),
        history: const [],
        newMessage: 'Hi',
      );

      // 2 system blocks (style + user profile) + 1 user message.
      expect(messages.length, 3);
      expect(messages[0].role, 'system');
      expect(messages[0].content, contains('HabitFlow'));
      expect(messages[1].role, 'system');
      expect(messages[1].content, contains('Nova'));
      expect(messages.last.role, 'user');
      expect(messages.last.content, 'Hi');
      expect(client.calls, 0); // no compression needed
    });

    test('includes habits, logs, journal and last summary as system blocks',
        () async {
      final client = _FakeClient();
      final builder = PromptBuilder(client: client);
      const user = PromptUser(id: 'u1', language: 'ru');
      final h1 = _habit(id: 'h1', name: 'Чтение');
      final ctx = PromptContext(
        habits: [h1],
        recentLogs: [
          _log(id: 'l1', habitId: 'h1', date: DateTime.utc(2025, 1, 5)),
        ],
        recentJournal: [
          _journal(
            id: 'j1',
            date: DateTime.utc(2025, 1, 5),
            text: 'Сегодня было неплохо.',
          ),
        ],
        lastSummary: 'Last 30 days: stable streaks.',
      );

      final messages = await builder.build(
        user: user,
        context: ctx,
        history: const [],
        newMessage: 'Что ты думаешь?',
      );

      // style + user + summary + logs + journal + new user msg = 6
      expect(messages.length, 6);
      expect(messages[2].content, contains('Last 30 days'));
      expect(messages[3].content, contains('Чтение'));
      expect(messages[3].content, contains('done'));
      expect(messages[4].content, contains('Сегодня было неплохо'));
    });

    test('truncates long journal entries to 500 chars', () async {
      final client = _FakeClient();
      final builder = PromptBuilder(client: client);
      const user = PromptUser(id: 'u1');
      final longText = 'x' * 1200;
      final ctx = PromptContext(
        recentJournal: [
          _journal(id: 'j1', date: DateTime.utc(2025, 1, 5), text: longText),
        ],
      );

      final messages = await builder.build(
        user: user,
        context: ctx,
        history: const [],
        newMessage: 'q',
      );
      final journalBlock =
          messages.firstWhere((m) => m.content.contains('journal entries'));
      // Block must contain a truncation marker and not the full 1200 x's.
      expect(journalBlock.content, contains('…'));
      expect(journalBlock.content.length, lessThan(longText.length));
    });

    test('keeps only last 20 messages of history', () async {
      final client = _FakeClient();
      final builder = PromptBuilder(client: client);
      const user = PromptUser(id: 'u1');
      final history = List<ChatMessage>.generate(
        50,
        (i) =>
            ChatMessage(role: i.isEven ? 'user' : 'assistant', content: 'msg$i'),
      );

      final messages = await builder.build(
        user: user,
        context: const PromptContext(),
        history: history,
        newMessage: 'now',
      );

      // 2 system blocks + 20 history + 1 new user = 23
      expect(messages.length, 23);
      // First non-system message must be msg30 (history[30]).
      final firstHistory = messages.firstWhere((m) => m.role != 'system');
      expect(firstHistory.content, 'msg30');
      expect(client.calls, 0);
    });

    test('includes identity statements in user system block when present',
        () async {
      final client = _FakeClient();
      final builder = PromptBuilder(client: client);
      const user = PromptUser(id: 'u1', name: 'Nova', language: 'ru');
      final h1 = _habit(
        id: 'h1',
        name: 'Чтение',
        identityStatement: 'читает каждый день',
      );
      final h2 = _habit(
        id: 'h2',
        name: 'Бег',
        identityStatement: 'бегает по утрам',
      );
      final ctx = PromptContext(habits: [h1, h2]);

      final messages = await builder.build(
        user: user,
        context: ctx,
        history: const [],
        newMessage: 'Hi',
      );

      // index 1 is user profile system block (style is index 0).
      final userBlock = messages[1].content;
      expect(userBlock, contains('Identity statements:'));
      expect(
        userBlock,
        contains('"Я становлюсь человеком, который читает каждый день"'),
      );
      expect(
        userBlock,
        contains('"Я становлюсь человеком, который бегает по утрам"'),
      );
      expect(userBlock, contains('Если пользователь упоминает прогресс'));
    });

    test('includes Stacks block describing chains A → B', () async {
      final client = _FakeClient();
      final builder = PromptBuilder(client: client);
      const user = PromptUser(id: 'u1', name: 'Nova', language: 'ru');
      final coffee = _habit(id: 'h1', name: 'Кофе');
      final journal = _habit(
        id: 'h2',
        name: 'Дневник',
        stackAfterHabitId: 'h1',
      );
      final ctx = PromptContext(habits: [coffee, journal]);

      final messages = await builder.build(
        user: user,
        context: ctx,
        history: const [],
        newMessage: 'Hi',
      );
      final userBlock = messages[1].content;
      expect(userBlock, contains('Stacks:'));
      expect(userBlock, contains('Кофе → Дневник'));
    });

    test('omits Stacks block when no habit references another', () async {
      final client = _FakeClient();
      final builder = PromptBuilder(client: client);
      const user = PromptUser(id: 'u1', language: 'ru');
      final h1 = _habit(id: 'h1', name: 'Чтение');
      final h2 = _habit(id: 'h2', name: 'Бег');
      final ctx = PromptContext(habits: [h1, h2]);

      final messages = await builder.build(
        user: user,
        context: ctx,
        history: const [],
        newMessage: 'Hi',
      );
      for (final m in messages) {
        expect(m.content, isNot(contains('Stacks:')));
      }
    });

    test('omits identity block when no habit has a statement', () async {
      final client = _FakeClient();
      final builder = PromptBuilder(client: client);
      const user = PromptUser(id: 'u1', language: 'ru');
      // Mix of null and empty/whitespace — none should leak in.
      final h1 = _habit(id: 'h1', name: 'Чтение');
      final h2 = _habit(id: 'h2', name: 'Бег', identityStatement: '');
      final h3 = _habit(id: 'h3', name: 'Йога', identityStatement: '   ');
      final ctx = PromptContext(habits: [h1, h2, h3]);

      final messages = await builder.build(
        user: user,
        context: ctx,
        history: const [],
        newMessage: 'Hi',
      );

      for (final m in messages) {
        expect(m.content, isNot(contains('Identity statements:')));
        expect(m.content, isNot(contains('Я становлюсь человеком')));
      }
    });

    test('triggers compression when history blows past token budget',
        () async {
      final client = _FakeClient(summary: 'tiny summary');
      // Tiny budget so even a couple long messages overflow.
      final builder = PromptBuilder(
        client: client,
        tokenBudget: 200,
        keepRecentMessages: 2,
      );
      const user = PromptUser(id: 'u1');

      // 100 messages, each ~500 chars → way above 200 tokens.
      final history = List<ChatMessage>.generate(
        100,
        (i) => ChatMessage(role: 'user', content: 'word ' * 100),
      );

      final messages = await builder.build(
        user: user,
        context: const PromptContext(),
        history: history,
        newMessage: 'newest',
      );

      expect(client.calls, greaterThanOrEqualTo(1));
      // After compression, expect to find a system block with the summary.
      final hasSummary = messages.any(
        (m) =>
            m.role == 'system' &&
            m.content.contains('Earlier chat summary'),
      );
      expect(hasSummary, isTrue);
      // Last message must still be the new user reply.
      expect(messages.last.role, 'user');
      expect(messages.last.content, 'newest');
    });
  });
}
