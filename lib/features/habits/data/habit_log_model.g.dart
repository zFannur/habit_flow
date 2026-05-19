// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitLogModelImpl _$$HabitLogModelImplFromJson(Map<String, dynamic> json) =>
    _$HabitLogModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String,
      date: _dateFromJson(json['log_date'] as String),
      status: _statusFromJson(json['status'] as String),
      value: (json['value'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$HabitLogModelImplToJson(_$HabitLogModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'habit_id': instance.habitId,
      'log_date': _dateToJson(instance.date),
      'status': _statusToJson(instance.status),
      'value': instance.value,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
    };
