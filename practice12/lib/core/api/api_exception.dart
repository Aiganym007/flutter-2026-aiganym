sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NoConnectionException extends ApiException {
  const NoConnectionException() : super('No connection');
}

final class RequestTimeoutException extends ApiException {
  const RequestTimeoutException() : super('The server took too long');
}

final class HttpStatusException extends ApiException {
  HttpStatusException(this.statusCode) : super('Server answered $statusCode');
  final int statusCode;
}

final class BadResponseException extends ApiException {
  const BadResponseException() : super('Unexpected answer from the server');
}
