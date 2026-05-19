import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_service.dart';

const _kSeenOnboarding = 'seen_onboarding';

/// Returns true if the user has already completed the onboarding flow.
final seenOnboardingProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_kSeenOnboarding) ?? false;
});

/// Callable action to mark onboarding as completed.
final markOnboardingSeenProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_kSeenOnboarding, true);
    // ignore: unused_result — invalidation happens via router rebuild
    ref.invalidate(seenOnboardingProvider);
  };
});
