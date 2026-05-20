import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../journal/data/journal_providers.dart';

/// Mirrors a row in `ai_summaries` (SPEC §5).
///
/// `range_start_date` / `range_end_date` are Postgres `DATE` — we treat them
/// as UTC midnight so equality stays timezone-stable.
class AiSummary {
  const AiSummary({
    required this.id,
    required this.userId,
    required this.rangeStartN,
    required this.rangeEndN,
    required this.rangeStartDate,
    required this.rangeEndDate,
    required this.content,
    required this.modelUsed,
    this.tokensUsed,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final int rangeStartN;
  final int rangeEndN;
  final DateTime rangeStartDate;
  final DateTime rangeEndDate;
  final String content;
  final String modelUsed;
  final int? tokensUsed;
  final DateTime createdAt;

  factory AiSummary.fromSupabase(Map<String, dynamic> row) {
    return AiSummary(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      rangeStartN: (row['range_start_n'] as num).toInt(),
      rangeEndN: (row['range_end_n'] as num).toInt(),
      rangeStartDate: _parseDateOnly(row['range_start_date'] as String),
      rangeEndDate: _parseDateOnly(row['range_end_date'] as String),
      content: (row['content'] as String?) ?? '',
      modelUsed: (row['model_used'] as String?) ?? '',
      tokensUsed: (row['tokens_used'] as num?)?.toInt(),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

DateTime _parseDateOnly(String s) {
  final parts = s.split('-');
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

/// Thin wrapper around the `ai_summaries` Supabase table.
class AiSummariesRepository {
  AiSummariesRepository({
    required SupabaseClient client,
    required String userId,
  })   : _client = client,
        _userId = userId;

  final SupabaseClient _client;
  final String _userId;

  static const _table = 'ai_summaries';

  /// Realtime stream of all summaries for the current user, newest first.
  Stream<List<AiSummary>> watchAll() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(AiSummary.fromSupabase).toList());
  }

  /// One-shot fetch for [id]. Returns `null` if not found.
  Future<AiSummary?> findById(String id) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .maybeSingle();
    if (row == null) return null;
    return AiSummary.fromSupabase(row);
  }

  /// Triggers Edge Function [generate_summary] to regenerate a summary
  /// for [rangeEndN] using the provided [openRouterKey] and optionally overriding the [model].
  /// Returns the newly created summary ID.
  Future<String> regenerate({
    required int rangeEndN,
    required String? openRouterKey,
    required String? model,
  }) async {
    final payload = <String, dynamic>{
      'user_id': _userId,
      'range_end_n': rangeEndN,
    };
    if (openRouterKey != null) {
      payload['openrouter_key'] = openRouterKey;
    }
    if (model != null) {
      payload['model'] = model;
    }

    final response = await _client.functions.invoke(
      'generate_summary',
      body: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['ok'] == false || data['status'] == 'error') {
        throw Exception(data['reason'] ?? 'Failed to regenerate summary');
      }
      final newId = data['summary_id'] as String?;
      if (newId != null) return newId;
    }
    throw Exception('No summary_id returned from Edge Function');
  }

  /// Deletes a summary by [id].
  Future<void> deleteSummary(String id) async {
    await _client.from(_table).delete().eq('id', id).eq('user_id', _userId);
  }
}

final aiSummariesRepositoryProvider = Provider<AiSummariesRepository>((ref) {
  return AiSummariesRepository(
    client: ref.watch(supabaseClientProvider),
    userId: ref.watch(currentUserIdProvider),
  );
});

/// Realtime list of AI summaries for the current user (newest first).
final aiSummariesProvider = StreamProvider<List<AiSummary>>((ref) {
  return ref.watch(aiSummariesRepositoryProvider).watchAll();
});

/// One-shot lookup of a single summary by id.
final aiSummaryByIdProvider =
    FutureProvider.family<AiSummary?, String>((ref, id) {
  return ref.watch(aiSummariesRepositoryProvider).findById(id);
});
