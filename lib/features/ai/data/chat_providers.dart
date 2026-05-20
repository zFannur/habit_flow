import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../habits/data/habits_providers.dart';
import '../../journal/data/journal_providers.dart';
import 'ai_messages_repository.dart';
import 'openrouter_client.dart';
import 'openrouter_key_repository.dart';
import 'openrouter_models_repository.dart';
import 'prompt_builder.dart';

/// Live repository (uses the Supabase singleton + auth from session).
final aiMessagesRepositoryProvider = Provider<AiMessagesRepository>((ref) {
  return AiMessagesRepository(
    client: ref.watch(supabaseClientProvider),
    userId: ref.watch(currentUserIdProvider),
  );
});

/// All chats for the current user (newest first). Used by drawer in chat
/// screen to render history.
final aiChatsStreamProvider = StreamProvider<List<AiChat>>((ref) {
  return ref.watch(aiMessagesRepositoryProvider).watchChats();
});

/// Currently selected chat id. `null` means "draft" — the next user message
/// will lazily create a fresh row in `ai_chats`.
final currentChatIdProvider = StateProvider<String?>((_) => null);

/// Persisted messages for [currentChatIdProvider]. Empty list when no chat
/// is selected yet.
final currentChatMessagesProvider = StreamProvider<List<AiMessage>>((ref) {
  final chatId = ref.watch(currentChatIdProvider);
  if (chatId == null) {
    return Stream.value(const <AiMessage>[]);
  }
  return ref.watch(aiMessagesRepositoryProvider).watchMessages(chatId);
});

/// User-message count for today (UTC). Drives the daily-quota progress bar
/// in the chat composer. Auto-refreshes whenever the chat messages stream
/// emits, so a freshly sent message bumps the bar without a manual reload.
final dailyMessageCountProvider = FutureProvider<int>((ref) async {
  ref.watch(currentChatMessagesProvider);
  final res = await ref.watch(aiMessagesRepositoryProvider).dailyUserMessageCount().run();
  return res.match(
    (f) => throw f,
    (count) => count,
  );
});

/// Prompt the user picked from the prompts grid; chat screen consumes it,
/// drops it into the input, and immediately auto-sends.
final pendingPromptProvider = StateProvider<String?>((_) => null);

/// Index of the active sub-tab inside [AiScreen]: 0=Chat, 1=Summaries,
/// 2=Prompts. Lifted to a provider so prompts grid can switch back to chat
/// after seeding [pendingPromptProvider].
final aiActiveTabProvider = StateProvider<int>((_) => 0);

// ---------------------------------------------------------------------------
// Chat controller
// ---------------------------------------------------------------------------

/// UI state of the chat composer / streaming message.
class ChatState {
  const ChatState({
    this.streamingText = '',
    this.isStreaming = false,
    this.rateLimited = false,
    this.errorMessage,
    this.pendingMessages = const <AiMessage>[],
  });

  /// Live text being streamed from the model. Empty when no stream is active.
  final String streamingText;

  /// `true` while a request is in flight or chunks are arriving.
  final bool isStreaming;

  /// `true` when the last request hit OpenRouter's daily rate limit (429).
  /// UI shows a red banner; cleared the next time the user successfully sends.
  final bool rateLimited;

  /// Generic error message — non-429 failure, e.g. invalid key, network.
  final String? errorMessage;

  /// Locally-inserted messages that have not yet arrived through Supabase
  /// realtime. UI merges these with the server stream so the user sees their
  /// own message immediately and the assistant reply does not blink between
  /// stream end and realtime emission. Reconciled on every server emission
  /// — entries already present on the server are dropped.
  final List<AiMessage> pendingMessages;

  ChatState copyWith({
    String? streamingText,
    bool? isStreaming,
    bool? rateLimited,
    String? errorMessage,
    bool clearError = false,
    List<AiMessage>? pendingMessages,
  }) {
    return ChatState(
      streamingText: streamingText ?? this.streamingText,
      isStreaming: isStreaming ?? this.isStreaming,
      rateLimited: rateLimited ?? this.rateLimited,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingMessages: pendingMessages ?? this.pendingMessages,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required Ref ref,
    OpenRouterClient Function(String apiKey)? clientFactory,
  })  : _ref = ref,
        _clientFactory = clientFactory ?? _defaultClientFactory,
        super(const ChatState()) {
    _ref.listen<AsyncValue<String?>>(openRouterKeyProvider, (prev, next) {
      next.whenData((key) {
        if (key != null && key.isNotEmpty && state.errorMessage == 'no_key') {
          state = state.copyWith(clearError: true);
        }
      });
    });
  }

  final Ref _ref;
  final OpenRouterClient Function(String apiKey) _clientFactory;
  StreamSubscription<String>? _sub;

  static OpenRouterClient _defaultClientFactory(String apiKey) =>
      OpenRouterClient(apiKey: apiKey);

  /// Cancel any in-flight stream. Idempotent.
  Future<void> cancel() async {
    await _sub?.cancel();
    _sub = null;
    state = state.copyWith(isStreaming: false, streamingText: '');
  }

  /// Drop pending messages that the server stream has already delivered.
  /// Called from the UI on every emission of `currentChatMessagesProvider`.
  void reconcile(List<AiMessage> serverMessages) {
    if (state.pendingMessages.isEmpty) return;
    final ids = serverMessages.map((m) => m.id).toSet();
    final remaining = state.pendingMessages
        .where((m) => !ids.contains(m.id))
        .toList(growable: false);
    if (remaining.length != state.pendingMessages.length) {
      state = state.copyWith(pendingMessages: remaining);
    }
  }

