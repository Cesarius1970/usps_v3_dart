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
      expect(
        exception.toString(),
        contains(
          'UspsApiException (Status: 400) [Code: ERR_INVALID_INPUT]: Invalid tracking number',
        ),
      );
    });

    test('UspsAuthException toString formats status and message', () {
      const exception = UspsAuthException(
        message: 'Unauthorized access',
        statusCode: 401,
      );

      expect(exception.statusCode, equals(401));
      expect(
        exception.toString(),
        contains('UspsAuthException (Status: 401): Unauthorized access'),
      );
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
    });

    test('UspsUnknownException handles stack trace and cause', () {
      final stack = StackTrace.current;
      final exception = UspsUnknownException(
        message: 'Unexpected crash',
        stackTrace: stack,
      );

      expect(exception.stackTrace, equals(stack));
      expect(
        exception.toString(),
        contains('UspsUnknownException: Unexpected crash'),
      );
    });
  });
}
