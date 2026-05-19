import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../habits/data/habits_providers.dart' as habits_providers;
import '../../journal/data/journal_providers.dart';

/// Slim model of the `public.users` row with supporter-relevant fields.
class UserRow {
  const UserRow({
    required this.id,
    required this.isSupporter,
    this.totalStarsDonated = 0,
    this.firstName,
    this.telegramUsername,
    this.createdAt,
  });

  factory UserRow.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] as String?;
    return UserRow(
      id: json['id'] as String,
      isSupporter: (json['is_supporter'] as bool?) ?? false,
      totalStarsDonated: (json['total_stars_donated'] as num?)?.toInt() ?? 0,
      firstName: json['first_name'] as String?,
      telegramUsername: json['telegram_username'] as String?,
      createdAt: createdRaw != null ? DateTime.tryParse(createdRaw) : null,
    );
  }

  final String id;
  final bool isSupporter;
  final int totalStarsDonated;
  final String? firstName;
  final String? telegramUsername;
  final DateTime? createdAt;
}

/// Aggregated stats for the Profile user card.
class ProfileStats {
  const ProfileStats({
    required this.daysWithApp,
    required this.activeHabits,
    required this.maxStreak,
  });

  final int daysWithApp;
  final int activeHabits;
  final int maxStreak;
}

/// Computed stats: days since signup, count of active habits, longest streak.
/// Re-derives from existing providers (habitsStreamProvider + userRowProvider)
/// so it stays in sync without extra fetches.
final profileStatsProvider = Provider<ProfileStats>((ref) {
  final user = ref.watch(userRowProvider).valueOrNull;
  final habits = ref.watch(habits_providers.habitsStreamProvider).valueOrNull
      ?? const [];

  final activeHabits = habits.where((h) => h.endedAt == null).length;

  final daysWithApp = user?.createdAt == null
      ? 0
      : DateTime.now().toUtc().difference(user!.createdAt!.toUtc()).inDays
          .clamp(0, 1 << 30);

  // Walk per-habit streaks via existing streakProvider — it already
  // accounts for schedule type and partial logs.
  var maxStreak = 0;
  for (final h in habits) {
    final s = ref.watch(habits_providers.streakProvider(h.id));
    if (s > maxStreak) maxStreak = s;
  }

  return ProfileStats(
    daysWithApp: daysWithApp,
    activeHabits: activeHabits,
    maxStreak: maxStreak,
  );
});

/// Realtime stream of the current user's `public.users` row.
///
/// Re-emits whenever `is_supporter` or other columns change — for example,
/// after a successful Telegram Stars payment invalidates this provider.
final userRowProvider = StreamProvider<UserRow>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);

  return client
      .from('users')
      .stream(primaryKey: ['id'])
      .eq('id', userId)
      .map((rows) {
        if (rows.isEmpty) {
          return UserRow(id: userId, isSupporter: false);
        }
        return UserRow.fromJson(rows.first);
      });
});

