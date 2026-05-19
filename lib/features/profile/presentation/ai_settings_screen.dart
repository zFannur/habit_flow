import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/services/telegram_service.dart';
import '../../ai/data/ai_style_repository.dart';
import '../../ai/data/openrouter_key_repository.dart';
import '../../ai/data/openrouter_models_repository.dart';
import '../../ai/domain/style_prompts.dart';

/// Экран «ИИ и модель» (см. docs/design/ai-settings.html).
/// Копируется 1:1: ключ OpenRouter, выбор модели, стиль ИИ, использование.
class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final preferred = ref.watch(preferredModelControllerProvider);
    final selectedModel = preferred.maybeWhen(
      data: (v) => v ?? 'openai/gpt-oss-120b:free',
      orElse: () => 'openai/gpt-oss-120b:free',
    );
    final styleAsync = ref.watch(aiStyleControllerProvider);
    final selectedStyle = styleAsync.maybeWhen(
      data: (s) => s.wireName,
      orElse: () => AiStyle.coach.wireName,
    );
    // TODO(07-04): replace with real `users.is_supporter` flag once the
    // donations feature lands. Until then Poet stays locked for everyone.
    const isSupporter = false;

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
                  _ApiKeySection(onHowItWorks: _showHowItWorks),
                  const SizedBox(height: 16),
                  _ModelSection(
                    selectedModel: selectedModel,
                    onModelSelect: (id) => ref
                        .read(preferredModelControllerProvider.notifier)
                        .select(id),
                  ),
                  const SizedBox(height: 16),
                  _StyleSection(
                    selectedStyle: selectedStyle,
                    isSupporter: isSupporter,
                    onStyleSelect: (id) {
                      final next = AiStyle.fromWire(id);
                      // Guard: Poet is donor-only. UI also disables the row,
                      // but defend against accidental wire-id mismatches.
                      if (next.requiresSupporter && !isSupporter) return;
                      ref
                          .read(aiStyleControllerProvider.notifier)
                          .select(next);
                    },
                  ),
                  const SizedBox(height: 16),
                  const _UsageSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHowItWorks() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C0F1419),
      isScrollControlled: true,
      builder: (_) => const _HowItWorksSheet(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              _BackButton(onTap: onBack),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).aiSettingsTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                    letterSpacing: -0.02 * 17,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.card,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: c.border, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            LucideIcons.chevronLeft,
            size: 20,
            color: c.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── SECTION LABEL ─────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08 * 11,
          color: c.textTertiary,
          height: 1.2,
        ),
      ),
    );
  }
}

// ───────────────────────── CARD ─────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider({this.horizontalMargin = 16});

  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Container(height: 1, color: c.border),
    );
  }
}

// ───────────────────────── API KEY SECTION ─────────────────────────

/// Маскирует ключ для отображения: первые 9 символов + bullets + последние 4.
String _maskKey(String key) {
  if (key.length <= 13) return key;
  final head = key.substring(0, 9);
  final tail = key.substring(key.length - 4);
  return '$head•••••••••••••••••$tail';
}

class _ApiKeySection extends ConsumerStatefulWidget {
  const _ApiKeySection({required this.onHowItWorks});

  final VoidCallback onHowItWorks;

  @override
  ConsumerState<_ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends ConsumerState<_ApiKeySection> {
  bool _editing = false;
  bool _showKey = false;
  final TextEditingController _inputCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputCtl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _inputCtl.dispose();
    super.dispose();
  }

  void _handleTest() {
    ref.read(openRouterKeyControllerProvider.notifier).test();
  }

