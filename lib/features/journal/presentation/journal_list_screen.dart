import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_empty_state.dart';
import '../../../shared/widgets/hf_error_state.dart';
import '../data/journal_entry_model.dart';
import '../data/journal_providers.dart';

class JournalListScreen extends ConsumerStatefulWidget {
  const JournalListScreen({super.key});

  @override
  ConsumerState<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends ConsumerState<JournalListScreen> {
  String _filter = 'all';
  bool _searchOpen = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchQuery = '';
        _searchCtrl.clear();
      }
    });
  }

  List<JournalEntryModel> _applyFilter(List<JournalEntryModel> entries) {
    final now = DateTime.now();
    final q = _searchQuery.trim().toLowerCase();
    return entries.where((e) {
      switch (_filter) {
        case 'month':
          if (!(e.date.year == now.year && e.date.month == now.month)) {
            return false;
          }
        case 'low':
          if (!e.isLowMood) return false;
        case 'high':
          if (!e.isHighMood) return false;
      }
      if (q.isNotEmpty && !e.text.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    final filters = <_FilterDef>[
      _FilterDef('all', l.journalListFilterAll),
      _FilterDef('month', l.journalListFilterMonth),
      _FilterDef('low', l.journalListFilterLowMood),
      _FilterDef('high', l.journalListFilterHighMood),
    ];

    final entriesAsync = ref.watch(journalEntriesProvider);
    final countAsync = ref.watch(journalEntryCountProvider);
    final streak = ref.watch(journalStreakProvider);

    return Container(
      color: c.bgSecondary,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _StaticHeader(
                  searchOpen: _searchOpen,
                  searchController: _searchCtrl,
                  onSearchToggle: _toggleSearch,
                  onSearchChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _CounterCard(
                    countAsync: countAsync,
                    streak: streak,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        for (var i = 0; i < filters.length; i++) ...[
                          _FilterChip(
                            label: filters[i].label,
                            selected: _filter == filters[i].id,
                            onTap: () =>
                                setState(() => _filter = filters[i].id),
                          ),
                          if (i < filters.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              entriesAsync.when(
                data: (entries) {
                  final filtered = _applyFilter(entries);
                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 56),
                        child: Center(
                          child: HFEmptyState(
                            emoji: '📓',
                            title: l.emptyTitleNoEntries,
                            description: l.emptyDescNoEntries,
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _EntryCard(
                        entry: filtered[i],
                        onTap: () =>
                            context.push('/journal/${filtered[i].id}'),
                      ),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: HFErrorState(
                      error: e,
                      onRetry: () => ref.invalidate(journalEntriesProvider),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: _Fab(onTap: () => context.push('/journal/new')),
          ),
        ],
      ),
    );
  }
}

class _StaticHeader extends StatelessWidget {
  const _StaticHeader({
    required this.searchOpen,
    required this.searchController,
    required this.onSearchToggle,
    required this.onSearchChanged,
  });

  final bool searchOpen;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          if (!searchOpen)
            const SizedBox(width: 64)
          else
            const SizedBox(width: 8),
          Expanded(
            child: searchOpen
                ? TextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: onSearchChanged,
                    style: TextStyle(
                      fontSize: 15,
                      color: c.textPrimary,
                      height: 1.2,
                    ),
                    cursorColor: c.accent,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: l.commonSearch,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: c.textTertiary,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      l.journalListTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onSearchToggle,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    searchOpen ? LucideIcons.x : LucideIcons.search,
                    size: 20,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.countAsync, required this.streak});

  final AsyncValue<int> countAsync;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final count = countAsync.valueOrNull ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.border, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      child: Row(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              height: 1,
              letterSpacing: -0.03 * 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.journalListEntriesLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.journalListStreak(streak),
                  style: TextStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rFull),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? c.accent.withValues(alpha: 0.10) : c.card,
            borderRadius: BorderRadius.circular(HFTokens.rFull),
            border: Border.all(
              color: selected ? c.accent : c.border,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? c.accent : c.textSecondary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.onTap});

  final JournalEntryModel entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final preview = entry.text.length > 100
        ? '${entry.text.substring(0, 100)}…'
        : entry.text;
    final mood = entry.mood;
    final gradient = _moodGradient(mood);
    final emoji = _moodEmoji(mood);
    final dateLabel = _formatDate(entry.date);
    final timeLabel = _formatTime(entry.createdAt);

    return Material(
      color: c.card,
      borderRadius: BorderRadius.circular(HFTokens.rLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HFTokens.rLg),
            border: Border.all(color: c.border, width: 1),
            boxShadow: HFTokens.cardShadow(c.shadow),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(HFTokens.rLg),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(gradient: gradient),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      dateLabel,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: c.textPrimary,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      emoji,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  timeLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: c.textTertiary,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            preview,
                            style: TextStyle(
                              fontSize: 13,
                              color: c.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.accent,
      borderRadius: BorderRadius.circular(HFTokens.rFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rFull),
        child: Container(
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(HFTokens.rFull),
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.35),
                offset: const Offset(0, 4),
                blurRadius: 16,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('➕', style: TextStyle(fontSize: 16, height: 1)),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).journalFabLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

LinearGradient _moodGradient(int? mood) {
  if (mood == null) {
    return const LinearGradient(
      colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    );
  }
  if (mood <= 3) {
    return const LinearGradient(
      colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
    );
  }
  if (mood <= 6) {
    return const LinearGradient(
      colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    );
  }
  return const LinearGradient(
    colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
  );
}

String _moodEmoji(int? mood) {
  if (mood == null) return '😐';
  if (mood <= 2) return '😢';
  if (mood <= 4) return '😕';
  if (mood <= 6) return '😐';
  if (mood <= 8) return '😄';
  return '🤩';
}

String _formatDate(DateTime d) {
  const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  const months = [
    'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];
  final wd = weekdays[d.weekday - 1];
  final mo = months[d.month - 1];
  return '${d.day} $mo, $wd';
}

String _formatTime(DateTime dt) {
  final local = dt.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class _FilterDef {
  const _FilterDef(this.id, this.label);
  final String id;
  final String label;
}