  void _appendPending(AiMessage message) {
    state = state.copyWith(
      pendingMessages: [...state.pendingMessages, message],
    );
  }

  /// Sends [text] as the next user message in the active chat.
  ///
  /// Side effects:
  /// 1. Clear previous error / 429 flags.
  /// 2. Lazy-create chat row when [currentChatIdProvider] is null.
  /// 3. Persist user message → call OpenRouter → accumulate stream into
  ///    [ChatState.streamingText] → persist final assistant message.
  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.isStreaming) return;

    // Resolve the API key first — without it we can't proceed.
    final apiKey = await _ref.read(openRouterKeyProvider.future);
    if (apiKey == null || apiKey.isEmpty) {
      state = state.copyWith(
        errorMessage: 'no_key',
        rateLimited: false,
      );
      return;
    }

    state = state.copyWith(
      streamingText: '',
      isStreaming: true,
      rateLimited: false,
      clearError: true,
    );

    final repo = _ref.read(aiMessagesRepositoryProvider);

    // Lazy create the chat the first time the user sends a message.
    var chatId = _ref.read(currentChatIdProvider);
    if (chatId == null) {
      final firstWords = text.length > 60 ? '${text.substring(0, 57)}…' : text;
      final createRes = await repo.createChat(title: firstWords).run();
      final created = createRes.match(
        (f) {
          state = state.copyWith(
            isStreaming: false,
            errorMessage: 'generic',
          );
          return null;
        },
        (ok) => ok,
      );
      if (created == null) return;
      chatId = created.id;
      _ref.read(currentChatIdProvider.notifier).state = chatId;
    }

    // Snapshot of prior messages — used for prompt-builder history.
    final priorMessages = await _safeListMessages(repo, chatId);

    // Persist the user message immediately so it shows up in the realtime
    // stream and survives a reload mid-streaming. Keep the returned row in
    // pendingMessages so the UI shows it without waiting for realtime.
    final userMsgRes = await repo.insertMessage(
      chatId: chatId,
      role: 'user',
      content: text,
    ).run();
    final userMsg = userMsgRes.match(
      (f) {
        state = state.copyWith(
          isStreaming: false,
          errorMessage: 'generic',
        );
        return null;
      },
      (ok) => ok,
    );
    if (userMsg == null) return;
    _appendPending(userMsg);

    // Build the prompt with full app context.
    final client = _clientFactory(apiKey);
    final builder = PromptBuilder(client: client);
    final user = _ref.read(currentUserIdProvider);
    final habits = _ref.read(habitsStreamProvider).value ?? const [];
    final journal = _ref.read(journalEntriesProvider).value ?? const [];

    final history = priorMessages
        .map((m) => ChatMessage(role: m.role, content: m.content))
        .toList();

    final selectedModel = _ref.read(preferredModelControllerProvider).value;

    List<OpenRouterMessage> messages;
    try {
      messages = await builder.build(
        user: PromptUser(id: user),
        context: PromptContext(
          habits: habits,
          recentLogs: const [],
          recentJournal: journal,
        ),
        history: history,
        newMessage: text,
      );
    } catch (_) {
      state = state.copyWith(
        isStreaming: false,
        errorMessage: 'generic',
      );
      return;
    }

    final buffer = StringBuffer();
    final completer = Completer<void>();

    _sub = client
        .chatCompletion(
          messages: messages,
          model: selectedModel ?? Env.defaultModel,
          stream: true,
        )
        .listen(
          (chunk) {
            buffer.write(chunk);
            // Push partial text to UI immediately for the streaming effect.
            state = state.copyWith(streamingText: buffer.toString());
          },
          onError: (Object e, StackTrace st) {
            final is429 = e is DioException && e.response?.statusCode == 429;
            state = state.copyWith(
              isStreaming: false,
              streamingText: '',
              rateLimited: is429,
              errorMessage: is429 ? null : 'generic',
            );
            if (!completer.isCompleted) completer.complete();
          },
          onDone: () async {
            final finalText = buffer.toString().trim();
            if (finalText.isNotEmpty) {
              final assistantMsgRes = await repo.insertMessage(
                chatId: chatId!,
                role: 'assistant',
                content: finalText,
              ).run();
              assistantMsgRes.match(
                (f) {
                  // Persistence error — surface generic message but keep the
                  // text already shown so the user does not lose the reply.
                  state = state.copyWith(
                    errorMessage: 'generic',
                  );
                },
                (assistantMsg) {
                  // Hold the assistant reply locally until realtime emits it,
                  // otherwise the bubble would blink off between stream end
                  // and the next stream tick.
                  _appendPending(assistantMsg);
                },
              );
            }
            state = state.copyWith(
              isStreaming: false,
              streamingText: '',
            );
            if (!completer.isCompleted) completer.complete();
          },
          cancelOnError: true,
        );
    await completer.future;
  }

  Future<List<AiMessage>> _safeListMessages(
    AiMessagesRepository repo,
    String chatId,
  ) async {
    final res = await repo.listMessages(chatId).run();
    return res.getOrElse((_) => const <AiMessage>[]);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref: ref);
});
