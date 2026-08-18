# USPS v3 Dart SDK (`usps_v3_dart`)

[![Pub Version](https://img.shields.io/pub/v/usps_v3_dart.svg)](https://pub.dev/packages/usps_v3_dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A strongly-typed, production-ready Dart SDK for the official **USPS REST APIs (v3)** (`developer.usps.com`).

---

## Features

- **Automated OAuth 2.0 Management**: Handles token acquisition, in-memory caching, proactive renewal, and seamless 401 retry via HTTP interceptors.
- **Package Tracking**: Query status and chronological scan events for single or batch tracking numbers (`TrackingRepository`).
- **Address Standardization**: Validate US addresses, fix formats, and append official `ZIP+4` codes (`AddressesRepository`).
- **Post Office & Facility Locator**: Search USPS facilities by ZIP code or geographic coordinates (`LocationsRepository`).
- **Postage Rate Calculator**: Calculate domestic base rates and surcharges by weight, dimensions, and mail class (`PricingRepository`).
- **Shipping Labels**: Generate domestic postage labels with barcodes in PDF, PNG, or ZPL formats (`ShippingRepository`).
- **Unified Error Handling**: Strongly-typed exception hierarchy (`UspsApiException`, `UspsAuthException`, `UspsNetworkException`).

---

## Installation

Add `usps_v3_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  usps_v3_dart: ^1.0.0
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
  // 1. Initialize client facade
  final usps = UspsClient(
    clientId: 'YOUR_USPS_CLIENT_ID',
    clientSecret: 'YOUR_USPS_CLIENT_SECRET',
    environment: UspsEnvironment.sandbox, // or UspsEnvironment.production
  );

  // 2. Track a package
  try {
    final tracking = await usps.tracking.getTracking(
      '9400111899562537624656',
      expand: 'DETAIL',
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

### 3. Rate Calculation

```dart
final quote = await usps.pricing.calculateRates(
  const RateRequest(
    originZipCode: '20260',
    destinationZipCode: '78701',
    weight: 2.5,
    length: 10.0,
    width: 6.0,
    height: 4.0,
    mailClass: 'PRIORITY_MAIL',
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
    mailClass: 'PRIORITY_MAIL',
    imageType: 'PDF',
  ),
);

print('Tracking Number: ${label.trackingNumber}');
print('Postage Cost: \$${label.totalPrice}');
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
