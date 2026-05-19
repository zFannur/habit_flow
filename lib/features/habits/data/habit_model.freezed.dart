// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HabitModel _$HabitModelFromJson(Map<String, dynamic> json) {
  return _HabitModel.fromJson(json);
}

/// @nodoc
mixin _$HabitModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Free-text category label as stored in the DB column `category`. The
  /// id of a structured category lives separately in [categoryId] (joined
  /// from `habit_categories` when present).
  String? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'habit_type', fromJson: _typeFromJson, toJson: _typeToJson)
  HabitType get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'icon_emoji')
  String? get emoji => throw _privateConstructorUsedError;
  @JsonKey(name: 'icon_telegram_file_id')
  String? get iconTelegramFileId => throw _privateConstructorUsedError;
  @JsonKey(name: 'color')
  String? get accentColor => throw _privateConstructorUsedError; // Target (countable / timed)
  @JsonKey(name: 'target_value')
  double? get target => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_unit')
  String? get unit => throw _privateConstructorUsedError; // Schedule
  @JsonKey(
    name: 'schedule_type',
    fromJson: _scheduleTypeFromJson,
    toJson: _scheduleTypeToJson,
  )
  ScheduleType get scheduleType => throw _privateConstructorUsedError;
  @JsonKey(name: 'schedule_config')
  Map<String, dynamic> get schedule => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'reminder_times',
    fromJson: _reminderTimesFromJson,
    toJson: _reminderTimesToJson,
  )
  List<String> get reminderTimes => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get startedAt => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'end_date',
    fromJson: _dateFromJsonNullable,
    toJson: _dateToJsonNullable,
  )
  DateTime? get endedAt => throw _privateConstructorUsedError; // Behaviour science
  @JsonKey(name: 'stack_after_habit_id')
  String? get stackAfterHabitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'implementation_when')
  String? get implementationWhen => throw _privateConstructorUsedError;
  @JsonKey(name: 'implementation_where')
  String? get implementationWhere => throw _privateConstructorUsedError;
  @JsonKey(name: 'identity_statement')
  String? get identityStatement => throw _privateConstructorUsedError;
  @JsonKey(name: 'two_minute_version')
  String? get twoMinuteVersion => throw _privateConstructorUsedError;
  String? get reward => throw _privateConstructorUsedError; // State
  @JsonKey(name: 'is_archived')
  bool get isArchived => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this HabitModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitModelCopyWith<HabitModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitModelCopyWith<$Res> {
  factory $HabitModelCopyWith(
    HabitModel value,
    $Res Function(HabitModel) then,
  ) = _$HabitModelCopyWithImpl<$Res, HabitModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String name,
    String? category,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'habit_type', fromJson: _typeFromJson, toJson: _typeToJson)
    HabitType type,
    @JsonKey(name: 'icon_emoji') String? emoji,
    @JsonKey(name: 'icon_telegram_file_id') String? iconTelegramFileId,
    @JsonKey(name: 'color') String? accentColor,
    @JsonKey(name: 'target_value') double? target,
    @JsonKey(name: 'target_unit') String? unit,
    @JsonKey(
      name: 'schedule_type',
      fromJson: _scheduleTypeFromJson,
      toJson: _scheduleTypeToJson,
    )
    ScheduleType scheduleType,
    @JsonKey(name: 'schedule_config') Map<String, dynamic> schedule,
    @JsonKey(
      name: 'reminder_times',
      fromJson: _reminderTimesFromJson,
      toJson: _reminderTimesToJson,
    )
    List<String> reminderTimes,
    @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
    DateTime startedAt,
    @JsonKey(
      name: 'end_date',
      fromJson: _dateFromJsonNullable,
      toJson: _dateToJsonNullable,
    )
    DateTime? endedAt,
    @JsonKey(name: 'stack_after_habit_id') String? stackAfterHabitId,
    @JsonKey(name: 'implementation_when') String? implementationWhen,
    @JsonKey(name: 'implementation_where') String? implementationWhere,
    @JsonKey(name: 'identity_statement') String? identityStatement,
    @JsonKey(name: 'two_minute_version') String? twoMinuteVersion,
    String? reward,
    @JsonKey(name: 'is_archived') bool isArchived,
    int position,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$HabitModelCopyWithImpl<$Res, $Val extends HabitModel>
    implements $HabitModelCopyWith<$Res> {
  _$HabitModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? category = freezed,
    Object? categoryId = freezed,
    Object? type = null,
    Object? emoji = freezed,
    Object? iconTelegramFileId = freezed,
    Object? accentColor = freezed,
    Object? target = freezed,
    Object? unit = freezed,
    Object? scheduleType = null,
    Object? schedule = null,
    Object? reminderTimes = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? stackAfterHabitId = freezed,
    Object? implementationWhen = freezed,
    Object? implementationWhere = freezed,
    Object? identityStatement = freezed,
    Object? twoMinuteVersion = freezed,
    Object? reward = freezed,
    Object? isArchived = null,
    Object? position = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as HabitType,
            emoji: freezed == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String?,
            iconTelegramFileId: freezed == iconTelegramFileId
                ? _value.iconTelegramFileId
                : iconTelegramFileId // ignore: cast_nullable_to_non_nullable
                      as String?,
            accentColor: freezed == accentColor
                ? _value.accentColor
                : accentColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            target: freezed == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                      as double?,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
            scheduleType: null == scheduleType
                ? _value.scheduleType
                : scheduleType // ignore: cast_nullable_to_non_nullable
                      as ScheduleType,
            schedule: null == schedule
                ? _value.schedule
                : schedule // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            reminderTimes: null == reminderTimes
                ? _value.reminderTimes
                : reminderTimes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            stackAfterHabitId: freezed == stackAfterHabitId
                ? _value.stackAfterHabitId
                : stackAfterHabitId // ignore: cast_nullable_to_non_nullable
                      as String?,
            implementationWhen: freezed == implementationWhen
                ? _value.implementationWhen
                : implementationWhen // ignore: cast_nullable_to_non_nullable
                      as String?,
            implementationWhere: freezed == implementationWhere
                ? _value.implementationWhere
                : implementationWhere // ignore: cast_nullable_to_non_nullable
                      as String?,
            identityStatement: freezed == identityStatement
                ? _value.identityStatement
                : identityStatement // ignore: cast_nullable_to_non_nullable
                      as String?,
            twoMinuteVersion: freezed == twoMinuteVersion
                ? _value.twoMinuteVersion
                : twoMinuteVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            reward: freezed == reward
                ? _value.reward
                : reward // ignore: cast_nullable_to_non_nullable
                      as String?,
            isArchived: null == isArchived
                ? _value.isArchived
                : isArchived // ignore: cast_nullable_to_non_nullable
                      as bool,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HabitModelImplCopyWith<$Res>
    implements $HabitModelCopyWith<$Res> {
  factory _$$HabitModelImplCopyWith(
    _$HabitModelImpl value,
    $Res Function(_$HabitModelImpl) then,
  ) = __$$HabitModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String name,
    String? category,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'habit_type', fromJson: _typeFromJson, toJson: _typeToJson)
    HabitType type,
    @JsonKey(name: 'icon_emoji') String? emoji,
    @JsonKey(name: 'icon_telegram_file_id') String? iconTelegramFileId,
    @JsonKey(name: 'color') String? accentColor,
    @JsonKey(name: 'target_value') double? target,
    @JsonKey(name: 'target_unit') String? unit,
    @JsonKey(
      name: 'schedule_type',
      fromJson: _scheduleTypeFromJson,
      toJson: _scheduleTypeToJson,
    )
    ScheduleType scheduleType,
    @JsonKey(name: 'schedule_config') Map<String, dynamic> schedule,
    @JsonKey(
      name: 'reminder_times',
      fromJson: _reminderTimesFromJson,
      toJson: _reminderTimesToJson,
    )
    List<String> reminderTimes,
    @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
    DateTime startedAt,
    @JsonKey(
      name: 'end_date',
      fromJson: _dateFromJsonNullable,
      toJson: _dateToJsonNullable,
    )
    DateTime? endedAt,
    @JsonKey(name: 'stack_after_habit_id') String? stackAfterHabitId,
    @JsonKey(name: 'implementation_when') String? implementationWhen,
    @JsonKey(name: 'implementation_where') String? implementationWhere,
    @JsonKey(name: 'identity_statement') String? identityStatement,
    @JsonKey(name: 'two_minute_version') String? twoMinuteVersion,
    String? reward,
    @JsonKey(name: 'is_archived') bool isArchived,
    int position,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$HabitModelImplCopyWithImpl<$Res>
    extends _$HabitModelCopyWithImpl<$Res, _$HabitModelImpl>
    implements _$$HabitModelImplCopyWith<$Res> {
  __$$HabitModelImplCopyWithImpl(
    _$HabitModelImpl _value,
    $Res Function(_$HabitModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? category = freezed,
    Object? categoryId = freezed,
    Object? type = null,
    Object? emoji = freezed,
    Object? iconTelegramFileId = freezed,
    Object? accentColor = freezed,
    Object? target = freezed,
    Object? unit = freezed,
    Object? scheduleType = null,
    Object? schedule = null,
    Object? reminderTimes = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? stackAfterHabitId = freezed,
    Object? implementationWhen = freezed,
    Object? implementationWhere = freezed,
    Object? identityStatement = freezed,
    Object? twoMinuteVersion = freezed,
    Object? reward = freezed,
    Object? isArchived = null,
    Object? position = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$HabitModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as HabitType,
        emoji: freezed == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String?,
        iconTelegramFileId: freezed == iconTelegramFileId
            ? _value.iconTelegramFileId
            : iconTelegramFileId // ignore: cast_nullable_to_non_nullable
                  as String?,
        accentColor: freezed == accentColor
            ? _value.accentColor
            : accentColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        target: freezed == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as double?,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
        scheduleType: null == scheduleType
            ? _value.scheduleType
            : scheduleType // ignore: cast_nullable_to_non_nullable
                  as ScheduleType,
        schedule: null == schedule
            ? _value._schedule
            : schedule // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        reminderTimes: null == reminderTimes
            ? _value._reminderTimes
            : reminderTimes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        stackAfterHabitId: freezed == stackAfterHabitId
            ? _value.stackAfterHabitId
            : stackAfterHabitId // ignore: cast_nullable_to_non_nullable
                  as String?,
        implementationWhen: freezed == implementationWhen
            ? _value.implementationWhen
            : implementationWhen // ignore: cast_nullable_to_non_nullable
                  as String?,
        implementationWhere: freezed == implementationWhere
            ? _value.implementationWhere
            : implementationWhere // ignore: cast_nullable_to_non_nullable
                  as String?,
        identityStatement: freezed == identityStatement
            ? _value.identityStatement
            : identityStatement // ignore: cast_nullable_to_non_nullable
                  as String?,
        twoMinuteVersion: freezed == twoMinuteVersion
            ? _value.twoMinuteVersion
            : twoMinuteVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        reward: freezed == reward
            ? _value.reward
            : reward // ignore: cast_nullable_to_non_nullable
                  as String?,
        isArchived: null == isArchived
            ? _value.isArchived
            : isArchived // ignore: cast_nullable_to_non_nullable
                  as bool,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitModelImpl extends _HabitModel {
  const _$HabitModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    required this.name,
    this.category,
    @JsonKey(name: 'category_id') this.categoryId,
    @JsonKey(name: 'habit_type', fromJson: _typeFromJson, toJson: _typeToJson)
    required this.type,
    @JsonKey(name: 'icon_emoji') this.emoji,
    @JsonKey(name: 'icon_telegram_file_id') this.iconTelegramFileId,
    @JsonKey(name: 'color') this.accentColor,
    @JsonKey(name: 'target_value') this.target,
    @JsonKey(name: 'target_unit') this.unit,
    @JsonKey(
      name: 'schedule_type',
      fromJson: _scheduleTypeFromJson,
      toJson: _scheduleTypeToJson,
    )
    required this.scheduleType,
    @JsonKey(name: 'schedule_config')
    final Map<String, dynamic> schedule = const <String, dynamic>{},
    @JsonKey(
      name: 'reminder_times',
      fromJson: _reminderTimesFromJson,
      toJson: _reminderTimesToJson,
    )
    final List<String> reminderTimes = const <String>[],
    @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
    required this.startedAt,
    @JsonKey(
      name: 'end_date',
      fromJson: _dateFromJsonNullable,
      toJson: _dateToJsonNullable,
    )
    this.endedAt,
    @JsonKey(name: 'stack_after_habit_id') this.stackAfterHabitId,
    @JsonKey(name: 'implementation_when') this.implementationWhen,
    @JsonKey(name: 'implementation_where') this.implementationWhere,
    @JsonKey(name: 'identity_statement') this.identityStatement,
    @JsonKey(name: 'two_minute_version') this.twoMinuteVersion,
    this.reward,
    @JsonKey(name: 'is_archived') this.isArchived = false,
    this.position = 0,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _schedule = schedule,
       _reminderTimes = reminderTimes,
       super._();

  factory _$HabitModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;

  /// Free-text category label as stored in the DB column `category`. The
  /// id of a structured category lives separately in [categoryId] (joined
  /// from `habit_categories` when present).
  @override
  final String? category;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  @JsonKey(name: 'habit_type', fromJson: _typeFromJson, toJson: _typeToJson)
  final HabitType type;
  @override
  @JsonKey(name: 'icon_emoji')
  final String? emoji;
  @override
  @JsonKey(name: 'icon_telegram_file_id')
  final String? iconTelegramFileId;
  @override
  @JsonKey(name: 'color')
  final String? accentColor;
  // Target (countable / timed)
  @override
  @JsonKey(name: 'target_value')
  final double? target;
  @override
  @JsonKey(name: 'target_unit')
  final String? unit;
  // Schedule
  @override
  @JsonKey(
    name: 'schedule_type',
    fromJson: _scheduleTypeFromJson,
    toJson: _scheduleTypeToJson,
  )
  final ScheduleType scheduleType;
  final Map<String, dynamic> _schedule;
  @override
  @JsonKey(name: 'schedule_config')
  Map<String, dynamic> get schedule {
    if (_schedule is EqualUnmodifiableMapView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_schedule);
  }

  final List<String> _reminderTimes;
  @override
  @JsonKey(
    name: 'reminder_times',
    fromJson: _reminderTimesFromJson,
    toJson: _reminderTimesToJson,
  )
  List<String> get reminderTimes {
    if (_reminderTimes is EqualUnmodifiableListView) return _reminderTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reminderTimes);
  }

  @override
  @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime startedAt;
  @override
  @JsonKey(
    name: 'end_date',
    fromJson: _dateFromJsonNullable,
    toJson: _dateToJsonNullable,
  )
  final DateTime? endedAt;
  // Behaviour science
  @override
  @JsonKey(name: 'stack_after_habit_id')
  final String? stackAfterHabitId;
  @override
  @JsonKey(name: 'implementation_when')
  final String? implementationWhen;
  @override
  @JsonKey(name: 'implementation_where')
  final String? implementationWhere;
  @override
  @JsonKey(name: 'identity_statement')
  final String? identityStatement;
  @override
  @JsonKey(name: 'two_minute_version')
  final String? twoMinuteVersion;
  @override
  final String? reward;
  // State
  @override
  @JsonKey(name: 'is_archived')
  final bool isArchived;
  @override
  @JsonKey()
  final int position;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'HabitModel(id: $id, userId: $userId, name: $name, category: $category, categoryId: $categoryId, type: $type, emoji: $emoji, iconTelegramFileId: $iconTelegramFileId, accentColor: $accentColor, target: $target, unit: $unit, scheduleType: $scheduleType, schedule: $schedule, reminderTimes: $reminderTimes, startedAt: $startedAt, endedAt: $endedAt, stackAfterHabitId: $stackAfterHabitId, implementationWhen: $implementationWhen, implementationWhere: $implementationWhere, identityStatement: $identityStatement, twoMinuteVersion: $twoMinuteVersion, reward: $reward, isArchived: $isArchived, position: $position, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.iconTelegramFileId, iconTelegramFileId) ||
                other.iconTelegramFileId == iconTelegramFileId) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.scheduleType, scheduleType) ||
                other.scheduleType == scheduleType) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            const DeepCollectionEquality().equals(
              other._reminderTimes,
              _reminderTimes,
            ) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.stackAfterHabitId, stackAfterHabitId) ||
                other.stackAfterHabitId == stackAfterHabitId) &&
            (identical(other.implementationWhen, implementationWhen) ||
                other.implementationWhen == implementationWhen) &&
            (identical(other.implementationWhere, implementationWhere) ||
                other.implementationWhere == implementationWhere) &&
            (identical(other.identityStatement, identityStatement) ||
                other.identityStatement == identityStatement) &&
            (identical(other.twoMinuteVersion, twoMinuteVersion) ||
                other.twoMinuteVersion == twoMinuteVersion) &&
            (identical(other.reward, reward) || other.reward == reward) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    name,
    category,
    categoryId,
    type,
    emoji,
    iconTelegramFileId,
    accentColor,
    target,
    unit,
    scheduleType,
    const DeepCollectionEquality().hash(_schedule),
    const DeepCollectionEquality().hash(_reminderTimes),
    startedAt,
    endedAt,
    stackAfterHabitId,
    implementationWhen,
    implementationWhere,
    identityStatement,
    twoMinuteVersion,
    reward,
    isArchived,
    position,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitModelImplCopyWith<_$HabitModelImpl> get copyWith =>
      __$$HabitModelImplCopyWithImpl<_$HabitModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitModelImplToJson(this);
  }
}

