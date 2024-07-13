import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/providers/failures.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;

typedef FutureVoid = FutureEither<void>;
