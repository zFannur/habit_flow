// Golden regression for the HFErrorState surface.
//
// Renders the four canonical error kinds (network / unauthorized / AI rate
// limit / generic) and locks the pixel output. The widget classifies the
// passed `error` argument via `RepositoryError.from`, so we feed it the
// concrete sealed types directly to make the goldens deterministic.
//
// File must compile cleanly. Goldens are produced via `--update-goldens`
// outside of this file.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/config/theme.dart';
import 'package:habit_flow/core/error/repository_error.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/shared/widgets/hf_error_state.dart';

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
  group('HFErrorState golden', () {
    testWidgets('network error with retry', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_frame(
        HFErrorState(
          error: const RepositoryNetworkError(),
          onRetry: () {},
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(HFErrorState),
        matchesGoldenFile('goldens/error_network.png'),
      );
    });

    testWidgets('unauthorized → re-login', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_frame(
        HFErrorState(
          error: const RepositoryUnauthorizedError(),
          onRelogin: () {},
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(HFErrorState),
        matchesGoldenFile('goldens/error_unauthorized.png'),
      );
    });

    testWidgets('AI rate-limit context with change-model action',
        (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_frame(
        HFErrorState(
          // The classifier looks at the message body for "429"/"rate limit"
          // tokens to surface the AI-limit branch.
          error: RepositoryUnknownError(
            Exception('429 rate limit'),
            message: '429 rate limit hit',
          ),
          isAiContext: true,
          onChangeModel: () {},
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(HFErrorState),
        matchesGoldenFile('goldens/error_ai_limit.png'),
      );
    });

    testWidgets('generic error fallback with retry', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_frame(
        HFErrorState(
          error: RepositoryUnknownError(
            Exception('boom'),
            message: 'something went wrong',
          ),
          onRetry: () {},
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(HFErrorState),
        matchesGoldenFile('goldens/error_generic.png'),
      );
    });
  });
}
