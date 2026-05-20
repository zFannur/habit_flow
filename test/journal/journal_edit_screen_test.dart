import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/config/theme.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/core/services/locale_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_flow/core/errors/result.dart';
import 'package:habit_flow/features/journal/data/journal_entry_model.dart';
import 'package:habit_flow/features/journal/data/journal_providers.dart';
import 'package:habit_flow/features/journal/data/journal_repository.dart';
import 'package:habit_flow/features/journal/presentation/journal_edit_screen.dart';
import 'package:habit_flow/features/habits/data/habits_providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Shared SupabaseClient created once at module level — before FakeAsync kicks
// in — so GoTrueClient timers don't leak into testWidgets' FakeAsync harness.
// ---------------------------------------------------------------------------

final _sharedClient = SupabaseClient(
  'https://example.supabase.co',
  'anon',
  httpClient: MockClient.streaming((req, _) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode('[]')),
      200,
      headers: {'content-type': 'application/json'},
    );
  }),
);

// ---------------------------------------------------------------------------
// Fake repository — overrides all async methods; reuses _sharedClient so no
// new GoTrueClient timers are created per test.
// ---------------------------------------------------------------------------

class _FakeRepo extends JournalRepository {
  _FakeRepo({this.seeded})
      : super(client: _sharedClient, userId: _kUserId);

  final JournalEntryModel? seeded;
  final List<JournalEntryModel> upserted = [];

  @override
  Stream<List<JournalEntryModel>> watchAll() =>
      Stream.value(seeded != null ? [seeded!] : []);

  @override
  AppTask<JournalEntryModel> upsert(JournalEntryModel entry) {
    upserted.add(entry);
    return TaskEither.of(entry);
  }

  @override
  AppTask<int> totalCount() {
    return TaskEither.of(seeded != null ? 1 : 0);
  }
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _kUserId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const _kEntryId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

JournalEntryModel _makeEntry({
  String text = 'Existing text',
  int mood = 5,
  int energy = 4,
}) =>
    JournalEntryModel(
      id: _kEntryId,
      userId: _kUserId,
      date: DateTime.utc(2026, 5, 7),
      text: text,
      mood: mood,
      energy: energy,
      createdAt: DateTime.utc(2026, 5, 7, 10),
      updatedAt: DateTime.utc(2026, 5, 7, 10),
    );

// ---------------------------------------------------------------------------
// Widget helpers
// ---------------------------------------------------------------------------

const _kDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _kLocales = [Locale('ru'), Locale('en')];

List<Override> _overrides(_FakeRepo repo) => [
      journalRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWithValue(_kUserId),
      journalEntriesProvider.overrideWith(
        (_) => Stream.value(repo.seeded != null ? [repo.seeded!] : []),
      ),
      sharedPreferencesProvider.overrideWithValue(_prefs),
      habitsForDayProvider.overrideWith((ref, date) => const AsyncValue.data([])),
    ];

/// Simple wrap — no Navigator stack; good for render assertions.
Widget _wrap(Widget child, _FakeRepo repo) {
  return ProviderScope(
    overrides: _overrides(repo),
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('ru'),
      localizationsDelegates: _kDelegates,
      supportedLocales: _kLocales,
      home: child,
    ),
  );
}

/// Pushable wrap — screen pushed via Navigator so pop() has a route to pop.
Widget _wrapPushable(Widget screen, _FakeRepo repo) {
  return ProviderScope(
    overrides: _overrides(repo),
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('ru'),
      localizationsDelegates: _kDelegates,
      supportedLocales: _kLocales,
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(ctx).push(
              MaterialPageRoute<void>(builder: (_) => screen),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

late SharedPreferences _prefs;

void main() {
  // Force _sharedClient to initialize before FakeAsync wraps any test,
  // otherwise GoTrueClient's timers are created inside FakeAsync and leak.
  setUpAll(() async {
    // Accessing _sharedClient here triggers its lazy initializer outside
    // of any individual test's FakeAsync zone.
    expect(_sharedClient, isNotNull);
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  group('JournalEditScreen — new entry', () {
    testWidgets('renders save button and text fields', (tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(_wrap(const JournalEditScreen(), repo));
      await tester.pump();

      expect(find.text('Сохранить'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('tapping save calls repo.upsert then pops screen',
        (tester) async {
      final repo = _FakeRepo();

      await tester.pumpWidget(_wrapPushable(const JournalEditScreen(), repo));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Сохранить'), findsOneWidget);

      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      expect(repo.upserted, hasLength(1));
      expect(repo.upserted.first.userId, _kUserId);
      // Screen was popped — save button is no longer visible.
      expect(find.text('Сохранить'), findsNothing);
    });
  });

  group('JournalEditScreen — existing entry', () {
    testWidgets('loads entry from stream and pre-fills free-text field',
        (tester) async {
      final entry = _makeEntry(text: 'Loaded note', mood: 8, energy: 3);
      final repo = _FakeRepo(seeded: entry);

      await tester.pumpWidget(
          _wrap(JournalEditScreen(entryId: _kEntryId), repo));
      await tester.pumpAndSettle();

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      final mainField = fields.firstWhere(
        (f) => f.controller?.text == 'Loaded note',
        orElse: () => throw TestFailure('Free-text field not pre-filled'),
      );
      expect(mainField.controller?.text, 'Loaded note');
    });

    testWidgets('upsert is called with the original entry id on save',
        (tester) async {
      final entry = _makeEntry(text: 'Old text');
      final repo = _FakeRepo(seeded: entry);

      await tester.pumpWidget(
          _wrapPushable(JournalEditScreen(entryId: _kEntryId), repo));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      expect(repo.upserted, hasLength(1));
      expect(repo.upserted.first.id, _kEntryId);
    });
  });
}
