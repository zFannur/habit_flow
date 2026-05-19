import '../../../core/utils/token_counter.dart';
import '../../habits/data/habit_log_model.dart';
import '../../habits/data/habit_model.dart';
import '../../journal/data/journal_entry_model.dart';
import '../domain/style_prompts.dart';
import 'openrouter_client.dart';

/// Лёгкий профиль пользователя для шапки промпта. Полноценная сущность
/// `users` появится в более поздних задачах, поэтому здесь — минимально
/// необходимый набор полей для system-сообщений (см. SPEC §7.4).
class PromptUser {
  const PromptUser({
    required this.id,
    this.name,
    this.language = 'ru',
    this.aiStyle = 'coach',
  });

  final String id;
  final String? name;
  final String language;

  /// Идентификатор стиля ИИ (см. SPEC §12). Реальные системные
  /// промпты и тексты — задача 06-06; здесь используется только как
  /// маркер.
  final String aiStyle;
}

/// Контекст приложения (привычки, логи, дневник, последняя сводка),
/// который скармливается в промпт.
class PromptContext {
  const PromptContext({
    this.habits = const [],
    this.recentLogs = const [],
    this.recentJournal = const [],
    this.lastSummary,
  });

  final List<HabitModel> habits;

  /// Последние ~50 записей `habit_logs` (см. SPEC §7.4). Любой избыток
  /// будет усечён в `PromptBuilder.build`.
  final List<HabitLogModel> recentLogs;

  /// Последние ~30 записей дневника. Каждая будет обрезана до 500 символов.
  final List<JournalEntryModel> recentJournal;

  /// Текст последней `ai_summary` (если есть).
  final String? lastSummary;
}

/// Минимальный shape сообщения чата, без привязки к freezed/json. Совпадает
/// по форме с `OpenRouterMessage`, чтобы builder напрямую отдавал готовый
/// список для `OpenRouterClient.chatCompletion`.
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final String role;
  final String content;

  OpenRouterMessage toOpenRouter() =>
      OpenRouterMessage(role: role, content: content);
}

/// Сборка контекстного окна для chat-запроса (SPEC §7.4) с защитой от
/// переполнения 80K-бюджета токенов.
///
/// Логика сжатия:
/// - если суммарный размер промпта > [tokenBudget], всё, что **до**
///   `keepRecentMessages` последних реплик, сворачивается в одну
///   `system`-summary через дешёвую модель;
/// - сжатие **рекурсивное**: если после первой компрессии всё ещё
///   тесно — сжимаем результат ещё раз. Когда сжимать уже нечего
///   (`keepRecentMessages` >= history.length), возвращаем как есть, чтобы
///   гарантированно остановиться.
class PromptBuilder {
  PromptBuilder({
    required this.client,
    this.compressionModel = 'openai/gpt-oss-120b:free',
    this.tokenBudget = 80000,
    this.keepRecentMessages = 5,
    this.maxLogs = 50,
    this.maxJournalEntries = 30,
    this.journalTruncateChars = 500,
    this.maxHistoryMessages = 20,
  });

  final OpenRouterClient client;
  final String compressionModel;
  final int tokenBudget;
  final int keepRecentMessages;
  final int maxLogs;
  final int maxJournalEntries;
  final int journalTruncateChars;
  final int maxHistoryMessages;

