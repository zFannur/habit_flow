import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../journal/data/journal_providers.dart';

class AiPrompt {
  const AiPrompt({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.title,
    required this.description,
    required this.category, // 'analysis', 'emotions', 'growth', 'relapse'
    this.isSystem = false,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String emoji;
  final String title;
  final String description;
  final String category;
  final bool isSystem;
  final DateTime createdAt;

  factory AiPrompt.fromSupabase(Map<String, dynamic> row) {
    return AiPrompt(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      emoji: row['emoji'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      category: row['category'] as String,
      isSystem: row['is_system'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

class AiPromptsRepository {
  AiPromptsRepository({
    required SupabaseClient client,
    required String userId,
  })  : _client = client,
        _userId = userId;

  final SupabaseClient _client;
  final String _userId;

  static const _table = 'ai_prompts';

  /// Watches all custom prompts for the current user.
  Stream<List<AiPrompt>> watchCustomPrompts() {
    if (_userId.isEmpty) return Stream.value([]);
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(AiPrompt.fromSupabase).toList());
  }

  /// Adds a new custom prompt.
  Future<void> createPrompt({
    required String emoji,
    required String title,
    required String description,
    required String category,
  }) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');
    await _client.from(_table).insert({
      'user_id': _userId,
      'emoji': emoji,
      'title': title,
      'description': description,
      'category': category,
      'is_system': false,
    });
  }

  /// Deletes a custom prompt by ID.
  Future<void> deletePrompt(String id) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');
    await _client.from(_table).delete().eq('id', id).eq('user_id', _userId);
  }
}

final aiPromptsRepositoryProvider = Provider<AiPromptsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  return AiPromptsRepository(client: client, userId: userId);
});

final customPromptsStreamProvider = StreamProvider<List<AiPrompt>>((ref) {
  return ref.watch(aiPromptsRepositoryProvider).watchCustomPrompts();
});
