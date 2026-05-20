import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/presentation/ai_screen.dart';
import '../../features/ai/presentation/summary_detail_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/auth/data/auth_providers.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/habits/presentation/habit_form_screen.dart';
import '../../features/habits/presentation/habit_detail_screen.dart';
import '../../features/habits/presentation/habits_list_screen.dart';
import '../../features/habits/presentation/today_screen.dart';
import '../../features/journal/presentation/journal_edit_screen.dart';
import '../../features/journal/presentation/journal_list_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/about_screen.dart';
import '../../features/profile/presentation/account_screen.dart';
import '../../features/profile/presentation/ai_settings_screen.dart';
import '../../features/profile/presentation/appearance_settings_screen.dart';
import '../../features/profile/presentation/contact_screen.dart';
import '../../features/profile/presentation/donate_screen.dart';
import '../../features/profile/presentation/notifications_settings_screen.dart';
import '../../features/profile/presentation/privacy_policy_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/reflection_template_screen.dart';
import '../../features/shell/presentation/root_shell.dart';
import '../services/onboarding_service.dart';

/// Маршрутизатор приложения.
/// 5 вкладок: /today, /habits, /analytics, /ai, /profile.
/// Вне ShellRoute: /splash, /onboarding, /habits/new, /habits/:id, /journal/new и т.п.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final seenOnboarding = ref.read(seenOnboardingProvider);
      final location = state.uri.path;

      final onSplash = location == '/splash';
      final onOnboarding = location == '/onboarding';

      if (authState is Authenticated) {
        if (onSplash) {
          return seenOnboarding ? '/today' : '/onboarding';
        }
        return null;
      }

      // Not yet authenticated — stay on splash while signing in.
      if (!onSplash && !onOnboarding) return '/splash';

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/splash'),
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),

      GoRoute(
        path: '/habits/new',
        builder: (_, _) => const HabitFormScreen(),
      ),
      GoRoute(
        path: '/habits/:id/edit',
        builder: (_, state) =>
            HabitFormScreen(habitId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/habits/:id',
        builder: (_, state) =>
            HabitDetailScreen(habitId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/journal/new',
        builder: (_, _) => const JournalEditScreen(),
      ),
      GoRoute(
        path: '/journal/:id',
        builder: (_, state) =>
            JournalEditScreen(entryId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/summary/:id',
        builder: (_, state) =>
            SummaryDetailScreen(summaryId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/donate',
        builder: (_, _) => const DonateScreen(),
      ),
      GoRoute(
        path: '/profile/notifications',
        builder: (_, _) => const NotificationsSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/ai-settings',
        builder: (_, _) => const AiSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/appearance',
        builder: (_, _) => const AppearanceSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/account',
        builder: (_, _) => const AccountScreen(),
      ),
      GoRoute(
        path: '/profile/reflection-template',
        builder: (_, _) => const ReflectionTemplateScreen(),
      ),
      GoRoute(
        path: '/profile/about',
        builder: (_, _) => const AboutScreen(),
      ),
      GoRoute(
        path: '/profile/privacy',
        builder: (_, _) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/profile/contact',
        builder: (_, _) => const ContactScreen(),
      ),

      // Shell с bottom tab bar
      ShellRoute(
        builder: (_, _, child) => RootShell(child: child),
        routes: [
          GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
          GoRoute(path: '/habits', builder: (_, _) => const HabitsListScreen()),
          GoRoute(
            path: '/analytics',
            builder: (_, state) => AnalyticsScreen(
              showWeeklyReview: state.uri.queryParameters['review'] == '1',
            ),
          ),
          GoRoute(path: '/ai', builder: (_, _) => const AiScreen()),
          GoRoute(
            path: '/journal',
            builder: (_, _) => const JournalListScreen(),
          ),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        ],
      ),
    ],
  );
});

/// Notifies [GoRouter.refreshListenable] whenever auth state changes so the
/// redirect logic re-runs automatically.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (_, _) => notifyListeners());
  }
}
