// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Failure {
  String? get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) auth,
    required TResult Function(int status, String? message) server,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) parse,
    required TResult Function(String? message) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? auth,
    TResult? Function(int status, String? message)? server,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? parse,
    TResult? Function(String? message)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? auth,
    TResult Function(int status, String? message)? server,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? parse,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(AuthFailureF value) auth,
    required TResult Function(ServerFailure value) server,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(ParseFailure value) parse,
    required TResult Function(UnknownFailure value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(AuthFailureF value)? auth,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(ParseFailure value)? parse,
    TResult? Function(UnknownFailure value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(AuthFailureF value)? auth,
    TResult Function(ServerFailure value)? server,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(ParseFailure value)? parse,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FailureCopyWith<Failure> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _value.copyWith(
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(
    _$NetworkFailureImpl value,
    $Res Function(_$NetworkFailureImpl) then,
  ) = __$$NetworkFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
    _$NetworkFailureImpl _value,
    $Res Function(_$NetworkFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$NetworkFailureImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$NetworkFailureImpl implements NetworkFailure {
  const _$NetworkFailureImpl({this.message});

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.network(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      __$$NetworkFailureImplCopyWithImpl<_$NetworkFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) auth,
    required TResult Function(int status, String? message) server,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) parse,
    required TResult Function(String? message) unknown,
  }) {
    return network(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? auth,
    TResult? Function(int status, String? message)? server,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? parse,
    TResult? Function(String? message)? unknown,
  }) {
    return network?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? auth,
    TResult Function(int status, String? message)? server,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? parse,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(AuthFailureF value) auth,
    required TResult Function(ServerFailure value) server,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(ParseFailure value) parse,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(AuthFailureF value)? auth,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(ParseFailure value)? parse,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(AuthFailureF value)? auth,
    TResult Function(ServerFailure value)? server,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(ParseFailure value)? parse,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure implements Failure {
  const factory NetworkFailure({final String? message}) = _$NetworkFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthFailureFImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$AuthFailureFImplCopyWith(
    _$AuthFailureFImpl value,
    $Res Function(_$AuthFailureFImpl) then,
  ) = __$$AuthFailureFImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$AuthFailureFImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$AuthFailureFImpl>
    implements _$$AuthFailureFImplCopyWith<$Res> {
  __$$AuthFailureFImplCopyWithImpl(
    _$AuthFailureFImpl _value,
    $Res Function(_$AuthFailureFImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$AuthFailureFImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AuthFailureFImpl implements AuthFailureF {
  const _$AuthFailureFImpl({this.message});

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.auth(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthFailureFImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthFailureFImplCopyWith<_$AuthFailureFImpl> get copyWith =>
      __$$AuthFailureFImplCopyWithImpl<_$AuthFailureFImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) auth,
    required TResult Function(int status, String? message) server,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) parse,
    required TResult Function(String? message) unknown,
  }) {
    return auth(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? auth,
    TResult? Function(int status, String? message)? server,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? parse,
    TResult? Function(String? message)? unknown,
  }) {
    return auth?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? auth,
    TResult Function(int status, String? message)? server,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? parse,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(AuthFailureF value) auth,
    required TResult Function(ServerFailure value) server,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(ParseFailure value) parse,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return auth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(AuthFailureF value)? auth,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(ParseFailure value)? parse,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return auth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(AuthFailureF value)? auth,
    TResult Function(ServerFailure value)? server,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(ParseFailure value)? parse,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(this);
    }
    return orElse();
  }
}

abstract class AuthFailureF implements Failure {
  const factory AuthFailureF({final String? message}) = _$AuthFailureFImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthFailureFImplCopyWith<_$AuthFailureFImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ServerFailureImplCopyWith(
    _$ServerFailureImpl value,
    $Res Function(_$ServerFailureImpl) then,
  ) = __$$ServerFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int status, String? message});
}

/// @nodoc
class __$$ServerFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ServerFailureImpl>
    implements _$$ServerFailureImplCopyWith<$Res> {
  __$$ServerFailureImplCopyWithImpl(
    _$ServerFailureImpl _value,
    $Res Function(_$ServerFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null, Object? message = freezed}) {
    return _then(
      _$ServerFailureImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as int,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ServerFailureImpl implements ServerFailure {
  const _$ServerFailureImpl({required this.status, this.message});

  @override
  final int status;
  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.server(status: $status, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerFailureImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      __$$ServerFailureImplCopyWithImpl<_$ServerFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) auth,
    required TResult Function(int status, String? message) server,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) parse,
    required TResult Function(String? message) unknown,
  }) {
    return server(status, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? auth,
    TResult? Function(int status, String? message)? server,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? parse,
    TResult? Function(String? message)? unknown,
  }) {
    return server?.call(status, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? auth,
    TResult Function(int status, String? message)? server,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? parse,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(status, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(AuthFailureF value) auth,
    required TResult Function(ServerFailure value) server,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(ParseFailure value) parse,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(AuthFailureF value)? auth,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(ParseFailure value)? parse,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(AuthFailureF value)? auth,
    TResult Function(ServerFailure value)? server,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(ParseFailure value)? parse,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerFailure implements Failure {
  const factory ServerFailure({
    required final int status,
    final String? message,
  }) = _$ServerFailureImpl;

  int get status;
  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NotFoundFailureImplCopyWith(
    _$NotFoundFailureImpl value,
    $Res Function(_$NotFoundFailureImpl) then,
  ) = __$$NotFoundFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$NotFoundFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NotFoundFailureImpl>
    implements _$$NotFoundFailureImplCopyWith<$Res> {
  __$$NotFoundFailureImplCopyWithImpl(
    _$NotFoundFailureImpl _value,
    $Res Function(_$NotFoundFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$NotFoundFailureImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$NotFoundFailureImpl implements NotFoundFailure {
  const _$NotFoundFailureImpl({this.message});

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.notFound(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      __$$NotFoundFailureImplCopyWithImpl<_$NotFoundFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) auth,
    required TResult Function(int status, String? message) server,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) parse,
    required TResult Function(String? message) unknown,
  }) {
    return notFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? auth,
    TResult? Function(int status, String? message)? server,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? parse,
    TResult? Function(String? message)? unknown,
  }) {
    return notFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? auth,
    TResult Function(int status, String? message)? server,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? parse,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(AuthFailureF value) auth,
    required TResult Function(ServerFailure value) server,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(ParseFailure value) parse,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(AuthFailureF value)? auth,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(ParseFailure value)? parse,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(AuthFailureF value)? auth,
    TResult Function(ServerFailure value)? server,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(ParseFailure value)? parse,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundFailure implements Failure {
  const factory NotFoundFailure({final String? message}) =
      _$NotFoundFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ParseFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ParseFailureImplCopyWith(
    _$ParseFailureImpl value,
    $Res Function(_$ParseFailureImpl) then,
  ) = __$$ParseFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$ParseFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ParseFailureImpl>
    implements _$$ParseFailureImplCopyWith<$Res> {
  __$$ParseFailureImplCopyWithImpl(
    _$ParseFailureImpl _value,
    $Res Function(_$ParseFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$ParseFailureImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ParseFailureImpl implements ParseFailure {
  const _$ParseFailureImpl({this.message});

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.parse(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParseFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParseFailureImplCopyWith<_$ParseFailureImpl> get copyWith =>
      __$$ParseFailureImplCopyWithImpl<_$ParseFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) auth,
    required TResult Function(int status, String? message) server,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) parse,
    required TResult Function(String? message) unknown,
  }) {
    return parse(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? auth,
    TResult? Function(int status, String? message)? server,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? parse,
    TResult? Function(String? message)? unknown,
  }) {
    return parse?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? auth,
    TResult Function(int status, String? message)? server,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? parse,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (parse != null) {
      return parse(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(AuthFailureF value) auth,
    required TResult Function(ServerFailure value) server,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(ParseFailure value) parse,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return parse(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(AuthFailureF value)? auth,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(ParseFailure value)? parse,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return parse?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(AuthFailureF value)? auth,
    TResult Function(ServerFailure value)? server,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(ParseFailure value)? parse,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (parse != null) {
      return parse(this);
    }
    return orElse();
  }
}

abstract class ParseFailure implements Failure {
  const factory ParseFailure({final String? message}) = _$ParseFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParseFailureImplCopyWith<_$ParseFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(
    _$UnknownFailureImpl value,
    $Res Function(_$UnknownFailureImpl) then,
  ) = __$$UnknownFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
    _$UnknownFailureImpl _value,
    $Res Function(_$UnknownFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$UnknownFailureImpl(
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl({this.message});

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.unknown(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) auth,
    required TResult Function(int status, String? message) server,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) parse,
    required TResult Function(String? message) unknown,
  }) {
    return unknown(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? auth,
    TResult? Function(int status, String? message)? server,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? parse,
    TResult? Function(String? message)? unknown,
  }) {
    return unknown?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? auth,
    TResult Function(int status, String? message)? server,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? parse,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(AuthFailureF value) auth,
    required TResult Function(ServerFailure value) server,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(ParseFailure value) parse,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(AuthFailureF value)? auth,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(ParseFailure value)? parse,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(AuthFailureF value)? auth,
    TResult Function(ServerFailure value)? server,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(ParseFailure value)? parse,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements Failure {
  const factory UnknownFailure({final String? message}) = _$UnknownFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
