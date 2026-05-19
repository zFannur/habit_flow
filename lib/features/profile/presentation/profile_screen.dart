import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../data/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _gold = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldBg = isDark
        ? const Color(0x24F59E0B)
        : const Color(0x1AF59E0B);
    final goldBorder = isDark
        ? const Color(0x4DF59E0B)
        : const Color(0x40F59E0B);

    return ColoredBox(
      color: c.bgSecondary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _UserCard(goldBg: goldBg, goldBorder: goldBorder),
          ),
          _SectionLabel(text: l.profileSectionBasic),
          _MenuGroup(
            rows: [
              _MenuRowData(
                emoji: '📓',
                label: l.profileMenuJournal,
                iconBg: const Color(0x1FF59E0B),
                onTap: () => context.go('/journal'),
              ),
              _MenuRowData(
                emoji: '👤',
                label: l.profileMenuAccount,
                iconBg: const Color(0x1F3B82F6),
                onTap: () => context.push('/profile/account'),
              ),
            ],
          ),
          _SectionLabel(text: l.profileSectionSettings),
          _MenuGroup(
            rows: [
              _MenuRowData(
                emoji: '✨',
                label: l.profileMenuAiSettings,
                iconBg: const Color(0x1FA855F7),
                onTap: () => context.push('/profile/ai-settings'),
              ),
              _MenuRowData(
                emoji: '🔔',
                label: l.profileMenuNotifications,
                iconBg: const Color(0x1FF59E0B),
                onTap: () => context.push('/profile/notifications'),
              ),
              _MenuRowData(
                emoji: '🎨',
                label: l.profileMenuAppearance,
                iconBg: const Color(0x1F3B82F6),
                onTap: () => context.push('/profile/appearance'),
              ),
              _MenuRowData(
                emoji: '📓',
                label: l.profileMenuReflectionTemplate,
                iconBg: const Color(0x1F10B981),
                onTap: () => context.push('/profile/reflection-template'),
              ),
            ],
          ),
          _SectionLabel(text: l.profileSectionSupport),
          _MenuGroup(
            rows: [
              _MenuRowData(
                emoji: '💎',
                label: l.profileMenuDonate,
                iconBg: const Color(0x24F59E0B),
                onTap: () => context.push('/profile/donate'),
              ),
              _MenuRowData(
                emoji: 'ℹ️',
                label: l.profileMenuAbout,
                iconBg: const Color(0x1F3B82F6),
                onTap: () => context.push('/profile/about'),
              ),
              _MenuRowData(
                emoji: '📜',
                label: l.profileMenuPrivacy,
                iconBg: const Color(0x1F6B7280),
                onTap: () => context.push('/profile/privacy'),
              ),
              _MenuRowData(
                emoji: '✉️',
                label: l.profileMenuContact,
                iconBg: const Color(0x1F10B981),
                onTap: () => context.push('/profile/contact'),
              ),
            ],
          ),
          const _DangerSectionLabel(),
          _MenuGroup(
            rows: [
              _MenuRowData(
                emoji: '🗑️',
                label: l.profileMenuDeleteAccount,
                iconBg: const Color(0x1AEF4444),
                danger: true,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

void _confirmDeleteAccount(BuildContext context) {
  final c = HFColors.of(context);
  final l = AppLocalizations.of(context);
  showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        l.profileDeleteAccountTitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
      ),
      content: Text(
        l.profileDeleteAccountMessage,
        style: TextStyle(
          fontSize: 14,
          color: c.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: Text(
            l.commonCancel,
            style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogCtx).pop();
            // TODO: вызов Edge Function delete_account (см. SPEC §3).
          },
          child: Text(
            l.commonDelete,
            style: TextStyle(color: c.danger, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _UserCard extends ConsumerWidget {
  const _UserCard({required this.goldBg, required this.goldBorder});

  final Color goldBg;
  final Color goldBorder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    // Resolve all derived values defensively so a stream/provider throw
    // can't blank the whole Profile screen.
    UserRow? user;
    try {
      user = ref.watch(userRowProvider).valueOrNull;
    } catch (e, st) {
      debugPrint('userRowProvider read failed: $e\n$st');
      user = null;
    }
    final isSupporter = user?.isSupporter ?? false;
    final firstName = user?.firstName?.trim() ?? '';
    final tgUsername = user?.telegramUsername?.trim() ?? '';
    final displayName = firstName.isNotEmpty
        ? firstName
        : (tgUsername.isNotEmpty ? tgUsername : '—');
    String initial = '·';
    try {
      if (displayName.isNotEmpty) {
        initial = displayName.characters.first.toUpperCase();
      }
    } catch (_) {
      initial = '·';
    }
    final usernameLabel = tgUsername.isNotEmpty ? '@$tgUsername' : '';
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x596366F1),
                  offset: Offset(0, 4),
                  blurRadius: 20,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.02 * 34,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              letterSpacing: -0.02 * 22,
              height: 1.15,
            ),
          ),
          if (usernameLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              usernameLabel,
              style: TextStyle(
                fontSize: 14,
                color: c.textTertiary,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (isSupporter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: goldBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: goldBorder, width: 1),
              ),
              child: Text(
                l.profileBadgeSupporter,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ProfileScreen._gold,
                  letterSpacing: 0.01 * 12,
                  height: 1,
                ),
              ),
            ),
          if (isSupporter) const SizedBox(height: 4),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.border, width: 1)),
            ),
            child: Builder(
              builder: (ctx) {
                ProfileStats stats;
                try {
                  stats = ref.watch(profileStatsProvider);
                } catch (e, st) {
                  debugPrint('profileStatsProvider read failed: $e\n$st');
                  stats = const ProfileStats(
                    daysWithApp: 0,
                    activeHabits: 0,
                    maxStreak: 0,
                  );
                }
                return Row(
                  children: [
                    _StatCol(
                      value: '${stats.daysWithApp}',
                      label: l.profileStatsDaysWithApp,
                    ),
                    _StatCol(
                      value: '${stats.activeHabits}',
                      label: l.profileStatsActiveHabits,
                      border: true,
                    ),
                    _StatCol(
                      value: '🔥 ${stats.maxStreak}',
                      label: l.profileStatsStreak,
                      border: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({
    required this.value,
    required this.label,
    this.border = false,
  });

  final String value;
  final String label;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: border
              ? Border(left: BorderSide(color: c.border, width: 1))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                letterSpacing: -0.03 * 20,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: c.textTertiary,
                fontWeight: FontWeight.w500,
                height: 1.3,
                letterSpacing: 0.01 * 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.07 * 11,
          color: c.textTertiary,
          height: 1,
        ),
      ),
    );
  }
}

