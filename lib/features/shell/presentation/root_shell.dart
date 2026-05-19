import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_bottom_tab_bar.dart';

/// Корневая оболочка приложения с 5 вкладками (см. SPEC §4 + design-system.html).
class RootShell extends StatelessWidget {
  const RootShell({super.key, required this.child});

  final Widget child;

  static const _tabRoutes = <String>[
    '/today',
    '/habits',
    '/analytics',
    '/ai',
    '/profile',
  ];

  static const _tabIcons = <IconData>[
    LucideIcons.home,
    LucideIcons.listChecks,
    LucideIcons.barChart3,
    LucideIcons.sparkles,
    LucideIcons.user,
  ];

  int _activeIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final i = _tabRoutes.indexWhere((r) => loc.startsWith(r));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final active = _activeIndex(context);

    final labels = <String>[
      l.navToday,
      l.navHabits,
      l.navAnalytics,
      l.navAi,
      l.navProfile,
    ];

    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: SafeArea(top: true, bottom: false, child: child),
      bottomNavigationBar: HFBottomTabBar(
        items: [
          for (var i = 0; i < _tabRoutes.length; i++)
            HFTabItem(label: labels[i], icon: _tabIcons[i]),
        ],
        activeIndex: active,
        onChanged: (i) => context.go(_tabRoutes[i]),
      ),
    );
  }
}