  Future<void> _handleSave() async {
    final value = _inputCtl.text.trim();
    if (value.length < 10) return;
    await ref.read(openRouterKeyControllerProvider.notifier).save(value);
    if (!mounted) return;
    setState(() {
      _editing = false;
      _inputCtl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final keyState = ref.watch(openRouterKeyControllerProvider);
    final showInput = _editing || !keyState.hasKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(label: l.aiSettingsApiKeySection),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l.aiSettingsApiKeyLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (showInput)
                      _buildInputRow(c)
                    else
                      _buildKeyRow(c, keyState.key!),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _LinkButton(
                          label: l.aiSettingsApiKeyLink,
                          onTap: () => const TelegramService()
                              .openLink('https://openrouter.ai/keys'),
                        ),
                        const SizedBox(width: 16),
                        _LinkButton(
                          label: l.aiSettingsHowItWorks,
                          onTap: widget.onHowItWorks,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!showInput) ...[
                const _CardDivider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TestButton(
                        status: keyState.status,
                        onTap: keyState.status == OpenRouterKeyStatus.checking
                            ? null
                            : _handleTest,
                      ),
                      const SizedBox(height: 10),
                      _StatusRow(status: keyState.status),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyRow(HFColors c, String key) {
    final l = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: c.bgSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _showKey ? key : _maskKey(key),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: c.textPrimary,
                      letterSpacing: 0.02 * 13,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _IconButton(
                  icon: _showKey ? LucideIcons.eyeOff : LucideIcons.eye,
                  onTap: () => setState(() => _showKey = !_showKey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _PrimaryButton(
          label: l.commonReplace,
          onTap: () => setState(() {
            _editing = true;
          }),
        ),
      ],
    );
  }

  Widget _buildInputRow(HFColors c) {
    final l = AppLocalizations.of(context);
    final canSave = _inputCtl.text.length >= 10;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: c.bgSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: TextField(
              controller: _inputCtl,
              autofocus: true,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: c.textPrimary,
                letterSpacing: 0.02 * 13,
                height: 1.4,
              ),
              cursorColor: c.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'sk-or-v1-...',
                hintStyle: TextStyle(
                  fontFamily: '',
                  fontSize: 13,
                  color: c.textTertiary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _PrimaryButton(
          label: l.commonSave,
          enabled: canSave,
          onTap: canSave ? _handleSave : null,
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.bgTertiary,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 16, color: c.textSecondary),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final disabled = !enabled || onTap == null;
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Material(
        color: c.accent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: c.accent,
          height: 1.4,
          decoration: TextDecoration.underline,
          decorationColor: c.accent,
        ),
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  const _TestButton({required this.status, required this.onTap});

  final OpenRouterKeyStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final testing = status == OpenRouterKeyStatus.checking;

    final bg = testing
        ? c.accent.withValues(alpha: 0.04)
        : Colors.transparent;
    final fg = testing ? c.accent : c.textSecondary;
    final border = testing
        ? c.accent.withValues(alpha: 0.3)
        : c.border;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: border, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (testing) ...[
                _Spinner(color: c.accent),
                const SizedBox(width: 6),
                Text(
                  l.commonSending,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fg,
                    height: 1.2,
                  ),
                ),
              ] else ...[
                const Text(
                  '🧪',
                  style: TextStyle(fontSize: 14, height: 1.2),
                ),
                const SizedBox(width: 6),
                Text(
                  l.aiSettingsTestButton,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fg,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatefulWidget {
  const _Spinner({required this.color});

  final Color color;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctl,
      child: CustomPaint(
        size: const Size(14, 14),
        painter: _SpinnerPainter(color: widget.color),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 2.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final track = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawOval(rect, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -1.5708, 1.5708, false, arc);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.status});

  final OpenRouterKeyStatus status;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    final (Color dot, String text, Color textColor) = switch (status) {
      OpenRouterKeyStatus.unchecked => (
        const Color(0xFFD1D5DB),
        l.aiSettingsStatusUnchecked,
        c.textTertiary,
      ),
      OpenRouterKeyStatus.checking => (
        c.accent,
        l.aiSettingsStatusChecking,
        c.accent,
      ),
      OpenRouterKeyStatus.ok => (
        c.success,
        l.aiSettingsStatusOk,
        const Color(0xFF16A34A),
      ),
      OpenRouterKeyStatus.error => (
        c.danger,
        l.aiSettingsStatusError,
        c.danger,
      ),
    };

    return Row(
      children: [
        if (status != OpenRouterKeyStatus.checking) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── MODELS ─────────────────────────

class _Model {
  const _Model({
    required this.id,
    required this.name,
    required this.provider,
    this.price,
    this.free = false,
    required this.context,
    this.rpm,
    this.rpd,
  });

  final String id;
  final String name;
  final String provider;
  final String? price;
  final bool free;
  final String context;
  final int? rpm;
  final int? rpd;
}

const _kModels = <_Model>[
  _Model(
    id: 'openai/gpt-oss-120b:free',
    name: 'GPT-OSS 120B',
    provider: 'OpenAI',
    free: true,
    context: '131K',
    rpm: 20,
    rpd: 200,
  ),
  _Model(
    id: 'openai/gpt-oss-120b',
    name: 'GPT-OSS 120B',
    provider: 'OpenAI',
    price: r'$0.04 / $0.18',
    context: '131K',
    rpm: 60,
  ),
  _Model(
    id: 'qwen/qwen3-coder:free',
    name: 'Qwen3 Coder',
    provider: 'Qwen / Alibaba',
    free: true,
    context: '32K',
    rpm: 20,
    rpd: 200,
  ),
  _Model(
    id: 'anthropic/claude-haiku-4-5',
    name: 'Claude Haiku 4.5',
    provider: 'Anthropic',
    price: r'$0.08 / $0.25',
    context: '200K',
    rpm: 50,
  ),
  _Model(
    id: 'google/gemini-2.5-flash',
    name: 'Gemini 2.5 Flash',
    provider: 'Google DeepMind',
    price: r'$0.00 / $0.00',
    context: '1M',
    rpm: 60,
  ),
  _Model(
    id: 'meta-llama/llama-4-maverick',
    name: 'Llama 4 Maverick',
    provider: 'Meta',
    price: r'$0.10 / $0.28',
    context: '512K',
    rpm: 30,
  ),
];

class _ModelSection extends ConsumerStatefulWidget {
  const _ModelSection({
    required this.selectedModel,
    required this.onModelSelect,
  });

  final String selectedModel;
  final ValueChanged<String> onModelSelect;

  @override
  ConsumerState<_ModelSection> createState() => _ModelSectionState();
}

class _ModelSectionState extends ConsumerState<_ModelSection> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Filter by id/name (case-insensitive). Always keep the currently selected
  /// model visible so the user does not "lose" it behind the filter.
  List<OpenRouterModelInfo> _filter(List<OpenRouterModelInfo> list) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list
        .where((m) =>
            m.id == widget.selectedModel ||
            m.id.toLowerCase().contains(q) ||
            m.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Widget _buildList(List<OpenRouterModelInfo> source) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final list = _filter(source);
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            l.aiSettingsModelsEmpty,
            style: TextStyle(fontSize: 13, color: c.textTertiary),
          ),
        ),
      );
    }
    return SizedBox(
      height: 320,
      child: Scrollbar(
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: list.length,
          separatorBuilder: (_, _) => const _CardDivider(),
          itemBuilder: (_, i) => _ModelRow(
            model: list[i],
            selected: widget.selectedModel == list[i].id,
            onSelect: () => widget.onModelSelect(list[i].id),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final modelsAsync = ref.watch(availableModelsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(label: l.aiSettingsModelSection),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: c.bgSecondary,
              border: Border.all(color: c.border, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(LucideIcons.search, size: 16, color: c.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(fontSize: 14, color: c.textPrimary),
                    cursorColor: c.accent,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: l.aiSettingsModelSearchHint,
                      hintStyle:
                          TextStyle(fontSize: 14, color: c.textTertiary),
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                    child:
                        Icon(LucideIcons.x, size: 16, color: c.textTertiary),
                  ),
              ],
            ),
          ),
        ),
        _Card(
          child: modelsAsync.when(
            data: (models) => _buildList(
              models.isEmpty ? _kModels.map(_modelFromStatic).toList() : models,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, _) =>
                _buildList(_kModels.map(_modelFromStatic).toList()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
          child: GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.aiSettingsAllModelsLink,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: c.accent,
                    height: 1.4,
                    decoration: TextDecoration.underline,
                    decorationColor: c.accent,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(LucideIcons.chevronRight, size: 14, color: c.accent),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Adapts the legacy hard-coded [_Model] entry into the new
/// [OpenRouterModelInfo] shape used by the live Edge Function.
OpenRouterModelInfo _modelFromStatic(_Model m) {
  return OpenRouterModelInfo(
    id: m.id,
    name: m.name,
    contextLength: null,
    promptPrice: null,
    completionPrice: m.free ? '0' : null,
    free: m.free,
  );
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({
    required this.model,
    required this.selected,
    required this.onSelect,
  });

  final OpenRouterModelInfo model;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    return Material(
      color: selected ? c.accent.withValues(alpha: 0.04) : Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 7,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          model.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        if (model.free) const _FreeBadge(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    _MetaLine(model: model),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PriceLabel(model: model),
            ],
          ),
        ),
      ),
    );
  }
}

/// Provider name from id like `openai/gpt-4o` → `OpenAI`.
String _providerOf(OpenRouterModelInfo m) {
  final slash = m.id.indexOf('/');
  if (slash <= 0) return '';
  final raw = m.id.substring(0, slash);
  if (raw.isEmpty) return '';
  return raw[0].toUpperCase() + raw.substring(1);
}

/// Human-readable context: 131072 → "131K", 1000000 → "1M".
String? _contextLabel(int? ctx) {
  if (ctx == null || ctx <= 0) return null;
  if (ctx >= 1000000) {
    final m = ctx / 1000000;
    return m == m.roundToDouble()
        ? '${m.toInt()}M'
        : '${m.toStringAsFixed(1)}M';
  }
  if (ctx >= 1000) {
    final k = ctx / 1000;
    return '${k.round()}K';
  }
  return ctx.toString();
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, this.disabled = false});

  final bool selected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final borderColor = disabled
        ? c.bgTertiary
        : (selected ? c.accent : c.border);
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: selected ? c.accent : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: selected ? 1 : 0,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _FreeBadge extends StatelessWidget {
  const _FreeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0x1F22C55E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppLocalizations.of(context).aiBadgeFree,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.04 * 10,
          color: Color(0xFF16A34A),
          height: 1.2,
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.model});

  final OpenRouterModelInfo model;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final provider = _providerOf(model);
    final ctx = _contextLabel(model.contextLength);
    final parts = <String>[
      if (provider.isNotEmpty) provider,
      if (ctx != null) '$ctx ctx',
    ];

    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '·',
              style: TextStyle(
                fontSize: 12,
                color: c.border,
                height: 1.4,
              ),
            ),
          ),
        );
      }
      children.add(
        Text(
          parts[i],
          style: TextStyle(
            fontSize: 12,
            color: c.textTertiary,
            height: 1.4,
          ),
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.model});