class _DangerSectionLabel extends StatelessWidget {
  const _DangerSectionLabel();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        l.profileSectionDanger,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.07 * 11,
          color: c.danger.withValues(alpha: 0.7),
          height: 1,
        ),
      ),
    );
  }
}

class _MenuRowData {
  const _MenuRowData({
    required this.emoji,
    required this.label,
    required this.iconBg,
    this.danger = false,
    this.onTap,
  });

  final String emoji;
  final String label;
  final Color iconBg;
  final bool danger;
  final VoidCallback? onTap;
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.rows});

  final List<_MenuRowData> rows;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: c.shadow,
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++)
              _MenuRow(data: rows[i], isLast: i == rows.length - 1),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.data, required this.isLast});

  final _MenuRowData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.card,
      child: InkWell(
        onTap: data.onTap,
        highlightColor: c.bgTertiary,
        splashColor: c.bgTertiary,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: data.danger
                          ? const Color(0x1AEF4444)
                          : data.iconBg,
                      borderRadius: BorderRadius.circular(10),
                      border: data.danger
                          ? Border.all(
                              color: const Color(0x26EF4444),
                              width: 1,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      data.emoji,
                      style: const TextStyle(fontSize: 18, height: 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: data.danger ? c.danger : c.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (!data.danger)
                    _Chevron(color: c.textTertiary),
                ],
              ),
            ),
            if (!isLast)
              Positioned(
                left: 64,
                right: 0,
                bottom: 0,
                child: Container(height: 1, color: c.border),
              ),
          ],
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(7, 13),
      painter: _ChevronPainter(color: color),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(1, 1)
      ..lineTo(6, 6.5)
      ..lineTo(1, 12);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
