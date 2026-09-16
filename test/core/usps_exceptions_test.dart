import 'package:test/test.dart';
import 'package:usps_v3_dart/src/core/exceptions/usps_exceptions.dart';

void main() {
  group('UspsException hierarchy', () {
    test('UspsApiException toString formats status and code', () {
      const exception = UspsApiException(
        message: 'Invalid tracking number',
        statusCode: 400,
        errorCode: 'ERR_INVALID_INPUT',
        data: {'error': 'details'},
      );

      expect(exception.statusCode, equals(400));
      expect(exception.errorCode, equals('ERR_INVALID_INPUT'));
      expect(exception.message, equals('Invalid tracking number'));
      expect(exception.data, equals({'error': 'details'}));
      expect(
        exception.toString(),
        contains(
          'UspsApiException (Status: 400) [Code: ERR_INVALID_INPUT]: Invalid tracking number',
        ),
      );

      // Branch without status and error code
      const simpleException = UspsApiException(message: 'Simple API error');
      expect(simpleException.toString(), equals('UspsApiException: Simple API error'));

      // Branch with only status code
      const statusOnly = UspsApiException(message: 'Server error', statusCode: 500);
      expect(statusOnly.toString(), equals('UspsApiException (Status: 500): Server error'));

      // Branch with only error code
      const codeOnly = UspsApiException(message: 'Validation error', errorCode: 'ERR_VAL');
      expect(codeOnly.toString(), equals('UspsApiException [Code: ERR_VAL]: Validation error'));
    });

    test('UspsAuthException toString formats status and message', () {
      const exception = UspsAuthException(
        message: 'Unauthorized access',
        statusCode: 401,
        data: {'detail': 'expired'},
      );

      expect(exception.statusCode, equals(401));
      expect(exception.data, equals({'detail': 'expired'}));
      expect(
        exception.toString(),
        contains('UspsAuthException (Status: 401): Unauthorized access'),
      );

      // Branch without status code
      const noStatusException = UspsAuthException(message: 'Missing credentials');
      expect(noStatusException.toString(), equals('UspsAuthException: Missing credentials'));
    });

    test('UspsNetworkException handles cause', () {
      final cause = Exception('Connection reset');
      final exception = UspsNetworkException(
        message: 'Network unreachable',
        cause: cause,
      );

      expect(exception.cause, equals(cause));
      expect(
        exception.toString(),
        contains(
          'UspsNetworkException: Network unreachable (Cause: Exception: Connection reset)',
        ),
      );

      // Branch without cause
      const noCauseException = UspsNetworkException(message: 'Connection timed out');
      expect(noCauseException.toString(), equals('UspsNetworkException: Connection timed out'));
    });

    test('UspsUnknownException handles stack trace and cause', () {
      final stack = StackTrace.current;
      final cause = Exception('Crash');
      final exception = UspsUnknownException(
        message: 'Unexpected crash',
        cause: cause,
        stackTrace: stack,
      );

      expect(exception.cause, equals(cause));
      expect(exception.stackTrace, equals(stack));
      expect(
        exception.toString(),
        contains('UspsUnknownException: Unexpected crash (Cause: Exception: Crash)'),
      );

      // Branch without cause
      const noCauseException = UspsUnknownException(message: 'Generic failure');
      expect(noCauseException.toString(), equals('UspsUnknownException: Generic failure'));
    });

    test('UspsGenericException formats base UspsException toString', () {
      const exception = UspsGenericException(message: 'Base exception message');
      expect(exception.message, equals('Base exception message'));
      expect(exception.toString(), equals('UspsGenericException: Base exception message'));
    });
  });
}
