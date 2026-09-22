import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() {
  group('UspsWebhookVerifier', () {
    const payload = '{"trackingNumber":"9400111899562537680001","status":"Delivered"}';
    const secretKey = 'my-secret-webhook-key-123';

    test('constructor instantiates correctly', () {
      expect(const UspsWebhookVerifier(), isNotNull);
    });

    test('computeSignature generates expected HMAC-SHA256 hex digest', () {
      final signature = UspsWebhookVerifier.computeSignature(
        payload: payload,
        secretKey: secretKey,
      );

      expect(signature, isNotEmpty);
      expect(signature.length, equals(64)); // SHA-256 is 64 hex characters
    });

    test('verify returns true for valid matching signature', () {
      final validSignature = UspsWebhookVerifier.computeSignature(
        payload: payload,
        secretKey: secretKey,
      );

      final isValid = UspsWebhookVerifier.verify(
        payload: payload,
        signature: validSignature,
        secretKey: secretKey,
      );

      expect(isValid, isTrue);
    });

    test('verify returns true with uppercase or leading/trailing whitespace signature', () {
      final validSignature = UspsWebhookVerifier.computeSignature(
        payload: payload,
        secretKey: secretKey,
      );

      final isValid = UspsWebhookVerifier.verify(
        payload: payload,
        signature: '  ${validSignature.toUpperCase()}  ',
        secretKey: secretKey,
      );

      expect(isValid, isTrue);
    });

    test('verify returns false for modified payload', () {
      final validSignature = UspsWebhookVerifier.computeSignature(
        payload: payload,
        secretKey: secretKey,
      );

      final isValid = UspsWebhookVerifier.verify(
        payload: '{"trackingNumber":"tampered-payload"}',
        signature: validSignature,
        secretKey: secretKey,
      );

      expect(isValid, isFalse);
    });

    test('verify returns false for wrong secretKey', () {
      final validSignature = UspsWebhookVerifier.computeSignature(
        payload: payload,
        secretKey: secretKey,
      );

      final isValid = UspsWebhookVerifier.verify(
        payload: payload,
        signature: validSignature,
        secretKey: 'wrong-secret-key',
      );

      expect(isValid, isFalse);
    });

    test('verify returns false for empty signature or secretKey', () {
      expect(
        UspsWebhookVerifier.verify(
          payload: payload,
          signature: '',
          secretKey: secretKey,
        ),
        isFalse,
      );

      expect(
        UspsWebhookVerifier.verify(
          payload: payload,
          signature: 'abcd',
          secretKey: '',
        ),
        isFalse,
      );
    });

    test('verify returns false for signature of different length', () {
      expect(
        UspsWebhookVerifier.verify(
          payload: payload,
          signature: 'short',
          secretKey: secretKey,
        ),
        isFalse,
      );
    });
  });
}
