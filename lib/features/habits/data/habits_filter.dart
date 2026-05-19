import '../domain/habit_status.dart';
import '../domain/habit_type.dart';
import 'habit_model.dart';

/// Which status bucket is shown in Tab 2.
enum HabitsStatusFilter { all, active, archive }

/// Sort order for the habits list.
enum HabitsSortOrder {
  /// Newest first (default).
  byCreated,

  /// Descending streak (longest streak at the top).
  byStreak,

  /// Descending completion rate (highest rate at the top).
  byRate,
}

/// Pure filter + sort logic for the habits list screen.
/// Kept dependency-free so it can be unit-tested without Flutter/Riverpod.
class HabitsFilter {
  const HabitsFilter({
    this.statusFilter = HabitsStatusFilter.all,
    this.categoryFilter,
    this.query = '',
    this.sortOrder = HabitsSortOrder.byCreated,
  });

  final HabitsStatusFilter statusFilter;

  /// `null` means "all categories". Non-null matches [HabitModel.category].
  final String? categoryFilter;

  final String query;
  final HabitsSortOrder sortOrder;

  HabitsFilter copyWith({
    HabitsStatusFilter? statusFilter,
    Object? categoryFilter = _sentinel,
    String? query,
    HabitsSortOrder? sortOrder,
  }) {
    return HabitsFilter(
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter:
          categoryFilter == _sentinel ? this.categoryFilter : categoryFilter as String?,
      query: query ?? this.query,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  // -------------------------------------------------------------------------

  /// Applies [statusFilter], [categoryFilter] and [query] to [habits],
  /// then sorts the result by [sortOrder].
  ///
  /// [streakFor] and [rateFor] are resolver callbacks so the caller can
  /// provide pre-computed per-habit values without this class depending on
  /// Riverpod providers directly.
  List<HabitModel> apply(
    List<HabitModel> habits, {
    int Function(String habitId)? streakFor,
    int Function(String habitId)? rateFor,
  }) {
    final q = query.toLowerCase();

    var result = habits.where((h) {
      // Status bucket.
      switch (statusFilter) {
        case HabitsStatusFilter.all:
          break;
        case HabitsStatusFilter.active:
          if (h.status != HabitStatus.active) return false;
        case HabitsStatusFilter.archive:
          if (h.status != HabitStatus.archived) return false;
      }

      // Category.
      if (categoryFilter != null && h.category != categoryFilter) return false;

      // Text search.
      if (q.isNotEmpty && !h.name.toLowerCase().contains(q)) return false;

      return true;
    }).toList();

    // Sort.
    switch (sortOrder) {
      case HabitsSortOrder.byCreated:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case HabitsSortOrder.byStreak:
        if (streakFor != null) {
          result.sort((a, b) => streakFor(b.id).compareTo(streakFor(a.id)));
        }
      case HabitsSortOrder.byRate:
        if (rateFor != null) {
          result.sort((a, b) => rateFor(b.id).compareTo(rateFor(a.id)));
        }
    }

    return result;
  }

  /// Unique category labels extracted from [habits], sorted alphabetically.
  static List<String> categoriesFrom(List<HabitModel> habits) {
    final seen = <String>{};
    for (final h in habits) {
      if (h.category != null && h.category!.isNotEmpty) {
        seen.add(h.category!);
      }
    }
    return seen.toList()..sort();
  }

  /// Count how many habits from [habits] pass the status filter only
  /// (ignores query + category). Used to populate chip badges.
  static int countForStatus(
    List<HabitModel> habits,
    HabitsStatusFilter status,
  ) {
    return habits.where((h) {
      switch (status) {
        case HabitsStatusFilter.all:
          return true;
        case HabitsStatusFilter.active:
          return h.status == HabitStatus.active;
        case HabitsStatusFilter.archive:
          return h.status == HabitStatus.archived;
      }
    }).length;
  }
}

// Private sentinel so copyWith can distinguish "null passed" from "not passed".
const _sentinel = Object();

// ---------------------------------------------------------------------------
// Helpers to infer type-badge display data from HabitModel.
// ---------------------------------------------------------------------------

extension HabitModelBadge on HabitModel {
  /// Badge text for the type, used on the list card.
  /// Localisation-independent short label (resolved in the widget layer via
  /// AppLocalizations).
  String get typeBadgeKey {
    switch (type) {
      case HabitType.binary:
        return 'binary';
      case HabitType.countable:
        return 'countable';
      case HabitType.timed:
        return 'timed';
      case HabitType.anti:
        return 'anti';
    }
  }
}