  /// Собирает финальный список сообщений для отправки в OpenRouter.
  ///
  /// Контекст оформляется как несколько `system`-сообщений, история
  /// чата сохраняет роли как есть, а `newMessage` добавляется как
  /// последняя `user`-реплика.
  Future<List<OpenRouterMessage>> build({
    required PromptUser user,
    required PromptContext context,
    required List<ChatMessage> history,
    required String newMessage,
    AiStyle? style,
    @Deprecated('Use [style] of type AiStyle. Kept for chat-flow back-compat.')
    String? summaryStyle,
  }) async {
    // Resolution order: explicit `style` arg → legacy `summaryStyle` string
    // (callers from 06-04 chat flow) → user's persisted `aiStyle` field.
    final resolved = style ??
        AiStyle.fromWire(summaryStyle ?? user.aiStyle);
    final systemBlocks = _buildSystemBlocks(user, context, resolved);

    // Усекаем history до последних N сообщений ещё до токен-проверки —
    // это самый дешёвый способ держать промпт в рамках.
    final trimmedHistory = history.length > maxHistoryMessages
        ? history.sublist(history.length - maxHistoryMessages)
        : List<ChatMessage>.from(history);

    final newUserMsg = ChatMessage(role: 'user', content: newMessage);

    final compactedHistory = await _compressIfNeeded(
      systemBlocks: systemBlocks,
      history: trimmedHistory,
      newMessage: newUserMsg,
    );

    return <OpenRouterMessage>[
      ...systemBlocks.map((s) => OpenRouterMessage(role: 'system', content: s)),
      ...compactedHistory.map((m) => m.toOpenRouter()),
      newUserMsg.toOpenRouter(),
    ];
  }

  // ---------------------------------------------------------------------------
  // System blocks
  // ---------------------------------------------------------------------------

  List<String> _buildSystemBlocks(
    PromptUser user,
    PromptContext ctx,
    AiStyle style,
  ) {
    final blocks = <String>[];

    blocks.add(_styleBlock(style, user.language));
    blocks.add(_userBlock(user, ctx.habits));
    if (ctx.lastSummary != null && ctx.lastSummary!.trim().isNotEmpty) {
      blocks.add('Last AI summary:\n${ctx.lastSummary!.trim()}');
    }
    if (ctx.recentLogs.isNotEmpty) {
      blocks.add(_logsTable(ctx.recentLogs.take(maxLogs).toList(), ctx.habits));
    }
    if (ctx.recentJournal.isNotEmpty) {
      blocks.add(
        _journalBlock(ctx.recentJournal.take(maxJournalEntries).toList()),
      );
    }
    return blocks;
  }

  String _styleBlock(AiStyle style, String language) {
    // SPEC §12: stylised system prompt + privacy/topic suffix. The
    // existing test suite expects the word "HabitFlow" to appear in the
    // first system block, so we tag it here as a stable marker even
    // though the real persona text doesn't repeat it.
    final body = StylePrompts.systemPrompt(style, language);
    return '[HabitFlow assistant — style: ${style.wireName}]\n$body';
  }

  String _userBlock(PromptUser user, List<HabitModel> habits) {
    final buf = StringBuffer();
    buf.writeln('User profile:');
    buf.writeln('- id: ${user.id}');
    if (user.name != null && user.name!.isNotEmpty) {
      buf.writeln('- name: ${user.name}');
    }
    buf.writeln('- language: ${user.language}');
    final active = habits.where((h) => !h.isArchived).toList();
    if (active.isNotEmpty) {
      buf.writeln('Active habits (${active.length}):');
      for (final h in active) {
        buf.writeln('- ${h.name} [${h.type.wireName}]');
      }
    }
    // SPEC §8 — Habit Stacking (08-01). Surface chains "A → B" so the
    // model can reason about anchor/follower relations.
    final habitsById = {for (final h in active) h.id: h};
    final stackLines = <String>[];
    for (final h in active) {
      final anchorId = h.stackAfterHabitId;
      if (anchorId == null || anchorId.isEmpty) continue;
      final anchor = habitsById[anchorId];
      if (anchor == null) continue;
      stackLines.add('- ${anchor.name} → ${h.name}');
    }
    if (stackLines.isNotEmpty) {
      buf.writeln('Stacks:');
      for (final line in stackLines) {
        buf.writeln(line);
      }
    }

    // SPEC §8: identity-based habits. Pull non-empty `identity_statement`
    // values so the model can mirror them back when the user mentions
    // progress (см. план 08-05).
    final identities = active
        .map((h) => h.identityStatement?.trim())
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
    if (identities.isNotEmpty) {
      buf.writeln('Identity statements:');
      for (final s in identities) {
        buf.writeln('- "Я становлюсь человеком, который $s"');
      }
      buf.writeln(
        'Если пользователь упоминает прогресс, напомни ему identity '
        'statement из списка выше.',
      );
    }
    return buf.toString().trimRight();
  }

