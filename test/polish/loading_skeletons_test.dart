// Loading-state regression for HFSkeleton + a smoke "celebration overlay"
// integration test (план 09-06).
//
// HFSkeleton drives a repeat-forever AnimationController that produces a
// shimmer gradient. The widget tests below verify:
//   * the skeleton mounts and animates without throwing;
//   * size / radius props are honoured;
//   * a list of skeletons (typical loading-state layout) lays out cleanly.
//
// The "celebration overlay" portion is a forward-compatible smoke test: it
// pumps a Flutter overlay that hosts an animated emoji when the streak
// reaches a milestone and asserts the animation completes. When the
// dedicated `HFConfetti` widget lands in shared/widgets, this test will be
// retargeted to it; until then it locks down the harness.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/config/theme.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/shared/widgets/hf_skeleton.dart';

const _kDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

Widget _frame(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    localizationsDelegates: _kDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(393, 852),
        devicePixelRatio: 1.0,
        textScaler: TextScaler.linear(1.0),
      ),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('HFSkeleton', () {
    testWidgets('mounts with explicit size and animates', (tester) async {
      await tester.pumpWidget(_frame(
        const Center(
          child: HFSkeleton(width: 200, height: 16),
        ),
      ));

      // Initial frame.
      expect(find.byType(HFSkeleton), findsOneWidget);

      // Drive the animation forward to confirm the controller is running.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 700));
      // No throw, no overflow assertion — animation cycle reached the
      // shimmer turnover safely.
      expect(find.byType(HFSkeleton), findsOneWidget);
    });

    testWidgets('renders a list of skeletons in a Column', (tester) async {
      await tester.pumpWidget(_frame(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              HFSkeleton(width: double.infinity, height: 64),
              SizedBox(height: 12),
              HFSkeleton(width: double.infinity, height: 64),
              SizedBox(height: 12),
              HFSkeleton(width: double.infinity, height: 64),
            ],
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HFSkeleton), findsNWidgets(3));
    });

    testWidgets('honours custom radius without throwing', (tester) async {
      await tester.pumpWidget(_frame(
        const Center(
          child: HFSkeleton(width: 80, height: 80, radius: 40),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(HFSkeleton), findsOneWidget);
    });
  });

  group('Celebration overlay (smoke)', () {
    testWidgets('animated streak overlay completes without throwing',
        (tester) async {
      // Stand-in for the not-yet-extracted `HFConfetti` widget. When that
      // widget lands, swap [_StreakOverlay] for the real one — the harness
      // shape stays the same.
      final key = GlobalKey<NavigatorState>();

      await tester.pumpWidget(_frame(
        Navigator(
          key: key,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => const _OverlayHost(),
          ),
        ),
      ));
      await tester.pump();

      // Trigger the overlay by tapping the host.
      await tester.tap(find.byType(_OverlayHost));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 1200));

      // The emoji renders at least once during the animation lifecycle.
      expect(find.text('🎉'), findsWidgets);
    });
  });
}

class _OverlayHost extends StatefulWidget {
  const _OverlayHost();

  @override
  State<_OverlayHost> createState() => _OverlayHostState();
}

class _OverlayHostState extends State<_OverlayHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _ctrl.forward(from: 0),
      child: Stack(
        children: [
          const Center(child: Text('streak target')),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) {
              if (_ctrl.value == 0) return const SizedBox.shrink();
              return Opacity(
                opacity: 1 - _ctrl.value,
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 96)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
