import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/services/onboarding_service.dart';
import '../data/auth_providers.dart';
import '../domain/auth_state.dart';

/// Splash screen: reads Telegram initData, signs in, then redirects.
///
/// The visual loader is kept intentionally minimal — a design pass will
/// replace it with the final branded splash (see design task).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer to the next frame so the widget tree is fully mounted before we
    // call context-dependent navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final telegramService = ref.read(telegramServiceProvider);
    final initData = telegramService.getInitData();

    if (initData.isEmpty) {
      // Outside Telegram — show the stub, nothing to navigate.
      return;
    }

    await ref.read(authStateProvider.notifier).signIn(initData);
    // Router redirect listener (in app_router.dart) picks up the new
    // authState and drives navigation; no explicit context.go needed here.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final telegramService = ref.watch(telegramServiceProvider);

    // Outside-Telegram stub: shown when initData is unavailable.
    if (telegramService.getInitData().isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.telegram, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    l10n.splashOutsideTelegramTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.splashOutsideTelegramDesc,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final authState = ref.watch(authStateProvider);

    if (authState is Failed) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    l10n.splashAuthErrorTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.splashAuthErrorDesc,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _bootstrap,
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Authenticated state: router redirect takes care of navigation.
    // Show loader while signing in or redirecting.
    if (authState is Authenticated) {
      final seen = ref.watch(seenOnboardingProvider);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(seen ? '/today' : '/onboarding');
      });
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