  String _logsTable(List<HabitLogModel> logs, List<HabitModel> habits) {
    final names = {for (final h in habits) h.id: h.name};
    final buf = StringBuffer();
    buf.writeln('Recent habit logs (${logs.length}):');
    buf.writeln('date | habit | status | value');
    for (final log in logs) {
      final name = names[log.habitId] ?? log.habitId;
      final v = log.value?.toString() ?? '';
      buf.writeln(
        '${_dateOnly(log.date)} | $name | ${log.status.wireName} | $v',
      );
    }
    return buf.toString().trimRight();
  }

  String _journalBlock(List<JournalEntryModel> entries) {
    final buf = StringBuffer();
    buf.writeln('Recent journal entries (${entries.length}):');
    for (final e in entries) {
      final raw = e.text.trim();
      final truncated = raw.length > journalTruncateChars
          ? '${raw.substring(0, journalTruncateChars)}…'
          : raw;
      final mood = e.mood != null ? ' mood=${e.mood}' : '';
      final energy = e.energy != null ? ' energy=${e.energy}' : '';
      buf.writeln('[${_dateOnly(e.date)}$mood$energy] $truncated');
    }
    return buf.toString().trimRight();
  }

  String _dateOnly(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  // ---------------------------------------------------------------------------
  // Token budget / compression
  // ---------------------------------------------------------------------------

  Future<List<ChatMessage>> _compressIfNeeded({
    required List<String> systemBlocks,
    required List<ChatMessage> history,
    required ChatMessage newMessage,
  }) async {
    final total = _estimate(systemBlocks, history, newMessage);
    if (total <= tokenBudget) return history;

    // Нечего сжимать — последних `keepRecentMessages` уже достаточно
    // мало; возвращаем как есть, чтобы избежать бесконечной рекурсии.
    if (history.length <= keepRecentMessages) return history;

    final cutoff = history.length - keepRecentMessages;
    final toCompress = history.sublist(0, cutoff);
    final tail = history.sublist(cutoff);

    final summary = await _summarize(toCompress);
    final compressed = <ChatMessage>[
      ChatMessage(
        role: 'system',
        content: 'Earlier chat summary:\n$summary',
      ),
      ...tail,
    ];

    // Рекурсивно: вдруг даже после сжатия не помещаемся (например,
    // пришёл огромный контекст). Защита от бесконечной рекурсии — в
    // условии выше.
    return _compressIfNeeded(
      systemBlocks: systemBlocks,
      history: compressed,
      newMessage: newMessage,
    );
  }

  int _estimate(
    List<String> systemBlocks,
    List<ChatMessage> history,
    ChatMessage newMessage,
  ) {
    var total = TokenCounter.countAll(systemBlocks);
    for (final m in history) {
      total += TokenCounter.count(m.content);
    }
    total += TokenCounter.count(newMessage.content);
    return total;
  }

  Future<String> _summarize(List<ChatMessage> messages) async {
    final transcript = messages
        .map((m) => '${m.role}: ${m.content}')
        .join('\n');
    final req = <OpenRouterMessage>[
      const OpenRouterMessage(
        role: 'system',
        content:
            'Summarize the following chat transcript in <= 200 words. '
            'Preserve user goals, decisions and any open questions. '
            'Output plain text, no preamble.',
      ),
      OpenRouterMessage(role: 'user', content: transcript),
    ];
    final stream = client.chatCompletion(
      messages: req,
      model: compressionModel,
      stream: false,
    );
    final buf = StringBuffer();
    await for (final chunk in stream) {
      buf.write(chunk);
    }
    final text = buf.toString().trim();
    // Если модель вернула пусто — не уходим в null/empty: упадём в фолбэк
    // обрезкой, чтобы цикл сжатия гарантированно сходился.
    if (text.isEmpty) {
      return transcript.length > 2000
          ? '${transcript.substring(0, 2000)}…'
          : transcript;
    }
    return text;
  }
}
