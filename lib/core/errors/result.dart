import 'package:fpdart/fpdart.dart';
import 'failure.dart';

/// Единый алиас для типизированного результата.
typedef AppResult<T> = Either<Failure, T>;
typedef AppTask<T>   = TaskEither<Failure, T>;
