import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';

/// Lightweight projection of an `ai_messages` row.
class AiMessage {
  const AiMessage({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.tokensUsed,
  });

  final String id;
  final String chatId;
  final String userId;
  final String role;
  final String content;
  final int? tokensUsed;
  final DateTime createdAt;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      content: (json['content'] ?? '') as String,
      tokensUsed: (json['tokens_used'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Lightweight projection of an `ai_chats` row.
class AiChat {
  const AiChat({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AiChat.fromJson(Map<String, dynamic> json) {
    return AiChat(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: (json['title'] ?? '') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// CRUD wrapper over `ai_chats` and `ai_messages`. RLS on the server is the
/// authoritative filter; we still scope by `user_id` client-side to keep
/// queries deterministic.
class AiMessagesRepository {
  AiMessagesRepository({required SupabaseClient client, required String userId})
      : _client = client,
        _userId = userId;

  final SupabaseClient _client;
  final String _userId;

  static const _chatsTable = 'ai_chats';
  static const _messagesTable = 'ai_messages';

  Failure _mapError(Object e) {
    if (e is PostgrestException) {
      return Failure.server(
        status: int.tryParse(e.code ?? '') ?? 500,
        message: e.message,
      );
    }
    return Failure.unknown(message: e.toString());
  }

  /// All chats for the current user, newest first.
  AppTask<List<AiChat>> listChats() {
    return TaskEither.tryCatch(
      () async {
        final rows = await _client
            .from(_chatsTable)
            .select()
            .eq('user_id', _userId)
            .order('updated_at', ascending: false);
        return (rows as List)
            .cast<Map<String, dynamic>>()
            .map(AiChat.fromJson)
            .toList();
      },
      (e, st) => _mapError(e),
    );
  }

  /// Realtime stream of chats (newest first) for the drawer list.
  Stream<List<AiChat>> watchChats() {
    return _client
        .from(_chatsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('updated_at', ascending: false)
        .map((rows) => rows.map(AiChat.fromJson).toList());
  }

  /// Insert a fresh chat with [title]. Falls back to a generic title when
  /// caller passes `null` so the row has a useful drawer label until the
  /// first reply arrives.
  AppTask<AiChat> createChat({String? title}) {
    return TaskEither.tryCatch(
      () async {
        final cleanTitle = (title != null && title.isNotEmpty) ? title : null;
        final row = await _client
            .from(_chatsTable)
            .insert({
              'user_id': _userId,
              'title': ?cleanTitle,
            })
            .select()
            .single();
        return AiChat.fromJson(row);
      },
      (e, st) => _mapError(e),
    );
  }

  AppTask<void> renameChat(String chatId, String title) {
    return TaskEither.tryCatch(
      () => _client
          .from(_chatsTable)
          .update({'title': title})
          .eq('id', chatId)
          .eq('user_id', _userId),
      (e, st) => _mapError(e),
    );
  }

  AppTask<void> deleteChat(String chatId) {
    return TaskEither.tryCatch(
      () => _client
          .from(_chatsTable)
          .delete()
          .eq('id', chatId)
          .eq('user_id', _userId),
      (e, st) => _mapError(e),
    );
  }

  /// Messages for [chatId] ordered chronologically.
  AppTask<List<AiMessage>> listMessages(String chatId) {
    return TaskEither.tryCatch(
      () async {
        final rows = await _client
            .from(_messagesTable)
            .select()
            .eq('chat_id', chatId)
            .eq('user_id', _userId)
            .order('created_at', ascending: true);
        return (rows as List)
            .cast<Map<String, dynamic>>()
            .map(AiMessage.fromJson)
            .toList();
      },
      (e, st) => _mapError(e),
    );
  }

  /// Realtime stream of messages for [chatId] ordered chronologically.
  Stream<List<AiMessage>> watchMessages(String chatId) {
    return _client
        .from(_messagesTable)
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map(AiMessage.fromJson).toList());
  }

  /// Number of `role = 'user'` messages this user sent today (UTC). Used to
  /// drive the request-progress bar in the chat composer; persists across
  /// app restarts unlike a local counter.
  AppTask<int> dailyUserMessageCount() {
    return TaskEither.tryCatch(
      () async {
        final now = DateTime.now().toUtc();
        final startOfDay = DateTime.utc(now.year, now.month, now.day);
        final res = await _client
            .from(_messagesTable)
            .count(CountOption.exact)
            .eq('user_id', _userId)
            .eq('role', 'user')
            .gte('created_at', startOfDay.toIso8601String());
        return res;
      },
      (e, st) => _mapError(e),
    );
  }

  /// Inserts a single message and returns the persisted row.
  AppTask<AiMessage> insertMessage({
    required String chatId,
    required String role,
    required String content,
    int? tokensUsed,
  }) {
    return TaskEither.tryCatch(
      () async {
        final row = await _client
            .from(_messagesTable)
            .insert({
              'chat_id': chatId,
              'user_id': _userId,
              'role': role,
              'content': content,
              'tokens_used': ?tokensUsed,
            })
            .select()
            .single();
        return AiMessage.fromJson(row);
      },
      (e, st) => _mapError(e),
    );
  }
}
