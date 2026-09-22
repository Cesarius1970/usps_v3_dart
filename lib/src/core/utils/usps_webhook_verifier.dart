import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Cryptographic utility for verifying HMAC SHA-256 signatures on incoming USPS webhooks.
class UspsWebhookVerifier {
  /// Creates a [UspsWebhookVerifier] instance.
  const UspsWebhookVerifier();

  /// Computes the HMAC-SHA256 signature of a [payload] using the provided [secretKey].
  ///
  /// Returns the lowercase hexadecimal representation of the computed digest.
  static String computeSignature({
    required String payload,
    required String secretKey,
  }) {
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final digest = hmac.convert(utf8.encode(payload));
    return digest.toString();
  }

  /// Verifies whether the incoming [signature] matches the computed HMAC-SHA256 of [payload].
  ///
  /// Performs a constant-time byte comparison to protect against timing attacks.
  /// The [signature] may be formatted as either hexadecimal or base64.
  static bool verify({
    required String payload,
    required String signature,
    required String secretKey,
  }) {
    if (signature.isEmpty || secretKey.isEmpty) {
      return false;
    }

    final computedHex = computeSignature(
      payload: payload,
      secretKey: secretKey,
    );

    final normalizedSignature = signature.trim().toLowerCase();

    // Constant-time comparison between normalizedSignature and computedHex
    final sigBytes = utf8.encode(normalizedSignature);
    final compBytes = utf8.encode(computedHex);

    if (sigBytes.length != compBytes.length) {
      return false;
    }

    var result = 0;
    for (var i = 0; i < sigBytes.length; i++) {
      result |= sigBytes[i] ^ compBytes[i];
    }

    return result == 0;
  }
}
