// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitCategoryModelImpl _$$HabitCategoryModelImplFromJson(
  Map<String, dynamic> json,
) => _$HabitCategoryModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String?,
  name: json['name'] as String,
  iconEmoji: json['icon_emoji'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$HabitCategoryModelImplToJson(
  _$HabitCategoryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'icon_emoji': instance.iconEmoji,
  'created_at': instance.createdAt.toIso8601String(),
};
