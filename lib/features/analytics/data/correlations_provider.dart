import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../ai/data/openrouter_client.dart';
import '../../ai/data/openrouter_key_repository.dart';
import '../../habits/data/habit_log_model.dart';
import '../../habits/data/habit_model.dart';
import '../../habits/data/habits_providers.dart';
import '../../journal/data/journal_entry_model.dart';
import '../../journal/data/journal_providers.dart';

/// Single AI-derived correlation insight.
class CorrelationInsight {
  const CorrelationInsight({
    required this.habit,
    required this.factor,
    required this.direction,
    required this.strength,
    this.note,
  });

  /// Name (or id) of the habit involved.
  final String habit;

  /// What is correlated with the habit (e.g. "mood", "sleep", "weekend").
  final String factor;

  /// `up` (positive correlation) | `down` (negative) | `mixed` (unclear).
  final String direction;

  /// 0..1 — model's confidence in the relationship.
  final double strength;

  /// Optional one-line elaboration for the card.
  final String? note;

  factory CorrelationInsight.fromJson(Map<String, dynamic> json) {
    final raw = json['strength'];
    return CorrelationInsight(
      habit: (json['habit'] ?? '').toString(),
      factor: (json['factor'] ?? '').toString(),
      direction: (json['direction'] ?? 'mixed').toString(),
      strength: raw is num ? raw.toDouble().clamp(0.0, 1.0) : 0.5,
      note: json['note']?.toString(),
    );
  }
}

/// Why correlations could not be computed (UI surfaces a tailored message).
sealed class CorrelationsError implements Exception {
  const CorrelationsError();
}

class CorrelationsNoKeyError extends CorrelationsError {
  const CorrelationsNoKeyError();
}

class CorrelationsNotEnoughDataError extends CorrelationsError {
  const CorrelationsNotEnoughDataError({required this.logsCount});
  final int logsCount;
}

class CorrelationsRateLimitedError extends CorrelationsError {
  const CorrelationsRateLimitedError();
}

class CorrelationsGenericError extends CorrelationsError {
  const CorrelationsGenericError(this.message);
  final String message;
}

/// AI-derived insights computed on demand. AutoDispose so leaving the screen
/// doesn't hold the result forever; manual `ref.invalidate` reruns it.
final correlationsProvider =
    FutureProvider.autoDispose<List<CorrelationInsight>>((ref) async {
  final key = await ref.read(openRouterKeyProvider.future);
  if (key == null || key.isEmpty) {
    throw const CorrelationsNoKeyError();
  }

  final habits = ref.read(habitsStreamProvider).valueOrNull ?? const [];
  final entries =
      ref.read(journalEntriesProvider).valueOrNull ?? const [];

  // Need at least 7 logs across 7 calendar days for the model to find a
  // signal. Pull a 30-day window of logs through the existing repo.
  final today = ref.read(todayProvider);
  final from = today.subtract(const Duration(days: 30));
  final logsRepo = ref.read(habitLogsRepositoryProvider);
  final List<HabitLogModel> logs;
  try {
    logs = await logsRepo.rangeForUser(from, today);
  } catch (e) {
    throw CorrelationsGenericError('logs_fetch_failed: $e');
  }
  if (logs.length < 7) {
    throw CorrelationsNotEnoughDataError(logsCount: logs.length);
  }

  final prompt = _buildPrompt(habits: habits, logs: logs, journal: entries);

  final client = OpenRouterClient(apiKey: key);
  final stream = client.chatCompletion(
    messages: [
      const OpenRouterMessage(
        role: 'system',
        content: _systemPrompt,
      ),
      OpenRouterMessage(role: 'user', content: prompt),
    ],
    model: Env.defaultModel,
    stream: false,
  );

  final buf = StringBuffer();
  try {
    await for (final chunk in stream) {
      buf.write(chunk);
    }
  } catch (e) {
    final text = e.toString();
    if (text.contains('429')) throw const CorrelationsRateLimitedError();
    throw CorrelationsGenericError(text);
  }

  final raw = buf.toString().trim();
  return _parseResponse(raw);
});

const _systemPrompt = '''
You analyse a user's habit-tracker data and return correlations as strict JSON.
Output JSON only, no prose, no markdown fences. Schema:
{"insights":[{"habit":string,"factor":string,"direction":"up"|"down"|"mixed","strength":number,"note":string}]}
- "habit" must be one of the habit names in the input.
- "factor" describes the contextual signal (e.g. "weekend", "morning", "mood<=4", "after_journal").
- "direction" is up if doing the habit correlates with a positive change in factor, down for negative, mixed otherwise.
- "strength" is 0..1 confidence.
- Return at most 5 insights, prioritise high-strength ones.
- If signal is too weak, return {"insights":[]}.
''';

String _buildPrompt({
  required List<HabitModel> habits,
  required List<HabitLogModel> logs,
  required List<JournalEntryModel> journal,
}) {
  final names = {for (final h in habits) h.id: h.name};
  final buf = StringBuffer();
  buf.writeln('Habits:');
  for (final h in habits) {
    buf.writeln('- ${h.name} [${h.type.wireName}]');
  }
  buf.writeln();
  buf.writeln('Logs (${logs.length}, last 30 days):');
  buf.writeln('date | habit | status | value');
  for (final l in logs) {
    final name = names[l.habitId] ?? l.habitId;
    final v = l.value?.toString() ?? '';
    final d = '${l.date.year}-${l.date.month.toString().padLeft(2, '0')}-${l.date.day.toString().padLeft(2, '0')}';
    buf.writeln('$d | $name | ${l.status.wireName} | $v');
  }
  if (journal.isNotEmpty) {
    buf.writeln();
    buf.writeln('Journal mood/energy (${journal.length}):');
    buf.writeln('date | mood | energy');
    for (final e in journal.take(30)) {
      final d = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      buf.writeln('$d | ${e.mood ?? '-'} | ${e.energy ?? '-'}');
    }
  }
  buf.writeln();
  buf.writeln('Return correlations as JSON per the system schema.');
  return buf.toString();
}

/// Forgiving JSON extractor: model may wrap output in ```json fences or add
/// stray prose. Find the first `{...}` block and try to parse it.
List<CorrelationInsight> _parseResponse(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) {
    return const [];
  }
  final slice = raw.substring(start, end + 1);
  try {
    final decoded = jsonDecode(slice);
    if (decoded is! Map) return const [];
    final list = decoded['insights'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((m) => CorrelationInsight.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  } catch (_) {
    return const [];
  }
}
