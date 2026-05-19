// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HabitLogModel _$HabitLogModelFromJson(Map<String, dynamic> json) {
  return _HabitLogModel.fromJson(json);
}

/// @nodoc
mixin _$HabitLogModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'habit_id')
  String get habitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get date => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  HabitLogStatus get status => throw _privateConstructorUsedError;

  /// For countable / timed habits: how much was logged on [date].
  /// For binary / anti habits: typically `null`.
  double? get value => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this HabitLogModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HabitLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitLogModelCopyWith<HabitLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitLogModelCopyWith<$Res> {
  factory $HabitLogModelCopyWith(
    HabitLogModel value,
    $Res Function(HabitLogModel) then,
  ) = _$HabitLogModelCopyWithImpl<$Res, HabitLogModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'habit_id') String habitId,
    @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
    DateTime date,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    HabitLogStatus status,
    double? value,
    String? comment,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$HabitLogModelCopyWithImpl<$Res, $Val extends HabitLogModel>
    implements $HabitLogModelCopyWith<$Res> {
  _$HabitLogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HabitLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? habitId = null,
    Object? date = null,
    Object? status = null,
    Object? value = freezed,
    Object? comment = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            habitId: null == habitId
                ? _value.habitId
                : habitId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as HabitLogStatus,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double?,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
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
abstract class _$$HabitLogModelImplCopyWith<$Res>
    implements $HabitLogModelCopyWith<$Res> {
  factory _$$HabitLogModelImplCopyWith(
    _$HabitLogModelImpl value,
    $Res Function(_$HabitLogModelImpl) then,
  ) = __$$HabitLogModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'habit_id') String habitId,
    @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
    DateTime date,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    HabitLogStatus status,
    double? value,
    String? comment,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$HabitLogModelImplCopyWithImpl<$Res>
    extends _$HabitLogModelCopyWithImpl<$Res, _$HabitLogModelImpl>
    implements _$$HabitLogModelImplCopyWith<$Res> {
  __$$HabitLogModelImplCopyWithImpl(
    _$HabitLogModelImpl _value,
    $Res Function(_$HabitLogModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HabitLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? habitId = null,
    Object? date = null,
    Object? status = null,
    Object? value = freezed,
    Object? comment = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$HabitLogModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        habitId: null == habitId
            ? _value.habitId
            : habitId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as HabitLogStatus,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double?,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
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
class _$HabitLogModelImpl extends _HabitLogModel {
  const _$HabitLogModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'habit_id') required this.habitId,
    @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
    required this.date,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    required this.status,
    this.value,
    this.comment,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : super._();

  factory _$HabitLogModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitLogModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'habit_id')
  final String habitId;
  @override
  @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime date;
  @override
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  final HabitLogStatus status;

  /// For countable / timed habits: how much was logged on [date].
  /// For binary / anti habits: typically `null`.
  @override
  final double? value;
  @override
  final String? comment;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'HabitLogModel(id: $id, userId: $userId, habitId: $habitId, date: $date, status: $status, value: $value, comment: $comment, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitLogModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    habitId,
    date,
    status,
    value,
    comment,
    createdAt,
  );

  /// Create a copy of HabitLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitLogModelImplCopyWith<_$HabitLogModelImpl> get copyWith =>
      __$$HabitLogModelImplCopyWithImpl<_$HabitLogModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitLogModelImplToJson(this);
  }
}

abstract class _HabitLogModel extends HabitLogModel {
  const factory _HabitLogModel({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'habit_id') required final String habitId,
    @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
    required final DateTime date,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    required final HabitLogStatus status,
    final double? value,
    final String? comment,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$HabitLogModelImpl;
  const _HabitLogModel._() : super._();

  factory _HabitLogModel.fromJson(Map<String, dynamic> json) =
      _$HabitLogModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'habit_id')
  String get habitId;
  @override
  @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get date;
  @override
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  HabitLogStatus get status;

  /// For countable / timed habits: how much was logged on [date].
  /// For binary / anti habits: typically `null`.
  @override
  double? get value;
  @override
  String? get comment;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of HabitLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitLogModelImplCopyWith<_$HabitLogModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
