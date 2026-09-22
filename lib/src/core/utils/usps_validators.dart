/// Client-side input validation helpers for USPS formats and identifiers.
abstract final class UspsValidators {

  static final RegExp _zip5Regex = RegExp(r'^\d{5}$');
  static final RegExp _zipPlus4Regex = RegExp(r'^\d{4}$');
  static final RegExp _trackingNumberRegex = RegExp(r'^[A-Za-z0-9]{10,34}$');

  /// Whether [zip] is a valid 5-digit US postal ZIP code.
  static bool isValidZipCode(String? zip) {
    if (zip == null) return false;
    return _zip5Regex.hasMatch(zip.trim());
  }

  /// Whether [zipPlus4] is a valid 4-digit ZIP+4 extension.
  static bool isValidZipPlus4(String? zipPlus4) {
    if (zipPlus4 == null) return false;
    return _zipPlus4Regex.hasMatch(zipPlus4.trim());
  }

  /// Whether [trackingNumber] is formatted as a valid USPS tracking number (10-34 alphanumeric chars).
  static bool isValidTrackingNumber(String? trackingNumber) {
    if (trackingNumber == null) return false;
    return _trackingNumberRegex.hasMatch(trackingNumber.trim());
  }

  /// Validates a 5-digit [zip] code and throws an [ArgumentError] if invalid.
  static String requireValidZipCode(String zip, [String name = 'zipCode']) {
    final trimmed = zip.trim();
    if (!isValidZipCode(trimmed)) {
      throw ArgumentError.value(
        zip,
        name,
        'Invalid ZIP code: must be exactly 5 numeric digits.',
      );
    }
    return trimmed;
  }

  /// Validates a [trackingNumber] and throws an [ArgumentError] if invalid.
  static String requireValidTrackingNumber(
    String trackingNumber, [
    String name = 'trackingNumber',
  ]) {
    final trimmed = trackingNumber.trim();
    if (!isValidTrackingNumber(trimmed)) {
      throw ArgumentError.value(
        trackingNumber,
        name,
        'Invalid tracking number: must be 10-34 alphanumeric characters without spaces.',
      );
    }
    return trimmed;
  }
}
