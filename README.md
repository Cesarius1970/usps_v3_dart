# USPS v3 Dart SDK

A modern, strongly-typed Dart SDK for USPS REST APIs (v3).

## Features

- **OAuth 2.0 Authentication**: Automatic token acquisition, in-memory caching, and proactive auto-renewal on 401.
- **Tracking API**: Real-time package tracking and event history.
- **Addresses API**: Address validation, standardization, and ZIP+4 lookup.
- **Locations API**: Find USPS facilities and drop-off points by ZIP code or coordinates.
- **Prices / Rates API**: Calculate domestic postage rates and compare mail classes.
- **Shipping / Labels API**: Generate domestic shipping labels with barcode tracking.

## Getting Started

Add `usps_v3_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  usps_v3_dart: ^1.0.0
```

Obtain your API credentials (`clientId` and `clientSecret`) from the [USPS Developer Portal](https://developer.usps.com).

## Usage

```dart
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() async {
  // Initialize the client
  final usps = UspsClient(
    clientId: 'YOUR_CLIENT_ID',
    clientSecret: 'YOUR_CLIENT_SECRET',
  );

  // Track a package
  try {
    final tracking = await usps.tracking.getTracking('9400111899562537624656');
    print('Status: ${tracking.statusSummary}');
  } on UspsApiException catch (e) {
    print('USPS API Error: ${e.message} (Status: ${e.statusCode})');
  }

  // Standardize an Address
  final addressResponse = await usps.addresses.standardizeAddress(
    const Address(
      streetAddress: '475 L\'Enfant Plaza SW',
      city: 'Washington',
      state: 'DC',
      zipCode: '20260',
    ),
  );
  print('Standardized: ${addressResponse.address?.streetAddress}');

  // Calculate Rates
  final rates = await usps.pricing.calculateRates(
    const RateRequest(
      originZipCode: '20260',
      destinationZipCode: '78701',
      weight: 1.5,
    ),
  );
  print('Base Price: \$${rates.totalBasePrice}');
}
```

## Additional Information

- **API Examples Guide**: Ver [doc/api_examples.md](doc/api_examples.md) para ejemplos detallados de cada interfaz y modelo.
- **Issues & Feedback**: File issues on [GitHub Issues](https://github.com/cesar/usps_v3_dart/issues).
- **License**: MIT License.
