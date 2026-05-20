import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../data/ai_messages_repository.dart';
import '../data/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _prompts = <String>[
    'Проанализируй мою неделю',
    'Где у меня самые слабые места?',
    'Предложи новую привычку',
    'Почему я срываюсь?',
    'Как улучшить утренний ритуал?',
  ];

  // Free-tier daily limit (SPEC §6 / §13). Used as a soft visual progress bar
  // until we wire usage stats from the server.
  static const _requestsLimit = 200;

  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  bool _drawerOpen = false;
  bool _promptsOpen = false;
  bool _disclaimerVisible = true;
  String? _menuOpenChatId;
  String _inputText = '';

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      if (_inputController.text != _inputText) {
        setState(() => _inputText = _inputController.text);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<void> _send(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    _inputController.clear();
    setState(() {
      _inputText = '';
      _promptsOpen = false;
    });
    await ref.read(chatControllerProvider.notifier).sendMessage(clean);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  void _selectChat(String chatId) {
    ref.read(currentChatIdProvider.notifier).state = chatId;
    setState(() {
      _drawerOpen = false;
      _menuOpenChatId = null;
    });
  }

  void _newChat() {
    ref.read(currentChatIdProvider.notifier).state = null;
    setState(() {
      _drawerOpen = false;
      _menuOpenChatId = null;
    });
  }

  Future<void> _renameChat(String chatId, String currentTitle) async {
    setState(() => _menuOpenChatId = null);
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: currentTitle);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.aiChatRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.aiChatRenameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l.commonSave),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty || result == currentTitle) return;
    await ref.read(aiMessagesRepositoryProvider).renameChat(chatId, result);
    ref.invalidate(aiChatsStreamProvider);
  }

  Future<void> _deleteChat(String chatId) async {
    setState(() => _menuOpenChatId = null);
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.aiChatDeleteConfirmTitle),
        content: Text(l.aiChatDeleteConfirmText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(aiMessagesRepositoryProvider).deleteChat(chatId);
    if (ref.read(currentChatIdProvider) == chatId) {
      ref.read(currentChatIdProvider.notifier).state = null;
    }
    ref.invalidate(aiChatsStreamProvider);
  }

  void _openHeaderMenu() {
    final activeId = ref.read(currentChatIdProvider);
    if (activeId == null) return;
    final chats = ref.read(aiChatsStreamProvider).valueOrNull ?? const <AiChat>[];
    final active = chats.firstWhere(
      (c) => c.id == activeId,
      orElse: () => AiChat(
        id: activeId,
        userId: '',
        title: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.pencil),
              title: Text(l.aiChatRename),
              onTap: () {
                Navigator.pop(ctx);
                _renameChat(activeId, active.title);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2),
              title: Text(
                l.aiChatDelete,
                style: context.tt.bodyMedium!.copyWith(color: HFColors.of(context).danger),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _deleteChat(activeId);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    final chatState = ref.watch(chatControllerProvider);
    final messagesAsync = ref.watch(currentChatMessagesProvider);
    final chatsAsync = ref.watch(aiChatsStreamProvider);
    final activeChatId = ref.watch(currentChatIdProvider);

    // Auto-send the prompt that the prompts grid pushed in.
    ref.listen<String?>(pendingPromptProvider, (prev, next) {
      if (next == null || next.isEmpty) return;
      _inputController.text = next;
      setState(() {
        _inputText = next;
        _promptsOpen = false;
      });
      // Clear immediately so re-tapping the same prompt resends.
      ref.read(pendingPromptProvider.notifier).state = null;
      // Defer one frame so the input controller change is visible before send.
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(next));
    });

    // Whenever the server stream emits, drop pending messages it already
    // covers so we don't render duplicates.
    ref.listen<AsyncValue<List<AiMessage>>>(currentChatMessagesProvider,
        (_, next) {
      next.whenData(
        (server) => ref.read(chatControllerProvider.notifier).reconcile(server),
      );
    });

    final serverMessages = messagesAsync.valueOrNull ?? const <AiMessage>[];
    final messages = _mergeMessages(serverMessages, chatState.pendingMessages);
    // Scroll on new messages or while streaming chunks arrive.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());

    final showRateLimit = chatState.rateLimited;
    final showError = chatState.errorMessage != null && !showRateLimit;

    return Stack(
      children: [
        Container(
          color: c.bgPrimary,
          child: Column(
            children: [
              _Header(
                onMenuTap: () => setState(() => _drawerOpen = true),
                onNewChat: _newChat,
                onOverflow: _openHeaderMenu,
              ),
              if (showRateLimit) const _RateLimitBanner(),
              if (showError)
                _ErrorBanner(errorKey: chatState.errorMessage ?? 'generic'),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    HFTokens.s16,
                    HFTokens.s16,
                    HFTokens.s16,
                    HFTokens.s8,
                  ),
                  children: [
                    if (_disclaimerVisible) ...[
                      _Disclaimer(
                        onDismiss: () =>
                            setState(() => _disclaimerVisible = false),
                      ),
                      const SizedBox(height: 20),
                    ],
                    for (var i = 0; i < messages.length; i++)
                      _MessageRow(
                        message: messages[i],
                        showTime: _shouldShowTime(messages, i),
                      ),
                    if (chatState.isStreaming)
                      _StreamingMessageRow(text: chatState.streamingText),
                  ],
                ),
              ),
              _InputBar(
                inputController: _inputController,
                focusNode: _inputFocus,
                inputText: _inputText,
                requestsUsed:
                    ref.watch(dailyMessageCountProvider).valueOrNull ?? 0,
                requestsLimit: _requestsLimit,
                isNearLimit:
                    (ref.watch(dailyMessageCountProvider).valueOrNull ?? 0) >
                        160,
                promptsOpen: _promptsOpen,
                prompts: _prompts,
                isStreaming: chatState.isStreaming,
                onPromptsToggle: () =>
                    setState(() => _promptsOpen = !_promptsOpen),
                onPromptTap: (p) {
                  setState(() {
                    _inputController.text = p;
                    _inputController.selection = TextSelection.fromPosition(
                      TextPosition(offset: p.length),
                    );
                    _inputText = p;
                    _promptsOpen = false;
                  });
                },
                onSend: _send,
              ),
            ],
          ),
        ),
        if (_drawerOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() {
                _drawerOpen = false;
                _menuOpenChatId = null;
              }),
              child: Container(color: const Color(0x66000000)),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          top: 0,
          bottom: 0,
          left: _drawerOpen ? 0 : -290,
          width: 290,
          child: _Drawer(
            chats: chatsAsync.valueOrNull ?? const <AiChat>[],
            activeChatId: activeChatId,
            menuOpenChatId: _menuOpenChatId,
            onMenuToggle: (id) => setState(
              () => _menuOpenChatId = _menuOpenChatId == id ? null : id,
            ),
            onMenuClose: () => setState(() => _menuOpenChatId = null),
            onNewChat: _newChat,
            onSelectChat: _selectChat,
            onRenameChat: _renameChat,
            onDeleteChat: _deleteChat,
          ),
        ),
      ],
    );
  }

  /// Combines server-side messages with locally-buffered pending ones,
  /// dedupes by id, and orders chronologically. Pending entries with ids
  /// already present on the server are dropped — `reconcile` removes them
  /// from controller state shortly after.
  List<AiMessage> _mergeMessages(
    List<AiMessage> server,
    List<AiMessage> pending,
  ) {
    if (pending.isEmpty) return server;
    final seen = server.map((m) => m.id).toSet();
    final extra = pending.where((m) => !seen.contains(m.id));
    final merged = [...server, ...extra]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return merged;
  }

  bool _shouldShowTime(List<AiMessage> messages, int i) {
    if (i == 0) return true;
    final prev = messages[i - 1].createdAt;
    final cur = messages[i].createdAt;
    // Show a time separator when the gap between two adjacent messages is
    // ≥ 1 minute, mirroring the original mock behaviour.
    return cur.difference(prev).inMinutes >= 1;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onMenuTap,
    required this.onNewChat,
    required this.onOverflow,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onNewChat;
  final VoidCallback onOverflow;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          _IconButton(
            icon: LucideIcons.menu,
            color: c.textSecondary,
            onTap: onMenuTap,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ИИ',
                  style: context.tt.titleLarge!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.17),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HFTokens.s8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1FA855F7),
                    borderRadius: BorderRadius.circular(HFTokens.rFull),
                  ),
                  child: Text(
                    '🎓 Coach',
                    style: context.tt.bodyMedium!.copyWith(
                      color: HFTokens.premium,
                      height: 1.2,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _IconButton(
                icon: LucideIcons.plus,
                color: c.textSecondary,
                onTap: onNewChat,
              ),
              const SizedBox(width: 2),
              _IconButton(
                icon: LucideIcons.moreHorizontal,
                color: c.textSecondary,
                onTap: onOverflow,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Red banner shown above the message list when the last request returned
/// 429. The banner stays until the next successful send.
class _RateLimitBanner extends StatelessWidget {
  const _RateLimitBanner();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: c.danger.withValues(alpha: 0.08),
        border: Border(bottom: BorderSide(color: c.danger.withValues(alpha: 0.4))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.alertTriangle, size: 18, color: c.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.aiChatRateLimitedTitle,
                  style: context.tt.bodyMedium!.copyWith(color: c.danger, height: 1.3, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                const SizedBox(height: 3),
                Text(
                  l.aiChatRateLimitedText,
                  style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.5, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic non-429 error banner. [errorKey] selects the localised text:
/// `no_key` → ask user to add an OpenRouter key; anything else → generic.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.errorKey});

  final String errorKey;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final isNoKey = errorKey == 'no_key';
    final title = isNoKey ? l.aiChatNoKeyTitle : l.aiChatErrorGeneric;
    final body = isNoKey ? l.aiChatNoKeyText : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: c.warning.withValues(alpha: 0.08),
        border: Border(bottom: BorderSide(color: c.warning.withValues(alpha: 0.4))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 18, color: c.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1.3, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                if (body != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    body,
                    style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.5, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Streaming assistant bubble — same look as a regular assistant row, but the
/// text is whatever has arrived so far. Uses a lightweight blinking cursor at
/// the end to signal that more chunks are coming.
class _StreamingMessageRow extends StatelessWidget {
  const _StreamingMessageRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.border),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: text.isEmpty
          ? _TypingDots(color: c.textTertiary)
          : _Markdown(text: '$text▋'),
    );

    final avatar = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0x1FA855F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        LucideIcons.sparkles,
        size: 15,
        color: HFTokens.premium,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          avatar,
          const SizedBox(width: HFTokens.s8),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

/// Three-dot "thinking" indicator used while we wait for the first chunk.
class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.color});

  final Color color;

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final v = _ctrl.value;
        Color dot(double t) {
          // Brighten each dot in a staggered phase: 0, 0.33, 0.66.
          final phase = (v + t) % 1.0;
          final alpha = 0.3 + 0.7 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
          return widget.color.withValues(alpha: alpha);
        }

        Widget makeDot(double t) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dot(t),
                  shape: BoxShape.circle,
                ),
              ),
            );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [makeDot(0), makeDot(0.33), makeDot(0.66)],
        );
      },
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: c.bgSecondary,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(HFTokens.rLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  LucideIcons.shieldAlert,
                  size: 20,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).aiChatDisclaimerTitle,
                      style: context.tt.labelLarge!.copyWith(color: c.textPrimary, height: 1.3),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppLocalizations.of(context).aiChatDisclaimerText,
                      style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.6, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: c.card,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: c.border, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    AppLocalizations.of(context).aiChatDisclaimerOk,
                    style: context.tt.titleSmall!.copyWith(color: c.textPrimary, height: 1.2),
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

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message, required this.showTime});

  final AiMessage message;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final isUser = message.isUser;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? c.accent : c.card,
        border: isUser ? null : Border.all(color: c.border),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        boxShadow: isUser
            ? null
            : [
                BoxShadow(
                  color: c.shadow,
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                ),
              ],
      ),
      child: isUser
          ? Text(
              message.content,
              style: context.tt.bodyMedium!.copyWith(color: Colors.white, height: 1.6),
            )
          : _Markdown(text: message.content),
    );

    final avatar = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0x1FA855F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        LucideIcons.sparkles,
        size: 15,
        color: HFTokens.premium,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTime)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: HFTokens.s8),
            child: Text(
              _formatTime(message.createdAt),
              textAlign: TextAlign.center,
              style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2, fontWeight: FontWeight.w500),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: isUser
                ? [Flexible(child: bubble)]
                : [
                    avatar,
                    const SizedBox(width: HFTokens.s8),
                    Flexible(child: bubble),
                  ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _Markdown extends StatelessWidget {
  const _Markdown({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final lines = text.split('\n');
    final children = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) {
        children.add(const SizedBox(height: 8));
        continue;
      }
      final isBullet = line.startsWith('- ') || line.startsWith('• ');
      final content = isBullet ? line.substring(2) : line;
      final spans = _renderInline(content, c, context.tt);

      if (isBullet) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    '•',
                    style: context.tt.labelLarge!.copyWith(color: c.accent, height: 1.6),
                  ),
                ),
                const SizedBox(width: HFTokens.s8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1.6),
                      children: spans,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Text.rich(
            TextSpan(
              style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1.6),
              children: spans,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<InlineSpan> _renderInline(String text, HFColors c, TextTheme tt) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|`(.+?)`');
    var last = 0;
    for (final m in pattern.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: tt.labelLarge,
          ),
        );
      } else if (m.group(2) != null) {
        spans.add(
          TextSpan(
            text: m.group(2),
            style: tt.bodyMedium!.copyWith(color: c.accent, fontSize: 12.6),
          ),
        );
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return spans;
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.inputController,
    required this.focusNode,
    required this.inputText,
    required this.requestsUsed,
    required this.requestsLimit,
    required this.isNearLimit,
    required this.promptsOpen,
    required this.prompts,
    required this.isStreaming,
    required this.onPromptsToggle,
    required this.onPromptTap,
    required this.onSend,
  });

  final TextEditingController inputController;
  final FocusNode focusNode;
  final String inputText;
  final int requestsUsed;
  final int requestsLimit;
  final bool isNearLimit;
  final bool promptsOpen;
  final List<String> prompts;
  final bool isStreaming;
  final VoidCallback onPromptsToggle;
  final ValueChanged<String> onPromptTap;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final hasText = inputText.trim().isNotEmpty;
    final progressColor = isNearLimit ? c.warning : c.accent;
    final progressTextColor = isNearLimit ? c.warning : c.textTertiary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: HFTokens.s8),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      height: 2,
                      color: c.bgTertiary,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: requestsUsed / requestsLimit,
                          child: Container(color: progressColor),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${isNearLimit ? '⚠ ' : ''}${AppLocalizations.of(context).aiChatTokenCounter('gpt-oss-120b:free', requestsUsed, requestsLimit)}',
                  style: context.tt.labelSmall!.copyWith(color: progressTextColor, height: 1.2, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (promptsOpen) ...[
            Container(
              margin: const EdgeInsets.only(bottom: HFTokens.s8),
              decoration: BoxDecoration(
                color: c.bgSecondary,
                border: Border.all(color: c.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < prompts.length; i++)
                    InkWell(
                      onTap: () => onPromptTap(prompts[i]),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                        decoration: BoxDecoration(
                          border: i < prompts.length - 1
                              ? Border(bottom: BorderSide(color: c.border))
                              : null,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.sparkles,
                              size: 14,
                              color: HFTokens.premium,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                prompts[i],
                                style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1.3, fontSize: 13.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: c.bgSecondary,
              border: Border.all(
                color: hasText ? c.accent : c.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ComposerIconButton(
                  icon: LucideIcons.sparkles,
                  color: promptsOpen ? HFTokens.premium : c.textTertiary,
                  background: promptsOpen
                      ? const Color(0x1FA855F7)
                      : Colors.transparent,
                  onTap: onPromptsToggle,
                ),
                const SizedBox(width: HFTokens.s8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: TextField(
                      controller: inputController,
                      focusNode: focusNode,
                      minLines: 1,
                      maxLines: 5,
                      style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.5),
                      cursorColor: c.accent,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText:
                            AppLocalizations.of(context).aiChatInputPlaceholder,
                        hintStyle: context.tt.titleMedium!.copyWith(color: c.textTertiary, height: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: HFTokens.s8),
                _SendButton(
                  active: hasText && !isStreaming,
                  onTap: () {
                    if (!hasText || isStreaming) return;
                    onSend(inputController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: active ? c.accent : c.bgTertiary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            LucideIcons.arrowUp,
            size: 18,
            color: active ? Colors.white : c.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  const _Drawer({
    required this.chats,
    required this.activeChatId,
    required this.menuOpenChatId,
    required this.onMenuToggle,
    required this.onMenuClose,
    required this.onNewChat,
    required this.onSelectChat,
    required this.onRenameChat,
    required this.onDeleteChat,
  });

  final List<AiChat> chats;
  final String? activeChatId;
  final String? menuOpenChatId;
  final ValueChanged<String> onMenuToggle;
  final VoidCallback onMenuClose;
  final VoidCallback onNewChat;
  final ValueChanged<String> onSelectChat;
  final void Function(String chatId, String currentTitle) onRenameChat;
  final ValueChanged<String> onDeleteChat;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.bgPrimary,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: c.border)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      AppLocalizations.of(context).aiChatHistoryTitle,
                      style: context.tt.titleLarge!.copyWith(color: c.textPrimary, height: 1.3),
                    ),
                  ),
                  InkWell(
                    onTap: onNewChat,
                    borderRadius: BorderRadius.circular(HFTokens.rMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(HFTokens.rMd),
                        border: Border.fromBorderSide(
                          BorderSide(
                            color: c.border,
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.plus, size: 16, color: c.accent),
                          const SizedBox(width: HFTokens.s8),
                          Text(
                            AppLocalizations.of(context).aiChatNew,
                            style: context.tt.labelLarge!.copyWith(color: c.accent, height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: HFTokens.s8),
                children: [
                  for (final chat in chats)
                    _DrawerChatTile(
                      chat: chat,
                      isActive: activeChatId == chat.id,
                      menuOpen: menuOpenChatId == chat.id,
                      onTap: () => onSelectChat(chat.id),
                      onMenuToggle: () => onMenuToggle(chat.id),
                      onMenuClose: onMenuClose,
                      onRename: () => onRenameChat(chat.id, chat.title),
                      onDelete: () => onDeleteChat(chat.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerChatTile extends StatelessWidget {
  const _DrawerChatTile({
    required this.chat,
    required this.isActive,
    required this.menuOpen,
    required this.onTap,
    required this.onMenuToggle,
    required this.onMenuClose,
    required this.onRename,
    required this.onDelete,
  });

  final AiChat chat;
  final bool isActive;
  final bool menuOpen;
  final VoidCallback onTap;
  final VoidCallback onMenuToggle;
  final VoidCallback onMenuClose;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final activeBg = c.accent.withValues(alpha: 0.08);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? activeBg : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isActive ? c.accent : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.tt.bodyMedium!.copyWith(color: isActive ? c.accent : c.textPrimary, height: 1.3, fontSize: 13.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatChatDate(chat.updatedAt),
                        style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: HFTokens.s8),
                Material(
                  color: menuOpen ? c.bgTertiary : Colors.transparent,
                  borderRadius: BorderRadius.circular(HFTokens.rSm),
                  child: InkWell(
                    onTap: onMenuToggle,
                    borderRadius: BorderRadius.circular(HFTokens.rSm),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Icon(
                        LucideIcons.moreHorizontal,
                        size: 15,
                        color: c.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (menuOpen)
          Positioned(
            right: 12,
            top: 40,
            child: _ContextMenu(
              onRename: onRename,
              onDelete: onDelete,
              onClose: onMenuClose,
            ),
          ),
      ],
    );
  }

  String _formatChatDate(DateTime dt) {
    final local = dt.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$day.$m';
  }
}

class _ContextMenu extends StatelessWidget {
  const _ContextMenu({
    required this.onRename,
    required this.onDelete,
    required this.onClose,
  });

  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.card,
      borderRadius: BorderRadius.circular(HFTokens.rMd),
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(minWidth: 148),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(HFTokens.rMd),
          border: Border.all(color: c.border),
          boxShadow: [
            BoxShadow(
              color: c.shadow,
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ContextMenuItem(
              icon: LucideIcons.pencil,
              label: AppLocalizations.of(context).aiChatRename,
              danger: false,
              showDivider: true,
              onTap: onRename,
            ),
            _ContextMenuItem(
              icon: LucideIcons.trash2,
              label: AppLocalizations.of(context).aiChatDelete,
              danger: true,
              showDivider: false,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.danger,
    required this.showDivider,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool danger;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final color = danger ? c.danger : c.textPrimary;
    final iconColor = danger ? c.danger : c.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: c.border))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 9),
            Text(
              label,
              style: context.tt.bodyMedium!.copyWith(color: color, height: 1.2, fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}

