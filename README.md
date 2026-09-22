# USPS v3 Dart SDK (`usps_v3_dart`)

[![Pub Version](https://img.shields.io/pub/v/usps_v3_dart.svg)](https://pub.dev/packages/usps_v3_dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Coverage: 100%](https://img.shields.io/badge/Coverage-100%25-brightgreen.svg)](https://github.com/Cesarius1970/usps_v3_dart)

A strongly-typed, production-ready Dart SDK for the official **USPS REST APIs (v3)** (`developer.usps.com`).

---

## Features

- **Automated OAuth 2.0 Management**: Handles token acquisition, in-memory caching, proactive renewal, and seamless 401 retry via queued HTTP interceptors (`UspsAuthManager`, `UspsAuthInterceptor`).
- **Strongly-Typed Enums**: First-class enums for mail classes (`UspsMailClass`), label image formats (`LabelImageType`), pricing tiers (`PriceType`), and tracking modes (`TrackingExpand`).
- **Resilient Network Client**: Built-in exponential backoff retry for transient network errors and rate limits (`UspsRetryInterceptor`).
- **Secure Logging**: Auditable logging interceptor with automatic redaction of Bearer tokens and API secrets (`UspsLogInterceptor`).
- **Deterministic Resource Cleanup**: Clean disposal of underlying HTTP connection pools with `usps.close()`.
- **Client-Side Format Guards**: Input validation utilities for US 5-digit ZIP codes, ZIP+4 extensions, and tracking numbers (`UspsValidators`).
- **Package Tracking**: Query status and chronological scan events for single or batch tracking numbers (`TrackingRepository`).
- **Address Standardization**: Validate US addresses, fix formats, and append official `ZIP+4` codes (`AddressesRepository`).
- **Post Office & Facility Locator**: Search USPS facilities by ZIP code or geographic coordinates (`LocationsRepository`).
- **Postage Rate Calculator**: Calculate domestic base rates and surcharges by weight, dimensions, and mail class (`PricingRepository`).
- **Shipping Labels**: Generate domestic postage labels with barcodes in PDF, PNG, or ZPL formats (`ShippingRepository`).
- **Unified Error Handling**: Strongly-typed exception hierarchy (`UspsApiException`, `UspsAuthException`, `UspsNetworkException`, `UspsUnknownException`).

---

## Installation

Add `usps_v3_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  usps_v3_dart: ^1.1.0
```

Then run:

```bash
dart pub get
```

---

## Quick Start

```dart
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() async {
  // 1. Initialize client facade with optional retry and safe logging
  final usps = UspsClient(
    clientId: 'YOUR_USPS_CLIENT_ID',
    clientSecret: 'YOUR_USPS_CLIENT_SECRET',
    environment: UspsEnvironment.sandbox, // or UspsEnvironment.production
    enableRetry: true, // Auto-retry transient 429 / 5xx / timeouts
    enableLogging: false, // Set to true to debug requests with redacted tokens
  );

  try {
    // 2. Track a package
    final tracking = await usps.tracking.getTracking(
      '9400111899562537624656',
      expand: TrackingExpand.detail,
    );

    print('Status: ${tracking.status}');
    print('Summary: ${tracking.statusSummary}');
    for (final event in tracking.trackingEvents) {
      print('- [${event.eventTimestamp}] ${event.eventDescription}');
    }
  } on UspsApiException catch (e) {
    print('USPS API Error (${e.statusCode}): ${e.message}');
  } on UspsException catch (e) {
    print('SDK Error: ${e.message}');
  } finally {
    // 3. Always dispose client to release HTTP connection pools
    usps.close();
  }
}
```

---

## Usage Examples

### 1. Address Normalization & ZIP+4 Lookup

```dart
final response = await usps.addresses.standardizeAddress(
  const Address(
    streetAddress: '475 L\'Enfant Plaza SW',
    secondaryAddress: 'Suite 100',
    city: 'Washington',
    state: 'DC',
    zipCode: '20260',
  ),
);

final normalized = response.address;
if (normalized != null) {
  print('Address: ${normalized.streetAddress}, ${normalized.city}, ${normalized.state} ${normalized.zipCode}-${normalized.zipPlus4}');
}
```

### 2. Location Search

```dart
final locations = await usps.locations.findLocations(
  zipCode: '20260',
  maxResults: 5,
);

for (final location in locations.locations) {
  print('${location.locationName}: ${location.streetAddress}, ${location.city}');
}
```

### 3. Rate Calculation with Strongly-Typed Enums

```dart
final quote = await usps.pricing.calculateRates(
  const RateRequest(
    originZipCode: '20260',
    destinationZipCode: '78701',
    weight: 2.5,
    length: 10.0,
    width: 6.0,
    height: 4.0,
    mailClass: UspsMailClass.priorityMail,
    priceType: PriceType.retail,
  ),
);

print('Total Base Price: \$${quote.totalBasePrice}');
for (final rate in quote.rates) {
  print('- ${rate.mailClass} (Zone ${rate.zone}): \$${rate.price}');
}
```

### 4. Shipping Label Creation

```dart
final label = await usps.shipping.createLabel(
  const LabelRequest(
    fromAddress: Address(
      streetAddress: '475 L\'Enfant Plaza SW',
      city: 'Washington',
      state: 'DC',
      zipCode: '20260',
    ),
    toAddress: Address(
      streetAddress: '100 Congress Ave',
      city: 'Austin',
      state: 'TX',
      zipCode: '78701',
    ),
    weight: 1.5,
    mailClass: UspsMailClass.priorityMail,
    imageType: LabelImageType.pdf,
  ),
);

print('Tracking Number: ${label.trackingNumber}');
print('Postage Cost: \$${label.totalPrice}');
```

### 5. Client-Side Input Validation

```dart
if (UspsValidators.isValidZipCode('90210')) {
  print('Valid ZIP code!');
}

final cleanTracking = UspsValidators.requireValidTrackingNumber('9400111899562537624656');
```

---

## Error Handling

The SDK provides a structured exception hierarchy:

| Exception | Description |
| :--- | :--- |
| `UspsApiException` | Returned by USPS REST API endpoints (4xx, 5xx). Includes `statusCode`, `errorCode`, and raw `data`. |
| `UspsAuthException` | Authentication errors during OAuth 2.0 token acquisition or refresh. |
| `UspsNetworkException` | Low-level network connection failures, socket timeouts, or cancelled requests. |
| `UspsUnknownException` | Unexpected serialization or runtime errors. |

---

## License

MIT License. See [LICENSE](LICENSE) for details.