  final OpenRouterModelInfo model;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    if (model.free) return const SizedBox.shrink();
    final prompt = _formatPerMillion(model.promptPrice);
    final completion = _formatPerMillion(model.completionPrice);
    if (prompt == null && completion == null) {
      return const SizedBox.shrink();
    }
    final price =
        '${prompt ?? r'$0.00'} / ${completion ?? r'$0.00'}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'за 1M',
          style: TextStyle(
            fontSize: 11,
            color: c.textTertiary,
            height: 1.3,
          ),
        ),
        Text(
          price,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// OpenRouter pricing is per token; multiply by 1M and format as USD.
String? _formatPerMillion(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final parsed = double.tryParse(raw);
  if (parsed == null) return null;
  final perMillion = parsed * 1000000;
  return '\$${perMillion.toStringAsFixed(2)}';
}

// ───────────────────────── STYLES ─────────────────────────

class _Style {
  const _Style({
    required this.id,
    required this.emoji,
    required this.name,
    required this.desc,
    required this.preview,
    this.locked = false,
  });

  final String id;
  final String emoji;
  final String name;
  final String desc;
  final String preview;
  final bool locked;
}

const _kStyles = <_Style>[
  _Style(
    id: 'coach',
    emoji: '🎓',
    name: 'Coach',
    desc: 'Профессиональный, без сюсюканья. По умолчанию.',
    preview:
        'Три пропуска подряд — это уже паттерн. Что именно мешает: время, мотивация или обстоятельства? Давай разберём и скорректируем план.',
  ),
  _Style(
    id: 'sergeant',
    emoji: '💪',
    name: 'Sergeant',
    desc: 'Прямой, без оправданий. Жёсткий, но честный.',
    preview:
        'Три раза. Без исключений. Это не обстоятельства — это выбор. Либо ты делаешь это сегодня, либо признаёшь, что это не приоритет.',
  ),
  _Style(
    id: 'buddy',
    emoji: '🤗',
    name: 'Buddy',
    desc: 'Тёплый, неформальный, с юмором. Поддерживает.',
    preview:
        'Эй, всё норм! Жизнь случается 😅 Три пропуска — не катастрофа. Ты уже здесь и думаешь об этом, а это уже победа. Завтра?',
  ),
  _Style(
    id: 'sage',
    emoji: '🧘',
    name: 'Sage',
    desc: 'Стоическая мудрость, цитаты, метафоры.',
    preview:
        '«Не падение определяет нас, а то, как мы встаём». Три пропуска — лишь рябь на воде. Привычка — это не серия, а намерение. Что говорит тебе это молчание?',
  ),
  _Style(
    id: 'poet',
    emoji: '✍️',
    name: 'Poet',
    desc: 'Метафоры и образы. Только для поддержавших.',
    preview:
        'Три пустых вечера, как незаполненные строфы. Тело помнит ритм, даже когда разум забыл. Что остановило движение?',
    locked: true,
  ),
];

class _StyleSection extends StatelessWidget {
  const _StyleSection({
    required this.selectedStyle,
    required this.onStyleSelect,
    this.isSupporter = false,
  });

  final String selectedStyle;
  final ValueChanged<String> onStyleSelect;
  final bool isSupporter;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    // Poet's lock flag is data-driven: locked iff the user hasn't donated.
    final styles = _kStyles
        .map((s) => s.id == AiStyle.poet.wireName
            ? _Style(
                id: s.id,
                emoji: s.emoji,
                name: s.name,
                desc: s.desc,
                preview: s.preview,
                locked: !isSupporter,
              )
            : s)
        .toList();
    final current = styles.firstWhere(
      (s) => s.id == selectedStyle,
      orElse: () => styles.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(label: l.aiSettingsStyleSection),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            l.aiSettingsStyleSubtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
              height: 1.4,
            ),
          ),
        ),
        _Card(
          child: Column(
            children: [
              for (var i = 0; i < styles.length; i++) ...[
                _StyleRow(
                  style: styles[i],
                  selected: selectedStyle == styles[i].id,
                  onSelect: styles[i].locked
                      ? null
                      : () => onStyleSelect(styles[i].id),
                ),
                if (i != styles.length - 1) const _CardDivider(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 0, 6),
                child: Text(
                  l.aiSettingsStyleExampleHeader,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.textTertiary,
                    letterSpacing: 0.05 * 11,
                    height: 1.4,
                  ),
                ),
              ),
              _PreviewBubble(style: current),
            ],
          ),
        ),
      ],
    );
  }
}

