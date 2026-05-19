// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HabitCategoryModel _$HabitCategoryModelFromJson(Map<String, dynamic> json) {
  return _HabitCategoryModel.fromJson(json);
}

/// @nodoc
mixin _$HabitCategoryModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'icon_emoji')
  String? get iconEmoji => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this HabitCategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HabitCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitCategoryModelCopyWith<HabitCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitCategoryModelCopyWith<$Res> {
  factory $HabitCategoryModelCopyWith(
    HabitCategoryModel value,
    $Res Function(HabitCategoryModel) then,
  ) = _$HabitCategoryModelCopyWithImpl<$Res, HabitCategoryModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String? userId,
    String name,
    @JsonKey(name: 'icon_emoji') String? iconEmoji,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$HabitCategoryModelCopyWithImpl<$Res, $Val extends HabitCategoryModel>
    implements $HabitCategoryModelCopyWith<$Res> {
  _$HabitCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HabitCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? name = null,
    Object? iconEmoji = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            iconEmoji: freezed == iconEmoji
                ? _value.iconEmoji
                : iconEmoji // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HabitCategoryModelImplCopyWith<$Res>
    implements $HabitCategoryModelCopyWith<$Res> {
  factory _$$HabitCategoryModelImplCopyWith(
    _$HabitCategoryModelImpl value,
    $Res Function(_$HabitCategoryModelImpl) then,
  ) = __$$HabitCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String? userId,
    String name,
    @JsonKey(name: 'icon_emoji') String? iconEmoji,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$HabitCategoryModelImplCopyWithImpl<$Res>
    extends _$HabitCategoryModelCopyWithImpl<$Res, _$HabitCategoryModelImpl>
    implements _$$HabitCategoryModelImplCopyWith<$Res> {
  __$$HabitCategoryModelImplCopyWithImpl(
    _$HabitCategoryModelImpl _value,
    $Res Function(_$HabitCategoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HabitCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? name = null,
    Object? iconEmoji = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$HabitCategoryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        iconEmoji: freezed == iconEmoji
            ? _value.iconEmoji
            : iconEmoji // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitCategoryModelImpl extends _HabitCategoryModel {
  const _$HabitCategoryModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') this.userId,
    required this.name,
    @JsonKey(name: 'icon_emoji') this.iconEmoji,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : super._();

  factory _$HabitCategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitCategoryModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  final String name;
  @override
  @JsonKey(name: 'icon_emoji')
  final String? iconEmoji;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'HabitCategoryModel(id: $id, userId: $userId, name: $name, iconEmoji: $iconEmoji, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconEmoji, iconEmoji) ||
                other.iconEmoji == iconEmoji) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, name, iconEmoji, createdAt);

  /// Create a copy of HabitCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitCategoryModelImplCopyWith<_$HabitCategoryModelImpl> get copyWith =>
      __$$HabitCategoryModelImplCopyWithImpl<_$HabitCategoryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitCategoryModelImplToJson(this);
  }
}

abstract class _HabitCategoryModel extends HabitCategoryModel {
  const factory _HabitCategoryModel({
    required final String id,
    @JsonKey(name: 'user_id') final String? userId,
    required final String name,
    @JsonKey(name: 'icon_emoji') final String? iconEmoji,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$HabitCategoryModelImpl;
  const _HabitCategoryModel._() : super._();

  factory _HabitCategoryModel.fromJson(Map<String, dynamic> json) =
      _$HabitCategoryModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  String get name;
  @override
  @JsonKey(name: 'icon_emoji')
  String? get iconEmoji;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of HabitCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitCategoryModelImplCopyWith<_$HabitCategoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
