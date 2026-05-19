// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitModelImpl _$$HabitModelImplFromJson(Map<String, dynamic> json) =>
    _$HabitModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      categoryId: json['category_id'] as String?,
      type: _typeFromJson(json['habit_type'] as String),
      emoji: json['icon_emoji'] as String?,
      iconTelegramFileId: json['icon_telegram_file_id'] as String?,
      accentColor: json['color'] as String?,
      target: (json['target_value'] as num?)?.toDouble(),
      unit: json['target_unit'] as String?,
      scheduleType: _scheduleTypeFromJson(json['schedule_type'] as String),
      schedule:
          json['schedule_config'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      reminderTimes: json['reminder_times'] == null
          ? const <String>[]
          : _reminderTimesFromJson(json['reminder_times']),
      startedAt: _dateFromJson(json['start_date'] as String),
      endedAt: _dateFromJsonNullable(json['end_date'] as String?),
      stackAfterHabitId: json['stack_after_habit_id'] as String?,
      implementationWhen: json['implementation_when'] as String?,
      implementationWhere: json['implementation_where'] as String?,
      identityStatement: json['identity_statement'] as String?,
      twoMinuteVersion: json['two_minute_version'] as String?,
      reward: json['reward'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      position: (json['position'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$HabitModelImplToJson(_$HabitModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'category': instance.category,
      'category_id': instance.categoryId,
      'habit_type': _typeToJson(instance.type),
      'icon_emoji': instance.emoji,
      'icon_telegram_file_id': instance.iconTelegramFileId,
      'color': instance.accentColor,
      'target_value': instance.target,
      'target_unit': instance.unit,
      'schedule_type': _scheduleTypeToJson(instance.scheduleType),
      'schedule_config': instance.schedule,
      'reminder_times': _reminderTimesToJson(instance.reminderTimes),
      'start_date': _dateToJson(instance.startedAt),
      'end_date': _dateToJsonNullable(instance.endedAt),
      'stack_after_habit_id': instance.stackAfterHabitId,
      'implementation_when': instance.implementationWhen,
      'implementation_where': instance.implementationWhere,
      'identity_statement': instance.identityStatement,
      'two_minute_version': instance.twoMinuteVersion,
      'reward': instance.reward,
      'is_archived': instance.isArchived,
      'position': instance.position,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
