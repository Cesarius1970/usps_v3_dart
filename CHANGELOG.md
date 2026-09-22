# Changelog

## 1.2.0

- Added **Carrier Pickup API** (`CarrierPickupRepository`): check pickup eligibility, schedule carrier pickups, retrieve, update, and cancel appointments.
- Added **Service Standards API** (`ServiceStandardsRepository`): calculate delivery standards, benchmarks, and transit estimates between origin and destination ZIP codes.
- Added **SCAN Forms API** (`ScanFormsRepository`): generate consolidated PS Form 5630 barcode manifests for bulk shipments.
- Added **Proof of Delivery (POD)** in `TrackingRepository`: request official proof of delivery letter with digitized signature and delivery photo.
- Added **Webhook Verification Utility** (`UspsWebhookVerifier`): HMAC-SHA256 signature verification with constant-time comparison against timing attacks.
- Expanded facade client `UspsClient` to expose `pickup`, `serviceStandards`, and `scanForms`.
- Added 38 new unit tests (140 total) maintaining 100.00% line coverage across all 35 library files.

## 1.1.0

- Added strongly-typed enums for USPS APIs: `UspsMailClass`, `LabelImageType`, `PriceType`, and `TrackingExpand`.
- Added deterministic connection and resource disposal with `close({bool force = false})` on `UspsClient`, `UspsHttpClient`, and `UspsAuthManager`.
- Added `UspsRetryInterceptor` with exponential backoff for transient HTTP errors (429, 500, 502, 503, 504) and network timeouts.
- Added `UspsLogInterceptor` with automated redaction of sensitive Bearer tokens and client secrets for secure debugging.
- Added `UspsValidators` client-side guard utilities for US 5-digit ZIP codes, ZIP+4 extensions, and tracking numbers.
- Expanded test suite to 102 tests maintaining 100.00% line coverage across all library files.

## 1.0.1

- Updated dependencies to latest stable versions (`dio: ^5.11.1`, `coverage: ^1.15.0`, `build_runner: ^2.16.1`, `test: ^1.32.0`).
- Added `explicitToJson: true` to nested models to guarantee recursive JSON map serialization.
- Enhanced doc comments following Effective Dart documentation guidelines.
- Added comprehensive model serialization test suite and expanded unit tests achieving 100% line coverage.
- Optimized package publication structure with `.pubignore`.

## 1.0.0

- Initial release of `usps_v3_dart`.
- Automated OAuth 2.0 token management, caching, and auto-refresh interceptor (`UspsAuthManager`, `UspsAuthInterceptor`).
- Package Tracking API v3 support with detailed scan event history and batch lookup (`TrackingRepository`).
- Addresses API v3 support for normalization, city/state lookup, and ZIP+4 validation (`AddressesRepository`).
- Locations API v3 support for discovering USPS Post Offices and collection boxes (`LocationsRepository`).
- Pricing API v3 support for domestic rate calculations and fee breakdowns (`PricingRepository`).
- Shipping API v3 support for label generation (PDF, PNG, ZPL) and cancellation (`ShippingRepository`).
- Unified exception hierarchy (`UspsException`, `UspsApiException`, `UspsAuthException`, `UspsNetworkException`).
- `UspsClient` facade for central access.
