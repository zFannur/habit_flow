import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/services/telegram_service.dart';
import '../data/donations_repository.dart';

// TODO(real-data): replace with a real userProvider once it exists so the
// supporter badge in profile refreshes after payment.
final _supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final _donationsRepositoryProvider = Provider<DonationsRepository>((ref) {
  return DonationsRepository(client: ref.watch(_supabaseClientProvider));
});

/// Экран поддержки проекта через Telegram Stars (см. docs/design/donate.html).
/// Копируется 1:1: hero-карточка с золотой звездой, сетка пресетов 2×2
/// (последний — кастомный ввод), список бонусов и CTA-кнопка.
class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key});

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  // TODO(l10n): localize donation presets
  static const _presets = <_Preset>[
    _Preset(stars: 50, usd: r'$0.65', label: 'Кофе автору'),
    _Preset(stars: 150, usd: r'$1.95', label: 'Хороший обед', popular: true),
    _Preset(stars: 500, usd: r'$6.50', label: 'День разработки'),
    _Preset(custom: true),
  ];

  int _selected = 1;
  bool _loading = false;
  final TextEditingController _customCtl = TextEditingController();
  final TelegramService _telegram = const TelegramService();

  @override
  void initState() {
    super.initState();
    _customCtl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _customCtl.dispose();
    super.dispose();
  }

  int get _selectedStars {
    if (_selected == 3) {
      return int.tryParse(_customCtl.text) ?? 0;
    }
    return _presets[_selected].stars ?? 0;
  }

  Future<void> _onPay() async {
    final stars = _selectedStars;
    if (stars <= 0) return;

    setState(() => _loading = true);
    final l = AppLocalizations.of(context);

    try {
      final repo = ref.read(_donationsRepositoryProvider);
      final invoiceUrl = await repo.createInvoice(stars);

      _telegram.openInvoice(invoiceUrl, onStatus: (status) {
        if (!mounted) return;
        if (status == TgInvoiceStatus.paid) {
          // Invalidate supabase auth user stream so is_supporter refreshes.
          // TODO(real-data): invalidate userProvider when it exists.
          ref.invalidate(_supabaseClientProvider);
          _showToast(
            title: l.donateThanksTitle,
            message: l.donateThanksMessage,
            variant: _ToastVariant.success,
          );
        }
        // cancelled / failed: stay on screen, no toast.
      });
    } catch (_) {
      if (mounted) {
        _showToast(
          title: l.donateErrorTitle,
          message: l.donateErrorMessage,
          variant: _ToastVariant.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showToast({
    required String title,
    required String message,
    required _ToastVariant variant,
  }) {
    final c = HFColors.of(context);
    final color = variant == _ToastVariant.success ? c.success : c.danger;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              top: BorderSide(color: c.border),
              right: BorderSide(color: c.border),
              bottom: BorderSide(color: c.border),
              left: BorderSide(color: color, width: 4),
            ),
            boxShadow: HFTokens.toastShadow(c.shadow),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.tt.labelLarge!.copyWith(color: c.textPrimary, height: 1.2),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: Column(
        children: [
          _Header(onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const _HeroCard(),
                  const SizedBox(height: 16),
                  _PresetsSection(
                    presets: _presets,
                    selected: _selected,
                    onSelect: (i) => setState(() => _selected = i),
                    customCtl: _customCtl,
                  ),
                  const SizedBox(height: 16),
                  const _BenefitsCard(),
                  const SizedBox(height: 16),
                  _CtaSection(
                    selectedStars: _selectedStars,
                    loading: _loading,
                    onPay: (_selectedStars > 0 && !_loading) ? _onPay : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ToastVariant { success, error }

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
                l.donateTitle,
                style: context.tt.headlineSmall!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 20, fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border, width: 1),
        gradient: LinearGradient(
          begin: const Alignment(-0.5, -1),
          end: const Alignment(0.5, 1),
          stops: const [0.6, 1.0],
          colors: [c.card, const Color(0x0AF59E0B)],
        ),
        boxShadow: [
          BoxShadow(color: c.shadow, offset: const Offset(0, 2), blurRadius: 16),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              top: -24,
              right: -24,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x1FF59E0B), Color(0x00F59E0B)],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _GoldStar(size: 72),
                const SizedBox(height: 12),
                Text(
                  l.donateHeroTitle,
                  textAlign: TextAlign.center,
                  style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 22),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    l.donateHeroMessage,
                    textAlign: TextAlign.center,
                    style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.65),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldStar extends StatelessWidget {
  const _GoldStar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoldStarPainter()),
    );
  }
}

class _GoldStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 80;
    final pts = <Offset>[
      const Offset(40, 6),
      const Offset(48.7, 28.5),
      const Offset(73, 28.5),
      const Offset(53.2, 43.2),
      const Offset(60.6, 66.5),
      const Offset(40, 52.4),
      const Offset(19.4, 66.5),
      const Offset(26.8, 43.2),
      const Offset(7, 28.5),
      const Offset(31.3, 28.5),
    ];

    final path = Path()..moveTo(pts.first.dx * scale, pts.first.dy * scale);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx * scale, pts[i].dy * scale);
    }
    path.close();

    final glow = Paint()
      ..color = const Color(0x66F59E0B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glow);

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFD97706)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PresetsSection extends StatelessWidget {
  const _PresetsSection({
    required this.presets,
    required this.selected,
    required this.onSelect,
    required this.customCtl,
  });

  final List<_Preset> presets;
  final int selected;
  final ValueChanged<int> onSelect;
  final TextEditingController customCtl;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            l.donatePresetsLabel,
            style: context.tt.titleSmall!.copyWith(color: c.textSecondary, height: 1.2, letterSpacing: 0.01 * 13),
          ),
        ),
        // Top padding reserves room for the floating "Popular" badge that
        // sits at top: -10 of its preset card; without it the badge gets
        // clipped by the previous section on narrow viewports.
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final cellW = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: 16,
                children: [
                  for (var i = 0; i < presets.length; i++)
                    SizedBox(
                      width: cellW,
                      child: _PresetCard(
                        preset: presets[i],
                        selected: selected == i,
                        onTap: () => onSelect(i),
                        customCtl: customCtl,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PresetCard extends StatefulWidget {
  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.onTap,
    required this.customCtl,
  });

  final _Preset preset;
  final bool selected;
  final VoidCallback onTap;
  final TextEditingController customCtl;

  @override
  State<_PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<_PresetCard> {
  final FocusNode _focus = FocusNode();
  bool _showInput = false;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.preset.custom) {
      setState(() => _showInput = true);
      widget.onTap();
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _focus.requestFocus();
      });
    } else {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final p = widget.preset;
    final selected = widget.selected;

    final showInput = p.custom && _showInput;
    final padding = showInput
        ? const EdgeInsets.fromLTRB(14, 14, 14, 12)
        : const EdgeInsets.fromLTRB(12, 16, 12, 14);

    // Slight scale hint without overflowing the row gap (was 1.03 which
    // visibly clipped against the neighbour on selected state).
    final scale = selected ? 1.0 : 1.0;

    final boxShadow = <BoxShadow>[
      if (selected)
        BoxShadow(
          color: c.accent.withValues(alpha: 0.15),
          offset: Offset.zero,
          blurRadius: 0,
          spreadRadius: 3,
        ),
      BoxShadow(
        color: c.shadow,
        offset: Offset(0, selected ? 4 : 2),
        blurRadius: selected ? 12 : 8,
      ),
    ];

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? c.accent : c.border,
          width: selected ? 2 : 1.5,
        ),
        boxShadow: boxShadow,
      ),
      padding: padding,
      constraints: const BoxConstraints(minHeight: 96),
      child: _PresetContent(
        preset: p,
        selected: selected,
        showInput: showInput,
        focus: _focus,
        controller: widget.customCtl,
      ),
    );

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 100),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(16),
              child: card,
            ),
          ),
          if (p.popular)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(HFTokens.rFull),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: Text(
                    l.donatePopularBadge,
                    style: context.tt.bodyMedium!.copyWith(color: Colors.white, height: 1.4, letterSpacing: 0.04 * 10, fontWeight: FontWeight.w700, fontSize: 10.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PresetContent extends StatelessWidget {
  const _PresetContent({
    required this.preset,
    required this.selected,
    required this.showInput,
    required this.focus,
    required this.controller,
  });

  final _Preset preset;
  final bool selected;
  final bool showInput;
  final FocusNode focus;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    if (preset.custom) {
      if (showInput) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l.donateCustomInputLabel,
              textAlign: TextAlign.center,
              style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: c.bgSecondary,
                borderRadius: BorderRadius.circular(HFTokens.rMd),
                border: Border.all(color: c.accent, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: TextField(
                controller: controller,
                focusNode: focus,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                textAlign: TextAlign.center,
                style: context.tt.headlineSmall!.copyWith(color: c.textPrimary, height: 1.2),
                cursorColor: c.accent,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: '100',
                  hintStyle: context.tt.headlineSmall!.copyWith(color: c.textTertiary, height: 1.2),
                ),
              ),
            ),
          ],
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.pencil, size: 22, color: c.textSecondary),
          const SizedBox(height: 4),
          Text(
            l.donateCustomButton,
            style: context.tt.titleMedium!.copyWith(color: selected ? c.accent : c.textPrimary, height: 1.2),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${preset.stars} ⭐',
          style: context.tt.headlineSmall!.copyWith(color: selected ? c.accent : c.textPrimary, height: 1, letterSpacing: -0.02 * 20, fontSize: 20.0),
        ),
        const SizedBox(height: 5),
        Text(
          '≈ ${preset.usd}',
          style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.2, fontSize: 12.0),
        ),
        const SizedBox(height: 6),
        Text(
          preset.label ?? '',
          textAlign: TextAlign.center,
          style: context.tt.labelSmall!.copyWith(color: selected ? c.accent : c.textSecondary, height: 1.3),
        ),
      ],
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              l.donateBenefitsTitle,
              style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.01 * 15),
            ),
          ),
          _BenefitRow(icon: '💎', text: l.donateBenefitBadge),
          const SizedBox(height: 12),
          _BenefitRow(icon: '✍️', text: l.donateBenefitStyle),
          const SizedBox(height: 12),
          _BenefitRow(icon: '🎨', text: l.donateBenefitColor),
          const SizedBox(height: 12),
          _BenefitRow(icon: '❤️', text: l.donateBenefitThanks),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: c.bgTertiary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: context.tt.headlineSmall!.copyWith(height: 1)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection({
    required this.selectedStars,
    required this.onPay,
    this.loading = false,
  });

  final int selectedStars;
  final VoidCallback? onPay;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final enabled = selectedStars > 0;

    final bg = enabled ? c.accent : c.bgTertiary;
    final fg = enabled ? Colors.white : c.textTertiary;
    final label = enabled ? l.donateCta(selectedStars) : l.donateTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPay,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: c.accent.withValues(alpha: 0.35),
                          offset: const Offset(0, 4),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    )
                  else
                    CustomPaint(
                      size: const Size(18, 18),
                      painter: _StarPainter(color: fg),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: context.tt.bodyLarge!.copyWith(color: fg, height: 1.2, letterSpacing: -0.01 * 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            l.donateMobileNote,
            textAlign: TextAlign.center,
            style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.5, fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l.donateHistoryLink,
                style: context.tt.titleSmall!.copyWith(color: c.accent, height: 1.4),
              ),
              const SizedBox(width: 4),
              Icon(LucideIcons.arrowRight, size: 13, color: c.accent),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 18;
    final pts = <Offset>[
      const Offset(9, 1.5),
      const Offset(11.2, 6.5),
      const Offset(16.5, 6.9),
      const Offset(12.6, 10.3),
      const Offset(13.9, 15.5),
      const Offset(9, 12.7),
      const Offset(4.1, 15.5),
      const Offset(5.4, 10.3),
      const Offset(1.5, 6.9),
      const Offset(6.8, 6.5),
    ];
    final path = Path()..moveTo(pts.first.dx * scale, pts.first.dy * scale);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx * scale, pts[i].dy * scale);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _Preset {
  const _Preset({this.stars, this.usd, this.label, this.popular = false, this.custom = false});

  final int? stars;
  final String? usd;
  final String? label;
  final bool popular;
  final bool custom;
}