class _StyleRow extends StatelessWidget {
  const _StyleRow({
    required this.style,
    required this.selected,
    required this.onSelect,
  });

  final _Style style;
  final bool selected;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final disabled = style.locked;

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RadioDot(selected: selected, disabled: disabled),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  style.emoji,
                  style: const TextStyle(fontSize: 22, height: 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      style.desc,
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textTertiary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (style.locked) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: c.bgTertiary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.lock, size: 12, color: c.textTertiary),
                const SizedBox(width: 4),
                Text(
                  'Pro',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.textTertiary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    final inner = Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      child: content,
    );

    final wrapped = Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: selected
            ? c.accent.withValues(alpha: 0.04)
            : Colors.transparent,
        child: InkWell(onTap: onSelect, child: inner),
      ),
    );

    return wrapped;
  }
}

class _PreviewBubble extends StatelessWidget {
  const _PreviewBubble({required this.style});

  final _Style style;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(style.id),
        decoration: BoxDecoration(
          color: c.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border, width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                style.emoji,
                style: const TextStyle(fontSize: 18, height: 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                style.preview,
                style: TextStyle(
                  fontSize: 13,
                  color: c.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── USAGE ─────────────────────────

class _UsageSection extends StatelessWidget {
  const _UsageSection();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    const today = 23;
    const limit = 200;
    const pct = today / limit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(label: l.aiSettingsUsageSection),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatRow(
                label: l.aiSettingsUsageToday,
                value: '$today',
                suffix: ' / $limit запросов',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    height: 4,
                    color: c.bgTertiary,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(color: c.accent),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const _CardDivider(horizontalMargin: 0),
              _StatRow(
                label: l.aiSettingsUsageMonth,
                value: '412 запросов',
              ),
              const _CardDivider(horizontalMargin: 0),
              _StatRow(
                label: l.aiSettingsUsageSpent,
                value: r'$0.00',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Text(
                  l.aiSettingsUsageNote,
                  style: TextStyle(
                    fontSize: 11,
                    color: c.textTertiary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.suffix,
  });

  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
                height: 1.3,
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    height: 1.3,
                  ),
                ),
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: c.textTertiary,
                      height: 1.3,
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

// ───────────────────────── HOW IT WORKS SHEET ─────────────────────────

class _HowItWorksSheet extends StatelessWidget {
  const _HowItWorksSheet();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final items = [
      (
        icon: '🔑',
        title: l.aiSettingsHowItem1Title,
        text: l.aiSettingsHowItem1Text,
      ),
      (
        icon: '🌐',
        title: l.aiSettingsHowItem2Title,
        text: l.aiSettingsHowItem2Text,
      ),
      (
        icon: '💳',
        title: l.aiSettingsHowItem3Title,
        text: l.aiSettingsHowItem3Text,
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: c.bgTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l.aiSettingsHowItWorks,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
                letterSpacing: -0.02 * 20,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < items.length; i++) ...[
              _HowItem(
                icon: items[i].icon,
                title: items[i].title,
                text: items[i].text,
              ),
              if (i != items.length - 1) const SizedBox(height: 14),
            ],
            const SizedBox(height: 18),
            Material(
              color: c.accent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  child: Text(
                    l.commonUnderstand,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItem extends StatelessWidget {
  const _HowItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  final String icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: c.bgSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 18, height: 1)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: c.textSecondary,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

