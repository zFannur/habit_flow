import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/features/journal/data/journal_entry_model.dart';
import 'package:habit_flow/features/journal/data/journal_providers.dart';
import 'package:habit_flow/features/journal/presentation/journal_list_screen.dart';

JournalEntryModel _makeEntry({
  required String id,
  required int? mood,
  required DateTime date,
}) {
  return JournalEntryModel(
    id: id,
    userId: 'user-1',
    date: date,
    text: 'Entry $id',
    mood: mood,
    createdAt: date,
    updatedAt: date,
  );
}

Widget _wrap(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  final baseDate = DateTime.utc(2026, 5, 7);

  final entries = [
    _makeEntry(id: 'a', mood: 3, date: baseDate),                          // low
    _makeEntry(id: 'b', mood: 4, date: baseDate.subtract(const Duration(days: 1))),  // low
    _makeEntry(id: 'c', mood: 5, date: baseDate.subtract(const Duration(days: 2))),  // neutral — excluded
    _makeEntry(id: 'd', mood: 8, date: baseDate.subtract(const Duration(days: 3))),  // high — excluded
    _makeEntry(id: 'e', mood: null, date: baseDate.subtract(const Duration(days: 4))), // no mood — excluded
  ];

  List<Override> makeOverrides(List<JournalEntryModel> data) => [
        journalEntriesProvider.overrideWith(
          (_) => Stream.value(data),
        ),
        journalEntryCountProvider.overrideWith(
          (_) async => data.length,
        ),
      ];

  testWidgets('Low mood filter shows only entries with mood <= 4', (tester) async {
    await tester.pumpWidget(_wrap(
      const JournalListScreen(),
      makeOverrides(entries),
    ));
    await tester.pump(); // let stream emit

    // Tap the "Low mood" filter chip.
    await tester.tap(find.text('Low mood'));
    await tester.pump();

    // entries a (mood=3) and b (mood=4) must be visible.
    expect(find.text('Entry a'), findsOneWidget);
    expect(find.text('Entry b'), findsOneWidget);

    // entries c (mood=5), d (mood=8), e (null) must not appear.
    expect(find.text('Entry c'), findsNothing);
    expect(find.text('Entry d'), findsNothing);
    expect(find.text('Entry e'), findsNothing);
  });
}
