// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JournalEntryModelImpl _$$JournalEntryModelImplFromJson(
  Map<String, dynamic> json,
) => _$JournalEntryModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  date: DateTime.parse(json['entry_date'] as String),
  text: json['free_text'] as String? ?? '',
  mood: (json['mood'] as num?)?.toInt(),
  energy: (json['energy'] as num?)?.toInt(),
  answers: (json['answers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  linkedHabitLogIds:
      (json['linked_habit_log_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$JournalEntryModelImplToJson(
  _$JournalEntryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'entry_date': instance.date.toIso8601String(),
  'free_text': instance.text,
  'mood': instance.mood,
  'energy': instance.energy,
  'answers': instance.answers,
  'linked_habit_log_ids': instance.linkedHabitLogIds,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
