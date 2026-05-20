import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_toggle.dart';

/// Экран настроек уведомлений (см. docs/design/notifications-settings.html).
/// Копируется 1:1: Telegram-баннер, секция вечерней рефлексии, тихие часы,
/// выбор звука, превью уведомления и редкие уведомления.
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _reflectionOn = true;
  int _reflHour = 21;
  int _reflMin = 30;

  bool _quietOn = false;
  int _quietFromH = 23;
  int _quietFromM = 0;
  int _quietToH = 7;
  int _quietToM = 0;

  String _sound = 'on';

  bool _weeklyOn = true;
  bool _aiSummaryOn = true;
  bool _recoveryOn = true;

  static const _tgBlue = Color(0xFF2AABEE);

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: Column(
        children: [
          _Header(onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _TelegramBanner(),
                  const SizedBox(height: 16),
                  _Section(
                    label: l.notificationsReflectionSection,
                    child: _CardGroup(
                      children: [
                        _ToggleRow(
                          title: l.notificationsReflectionToggle,
                          value: _reflectionOn,
                          onChanged: (v) => setState(() => _reflectionOn = v),
                          showBottomBorder: _reflectionOn,
                        ),
                        if (_reflectionOn)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TimePicker(
                                  hour: _reflHour,
                                  minute: _reflMin,
                                  large: true,
                                  onChange: (h, m) => setState(() {
                                    _reflHour = h;
                                    _reflMin = m;
                                  }),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Text(
                                    l.notificationsReflectionHint,
                                    style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.5, fontSize: 12.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    label: l.notificationsQuietHoursSection,
                    child: _CardGroup(
                      children: [
                        _ToggleRow(
                          title: l.notificationsQuietToggle,
                          value: _quietOn,
                          onChanged: (v) => setState(() => _quietOn = v),
                          showBottomBorder: _quietOn,
                        ),
                        if (_quietOn)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            child: Text(
                                              l.notificationsQuietFrom,
                                              style: context.tt.labelSmall!.copyWith(color: c.textTertiary),
                                            ),
                                          ),
                                          _TimePicker(
                                            hour: _quietFromH,
                                            minute: _quietFromM,
                                            onChange: (h, m) => setState(() {
                                              _quietFromH = h;
                                              _quietFromM = m;
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        0,
                                        14,
                                      ),
                                      child: Text(
                                        '—',
                                        style: context.tt.headlineSmall!.copyWith(color: c.textTertiary),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            child: Text(
                                              l.notificationsQuietTo,
                                              style: context.tt.labelSmall!.copyWith(color: c.textTertiary),
                                            ),
                                          ),
                                          _TimePicker(
                                            hour: _quietToH,
                                            minute: _quietToM,
                                            onChange: (h, m) => setState(() {
                                              _quietToH = h;
                                              _quietToM = m;
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Text(
                                    l.notificationsQuietHint,
                                    style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.5, fontSize: 12.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    label: l.notificationsSoundSection,
                    child: _CardGroup(
                      children: [
                        _SoundRow(
                          title: l.notificationsSoundOn,
                          subtitle: l.notificationsSoundOnSubtitle,
                          muted: false,
                          selected: _sound == 'on',
                          onTap: () => setState(() => _sound = 'on'),
                          showBottomBorder: true,
                        ),
                        _SoundRow(
                          title: l.notificationsSoundOff,
                          subtitle: l.notificationsSoundOffSubtitle,
                          muted: true,
                          selected: _sound == 'off',
                          onTap: () => setState(() => _sound = 'off'),
                          showBottomBorder: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    label: l.notificationsPreviewSection,
                    child: const _NotificationPreview(),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    label: l.notificationsRareSection,
                    child: _CardGroup(
                      children: [
                        _RareNotifRow(
                          emoji: '📅',
                          iconBg: _weeklyOn
                              ? const Color(0x1A3B82F6)
                              : c.bgSecondary,
                          title: l.notificationsWeeklyTitle,
                          subtitle: l.notificationsWeeklySubtitle,
                          value: _weeklyOn,
                          onChanged: (v) => setState(() => _weeklyOn = v),
                          showBottomBorder: true,
                        ),
                        _RareNotifRow(
                          emoji: '✨',
                          iconBg: _aiSummaryOn
                              ? const Color(0x1AA855F7)
                              : c.bgSecondary,
                          title: l.notificationsAiSummaryTitle,
                          subtitle: l.notificationsAiSummarySubtitle,
                          value: _aiSummaryOn,
                          onChanged: (v) => setState(() => _aiSummaryOn = v),
                          showBottomBorder: true,
                        ),
                        _RareNotifRow(
                          emoji: '🔄',
                          iconBg: _recoveryOn
                              ? const Color(0x1AF59E0B)
                              : c.bgSecondary,
                          title: l.notificationsRecoveryTitle,
                          subtitle: l.notificationsRecoverySubtitle,
                          value: _recoveryOn,
                          onChanged: (v) => setState(() => _recoveryOn = v),
                          showBottomBorder: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(HFTokens.rSm),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 6, 4),
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 24,
                    color: c.accent,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l.notificationsTitle,
                style: context.tt.headlineSmall!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 20, fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TelegramBanner extends StatelessWidget {
  const _TelegramBanner();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x4D2AABEE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x1F2AABEE),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const _TelegramLogo(size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.notificationsTelegramBanner,
                  style: context.tt.titleSmall!.copyWith(color: c.textPrimary, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  l.notificationsTelegramDesc,
                  style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.55, fontSize: 12.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TelegramLogo extends StatelessWidget {
  const _TelegramLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TelegramLogoPainter(),
    );
  }
}

class _TelegramLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final bg = Paint()..color = const Color(0xFF2AABEE);
    canvas.drawCircle(
      Offset(12 * s, 12 * s),
      12 * s,
      bg,
    );
    final paper = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(5.5 * s, 11.8 * s)
      ..relativeLineTo(11.2 * s, -4.4 * s)
      ..relativeCubicTo(0.5 * s, -0.2 * s, 0.9 * s, 0.1 * s, 0.8 * s, 0.6 * s)
      ..relativeLineTo(-1.9 * s, 9 * s)
      ..relativeCubicTo(-0.1 * s, 0.5 * s, -0.5 * s, 0.7 * s, -0.9 * s, 0.4 * s)
      ..lineTo(12 * s, 14.9 * s)
      ..relativeLineTo(-1.7 * s, 1.7 * s)
      ..relativeCubicTo(-0.2 * s, 0.2 * s, -0.4 * s, 0.3 * s, -0.7 * s, 0.3 * s)
      ..relativeLineTo(0.3 * s, -2.8 * s)
      ..relativeLineTo(5.4 * s, -4.9 * s)
      ..relativeCubicTo(0.2 * s, -0.2 * s, 0 * s, -0.3 * s, -0.3 * s, -0.1 * s)
      ..lineTo(7.6 * s, 13.4 * s)
      ..lineTo(5.3 * s, 12.7 * s)
      ..relativeCubicTo(-0.5 * s, -0.2 * s, -0.5 * s, -0.5 * s, 0.2 * s, -0.9 * s)
      ..close();
    canvas.drawPath(path, paper);
  }

  @override
  bool shouldRepaint(covariant _TelegramLogoPainter oldDelegate) => false;
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Text(
            label.toUpperCase(),
            style: context.tt.labelSmall!.copyWith(color: c.textTertiary, letterSpacing: 0.08 * 11),
          ),
        ),
        child,
      ],
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.showBottomBorder,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: c.border, width: 1))
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.3),
            ),
          ),
          const SizedBox(width: 12),
          HFToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.hour,
    required this.minute,
    required this.onChange,
    this.large = false,
  });

  final int hour;
  final int minute;
  final void Function(int h, int m) onChange;
  final bool large;

  String _fmt(int n) => n.toString().padLeft(2, '0');

  Future<void> _open(BuildContext context) async {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    int draftH = hour;
    int draftM = minute;
    final result = await showDialog<(int, int)?>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setLocal) {
            return Dialog(
              backgroundColor: c.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _PickerColumn(
                            label: 'ч',
                            values: List.generate(24, (i) => i),
                            selected: draftH,
                            onSelect: (v) => setLocal(() => draftH = v),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            ':',
                            style: context.tt.headlineMedium!.copyWith(color: c.textTertiary),
                          ),
                        ),
                        Expanded(
                          child: _PickerColumn(
                            label: 'мин',
                            values: const [
                              0,
                              5,
                              10,
                              15,
                              20,
                              25,
                              30,
                              35,
                              40,
                              45,
                              50,
                              55,
                            ],
                            selected: draftM,
                            onSelect: (v) => setLocal(() => draftM = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx2).pop(null),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              side: BorderSide(color: c.border, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: c.textSecondary,
                              textStyle: context.tt.titleSmall,
                            ),
                            child: Text(l.commonCancel),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(ctx2).pop((draftH, draftM)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              backgroundColor: c.accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: context.tt.titleSmall,
                            ),
                            child: Text(l.commonDone),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      onChange(result.$1, result.$2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final padH = large ? 18.0 : 14.0;
    final padV = large ? 14.0 : 10.0;
    final radius = large ? 14.0 : 12.0;
    final fontSize = large ? 28.0 : 22.0;

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        decoration: BoxDecoration(
          color: c.bgSecondary,
          border: Border.all(color: c.border, width: 1.5),
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.clock, size: 16, color: c.accent),
            const SizedBox(width: 8),
            Text(
              '${_fmt(hour)}:${_fmt(minute)}',
              style: context.tt.labelLarge!.copyWith(color: c.textPrimary, letterSpacing: -0.02 * fontSize),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  const _PickerColumn({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final List<int> values;
  final int selected;
  final ValueChanged<int> onSelect;

  String _fmt(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, letterSpacing: 0.06 * 10, fontWeight: FontWeight.w700, fontSize: 10.0),
          ),
        ),
        SizedBox(
          height: 140,
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final v in values)
                  GestureDetector(
                    onTap: () => onSelect(v),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected == v
                            ? const Color(0x1A3B82F6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _fmt(v),
                        style: context.tt.titleMedium!.copyWith(color: selected == v ? c.accent : c.textPrimary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SoundRow extends StatelessWidget {
  const _SoundRow({
    required this.title,
    required this.subtitle,
    required this.muted,
    required this.selected,
    required this.onTap,
    required this.showBottomBorder,
  });

  final String title;
  final String subtitle;
  final bool muted;
  final bool selected;
  final VoidCallback onTap;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: showBottomBorder
              ? Border(bottom: BorderSide(color: c.border, width: 1))
              : null,
        ),
        padding: const EdgeInsets.fromLTRB(18, 13, 18, 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0x1A3B82F6)
                    : c.bgSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                muted ? LucideIcons.bellOff : LucideIcons.bell,
                size: 18,
                color: muted ? c.textTertiary : c.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.3),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.3, fontSize: 12.0),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.accent : c.border,
          width: selected ? 2 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent,
              ),
            )
          : null,
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2AABEE), Color(0xFF1A7FB5)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text('🤖', style: context.tt.bodyLarge),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'HabitFlow Bot',
                        style: context.tt.titleSmall!.copyWith(color: _NotificationsSettingsScreenState._tgBlue),
                      ),
                    ),
                    _TgBubble(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.border, width: 1)),
            ),
            padding: const EdgeInsets.only(top: 12),
            alignment: Alignment.center,
            child: Text(
              l.notificationsPreviewHint,
              textAlign: TextAlign.center,
              style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.4, fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _TgBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final bubbleParts = l.notificationsPreviewBubble.split('\n');
    final mainLine = bubbleParts.isNotEmpty ? bubbleParts[0] : '';
    final streakLine = bubbleParts.length > 1 ? bubbleParts.sublist(1).join('\n') : '';
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(color: c.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            offset: const Offset(0, 1),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            text: TextSpan(
              style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1.55),
              children: [
                TextSpan(text: '$mainLine\n'),
                TextSpan(
                  text: streakLine,
                  style: context.tt.labelLarge!.copyWith(color: c.warning),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _TgBtn(label: l.notificationsPreviewDone)),
              const SizedBox(width: 6),
              Expanded(child: _TgBtn(label: l.notificationsPreviewSkip)),
            ],
          ),
          const SizedBox(height: 6),
          _TgBtnSm(label: l.notificationsPreviewMore),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '07:30 ✓',
                style: context.tt.labelSmall!.copyWith(color: c.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TgBtn extends StatelessWidget {
  const _TgBtn({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _NotificationsSettingsScreenState._tgBlue,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.tt.titleSmall!.copyWith(color: _NotificationsSettingsScreenState._tgBlue),
      ),
    );
  }
}

class _TgBtnSm extends StatelessWidget {
  const _TgBtnSm({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: c.border, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
      alignment: Alignment.center,
      child: Text(
        label,
        style: context.tt.labelMedium!.copyWith(color: c.textSecondary),
      ),
    );
  }
}

class _RareNotifRow extends StatelessWidget {
  const _RareNotifRow({
    required this.emoji,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.showBottomBorder,
  });

  final String emoji;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: c.border, width: 1))
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: context.tt.titleLarge),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.2),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.3, fontSize: 12.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          HFToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
