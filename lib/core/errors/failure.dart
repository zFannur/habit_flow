import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({String? message}) = NetworkFailure;
  const factory Failure.auth({String? message}) = AuthFailureF;
  const factory Failure.server({required int status, String? message}) = ServerFailure;
  const factory Failure.notFound({String? message}) = NotFoundFailure;
  const factory Failure.parse({String? message}) = ParseFailure;
  const factory Failure.unknown({String? message}) = UnknownFailure;
}
