sealed class Failure {
  const Failure({required this.message});
  final String message;
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