abstract class _HabitModel extends HabitModel {
  const factory _HabitModel({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    required final String name,
    final String? category,
    @JsonKey(name: 'category_id') final String? categoryId,
    @JsonKey(name: 'habit_type', fromJson: _typeFromJson, toJson: _typeToJson)
    required final HabitType type,
    @JsonKey(name: 'icon_emoji') final String? emoji,
    @JsonKey(name: 'icon_telegram_file_id') final String? iconTelegramFileId,
    @JsonKey(name: 'color') final String? accentColor,
    @JsonKey(name: 'target_value') final double? target,
    @JsonKey(name: 'target_unit') final String? unit,
    @JsonKey(
      name: 'schedule_type',
      fromJson: _scheduleTypeFromJson,
      toJson: _scheduleTypeToJson,
    )
    required final ScheduleType scheduleType,
    @JsonKey(name: 'schedule_config') final Map<String, dynamic> schedule,
    @JsonKey(
      name: 'reminder_times',
      fromJson: _reminderTimesFromJson,
      toJson: _reminderTimesToJson,
    )
    final List<String> reminderTimes,
    @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
    required final DateTime startedAt,
    @JsonKey(
      name: 'end_date',
      fromJson: _dateFromJsonNullable,
      toJson: _dateToJsonNullable,
    )
    final DateTime? endedAt,
    @JsonKey(name: 'stack_after_habit_id') final String? stackAfterHabitId,
    @JsonKey(name: 'implementation_when') final String? implementationWhen,
    @JsonKey(name: 'implementation_where') final String? implementationWhere,
    @JsonKey(name: 'identity_statement') final String? identityStatement,
    @JsonKey(name: 'two_minute_version') final String? twoMinuteVersion,
    final String? reward,
    @JsonKey(name: 'is_archived') final bool isArchived,
    final int position,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$HabitModelImpl;
  const _HabitModel._() : super._();

  factory _HabitModel.fromJson(Map<String, dynamic> json) =
      _$HabitModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;

  /// Free-text category label as stored in the DB column `category`. The
  /// id of a structured category lives separately in [categoryId] (joined
  /// from `habit_categories` when present).
  @override
  String? get category;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  @JsonKey(name: 'habit_type', fromJson: _typeFromJson, toJson: _typeToJson)
  HabitType get type;
  @override
  @JsonKey(name: 'icon_emoji')
  String? get emoji;
  @override
  @JsonKey(name: 'icon_telegram_file_id')
  String? get iconTelegramFileId;
  @override
  @JsonKey(name: 'color')
  String? get accentColor; // Target (countable / timed)
  @override
  @JsonKey(name: 'target_value')
  double? get target;
  @override
  @JsonKey(name: 'target_unit')
  String? get unit; // Schedule
  @override
  @JsonKey(
    name: 'schedule_type',
    fromJson: _scheduleTypeFromJson,
    toJson: _scheduleTypeToJson,
  )
  ScheduleType get scheduleType;
  @override
  @JsonKey(name: 'schedule_config')
  Map<String, dynamic> get schedule;
  @override
  @JsonKey(
    name: 'reminder_times',
    fromJson: _reminderTimesFromJson,
    toJson: _reminderTimesToJson,
  )
  List<String> get reminderTimes;
  @override
  @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get startedAt;
  @override
  @JsonKey(
    name: 'end_date',
    fromJson: _dateFromJsonNullable,
    toJson: _dateToJsonNullable,
  )
  DateTime? get endedAt; // Behaviour science
  @override
  @JsonKey(name: 'stack_after_habit_id')
  String? get stackAfterHabitId;
  @override
  @JsonKey(name: 'implementation_when')
  String? get implementationWhen;
  @override
  @JsonKey(name: 'implementation_where')
  String? get implementationWhere;
  @override
  @JsonKey(name: 'identity_statement')
  String? get identityStatement;
  @override
  @JsonKey(name: 'two_minute_version')
  String? get twoMinuteVersion;
  @override
  String? get reward; // State
  @override
  @JsonKey(name: 'is_archived')
  bool get isArchived;
  @override
  int get position;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitModelImplCopyWith<_$HabitModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
