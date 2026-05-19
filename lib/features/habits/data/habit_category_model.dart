import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_category_model.freezed.dart';
part 'habit_category_model.g.dart';

/// Mirrors the `habit_categories` table (SPEC §5).
///
/// `userId == null` means a system / global category seeded for everyone.
@freezed
class HabitCategoryModel with _$HabitCategoryModel {
  const HabitCategoryModel._();

  const factory HabitCategoryModel({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    required String name,
    @JsonKey(name: 'icon_emoji') String? iconEmoji,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _HabitCategoryModel;

  factory HabitCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$HabitCategoryModelFromJson(json);

  /// `true` when this is a system-wide category (not owned by a user).
  bool get isSystem => userId == null;
}
