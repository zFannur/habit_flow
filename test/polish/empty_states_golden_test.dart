// Golden regression for the HFEmptyState surface.
//
// Renders the canonical empty-state shape (emoji 72 / title 18-700 /
// description 14 lh1.6 / optional CTA) for the most common payloads on the
// HabitFlow screens (no habits / no entries / no summaries) and locks the
// pixel output behind `matchesGoldenFile`.
//
// File must compile cleanly. The golden PNGs themselves are produced by
// `flutter test --update-goldens` outside of this file's scope; absence of
// the PNG simply makes the assertion fail at run-time without breaking
// `flutter analyze`.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/config/theme.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/shared/widgets/hf_button.dart';
import 'package:habit_flow/shared/widgets/hf_empty_state.dart';

const _kDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

Widget _frame(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    localizationsDelegates: _kDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(393, 852),
        devicePixelRatio: 1.0,
        textScaler: TextScaler.linear(1.0),
      ),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('HFEmptyState golden', () {
    testWidgets('no habits — emoji + title + description + CTA', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_frame(
        Builder(builder: (ctx) {
          final l = AppLocalizations.of(ctx);
          return HFEmptyState(
            emoji: '🌱',
            title: l.emptyTitleNoHabits,
            description: l.emptyDescNoHabits,
            action: HFButton(
              label: l.commonCreateHabit,
              onPressed: () {},
            ),
          );
        }),
      ));
      await tester.pump();

      await expectLater(
        find.byType(HFEmptyState),
        matchesGoldenFile('goldens/empty_no_habits.png'),
      );
    });

    testWidgets('no journal entries', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_frame(
        Builder(builder: (ctx) {
          final l = AppLocalizations.of(ctx);
          return HFEmptyState(
            emoji: '📓',
            title: l.emptyTitleNoEntries,
            description: l.emptyDescNoEntries,
            action: HFButton(
              label: l.emptyActionNoEntries,
              onPressed: () {},
            ),
          );
        }),
      ));
      await tester.pump();

      await expectLater(
        find.byType(HFEmptyState),
        matchesGoldenFile('goldens/empty_no_entries.png'),
      );
    });

    testWidgets('no AI summaries — has secondary action', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_frame(
        Builder(builder: (ctx) {
          final l = AppLocalizations.of(ctx);
          return HFEmptyState(
            emoji: '✨',
            title: l.emptyTitleNoSummaries,
            description: l.emptyDescNoSummaries(4),
            secondaryAction: HFButton(
              label: l.emptyActionNoSummaries,
              variant: HFButtonVariant.ghost,
              onPressed: () {},
            ),
          );
        }),
      ));
      await tester.pump();

      await expectLater(
        find.byType(HFEmptyState),
        matchesGoldenFile('goldens/empty_no_summaries.png'),
      );
    });
  });
}
