/// Base and specialized exceptions thrown by the USPS v3 Dart SDK.
library;

/// Base exception class for all errors generated or handled by the USPS SDK.
sealed class UspsException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Creates a new [UspsException] with the provided [message].
  const UspsException({required this.message});

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception thrown when the USPS API responds with an HTTP error status code (4xx, 5xx).
final class UspsApiException extends UspsException {
  /// HTTP status code returned by the USPS API.
  final int? statusCode;

  /// Raw response payload returned by the USPS API, if any.
  final dynamic data;

  /// Optional error code or title provided in the response body.
  final String? errorCode;

  /// Creates a new [UspsApiException].
  const UspsApiException({
    required super.message,
    this.statusCode,
    this.data,
    this.errorCode,
  });

  @override
  String toString() {
    final codeStr = statusCode != null ? ' (Status: $statusCode)' : '';
    final errStr = errorCode != null ? ' [Code: $errorCode]' : '';
    return 'UspsApiException$codeStr$errStr: $message';
  }
}

/// Exception thrown when an authentication error occurs (OAuth 2.0 token acquisition or refresh failure).
final class UspsAuthException extends UspsException {
  /// HTTP status code associated with the auth failure, if any.
  final int? statusCode;

  /// Optional raw response or error details.
  final dynamic data;

  /// Creates a new [UspsAuthException].
  const UspsAuthException({required super.message, this.statusCode, this.data});

  @override
  String toString() {
    final codeStr = statusCode != null ? ' (Status: $statusCode)' : '';
    return 'UspsAuthException$codeStr: $message';
  }
}

/// Exception thrown when a network-level or connectivity failure occurs (timeouts, DNS failures, connection refused).
final class UspsNetworkException extends UspsException {
  /// The underlying cause or exception, if available.
  final Object? cause;

  /// Creates a new [UspsNetworkException].
  const UspsNetworkException({required super.message, this.cause});

  @override
  String toString() => cause != null
      ? 'UspsNetworkException: $message (Cause: $cause)'
      : 'UspsNetworkException: $message';
}

/// Exception thrown when an unexpected or uncategorized error occurs.
final class UspsUnknownException extends UspsException {
  /// The underlying cause or exception, if available.
  final Object? cause;

  /// The stack trace associated with the unexpected error, if captured.
  final StackTrace? stackTrace;

  /// Creates a new [UspsUnknownException].
  const UspsUnknownException({
    required super.message,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => cause != null
      ? 'UspsUnknownException: $message (Cause: $cause)'
      : 'UspsUnknownException: $message';
}

/// Generic fallback exception when no specialized exception matches.
final class UspsGenericException extends UspsException {
  /// Creates a new [UspsGenericException] with the provided [message].
  const UspsGenericException({required super.message});
}
