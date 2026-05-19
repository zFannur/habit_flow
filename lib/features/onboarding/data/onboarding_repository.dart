import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../habits/data/habit_model.dart';
import '../../habits/data/habits_providers.dart';
import '../../habits/data/habits_repository.dart';
import '../../habits/domain/habit_type.dart';
import '../../habits/domain/schedule_type.dart';

/// Handles all persistence side-effects of the onboarding flow.
///
/// Exposed through [onboardingRepositoryProvider] so the screen can call it
/// via `ref.read(...)` without touching repositories directly.
class OnboardingRepository {
  OnboardingRepository({
    required HabitsRepository habitsRepository,
    required String userId,
  })  : _habits = habitsRepository,
        _userId = userId;

  final HabitsRepository _habits;
  final String _userId;

  /// Creates habits from a list of [_OnboardingTemplate] slugs.
  ///
  /// Each template is converted to a minimal [HabitModel] (binary type, daily
  /// schedule) and inserted via [HabitsRepository.create]. Failures are
  /// swallowed individually so one bad insert does not block the rest.
  Future<void> createFromTemplates(List<OnboardingTemplate> templates) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final tpl in templates) {
      try {
        final model = HabitModel(
          id: '',
          userId: _userId,
          name: tpl.nameRu,
          type: tpl.isAnti ? HabitType.anti : HabitType.binary,
          emoji: tpl.emoji,
          accentColor: '#3B82F6',
          scheduleType: ScheduleType.daily,
          schedule: const <String, dynamic>{},
          reminderTimes: const <String>[],
          startedAt: today,
          createdAt: now,
          updatedAt: now,
        );
        await _habits.create(model);
      } catch (_) {
        // Best-effort: skip if individual insert fails.
      }
    }
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(
    habitsRepository: ref.watch(habitsRepositoryProvider),
    userId: ref.watch(currentUserIdProvider),
  );
});

// ---------------------------------------------------------------------------
// Onboarding template definitions (mirrors _templates in onboarding_screen)
// ---------------------------------------------------------------------------

class OnboardingTemplate {
  const OnboardingTemplate({
    required this.emoji,
    required this.nameRu,
    required this.nameEn,
    this.isAnti = false,
  });

  final String emoji;
  final String nameRu;
  final String nameEn;
  final bool isAnti;
}

const List<OnboardingTemplate> kOnboardingTemplates = [
  OnboardingTemplate(emoji: '💧', nameRu: 'Пить воду', nameEn: 'Drink water'),
  OnboardingTemplate(
    emoji: '🧘',
    nameRu: 'Медитация',
    nameEn: 'Meditation',
  ),
  OnboardingTemplate(emoji: '🚶', nameRu: 'Прогулка', nameEn: 'Walk'),
  OnboardingTemplate(
    emoji: '🚭',
    nameRu: 'Без курения',
    nameEn: 'No smoking',
    isAnti: true,
  ),
  OnboardingTemplate(emoji: '📚', nameRu: 'Чтение', nameEn: 'Reading'),
  OnboardingTemplate(emoji: '✍️', nameRu: 'Дневник', nameEn: 'Journal'),
  OnboardingTemplate(emoji: '💪', nameRu: 'Спорт', nameEn: 'Exercise'),
  OnboardingTemplate(
    emoji: '🌅',
    nameRu: 'Ранний подъём',
    nameEn: 'Early rise',
  ),
];
