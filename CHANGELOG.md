# Changelog

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
