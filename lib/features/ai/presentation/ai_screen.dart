import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../data/chat_providers.dart';
import '../data/disclaimer_service.dart';
import '../data/openrouter_key_repository.dart';
import 'chat_screen.dart';
import 'prompts_grid_screen.dart';
import 'summaries_screen.dart';
import 'widgets/privacy_disclaimer_dialog.dart';

/// Tab 4: ИИ. Хост 3 саб-вкладок Чат / Сводки / Промпты + кнопка настроек.
/// Саб-вкладки — самодостаточные виджеты, переключаются через IndexedStack
/// (сохраняем скролл и состояние каждой).
class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  @override
  void initState() {
    super.initState();
    // Проверяем флаг после первого frame, чтобы context был ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDisclaimer());
  }

  Future<void> _maybeShowDisclaimer() async {
    if (!mounted) return;

    // Читаем ключ через FutureProvider — гарантированно дожидается загрузки.
    final key = await ref.read(openRouterKeyProvider.future);
    if (key == null || key.isEmpty) return;

    final disclaimerService = ref.read(disclaimerServiceProvider);
    final seen = await disclaimerService.hasSeen();
    if (seen) return;

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PrivacyDisclaimerDialog(),
    );
    await disclaimerService.markSeen();
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final tabs = [l.aiChatTab, l.aiSummariesTab, l.aiPromptsTab];
    final index = ref.watch(aiActiveTabProvider);

    return Container(
      color: c.bgPrimary,
      child: Column(
        children: [
          _AiTabHeader(
            tabs: tabs,
            active: index,
            onChange: (i) =>
                ref.read(aiActiveTabProvider.notifier).state = i,
            onSettings: () => context.push('/profile/ai-settings'),
          ),
          Expanded(
            child: IndexedStack(
              index: index,
              children: const [
                ChatScreen(),
                SummariesScreen(),
                PromptsGridScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiTabHeader extends StatelessWidget {
  const _AiTabHeader({
    required this.tabs,
    required this.active,
    required this.onChange,
    required this.onSettings,
  });

  final List<String> tabs;
  final int active;
  final ValueChanged<int> onChange;
  final VoidCallback onSettings;

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).aiScreenTitle,
                style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < tabs.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        _ChipTab(
                          label: tabs[i],
                          selected: i == active,
                          onTap: () => onChange(i),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RoundIcon(icon: LucideIcons.settings2, onTap: onSettings),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipTab extends StatelessWidget {
  const _ChipTab({required this.label, required this.selected, required this.onTap});

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
            color: selected ? c.accent.withValues(alpha: 0.1) : c.card,
            borderRadius: BorderRadius.circular(HFTokens.rFull),
            border: Border.all(
              color: selected ? c.accent : c.border,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: context.tt.bodySmall!.copyWith(color: selected ? c.accent : c.textSecondary, height: 1.2),
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.bgTertiary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: c.textPrimary),
        ),
      ),
    );
  }
}
